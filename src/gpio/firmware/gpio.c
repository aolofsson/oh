#include "gpio.h"

int gpio_init(int offset){

}

void gpio_mode(int dev, int pin, int val){

}  

void gpio_write(int dev, int pin, int val){

}

void gpio_toggle(int dev, int pin){

}

int gpio_read(int dev, int pin){

}

void gpio_regwrite(int dev, const reg, uint64 val){

}

uint64 gpio_regread(int dev, const reg, uint64 val){

}

int gpio_spi_init(int dev, int pins){

}

char gpio_spi_transfer (int handle, char byte){
  
  int count;
  for (count = 8; count > 0; count--){
    
    //sclk=1;
    //mosi=byte & 0x80
    //byte=byte<<1
    //sclk=0
    //byte|=miso  
  }
  return (byte);
}

