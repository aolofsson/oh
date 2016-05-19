#pragma once
#ifndef _SPI_INTERNAL
# error "Don't include this file directly"
#endif

#include <stdint.h>

struct spi_generic_dev {
	volatile uint32_t *regs;
};

___unused
static void _spi_reg_write(struct spi_generic_dev *dev, unsigned reg,
			   uint8_t val)
{
	dev->regs[reg] = val;
}

___unused
static uint32_t _spi_reg_read(struct spi_generic_dev *dev, unsigned reg)
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
	uint8_t config;

	/* TODO: Flush queues */

	/* TODO: Enable TX */


	/* TODO: Tell master to hold SS */

	config = _spi_reg_read(dev, SPI_CONFIG);

	while (count) {
		union buf {
			uint32_t u32;
			uint16_t u16[2];
			uint8_t u8[4];
		} ___packed;
		union buf rx0 = { 0 }, rx1 = { 0 }, tx0 = { 0 }, tx1 = { 0 };
		union buf *dst = (union buf *) &dev->regs[SPI_TX];

		if (tx)
			memcpy(&tx0.u32, u8_tx, count > 4 ? 4 : count);

		/* Enable TX */
		config &= ~SPI_CONFIG_DISABLE;
		_spi_reg_write(dev, SPI_CONFIG, config);

		/* Disable TX */
		//config |= SPI_CONFIG_DISABLE;
		//_spi_reg_write(dev, SPI_CONFIG, config);

		/* TODO: Check RX FIFO full instead */
		for (i = 0; count && i < 4 /* TODO: 8 */ ;) {
		     /*! (_spi_reg_read(dev, SPI_STATUS) & SPI_STATUS_TX_FIFO_HALF_FULL);) {*/
			switch (count) {
			case 1:
				dst->u8[0] = tx0.u8[0];
				count -= 1; i += 1;
				break;
			case 2:
				dst->u16[0] = tx0.u16[0];
				count -= 2; i += 2;
				break;
			case 3:
				dst->u16[0] = tx0.u16[0];
				dst->u8[0] = tx0.u8[3];
				count -= 3; i += 3;
				break;
			default:
				dst->u32 = tx0.u32;
				count -= 4; i += 4;
			};
		}
		///* Enable TX */
		//config &= ~SPI_CONFIG_DISABLE;
		//_spi_reg_write(dev, SPI_CONFIG, config);

		while (!SPI_STATE_IDLE(_spi_reg_read(dev, SPI_STATUS)))
			;

		rx0.u32 = dev->regs[SPI_RX0];
		rx1.u32 = dev->regs[SPI_RX1];

		//printf("rx0: %08x\n", rx0.u32);

		int j;
		//printf("i: %d\n", i);
		if (rx) {
		//printf("i: %d\n", i);
			for (j = 0; i, j < 4; i--, j++)
				*u8_rx++ = rx0.u8[j];
			for (j = 0; i, j < 4; i--, j++)
				*u8_rx++ = rx1.u8[j];
		}
	}

	(void) dummy_rx;

	/* TODO: Tell master to release SS */
}
