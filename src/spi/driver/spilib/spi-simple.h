#pragma once
#ifndef _SPI_INTERNAL
# error "Don't include this file directly"
#endif

#include "spi-generic.h"

typedef struct spi_generic_dev spi_dev_t;

__spi_unused
static int spi_init(spi_dev_t *dev, void *arg)
{
	if (!arg)
#ifdef SPI_SIMPLE_DEFAULT_ADDR
		arg = (void *) SPI_SIMPLE_DEFAULT_ADDR;
#else
		return -EINVAL;
#endif

	dev->regs = (struct spi_registers *) arg;

	return 0;
}

#define spi_fini(dev) /* nop */
#define spi_reg_write _spi_reg_write
#define spi_reg_read _spi_reg_read
#define spi_write _spi_write
#define spi_read _spi_read
