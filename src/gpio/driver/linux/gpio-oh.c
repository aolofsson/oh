/*
 * Open Hardware GPIO device driver
 *
 * Copyright (C) 2016 Parallella Foundation
 * Written by Ola Jeppsson <ola@adapteva.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * The full GNU General Public License is included in this distribution in the
 * file called COPYING.
 */

#include <linux/bitops.h>
#include <linux/gpio/driver.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/spinlock.h>

#define DRIVERNAME "oh-gpio"

#define	OH_GPIO_MAX_NR_GPIOS 64

#define OH_GPIO_DIR     0x00 /* set direction of pin */
#define OH_GPIO_IN      0x08 /* input data (read only) */
#define OH_GPIO_OUT     0x10 /* output data (write only) */
#define OH_GPIO_OUTCLR  0x18 /* alias, clears specific bits in GPIO_OUT */
#define OH_GPIO_OUTSET  0x20 /* alias, sets specific bits in GPIO_OUT */
#define OH_GPIO_OUTXOR  0x28 /* alias, toggles specific bits in GPIO_OUT */
#define OH_GPIO_IMASK   0x30 /* interrupt mask */
#define OH_GPIO_ITYPE   0x38 /* interrupt type (edge=0/level=1) */
#define OH_GPIO_IPOL    0x40 /* interrupt polarity (hi/rising / low/falling) */
#define OH_GPIO_ILAT    0x48 /* latched interrupts (read only) */
#define OH_GPIO_ILATCLR 0x50 /* clear an interrupt */

struct oh_gpio {
	void __iomem *base_addr;
	struct gpio_chip chip;
	spinlock_t lock;
};

static struct oh_gpio *to_oh_gpio(struct gpio_chip *gpio)
{
	return container_of(gpio, struct oh_gpio, chip);
}

#ifdef writeq
#define oh_gpio_writeq writeq
#else
static inline void oh_gpio_writeq(u64 value, void __iomem *addr)
{
	writel((u32) (value & 0xffffffff), addr);
	writel((u32) (value >> 32), (u8 __iomem *) addr + 4);
}
#endif
#ifdef readq
#define oh_gpio_readq readq
#else
static inline u64 oh_gpio_readq(void __iomem *addr)
{
	u64 lo, hi;

	lo = readl(addr);
	hi = readl((u8 __iomem *) addr + 4);

	return (hi << 32 | lo);
}
#endif

static inline void oh_gpio_reg_write(u64 value, struct oh_gpio *gpio,
				     unsigned long offset)
{
	if (gpio->chip.ngpio > 32)
		oh_gpio_writeq(value, (u8 __iomem *) gpio->base_addr + offset);
	else
		writel((u32) value, (u8 __iomem *) gpio->base_addr + offset);
}

static inline u64 oh_gpio_reg_read(struct oh_gpio *gpio, unsigned long offset)
{
	if (gpio->chip.ngpio > 32)
		return oh_gpio_readq((u8 __iomem *) gpio->base_addr + offset);
	else
		return (u64) readl((u8 __iomem *) gpio->base_addr + offset);
}

/**
 * oh_gpio_get_value_locked - Get value of the specified pin
 * @chip:	gpio chip device
 * @pin:	gpio pin number
 *
 * Note: Caller must hold gpio->lock.
 *
 * Return: 0 if the pin is low, 1 if pin is high.
 */
static int oh_gpio_get_value_locked(struct gpio_chip *chip, unsigned pin)
{
	u64 data;
	struct oh_gpio *gpio = to_oh_gpio(chip);

	data = oh_gpio_reg_read(gpio, OH_GPIO_IN);

	return (data >> pin) & 1;
}

/**
 * oh_gpio_get_value - Get value of the specified pin
 * @chip:	gpio chip device
 * @pin:	gpio pin number
 *
 * Return: 0 if the pin is low, 1 if pin is high.
 */
