# Driver layer for GPIO

* Don't hard code, initialize correctly
* uctions?

## User API

```c
#define OH_GPIO_DIR_IN	(0 << 0)
#define OH_GPIO_DIR_OUT	(1 << 0)

#define OH_GPIO_LOW	0
#define OH_GPIO_HIGH	1

/**
 * oh_gpio_init - GPIO init
 *
 * @param dev		uninitialized device structure
 * @param arg		target argument (depends on target)
 *
 * @return		0 on success. Negative on error
 */
int oh_gpio_init(oh_gpio_dev_t *dev, void *arg);

/**
 * oh_gpio_set_direction - Set pin direction
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 * @param direction	OH_GPIO_DIR_OUT or OH_GPIO_DIR_IN
 *
 * @return		0 on success. Negative on error
 */
int oh_gpio_set_direction(oh_gpio_dev_t *dev, unsigned gpio, unsigned direction);

/**
 * oh_gpio_read - Read pin value
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 *
 * @return		0 on low. 1 on high, negative on error.
 */
int oh_gpio_read(oh_gpio_dev_t *dev, unsigned gpio);

/**
 * oh_gpio_write - Set pin value
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 * @param value		0 on low, 1 on high
 *
 * @return		0 on success, negative on error.
 */
int oh_gpio_write(oh_gpio_dev_t *dev, unsigned gpio, int value);

/**
 * oh_gpio_toggle - Toggle pin value
 *
 * @param dev		device structure
 * @param gpio		gpio pin identifier
 *
 * @return		0 on success, negative on error.
 */
int oh_gpio_toggle(oh_gpio_dev_t *dev, unsigned gpio);
```
