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
static void _spi_transfer(struct spi_generic_dev *dev, const void *tx,
			  void *rx, unsigned count)
{
	unsigned i;
	uint8_t dummy_rx = 0;
	const uint8_t *u8_tx = (const uint8_t *) tx;
	uint8_t *u8_rx = (uint8_t *) rx;

	/* TODO: Flush queues */

	/* TODO: Enable TX */

	/* TODO: Tell master to hold SS */

	while (count) {
		/* TODO: Check RX FIFO full instead */
		for (i = 0;
		     ! (_spi_reg_read(dev, SPI_STATUS) & SPI_STATUS_TX_FIFO_HALF_FULL);
		     i++, count--) {
			if (tx)
				dev->regs[SPI_TX] = *u8_tx++;
			else
				dev->regs[SPI_TX] = 0;
		}
		while (i--) {
			if (rx)
				*u8_rx++ = dev->regs[SPI_RX];
			else
				dummy_rx = dev->regs[SPI_RX];
		}
	}

	(void) dummy_rx;

	/* TODO: Tell master to release SS */

	/* TODO: Disable TX */
}
