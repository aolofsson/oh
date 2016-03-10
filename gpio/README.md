GPIO: General Purpose Software Programmable IO
==============================================

## Features
* Input pins accessible through GPIO_IN register read
* output pins controllable through GPIO_OUT register writes.
* Special And/or/xor register access modes for atomic control of output pins
* Vector wide "OR" interrupt on edge detection 
* Maskable input data and input interrupts 
 
## Registers

| Register Name |Addr[7:3]| Access | Default | Description                 | 
|---------------|---------|--------|---------|-----------------------------|
| GPIO_OEN      |  0x0    | RD/WR  | L       | Output enable (1=enable)    |
| GPIO_OUT      |  0x1    | RD/WR  | n/a     | OUT = VALUE                 |
| GPIO_IEN      |  0x2    | RD/WR  | H       | Input pin enable            |
| GPIO_IN       |  0x3    | RD     | n/a     | Input pin value             |
| GPIO_OUTAND   |  0x4    | WR     | n/a     | OUT = OUT & VALUE           |
| GPIO_OUTORR   |  0x5    | WR     | n/a     | OUT = OUT 'or' VALUE        |
| GPIO_OUTXOR   |  0x6    | WR     | n/a     | OUT = OUT ^ VALUE           |
| GPIO_IMASK    |  0x7    | WR     | n/a     | OUT = OUT ^ VALUE           |

## Interface

* clk
* active low async reset
* emesh register access interface
* IO pin interface (in/out/tristate)

## Parameters
* AW : address space width (32/64)
* N  : number of IO (1-64)

## Code
* [gpio.v](hdl/gpio.v)
* [gpio_regmap.vh](hdl/gpio_regmap.vh)

## Building

```cd
cd $OH_HOME/gpio/dv
./build.sh	               # build with Icarus
./run.sh tests/test_regs.emf   # run test
gtkwave waveform.vcd           # open waveform
```

## Language
* Verilog

## Authors
* Andreas Olofsson

## License
* MIT


