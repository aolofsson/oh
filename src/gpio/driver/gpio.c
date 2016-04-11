#include "gpio.h"
#include <stdio.h>

void gpio_init(gpio_t *dev){
    printf("GPIO INIT\n");
}

void gpio_dir(gpio_t *dev, int pin, int val){
    if(val){
	printf("PIN %d set to OUTPUT\n", pin);
    }
    else{
	printf("PIN %d set to INPUT\n", pin);
    }
}

void gpio_write(gpio_t *dev, int pin, int val){
    printf("PIN %d set to %d\n", pin, val);
}

int gpio_read(gpio_t *dev, int pin){
    printf("PIN %d input is %d\n", pin, 0);
}

