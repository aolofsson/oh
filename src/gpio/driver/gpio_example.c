#define GPIO_TARGET GPIO_TARGET_SIMPLE
#define MY_GPIO_ADDR 0x810f0c00

#include <stdlib.h>
#include <unistd.h>
#include "gpio.h"

int  main()
{
	gpio_dev_t dev;

	// set up the pin numbers
	const unsigned west		= 4;
	const unsigned N		= 4;
	const unsigned led		= N * west + 0;
	const unsigned button		= N * west + 1;
	const unsigned clk		= N * west + 2;

	// init gpio (argument to SIMPLE is pointer to regs)
	if (gpio_init(&dev, (void *) MY_GPIO_ADDR))
		exit(EXIT_FAILURE);

	// set pin as output
	gpio_set_direction(&dev, led, GPIO_DIR_OUT);

	// set pin as output
	gpio_set_direction(&dev, clk, GPIO_DIR_OUT);

	// set pin as input
	gpio_set_direction(&dev, button, GPIO_DIR_IN);

	// init outputs
	gpio_write(&dev, clk, 0);
	gpio_write(&dev, led, 0);

	while (1) {
		usleep(1e6);

		// create clock pattern
		gpio_toggle(&dev, clk);

		// set led to button value
		if (gpio_read(&dev, button))
			gpio_write(&dev, led, 1);
		else
			gpio_write(&dev, led, 0);
	}

	return 0;
}
