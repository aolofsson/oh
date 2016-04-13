#define OH_GPIO_TARGET OH_GPIO_TARGET_SIMPLE
#define MY_GPIO_ADDR 0x810f0c00

#include <stdlib.h>
#include <unistd.h>
#include "oh-gpio.h"

int  main()
{
	oh_gpio_dev_t dev;

	// set up the pin numbers
	const unsigned west		= 4;
	const unsigned N		= 4;
	const unsigned led		= N * west + 0;
	const unsigned button		= N * west + 1;
	const unsigned clk		= N * west + 2;

	// init gpio (argument to SIMPLE is pointer to regs)
	if (oh_gpio_init(&dev, (void *) MY_GPIO_ADDR))
		exit(EXIT_FAILURE);

	// set pin as output
	oh_gpio_set_direction(&dev, led, OH_GPIO_DIR_OUT);

	// set pin as output
	oh_gpio_set_direction(&dev, clk, OH_GPIO_DIR_OUT);

	// set pin as input
	oh_gpio_set_direction(&dev, button, OH_GPIO_DIR_IN);

	// init outputs
	oh_gpio_write(&dev, clk, 0);
	oh_gpio_write(&dev, led, 0);

	while (1) {
		usleep(1e6);

		// create clock pattern
		oh_gpio_toggle(&dev, clk);

		// set led to button value
		if (oh_gpio_read(&dev, button))
			oh_gpio_write(&dev, led, 1);
		else
			oh_gpio_write(&dev, led, 0);
	}

	return 0;
}
