# Driver layer for SPI

## User API

```c

union spi_config {
	uint8_t reg;
	struct {
		unsigned disable:1;
		unsigned irq_enable:1;
		unsigned cpol:1;
		unsigned cpha:1;
		unsigned lsb_first:1;
		unsigned user_regs_enable:1; /* slave only */
	} __packed;
} __packed;

union spi_status {
	uint8_t reg;
	struct {
		unsigned split_transaction_data_ready:1;
		unsigned transfer_active:1; /* master only */
		unsigned tx_fifo_half_full:1; /* master only */
	} __packed;
} __packed;

/**
 * spi_init - SPI init
 *
 * @param dev		uninitialized device structure
 * @param arg		target argument (depends on target)
 *
 * @return		0 on success. Negative on error
 */
int spi_init(spi_dev_t *dev, void *arg);

/**
 * spi_set_config - Set configuration for SPI device
 *
 * @param dev		device structure
 * @param config	spi configuration
 *
 */
void spi_set_config(spi_dev_t *dev, union spi_config *config);

/**
 * spi_get_config - Get configuration for SPI device
 *
 * @param dev		device structure
 * @param config	spi configuration
 *
 */
void spi_get_config(spi_dev_t *dev, union spi_config *config);

/**
 * spi_get_status - Get status for SPI device
 *
 * @param dev		device structure
 * @param status	spi status
 *
 */
void spi_get_status(spi_dev_t *dev, union spi_status *status);

/**
 * spi_read - Read bytes
 *
 * @param dev		device structure
 * @param dest		destination buffer
 * @param count		number of bytes
 *
 */
void spi_read(spi_dev_t *dev, uint8_t *dest, unsigned count);

/**
 * spi_write - Write bytes
 *
 * @param dev		device structure
 * @param src		source buffer
 * @param count		number of bytes
 *
 */
void spi_write(spi_dev_t *dev, uint8_t *src, unsigned count);


```
