#pragma once
#include <stdint.h>
#include <errno.h>
#include <stddef.h>

/*** API */

#define GPIO_DIR_IN	(0 << 0)
#define GPIO_DIR_OUT	(1 << 0)

#define GPIO_LOW	0
#define GPIO_HIGH	1

/**
 * gpio_init - GPIO init
 *
 * @param dev		uninitialized device structure
 * @param arg		target argument (depends on target)
 *
 * @return		0 on success. Negative on error
 */
//int gpio_init(gpio_dev_t *dev, void *arg);

/**
 * gpio_set_direction - Set pin direction
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 * @param direction	GPIO_DIR_OUT or GPIO_DIR_IN
 *
 * @return		0 on success. Negative on error
 */
//int gpio_set_direction(gpio_dev_t *dev, unsigned gpio, unsigned direction);

/**
 * gpio_read - Read pin value
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 *
 * @return		0 on low. 1 on high, negative on error.
 */
//int gpio_read(gpio_dev_t *dev, unsigned gpio);

/**
 * gpio_write - Set pin value
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 * @param value		0 on low, 1 on high
 *
 * @return		0 on success, negative on error.
 */
//int gpio_write(gpio_dev_t *dev, unsigned gpio, int value);

/**
 * gpio_toggle - Toggle pin value
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 *
 * @return		0 on success, negative on error.
 */
//int gpio_toggle(gpio_dev_t *dev, unsigned gpio);


/*** Raw register access API */

#define GPIO_REG_DIR		(0x0 << 3)
#define GPIO_REG_IN		(0x1 << 3)
#define GPIO_REG_OUT		(0x2 << 3)
#define GPIO_REG_OUTCLR		(0x3 << 3)
#define GPIO_REG_OUTSET		(0x4 << 3)
#define GPIO_REG_OUTXORA	(0x5 << 3)
#define GPIO_REG_IMASK		(0x6 << 3)
#define GPIO_REG_ITYPE		(0x7 << 3)
#define GPIO_REG_IPOL		(0x8 << 3)
#define GPIO_REG_ILAT		(0x9 << 3)
#define GPIO_REG_ILATCLR	(0xA << 3)

/**
 * gpio_reg_read - Read a GPIO register
 *
 * @param dev		device structure
 * @param reg		gpio register
 *
 * @return		Register value, no error checking.
 */
//uint64_t gpio_reg_read(gpio_dev_t *dev, unsigned reg);

/**
 * gpio_reg_write - write to a GPIO register
 *
 * @param dev		device structure
 * @param reg		gpio register
 *
 */
//void gpio_reg_write(gpio_dev_t *dev, unsigned reg, uint64_t value);


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

struct gpio_registers {
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

#define GPIO_TARGET_SIMPLE	0
#define GPIO_TARGET_EPIPHANY	1

/* Autodetect target */
#ifndef GPIO_TARGET
# ifdef __epiphany__
#  define GPIO_TARGET GPIO_TARGET_EPIPHANY
# else
#  define GPIO_TARGET GPIO_TARGET_SIMPLE
# endif
#endif


#define _GPIO_INTERNAL
#if GPIO_TARGET == GPIO_TARGET_SIMPLE
# include "gpio-simple.h"
#elif GPIO_TARGET == GPIO_TARGET_EPIPHANY
# include "gpio-epiphany.h"
#else
# error "Invalid GPIO_TARGET"
#endif
#undef _GPIO_INTERNAL
