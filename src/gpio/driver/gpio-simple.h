#pragma once
#ifndef _GPIO_INTERNAL
# error "Don't include this file directly"
#endif

#include "gpio-generic.h"

typedef struct gpio_generic_dev gpio_dev_t;

__unused
static int gpio_init(gpio_dev_t *dev, void *arg)
{
	if (!arg)
#ifdef GPIO_SIMPLE_DEFAULT_ADDR
		arg = (void *) GPIO_SIMPLE_DEFAULT_ADDR;
#else
		return -EINVAL;
#endif

	dev->regs = (struct gpio_registers *) arg;

	return 0;
}

#define gpio_set_direction _gpio_set_direction
#define gpio_read _gpio_read
#define gpio_write _gpio_write
#define gpio_toggle _gpio_toggle
#define gpio_reg_read _gpio_reg_read
#define gpio_reg_write _gpio_reg_write
