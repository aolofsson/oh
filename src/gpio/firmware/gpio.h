#define GPIO_OFFSET   0
#define GPIO_OEN      0
#define GPIO_OUT      1
#define GPIO_IEN      2
#define GPIO_IN       3
#define GPIO_OUTAND   4
#define GPIO_OUTORR   5
#define GPIO_OUTXOR   6
#define GPIO_IMASK    7

#include <stdint.h>

// Provide pointer to GPIO module
int gpio_init(int offset);  

// Set pin mode
void gpio_mode(int dev, int pin, int val);  

// Write to a pin
void gpio_write(int dev, int pin, int val);

// Toggle a pin
void gpio_toggle(int dev, int pin);

// Read from a pin
int gpio_read(int dev, int pin);

// Write register
void gpio_regwrite(int dev, const reg, uint64 val);

// Read register
uint64 gpio_regread(int dev, const reg, uint64 val);

// Set up SPI
int gpio_spi_init(int dev, int pins);

// SPI transfer (byte)
char gpio_spi_transfer(int handle, char data);




