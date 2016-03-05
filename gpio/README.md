GPIO: General Purpose Software Programmable IO
==============================================

## Features
* Input pins accessible through GPIO_IN register read
* output pins controllable through GPIO_OUT register writes.
* Special And/or/xor register access modes for atomic control of output pins
* Vector wide "OR" interrupt on edge detection 
* Maskable input data and input interrupts 
 
## Registers

| Register Name | Access | Default | Description                 | 
|---------------|--------|---------|-----------------------------|
| GPIO_OEN      | RD/WR  | L       | Output enable (1=enable)    |
| GPIO_OUT      | RD/WR  | n/a     | OUT = VALUE                 |
| GPIO_IEN      | RD/WR  | H       | Input pin enable            |
| GPIO_IN       | RD     | n/a     | Input pin value             |
| GPIO_OUTAND   | WR     | n/a     | OUT = OUT & VALUE           |
| GPIO_OUTORR   | WR     | n/a     | OUT = OUT 'or' VALUE        |
| GPIO_OUTXOR   | WR     | n/a     | OUT = OUT ^ VALUE           |
| GPIO_IMASK    | RD/WR  | L       | Masks interupt on input pin |

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