static int oh_gpio_get_value(struct gpio_chip *chip, unsigned pin)
{
	int ret;
	unsigned long flags;
	struct oh_gpio *gpio = to_oh_gpio(chip);

	spin_lock_irqsave(&gpio->lock, flags);
	ret = oh_gpio_get_value_locked(chip, pin);
	spin_unlock_irqrestore(&gpio->lock, flags);

	return ret;
}

/**
 * oh_gpio_set_value - Assign output value for pin
 * @chip:	gpio chip device
 * @pin:	gpio pin number
 * @value:	value used to modify the state of the specified pin
 */
static void oh_gpio_set_value(struct gpio_chip *chip, unsigned pin, int value)
{
	u64 mask;
	unsigned long flags;
	struct oh_gpio *gpio = to_oh_gpio(chip);

	mask = BIT_ULL(pin);

	spin_lock_irqsave(&gpio->lock, flags);
	if (value)
		oh_gpio_reg_write(mask, gpio, OH_GPIO_OUTSET);
	else
		oh_gpio_reg_write(mask, gpio, OH_GPIO_OUTCLR);
	spin_unlock_irqrestore(&gpio->lock, flags);
}

/**
 * oh_gpio_get_direction - Get direction of pin
 * @chip:	gpio chip device
 * @pin:	gpio pin number
 *
 * Return: direction of pin, 0=out, 1=in
 */
static int oh_gpio_get_direction(struct gpio_chip *chip, unsigned pin)
{
	u64 dir;
	unsigned long flags;
	struct oh_gpio *gpio = to_oh_gpio(chip);

	spin_lock_irqsave(&gpio->lock, flags);
	dir = oh_gpio_reg_read(gpio, OH_GPIO_DIR);
	spin_unlock_irqrestore(&gpio->lock, flags);

	return !((dir >> pin) & 1);
}

/**
 * oh_gpio_direction_in - Set the direction of the specified GPIO pin as input
 * @chip:	gpio chip device
 * @pin:	gpio pin number
 *
 * Return: 0 always
 */
static int oh_gpio_direction_in(struct gpio_chip *chip, unsigned pin)
{
	u64 mask, dir;
	unsigned long flags;
	struct oh_gpio *gpio = to_oh_gpio(chip);

	mask = BIT_ULL(pin);

	spin_lock_irqsave(&gpio->lock, flags);
	dir = oh_gpio_reg_read(gpio, OH_GPIO_DIR);
	dir &= ~mask;
	oh_gpio_reg_write(dir, gpio, OH_GPIO_DIR);
	spin_unlock_irqrestore(&gpio->lock, flags);

	return 0;
}

/**
 * oh_gpio_direction_out - Set the direction of the specified GPIO pin as output
 * @chip:	gpio chip device
 * @pin:	gpio pin number
 * @value:	value to be written to pin
 *
 * This function sets the direction of specified GPIO pin as output, and uses
 * oh_gpio_set to set the specified pin value.
 *
 * Return: 0 always
 */
static int oh_gpio_direction_out(struct gpio_chip *chip, unsigned pin,
				 int value)
{
	u64 mask, dir;
	unsigned long flags;
	struct oh_gpio *gpio = to_oh_gpio(chip);

	mask = BIT_ULL(pin);

	spin_lock_irqsave(&gpio->lock, flags);
	dir = oh_gpio_reg_read(gpio, OH_GPIO_DIR);
	dir |= mask;
	oh_gpio_reg_write(dir, gpio, OH_GPIO_DIR);
	spin_unlock_irqrestore(&gpio->lock, flags);

	oh_gpio_set_value(chip, pin, value);

	return 0;
}

/**
 * oh_gpio_irq_mask - Disable interrupts for a gpio pin
 * @irq_data:	per irq and chip data passed down to chip functions
 *
 */
static void oh_gpio_irq_mask(struct irq_data *irq_data)
{
	u64 imask;
	unsigned long flags;
	unsigned pin;
	struct oh_gpio *gpio = to_oh_gpio(irq_data_get_irq_chip_data(irq_data));

	pin = irq_data->hwirq;

	spin_lock_irqsave(&gpio->lock, flags);
	imask = oh_gpio_reg_read(gpio, OH_GPIO_IMASK);
	imask |= BIT_ULL(pin);
	oh_gpio_reg_write(imask, gpio, OH_GPIO_IMASK);
	spin_unlock_irqrestore(&gpio->lock, flags);
}

