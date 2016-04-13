# Driver layer for GPIO

* Don't hard code, initialize correctly
* uctions?

## User API

```c
/*** API */

#define GPIO_DIR_IN	(0 << 0)
#define GPIO_DIR_OUT	(1 << 0)

#define GPIO_LOW	0
#define GPIO_HIGH	1

/**
 * gpio_init - GPIO init
 *
 * @param dev		uninitialized device structure
 * @param arg		target argument (depends on target)
 *
 * @return		0 on success. Negative on error
 */
int gpio_init(gpio_dev_t *dev, void *arg);

/**
 * gpio_set_direction - Set pin direction
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 * @param direction	GPIO_DIR_OUT or GPIO_DIR_IN
 *
 * @return		0 on success. Negative on error
 */
int gpio_set_direction(gpio_dev_t *dev, unsigned gpio, unsigned direction);

/**
 * gpio_read - Read pin value
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 *
 * @return		0 on low. 1 on high, negative on error.
 */
int gpio_read(gpio_dev_t *dev, unsigned gpio);

/**
 * gpio_write - Set pin value
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 * @param value		0 on low, 1 on high
 *
 * @return		0 on success, negative on error.
 */
int gpio_write(gpio_dev_t *dev, unsigned gpio, int value);

/**
 * gpio_toggle - Toggle pin value
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 *
 * @return		0 on success, negative on error.
 */
int gpio_toggle(gpio_dev_t *dev, unsigned gpio);
```
