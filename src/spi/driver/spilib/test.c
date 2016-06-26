#define SPI_TARGET SPI_TARGET_SIMPLE
#define SPI_SIMPLE_DEFAULT_ADDR 0xdeadbee0

#include <stdlib.h>
#include "spi.h"

int main()
{
	int val;
	spi_dev_t dev;

	if (spi_init(&dev, NULL))
		exit(EXIT_FAILURE);

	spi_set_direction(&dev, 63, SPI_DIR_IN);
	spi_set_direction(&dev,  0, SPI_DIR_OUT);

	val = 1;
	spi_write(&dev, 0, val);
	val = spi_read(&dev, 63);
	spi_write(&dev, 0, ~val & 1);
	val = spi_read(&dev, 63);
	spi_toggle(&dev, 0);
	val = spi_read(&dev, 63);

	return val;
}