/**
 * oh_gpio_irq_unmask - Enable interrupts for a gpio pin
 * @irq_data:	irq data containing irq number of gpio pin for the interrupt
 *		to enable
 */
static void oh_gpio_irq_unmask(struct irq_data *irq_data)
{
	u64 imask;
	unsigned long flags;
	unsigned pin;
	struct oh_gpio *gpio = to_oh_gpio(irq_data_get_irq_chip_data(irq_data));

	pin = irq_data->hwirq;

	spin_lock_irqsave(&gpio->lock, flags);
	imask = oh_gpio_reg_read(gpio, OH_GPIO_IMASK);
	imask &= ~BIT_ULL(pin);
	oh_gpio_reg_write(imask, gpio, OH_GPIO_IMASK);
	spin_unlock_irqrestore(&gpio->lock, flags);
}

/**
 * oh_gpio_irq_ack - Clear interrupt latch of a gpio pin
 * @irq_data:	irq data containing irq number of gpio pin for the interrupt
 *		to clear
 */
static void oh_gpio_irq_ack(struct irq_data *irq_data)
{
	unsigned long flags;
	unsigned pin;
	struct oh_gpio *gpio = to_oh_gpio(irq_data_get_irq_chip_data(irq_data));

	pin = irq_data->hwirq;

	spin_lock_irqsave(&gpio->lock, flags);
	oh_gpio_reg_write(BIT_ULL(pin), gpio, OH_GPIO_ILATCLR);
	spin_unlock_irqrestore(&gpio->lock, flags);
}

/**
 * oh_gpio_irq_next_edge_locked - Configure IPOL for next edge
 * @gpio:	oh gpio structure
 * @pin:	gpio pin number
 *
 * Note: Caller must hold gpio->lock.
 */
static void oh_gpio_irq_next_edge_locked(struct oh_gpio *gpio, unsigned pin)
{
	u64 ipol, mask;

	mask = BIT_ULL(pin);

	ipol = oh_gpio_reg_read(gpio, OH_GPIO_IPOL);

	if (oh_gpio_get_value_locked(&gpio->chip, pin))
		ipol &= ~mask;
	else
		ipol |= mask;

	oh_gpio_reg_write(ipol, gpio, OH_GPIO_IPOL);
}

/**
 * oh_gpio_irq_set_type - Set the irq type for a gpio pin
 * @irq_data:	irq data containing irq number of gpio pin
 * @type:	interrupt type that is to be set for the gpio pin
 *
 * Return: 0 on success, negative on error.
 */
static int oh_gpio_irq_set_type(struct irq_data *irq_data, unsigned type)
{
	u64 itype, ipol, mask;
	unsigned pin;
	unsigned long flags;
	irq_flow_handler_t handler;
	struct oh_gpio *gpio = to_oh_gpio(irq_data_get_irq_chip_data(irq_data));

	pin = irq_data->hwirq;
	mask = BIT_ULL(pin);

	spin_lock_irqsave(&gpio->lock, flags);

	itype = oh_gpio_reg_read(gpio, OH_GPIO_ITYPE);
	ipol = oh_gpio_reg_read(gpio, OH_GPIO_IPOL);

	switch (type) {
	case IRQ_TYPE_EDGE_BOTH:
		/* fall through, handle below */
	case IRQ_TYPE_EDGE_RISING:
		itype	&= ~mask;
		ipol	|= mask;
		break;
	case IRQ_TYPE_EDGE_FALLING:
		itype	&= ~mask;
		ipol	&= ~mask;
		break;
	case IRQ_TYPE_LEVEL_HIGH:
		itype	|= mask;
		ipol	|= mask;
		break;
	case IRQ_TYPE_LEVEL_LOW:
		itype	|= mask;
		ipol	&= ~mask;
		break;
	default:
		spin_unlock_irqrestore(&gpio->lock, flags);
		return -EINVAL;
	}

	oh_gpio_reg_write(itype, gpio, OH_GPIO_ITYPE);

	if (type == IRQ_TYPE_EDGE_BOTH)
		oh_gpio_irq_next_edge_locked(gpio, pin);
	else
		oh_gpio_reg_write(ipol, gpio, OH_GPIO_IPOL);

	spin_unlock_irqrestore(&gpio->lock, flags);

	handler = type & IRQ_TYPE_LEVEL_MASK ? handle_level_irq
					     : handle_edge_irq;
	irq_set_handler_locked(irq_data, handler);

	return 0;
}

