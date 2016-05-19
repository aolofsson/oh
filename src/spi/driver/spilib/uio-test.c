#include "spi.h"
#define SPI_TARGET SPI_TARGET_UIO
#include <stdio.h>

/* Assume master/slave pins are connected in loop-back */

/* TODO: Add burst */

/* OH SPI slave specifics */
struct oh_spi_mosi_pkt {
	struct {
		unsigned addr:6;
		unsigned mode:2;
	} __attribute__((packed));
	uint8_t	data;
} __attribute__((packed));

struct oh_spi_miso_pkt {
	unsigned:8;
	uint8_t	data;
} __attribute__((packed));


#define SLAVE_WRITE 0x00
#define SLAVE_READ  0x02
#define SLAVE_FETCH 0x03

uint8_t slave_access(spi_dev_t *dev, unsigned mode, unsigned addr, uint8_t data)
{
	struct oh_spi_miso_pkt miso;
	struct oh_spi_mosi_pkt mosi = {
		.addr = addr,
		.mode = mode,
		.data = data,
	};
	spi_write(dev, (uint8_t *) &mosi, sizeof(mosi));
	spi_read(dev, (uint8_t *) &miso, sizeof(miso));

	return miso.data;
}

void slave_write(spi_dev_t *dev, unsigned addr, uint8_t data)
{
	slave_access(dev, SLAVE_WRITE, addr, data);
}

uint8_t slave_read(spi_dev_t *dev, unsigned addr)
{
	return slave_access(dev, SLAVE_READ, addr, 0);
}

int main()
{
	int i;
	spi_dev_t master;
	uint8_t slave_regs[13];
	bool fail = false;

	if (spi_init(&master, (void *) "/dev/uio0")) {
		perror("spi_init");
		return 1;
	}

	for (i = 0; i < 13; i++)
		slave_write(&master, SPI_USER0 + i, i);

	for (i = 0; i < 13; i++)
		slave_regs[i] = slave_read(&master, SPI_USER0 + i);

	printf("slave user regs: ");
	for (i = 0; i < 13; i++)
		printf("0x%2x ", (int) slave_regs[i]);
	printf("\n");

	for (i = 0; i < 13; i++)
		if (slave_regs[i] != i)
			fail = true;

	spi_fini(&master);

	return fail ? 1 : 0;
}
