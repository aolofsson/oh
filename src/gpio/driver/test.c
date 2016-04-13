#define GPIO_TARGET GPIO_TARGET_SIMPLE
#define GPIO_SIMPLE_DEFAULT_ADDR 0xdeadbee0

#include <stdlib.h>
#include "gpio.h"

int main()
{
	int val;
	gpio_dev_t dev;

	if (gpio_init(&dev, NULL))
		exit(EXIT_FAILURE);

	gpio_set_direction(&dev, 63, GPIO_DIR_IN);
	gpio_set_direction(&dev,  0, GPIO_DIR_OUT);

	val = 1;
	gpio_write(&dev, 0, val);
	val = gpio_read(&dev, 63);
	gpio_write(&dev, 0, ~val & 1);
	val = gpio_read(&dev, 63);
	gpio_toggle(&dev, 0);
	val = gpio_read(&dev, 63);

	return val;
}
