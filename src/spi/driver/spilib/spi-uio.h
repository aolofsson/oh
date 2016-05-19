#pragma once
#ifndef _SPI_INTERNAL
# error "Don't include this file directly"
#endif

#include "spi-generic.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <stdbool.h>
#include <stdint.h>

struct spi_uio_dev {
	int fd;
	struct spi_generic_dev generic;
};

typedef struct spi_uio_dev spi_dev_t;

___unused
static int spi_init(spi_dev_t *dev, void *arg)
{
	char *path = arg;

	dev->fd = open(path, O_RDWR);
	if (dev->fd < 0)
		return -errno;

	dev->generic.regs = mmap(NULL, 0x1000, PROT_WRITE | PROT_READ,
				 MAP_SHARED, dev->fd, 0);
	if (dev->generic.regs == MAP_FAILED)
		return -errno;

	return 0;
}

___unused
static void spi_fini(spi_dev_t *dev)
{
	munmap((void *) dev->generic.regs, 0x1000);
	close(dev->fd);
}

#define spi_to_generic(dev) (&(dev)->generic)
#define spi_reg_write(dev, reg, val) _spi_reg_write(spi_to_generic((dev)), (reg), (val))
#define spi_reg_read(dev, reg) _spi_reg_read(spi_to_generic((dev)), (reg))
#define spi_write(dev, src, count) _spi_write(spi_to_generic((dev)), (src), (count))
#define spi_read(dev, dest, count) _spi_read(spi_to_generic((dev)), (dest), (count))