static struct irq_chip oh_gpio_irqchip = {
	.name		= DRIVERNAME,
	.irq_ack	= oh_gpio_irq_ack,
	.irq_mask	= oh_gpio_irq_mask,
	.irq_unmask	= oh_gpio_irq_unmask,
	.irq_set_type	= oh_gpio_irq_set_type,
};

/**
 * oh_gpio_irq_handler_for_each - IRQ handler helper
 * @gpio:	oh gpio structure
 * @ilat:	portion of ilat register
 * @base:	base pin number
 *
 * Calls the generic irq handlers for gpio pins with pending interrupts.
 */
static void oh_gpio_irq_handler_for_each(struct oh_gpio *gpio,
					 unsigned long *ilat, int base)
{
	int offset;
	unsigned long flags;
	unsigned child_irq_no;
	struct irq_desc *child_desc;
	u32 child_type;
	struct irq_domain *irqdomain = gpio->chip.irqdomain;

	for_each_set_bit(offset, ilat, 32) {
		child_irq_no = irq_find_mapping(irqdomain, base + offset);
		child_desc = irq_to_desc(child_irq_no);
		child_type = irqd_get_trigger_type(&child_desc->irq_data);

		/* Toggle edge for pin with both edges triggering enabled */
		if (child_type == IRQ_TYPE_EDGE_BOTH) {
			spin_lock_irqsave(&gpio->lock, flags);
			oh_gpio_irq_next_edge_locked(gpio, base + offset);
			spin_unlock_irqrestore(&gpio->lock, flags);
		}

		generic_handle_irq_desc(child_desc);
	}
}

/**
 * oh_gpio_irq_handler - IRQ handler
 * @irq:	oh_gpio irq number
 * @devid:	pointer to oh_gpio struct
 *
 * Reads the interrupt latch register register to get the gpio pin number(s)
 * that have pending interrupts. It then calls the generic irq handlers for
 * those pins irqs.
 *
 * Return: IRQ_HANDLED if any interrupts were handled, IRQ_NONE otherwise.
 */
static irqreturn_t oh_gpio_irq_handler(int irq, void *dev_id)
{
	u64 ilat;
	unsigned long flags, ilat_lo, ilat_hi;
	struct oh_gpio *gpio = dev_id;

	spin_lock_irqsave(&gpio->lock, flags);
	ilat = oh_gpio_reg_read(gpio, OH_GPIO_ILAT);
	spin_unlock_irqrestore(&gpio->lock, flags);

	if (!ilat)
		return IRQ_NONE;

	/* No generic 64-bit for_each_set_bit. Need to split in high/low */
	ilat_lo = (unsigned long) ((ilat >>  0) & 0xffffffff);
	ilat_hi = (unsigned long) ((ilat >> 32) & 0xffffffff);

	oh_gpio_irq_handler_for_each(gpio, &ilat_lo, 0);
	oh_gpio_irq_handler_for_each(gpio, &ilat_hi, 32);

	return IRQ_HANDLED;
}

static const struct of_device_id oh_gpio_of_match[] = {
	{ .compatible = "oh,gpio" },
	{ }
};
MODULE_DEVICE_TABLE(of, oh_gpio_of_match);

/**
 * oh_gpio_probe - Platform probe for a oh_gpio device
 * @pdev:	platform device
 *
 * Note: All interrupts are cleared + masked after function exits.
 *
 * Return: 0 on success, negative error otherwise.
 */
