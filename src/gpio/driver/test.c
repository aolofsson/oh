#define OH_GPIO_TARGET OH_GPIO_TARGET_SIMPLE
#define OH_GPIO_SIMPLE_DEFAULT_ADDR 0xdeadbee0

#include <stdlib.h>
#include "oh-gpio.h"

int main()
{
	int val;
	oh_gpio_dev_t dev;

	if (oh_gpio_init(&dev, NULL))
		exit(EXIT_FAILURE);

	oh_gpio_set_direction(&dev, 63, OH_GPIO_DIR_IN);
	oh_gpio_set_direction(&dev,  0, OH_GPIO_DIR_OUT);

	val = 1;
	oh_gpio_write(&dev, 0, val);
	val = oh_gpio_read(&dev, 63);
	oh_gpio_write(&dev, 0, ~val & 1);
	val = oh_gpio_read(&dev, 63);
	oh_gpio_toggle(&dev, 0);
	val = oh_gpio_read(&dev, 63);

	return val;
}
