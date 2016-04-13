#pragma once
#include <stdint.h>
#include <errno.h>
#include <stddef.h>

#define OH_GPIO_DIR_IN	(0 << 0)
#define OH_GPIO_DIR_OUT	(1 << 0)

#define OH_GPIO_LOW	0
#define OH_GPIO_HIGH	1

/**
 * oh_gpio_init - GPIO init
 *
 * @param dev		uninitialized device structure
 * @param arg		target argument (depends on target)
 *
 * @return		0 on success. Negative on error
 */
//int oh_gpio_init(oh_gpio_dev_t *dev, void *arg);

/**
 * oh_gpio_set_direction - Set pin direction
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 * @param direction	OH_GPIO_DIR_OUT or OH_GPIO_DIR_IN
 *
 * @return		0 on success. Negative on error
 */
//int oh_gpio_set_direction(oh_gpio_dev_t *dev, unsigned gpio,
//			  unsigned direction);

/**
 * oh_gpio_read - Read pin value
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 *
 * @return		0 on low. 1 on high, negative on error.
 */
//int oh_gpio_read(oh_gpio_dev_t *dev, unsigned gpio);

/**
 * oh_gpio_write - Set pin value
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 * @param value		0 on low, 1 on high
 *
 * @return		0 on success, negative on error.
 */
//int oh_gpio_write(oh_gpio_dev_t *dev, unsigned gpio, int value);

/**
 * oh_gpio_toggle - Toggle pin value
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 *
 * @return		0 on success, negative on error.
 */
//int oh_gpio_toggle(oh_gpio_dev_t *dev, unsigned gpio);

#ifndef __unused
# if defined(__GNUC__) || defined(__clang__)
#  define __unused __attribute__((unused))
# else
#  define __unused
# endif
#endif

#ifndef __packed
# if defined(__GNUC__) || defined(__clang__)
#  define __packed __attribute__((packed))
# else
#  define __packed
# endif
#endif

#ifndef __aligned
# if defined(__GNUC__) || defined(__clang__)
#  define __aligned(X) __attribute__((aligned(X)))
# else
#  define __aligned(X)
# endif
#endif

struct oh_gpio_registers {
	uint64_t dir;
	uint64_t in;
	uint64_t out;
	uint64_t outclr;
	uint64_t outset;
	uint64_t outxor;
	uint64_t imask;
	uint64_t itype;
	uint64_t ipol;
	uint64_t ilat;
	uint64_t ilatclr;
} __packed __aligned(8);

#define OH_GPIO_TARGET_SIMPLE	0
#define OH_GPIO_TARGET_EPIPHANY	1

/* Autodetect target */
#ifndef OH_GPIO_TARGET
# ifdef __epiphany__
#  define OH_GPIO_TARGET OH_GPIO_TARGET_EPIPHANY
# else
#  define OH_GPIO_TARGET OH_GPIO_TARGET_SIMPLE
# endif
#endif


#define _OH_GPIO_INTERNAL
#if OH_GPIO_TARGET == OH_GPIO_TARGET_SIMPLE
# include "oh-gpio-simple.h"
#elif OH_GPIO_TARGET == OH_GPIO_TARGET_EPIPHANY
# include "oh-gpio-epiphany.h"
#else
# error "Invalid OH_GPIO_TARGET"
#endif
#undef _OH_GPIO_INTERNAL
