#include "spi.h"
#define SPI_TARGET SPI_TARGET_UIO
#include <stdio.h>

/* Assume master/slave pins are connected in loop-back */

/* TODO: Add burst */

/* OH SPI slave specifics */
struct oh_spi_mosi_pkt {
	unsigned addr:6;
	unsigned mode:2;
	uint8_t	data;
} __attribute__((packed));

struct oh_spi_miso_pkt {
	uint8_t	data;
	unsigned fook:8;
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
	spi_transfer(dev, &mosi, &miso, sizeof(mosi));

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

	printf("status: %#x\n", spi_reg_read(&master, SPI_STATUS));

	printf("clkdiv: %#x\n", spi_reg_read(&master, SPI_CLKDIV));

	printf("config: %#x\n", spi_reg_read(&master, SPI_CONFIG));

	printf("spi_reg_read(28): %#x\n", spi_reg_read(&master, 28));
	spi_set_clkdiv(&master, 0x5);

	int j;
	for (j = 0; j < 10000; j++) {

		for (i = 0; i < 13; i++)
			slave_write(&master, SPI_USER0 + i, i * 2);

		for (i = 0; i < 13; i++)
			slave_regs[i] = slave_read(&master, SPI_USER0 + i);

		if (j == 0) {
			printf("slave user regs: ");
			for (i = 0; i < 13; i++)
				printf("0x%02x ", (int) slave_regs[i]);
			printf("\n");
		}

		for (i = 0; i < 13; i++)
			if (slave_regs[i] != i * 2)
				fail = true;

		for (i = 0; i < 13; i++)
			slave_write(&master, SPI_USER0 + i, i);

		for (i = 0; i < 13; i++)
			slave_regs[i] = slave_read(&master, SPI_USER0 + i);

		if (j == 0) {
			printf("slave user regs: ");
			for (i = 0; i < 13; i++)
				printf("0x%02x ", (int) slave_regs[i]);
			printf("\n");
		}

		for (i = 0; i < 13; i++)
			if (slave_regs[i] != i)
				fail = true;

		if (fail)
			break;

	}

	spi_fini(&master);

	if (fail)
		printf("FAIL\n");
	else
		printf("PASS\n");

	return fail ? 1 : 0;
}
