#pragma once
#ifndef _GPIO_INTERNAL
# error "Don't include this file directly"
#endif

struct gpio_generic_dev {
	volatile struct gpio_registers *regs;
};

__unused
static int _gpio_set_direction(struct gpio_generic_dev *dev, unsigned gpio,
			       unsigned direction)
{
	if (63 < gpio)
		return -EINVAL;

	if (direction == GPIO_DIR_OUT)
		dev->regs->dir |= 1ULL << gpio;
	else if (direction == GPIO_DIR_IN)
		dev->regs->dir &= ~(1ULL << gpio);
	else
		return -EINVAL;

	return 0;
}

__unused
static int _gpio_read(struct gpio_generic_dev *dev, unsigned gpio)
{
	if (63 < gpio)
		return -EINVAL;

	return (dev->regs->in >> gpio) & 1;
}

__unused
static int _gpio_write(struct gpio_generic_dev *dev, unsigned gpio,
			  int value)
{
	if (63 < gpio)
		return -EINVAL;

	if (value < 0)
		return -EINVAL;

	if (value)
		dev->regs->outset = (1ULL << gpio);
	else
		dev->regs->outclr = (1ULL << gpio);

	return 0;
}

__unused
static int _gpio_toggle(struct gpio_generic_dev *dev, unsigned gpio)
{
	if (63 < gpio)
		return -EINVAL;

	dev->regs->outxor = (1ULL << gpio);

	return 0;
}

__unused
static uint64_t _gpio_reg_read(struct gpio_generic_dev *dev, unsigned reg)
{
	uint64_t *regs = (uint64_t *) dev->regs;
	return regs[reg];
}

__unused
static void _gpio_reg_write(struct gpio_generic_dev *dev, unsigned reg,
			    uint64_t value)
{
	uint64_t *regs = (uint64_t *) dev->regs;
	regs[reg] = value;
}
