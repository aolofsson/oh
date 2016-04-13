#pragma once
#ifndef _OH_GPIO_INTERNAL
# error "Don't include this file directly"
#endif

struct oh_gpio_generic_dev {
	volatile struct oh_gpio_registers *regs;
	uint64_t dircache;
};

__unused
static int _oh_gpio_set_direction(struct oh_gpio_generic_dev *dev,
				  unsigned gpio, unsigned direction)
{
	if (63 < gpio)
		return -EINVAL;

	if (direction == OH_GPIO_DIR_OUT)
		dev->dircache |= (1ULL << gpio);
	else if (direction == OH_GPIO_DIR_IN)
		dev->dircache &= ~(1ULL << gpio);
	else
		return -EINVAL;

	dev->regs->dir = dev->dircache;

	return 0;
}

__unused
static int _oh_gpio_read(struct oh_gpio_generic_dev *dev, unsigned gpio)
{
	if (63 < gpio)
		return -EINVAL;

	return (dev->regs->in >> gpio) & 1;
}

__unused
static int _oh_gpio_write(struct oh_gpio_generic_dev *dev, unsigned gpio,
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
static int _oh_gpio_toggle(struct oh_gpio_generic_dev *dev, unsigned gpio)
{
	if (63 < gpio)
		return -EINVAL;

	dev->regs->outxor = (1ULL << gpio);

	return 0;
}
