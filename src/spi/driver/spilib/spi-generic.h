#pragma once
#ifndef _SPI_INTERNAL
# error "Don't include this file directly"
#endif

#include <stdint.h>
#include <string.h>

struct spi_generic_dev {
	volatile uint8_t *regs;
};

__spi_unused
static void _spi_reg_write(struct spi_generic_dev *dev, unsigned reg,
			   uint32_t val)
{
	if (reg & 3)
		dev->regs[reg] = (uint8_t) val;
	else
		*(volatile uint32_t *) &dev->regs[reg] = val;

}

__spi_unused
static uint32_t _spi_reg_read(struct spi_generic_dev *dev, unsigned reg)
{
	if (reg & 3)
		return (uint32_t) dev->regs[reg];
	else
		return *(uint32_t *) &dev->regs[reg];
}

__spi_unused
static void _spi_transfer(struct spi_generic_dev *dev, const void *tx,
			  void *rx, unsigned count)
{
	unsigned n;
	const uint8_t *u8_tx = (const uint8_t *) tx;
	uint8_t *u8_rx = (uint8_t *) rx;
	uint8_t config;

	/* TODO: Flush queues */

	/* TODO: Enable TX */

	/* TODO: Tell master to hold SS? */

	config = _spi_reg_read(dev, SPI_CONFIG);

	while (count) {
		union acme {
			uint32_t u32;
			uint16_t u16[2];
			uint8_t u8[4];
		} __spi_packed;
		union acme rx0, rx1, tx0, tx1;
		volatile union acme *txfifo = (union acme *) &dev->regs[SPI_TX];

		if (tx)
			memcpy(&tx0.u32, u8_tx, count > 4 ? 4 : count);
		if (tx && count > 4)
			memcpy(&tx1.u32, &u8_tx[4], count - 4 > 4 ? 4 : count - 4);

		/* Clear status register */
		_spi_reg_write(dev, SPI_STATUS, 0);
		while (_spi_reg_read(dev, SPI_STATUS))
			;

		/* Enable TX */
		config &= ~SPI_CONFIG_DISABLE;
		_spi_reg_write(dev, SPI_CONFIG, config);

		/* Write TX data to TX fifo */
		switch (count) {
		case 1:
			txfifo->u8[0] = tx0.u8[0];
			count -= 1; n = 1;
			break;
		case 2:
			txfifo->u16[0] = tx0.u16[0];
			count -= 2; n = 2;
			break;
		case 3:
			txfifo->u16[0] = tx0.u16[0];
			txfifo->u8[0] = tx0.u8[3];
			count -= 3; n = 3;
			break;
		case 4:
			txfifo->u32 = tx0.u32;
			count -= 4; n = 4;
			break;
		case 5:
			txfifo->u32 = tx0.u32;
			txfifo->u8[0] = tx1.u8[0];
			count -= 5; n = 5;
			break;
		case 6:
			txfifo->u32 = tx0.u32;
			txfifo->u32 = tx1.u16[0];
			count -= 6; n = 6;
			break;
		case 7:
			txfifo->u32 = tx0.u32;
			txfifo->u32 = tx1.u16[0];
			txfifo->u32 = tx1.u8[3];
			count -= 7; n = 7;
			break;
		default:
			txfifo->u32 = tx0.u32;
			txfifo->u32 = tx1.u32;
			count -= 8; n = 8;
			break;
		};

		/* Wait for transfer to complete */
		while (_spi_reg_read(dev, SPI_STATUS) & SPI_STATUS_ACTIVE)
			;
		while (!(_spi_reg_read(dev, SPI_STATUS) & SPI_STATUS_SPLIT))
			;

		if (rx) {
			uint8_t buf[8] = { 0 };
			unsigned i, j;

			/* Read deserializer */
			rx0.u32 = *(uint32_t *) &dev->regs[SPI_RX0];
			rx1.u32 = *(uint32_t *) &dev->regs[SPI_RX1];

			memcpy(&buf[0], &rx0, 4);
			memcpy(&buf[4], &rx1, 4);

			/* Reverse bytes in transfer */
			for (i = n - 1, j = 0; i > j; i--, j++) {
				uint8_t tmp;
				tmp = buf[i];
				buf[i] = buf[j];
				buf[j] = tmp;
			}

			memcpy(u8_rx, buf, n);
			u8_rx += n;
		}

	}

	_spi_reg_write(dev, SPI_STATUS, 0);

	/* TODO: Tell master to release SS */
}
