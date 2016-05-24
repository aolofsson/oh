#include "spi.h"
#define SPI_TARGET SPI_TARGET_UIO
#include <stdio.h>

/* Assume master/slave pins are connected in loop-back */

/* OH SPI slave specifics */
struct oh_spi_mosi_pkt {
	unsigned addr:6;
	unsigned mode:2;
	uint8_t	data[7];
} __attribute__((packed));

struct oh_spi_miso_pkt {
	unsigned:8;
	uint8_t	data[7];
} __attribute__((packed));


#define SLAVE_WRITE 0x00
#define SLAVE_READ  0x02
#define SLAVE_FETCH 0x03

void slave_access(spi_dev_t *dev, unsigned mode, unsigned addr, uint8_t *txbuf,
		  uint8_t *rxbuf, unsigned count)
{
	struct oh_spi_miso_pkt miso;
	struct oh_spi_mosi_pkt mosi = {
		.addr = addr,
		.mode = mode,
		.data = { 0 },
	};
	if (txbuf)
		memcpy(mosi.data, txbuf, count);

	if (mode == SLAVE_WRITE)
		spi_transfer(dev, &mosi, NULL, 1 + count);
	else
		spi_transfer(dev, &mosi, &miso, 1 + count);

	if (rxbuf)
		memcpy(rxbuf, &miso.data[0], count);
}

void slave_write_n(spi_dev_t *dev, unsigned addr, uint8_t *data, unsigned count)
{
	slave_access(dev, SLAVE_WRITE, addr, data, NULL, count);
}

void slave_write(spi_dev_t *dev, unsigned addr, uint8_t data)
{
	slave_access(dev, SLAVE_WRITE, addr, &data, NULL, 1);
}

uint8_t slave_read(spi_dev_t *dev, unsigned addr)
{
	uint8_t value;
	slave_access(dev, SLAVE_READ, addr, NULL, &value, 1);
	return value;
}

void slave_read_n(spi_dev_t *dev, unsigned addr, uint8_t *readback,
		     unsigned count)
{
	slave_access(dev, SLAVE_READ, addr, NULL, readback, count);
}


int main()
{
	int i, j;
	spi_dev_t master;
	uint8_t slave_regs[13];
	bool fail = false;

	if (spi_init(&master, (void *) "/dev/uio0")) {
		perror("spi_init");
		return 1;
	}

	spi_set_clkdiv(&master, 0xfe);

	slave_write(&master, SPI_CONFIG, 0);
	spi_reg_write(&master, SPI_CONFIG, 0);

	printf("status: %#x\n", spi_reg_read(&master, SPI_STATUS));

	printf("clkdiv: %#x\n", spi_reg_read(&master, SPI_CLKDIV));

	printf("config: %#x\n", spi_reg_read(&master, SPI_CONFIG));

	printf("spi_reg_read(28): %#x\n", spi_reg_read(&master, 28));

	printf("Testing write / read to slave regs loop\n");
#if 1
	for (i = 0; i < 1000; i++) {

		for (j = 0; j < 13; j++)
			slave_write(&master, SPI_USER0 + j, j * 2);

		for (j = 0; j < 13; j++) {
			//printf("i: 0x%x\n", i);
			slave_regs[j] = slave_read(&master, SPI_USER0 + j);
		}

		if (i == 0) {
			printf("slave user regs: ");
			for (j = 0; j < 13; j++)
				printf("0x%02x ", (int) slave_regs[j]);
			printf("\n");
		}

		for (j = 0; j < 13; j++)
			if (slave_regs[j] != j * 2) {
				printf("fail\n");
				fail = true;
			}

		for (j = 0; j < 13; j++)
			slave_write(&master, SPI_USER0 + j, j);

		for (j = 0; j < 13; j++)
			slave_regs[j] = slave_read(&master, SPI_USER0 + j);

		if (i == 0) {
			printf("slave user regs: ");
			for (j = 0; j < 13; j++)
				printf("0x%02x ", (int) slave_regs[j]);
			printf("\n");
		}

		for (j = 0; j < 13; j++)
			if (slave_regs[j] != j) {
				printf("fail\n");
				fail = true;
			}

		if (fail)
			break;

	}
#endif

	printf(fail ? "FAIL\n" : "OK\n");

	uint8_t written[7] = { 0xff, 0xee, 0xdd, 0xcc, 0xbb, 0xaa, 0x99};
	uint8_t readback[7] = { 0x0 };

#if 0
	printf("Testing high bits set and slave addr autoincrement\n");
	slave_write_n(&master, SPI_USER0, written, 7);
	slave_read_n(&master, SPI_USER0, readback, 7);
#else
	printf("Testing high bits set\n");
	for (i = 0; i < 7; i++) {
		slave_write(&master, SPI_USER0 + i, written[i]);
		readback[i] = slave_read(&master, SPI_USER0 + i);
	}
#endif

	for (i = 0; i < 7; i++) {
		printf("written[%d] = 0x%02x readback[%d] = 0x%02x\n",
		       i, (int) written[i], i, readback[i]);
		if (readback[i] != written[i])
			fail = true;
	}

	printf("rx0 = 0x%08x rx1 = 0x%08x\n",
	       spi_reg_read(&master, SPI_RX0), spi_reg_read(&master, SPI_RX1));

	spi_fini(&master);

	if (fail)
		printf("FAIL\n");
	else
		printf("PASS\n");

	return fail ? 1 : 0;
}
