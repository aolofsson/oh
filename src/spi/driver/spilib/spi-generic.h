#pragma once
#ifndef _SPI_INTERNAL
# error "Don't include this file directly"
#endif

#include <stdint.h>

struct spi_generic_dev {
	volatile uint8_t *regs;
};

___unused
static void _spi_reg_write(struct spi_generic_dev *dev, unsigned reg,
			   uint8_t val)
{
	dev->regs[reg] = val;
}

___unused
static uint8_t _spi_reg_read(struct spi_generic_dev *dev, unsigned reg)
{
	return dev->regs[reg];
}

___unused
static void _spi_read(struct spi_generic_dev *dev, uint8_t *dest,
		      unsigned count)
{
	while (count--)
		*dest++ = dev->regs[SPI_RX];
}

___unused
static void _spi_write(struct spi_generic_dev *dev, const uint8_t *src,
		       unsigned count)
{
	while (count--) {
		/* ??? Do we need this (and why isn't there a FULL flag)? */
		while (_spi_reg_read(dev, SPI_STATUS) & SPI_STATUS_TX_FIFO_HALF_FULL)
			;

		dev->regs[SPI_TX] = *src++;
	}
}
