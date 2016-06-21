GPIO: General Purpose Software Programmable IO
==============================================

## Features
* Input pins accessible through GPIO_IN register read
* Output pins controllable through GPIO_OUT register writes
* Vector wide "OR" interrupt on edge detection 
* Maskable input data and interrupts
* Special And/or/xor register access modes for atomic control of output pins
 
## Registers

| Register Name |Addr[6:3]|Access |Default| Description                     | 
|---------------|---------|-------|-------|---------------------------------|
| GPIO_DIR      |  0x0    | WR    | L     | Direction(0=input, 1=output)    |
| GPIO_IN       |  0x1    | RD    | n/a   | Input pin value                 |
| GPIO_OUT      |  0x2    | WR    | L     | Output pin value                |
| GPIO_OUTCLR   |  0x3    | WR    | n/a   | Output = output & ~value        |
| GPIO_OUTSET   |  0x4    | WR    | n/a   | Output = output "or" value      |
| GPIO_OUTXOR   |  0x5    | WR    | n/a   | Output = output ^ value         |
| GPIO_IMASK    |  0x6    | WR    | H     | Interrupt mask (1=mask)         |
| GPIO_ITYPE    |  0x7    | WR    | n/a   | IRQ type (0=edge,1=level)        |
| GPIO_IPOL     |  0x8    | WR    | H     | IRQ polarity (1=rising edge/high)|
| GPIO_ILAT     |  0x9    | RD    | L     | IRQ Status (1=latched irq)       |
| GPIO_ILATCLR  |  0xA    | WR    | n/a   | Clears ILAT(1=clear)             |

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