static int oh_gpio_probe(struct platform_device *pdev)
{
	int ret, irq;
	u32 ngpios;
	struct oh_gpio *gpio;
	struct gpio_chip *chip;
	struct resource *res;
	struct device_node *np = pdev->dev.of_node;

	gpio = devm_kzalloc(&pdev->dev, sizeof(*gpio), GFP_KERNEL);
	if (!gpio)
		return -ENOMEM;

	platform_set_drvdata(pdev, gpio);

	ret = of_property_read_u32(np, "ngpios", &ngpios);
	if (ret == -ENOENT) {
		dev_info(&pdev->dev,
			 "ngpios property missing, defaulting to %u\n",
			 OH_GPIO_MAX_NR_GPIOS);
		ngpios = OH_GPIO_MAX_NR_GPIOS;
	} else if (ret) {
		dev_err(&pdev->dev, "ngpios property is not valid\n");
		return ret;
	}

	if (ngpios > OH_GPIO_MAX_NR_GPIOS) {
		dev_err(&pdev->dev,
			"ngpios property is %u, max allowed is %u\n",
			(unsigned) ngpios, OH_GPIO_MAX_NR_GPIOS);
		return -EINVAL;
	}

	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	gpio->base_addr = devm_ioremap_resource(&pdev->dev, res);
	if (IS_ERR(gpio->base_addr))
		return PTR_ERR(gpio->base_addr);

	irq = platform_get_irq(pdev, 0);
	if (irq < 0) {
		dev_err(&pdev->dev, "invalid IRQ\n");
		return irq;
	}

	ret = devm_request_irq(&pdev->dev, irq, oh_gpio_irq_handler, 0,
			       dev_name(&pdev->dev), gpio);
	if (ret) {
		dev_err(&pdev->dev, "could not request IRQ\n");
		return ret;
	}

	spin_lock_init(&gpio->lock);

	/* configure the gpio chip */
	chip = &gpio->chip;
	chip->label = "oh_gpio";
	chip->owner = THIS_MODULE;
	chip->dev = &pdev->dev;
	chip->base = -1;
	chip->ngpio = (u16) ngpios;
	chip->get = oh_gpio_get_value;
	chip->set = oh_gpio_set_value;
	chip->get_direction = oh_gpio_get_direction;
	chip->direction_input = oh_gpio_direction_in;
	chip->direction_output = oh_gpio_direction_out;

	/* mask / clear all interrupts */
	oh_gpio_reg_write(~0ULL, gpio, OH_GPIO_IMASK);
	oh_gpio_reg_write(~0ULL, gpio, OH_GPIO_ILATCLR);

	/* register gpio chip */
	ret = gpiochip_add(chip);
	if (ret) {
		dev_err(&pdev->dev, "failed to add gpio chip\n");
		return ret;
	}

	ret = gpiochip_irqchip_add(chip, &oh_gpio_irqchip, 0,
				   handle_level_irq, IRQ_TYPE_NONE);
	if (ret) {
		dev_err(&pdev->dev, "failed to add irq chip\n");
		gpiochip_remove(chip);
		return ret;
	}

	return 0;
}

/**
 * oh_gpio_remove - Driver removal function
 * @pdev:	platform device
 *
 * Return: 0 always
 */
static int oh_gpio_remove(struct platform_device *pdev)
{
	struct oh_gpio *gpio = platform_get_drvdata(pdev);

	gpiochip_remove(&gpio->chip);

	return 0;
}

static struct platform_driver oh_gpio_driver = {
	.driver	= {
		.name = DRIVERNAME,
		.of_match_table = oh_gpio_of_match,
	},
	.probe = oh_gpio_probe,
	.remove = oh_gpio_remove,
};
module_platform_driver(oh_gpio_driver);

MODULE_AUTHOR("Ola Jeppsson <ola@adapteva.com>");
MODULE_DESCRIPTION("OH GPIO driver");
MODULE_VERSION("0.1");
MODULE_LICENSE("GPL");
