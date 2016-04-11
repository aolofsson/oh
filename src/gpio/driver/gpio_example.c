#include "gpio.h"

void main(){

    int west = 8;
    int N = 8;
    int led = N*west;
    gpio_t gdev, *pdev;
    pdev = &gdev;

    // how code should look??
    gpio_init(pdev);
    gpio_dir(pdev,led,GPIO_TX);
    while(1){
	gpio_write(pdev,led,1);
	usleep(1e6);      
	gpio_write(pdev,led,0);
	usleep(1e6);      
    }
}
