#include "gpio.h"

void main(){

    // set up the pin numbers
    int west = 8;
    int N = 8;
    int led = N*west;
    
    // init gpio
    gpio_t gdev, *pdev;
    pdev = &gdev;
    gpio_init(pdev);

    // set pin as output
    gpio_dir(pdev,led,GPIO_TX);
    // create a clock pattern
    while(1){
	gpio_write(pdev,led,1);
	usleep(1e6);      
	gpio_write(pdev,led,0);
	usleep(1e6);      
    }
}
