//Register number addr[6:3]
#define GPIO_DIR      0
#define GPIO_IN       1
#define GPIO_OUT      2
#define GPIO_OUTCLR   3
#define GPIO_OUTSET   4
#define GPIO_OUTXOR   5
#define GPIO_IMASK    6
#define GPIO_ITYPE    7
#define GPIO_IPOL     8
#define GPIO_ILAT     9
#define GPIO_ILATCLR  10

#definbe GPIO_TX   1
#definbe GPIO_RX   0


// define global struct...
//parameters per struct
//An oderered list of SPI interfaces
//-each interface has: N pins, a global offset

// Provide pointer to GPIO module
int gpio_init(gpio_t *dev offset);  

// Set pin mode
void gpio_dir(gpio_t *dev, int pin, int dir);  

// Write to a pin
void gpio_write(gpio_t *dev, int pin, int val);

// Toggle a pin
void gpio_toggle(gpio_t *dev, int pin);

// Read from a pin
int gpio_read(gpio_t *dev, int pin);




