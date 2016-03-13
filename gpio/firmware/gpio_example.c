#include "gpio.h"

void main(){

  int led = 0;  
  gpio_mode(led,GPIO_OUTPUT);
  while(1){
    gpio_write(led,1);
    usleep(1e6);      
    gpio_write(led,0);
    usleep(1e6);      
  }
}
