#pragma once
#ifndef _OH_GPIO_INTERNAL
# error "Don't include this file directly"
#endif

#include "oh-gpio-generic.h"

typedef struct oh_gpio_generic_dev oh_gpio_dev_t;

__unused
static int oh_gpio_init(oh_gpio_dev_t *dev, void *arg)
{
	if (!arg)
#ifdef OH_GPIO_SIMPLE_DEFAULT_ADDR
		arg = (void *) OH_GPIO_SIMPLE_DEFAULT_ADDR;
#else
		return -EINVAL;
#endif

	dev->regs = (struct oh_gpio_registers *) arg;
	dev->dircache = 0;

	return 0;
}

#define oh_gpio_set_direction _oh_gpio_set_direction
#define oh_gpio_read _oh_gpio_read
#define oh_gpio_write _oh_gpio_write
#define oh_gpio_toggle _oh_gpio_toggle
