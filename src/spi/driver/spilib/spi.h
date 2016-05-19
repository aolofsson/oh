#pragma once
#include <stdint.h>
#include <errno.h>
#include <stddef.h>

/*** API */

/**
 * spi_init - SPI init
 *
 * @param dev		uninitialized device structure
 * @param arg		target argument (depends on target)
 *
 * @return		0 on success. Negative on error
 */
//int spi_init(spi_dev_t *dev, void *arg);

/**
 * spi_init - SPI finalize
 *
 * @param dev		uninitialized device structure
 */
//void spi_init(spi_dev_t *dev);


/**
 * spi_set_config - Set configuration for SPI device
 *
 * @param dev		device structure
 * @param config	spi configuration
 *
 */
//void spi_set_config(spi_dev_t *dev, uint8_t config);
#define spi_set_config(dev, config) spi_reg_write((dev), SPI_CONFIG, (config))

/**
 * spi_get_config - Get configuration for SPI device
 *
 * @param dev		device structure
 *
 * @return		spi config register
 */
//uint8_t spi_get_config(spi_dev_t *dev);
#define spi_get_config(dev) spi_reg_read((dev), SPI_CONFIG)

/**
 * spi_get_status - Get status for SPI device
 *
 * @param dev		device structure
 *
 */
//uint8_t spi_get_status(spi_dev_t *dev);
#define spi_get_status(dev) spi_reg_read((dev), SPI_STATUS)

/**
 * spi_set_clkdiv - Set master clock divider
 *
 * @param dev		device structure
 * @param config	spi configuration
 *
 */
//void spi_set_clkdiv(spi_dev_t *dev, uint8_t clkdiv);
#define spi_set_clkdiv(dev, clkdiv) spi_reg_write((dev), SPI_CLKDIV, (clkdiv))

/**
 * spi_get_clkdiv - Get master clock divider
 *
 * @param dev		device structure
 *
 * @return		clock divider register
 *
 */
//uint8_t spi_get_clkdiv(spi_dev_t *dev);
#define spi_get_clkdiv(dev) spi_reg_read((dev), SPI_CLKDIV)

/**
 * spi_transter - Perform one SPI transfer
 *
 * @param dev		device structure
 * @param tx		transmit data buffer
 * @param rx		receive data buffer
 * @param count		number of bytes
 *
 */
//void spi_transfer(spi_dev_t *dev, uint8_t *tx, uint8_t *rx, unsigned count);

/*** Raw register access API */

#define SPI_CONFIG	0x00
#define SPI_STATUS	0x01
#define SPI_CLKDIV	0x02
#define SPI_TX		0x08 /* master only */
#define SPI_RX0		0x10
#define SPI_RX1		0x14
#define SPI_USER0	0x20 /* slave only, first user register */

#define SPI_CONFIG_DISABLE		(1 << 0)
#define SPI_CONFIG_IRQ_ENABLE		(1 << 1)
#define SPI_CONFIG_CPOL			(1 << 2)
#define SPI_CONFIG_CPHA			(1 << 3)
#define SPI_CONFIG_LSB			(1 << 4)
#define SPI_CONFIG_USER_REGS		(1 << 5)/* slave only */

#define SPI_STATUS_SPLIT		(1 << 0)
#define SPI_STATUS_STATE		(3 << 1) /* master only */
#define SPI_STATUS_TX_FIFO_HALF_FULL	(1 << 3) /* master only */

#define SPI_STATE_IDLE(status)		(((status) & SPI_STATUS_STATE) >> 1 == 0)
#define SPI_STATE_SETUP(status)		(((status) & SPI_STATUS_STATE) >> 1 == 1)
#define SPI_STATE_DATA(status)		(((status) & SPI_STATUS_STATE) >> 1 == 2)
#define SPI_STATE_HOLD(status)		(((status) & SPI_STATUS_STATE) >> 1 == 3)
/**
 * spi_reg_write - Set SPI device register
 *
 * @param dev		device structure
 * @param reg		register
 * @param val		value
 *
 */
//void spi_reg_write(spi_dev_t *dev, unsigned reg, uint8_t val);

/**
 * spi_reg_read - Get SPI device register
 *
 * @param dev		device structure
 * @param reg		register
 *
 * @return		register value
 */
//uint8_t spi_reg_write(spi_dev_t *dev, unsigned reg);

#ifndef ___unused
# if defined(__GNUC__) || defined(__clang__)
#  define ___unused __attribute__((unused))
# else
#  define ___unused
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

/* Targets */
#define SPI_TARGET_SIMPLE	0
#define SPI_TARGET_EPIPHANY	1
#define SPI_TARGET_UIO		2

/* Autodetect target */
#ifndef SPI_TARGET
# if defined(__epiphany__)
#  define SPI_TARGET SPI_TARGET_EPIPHANY
# elif defined(__linux__)
#  define SPI_TARGET SPI_TARGET_UIO
#else
#  define SPI_TARGET SPI_TARGET_SIMPLE
# endif
#endif


#define _SPI_INTERNAL
#if SPI_TARGET == SPI_TARGET_SIMPLE
# include "spi-simple.h"
#elif SPI_TARGET == SPI_TARGET_EPIPHANY
# include "spi-epiphany.h"
#elif SPI_TARGET == SPI_TARGET_UIO
# include "spi-uio.h"
#else
# error "Invalid SPI_TARGET"
#endif
#undef _SPI_INTERNAL
