Mini-IO: A lightweight IO interface
=============================================

1. [Features](#features)
2. [Registers](#registers)
3. [Interface](#interface)
4. [Parameters](#parameters)
5. [Code](#code)
6. [Driver](#driver)
7. [Authors](#authors)
8. [License](#license)

## Introduction
* Mini-IO (MIO) is a generic protocol agnostic link for moving data between chips (or silicon dies). 

## Features

* Source synchronous
* Clock aligned by transmitter at 90 degrees
* Parametrized I/O and system side bus width
* Configurable as single or dual data rate
* Configurable as lsb or msb first transfer

## Registers

| Register Name |Addr[5:2]| Access | Default | Description                    | 
|---------------|---------|--------|---------|--------------------------------|
| MIO_CONFIG    |  0x0    | RD/WR  | L       | Configuration register         |
| MIO_STATUS    |  0x1    | RD/WR  | n/a     | Status register                |
| MIO_CLKDIV    |  0x2    | RD/WR  | H       | TX frequency setting           |
| MIO_CLKPHASE  |  0x3    | RD/WR  | n/a     | TX phase setting               |
| MIO_ODELAY    |  0x5    | RD/WR  | n/a     | TX output data delay           |
| MIO_IDELAY    |  0x4    | RD/WR  | n/a     | RX input data delay            |
| MIO_ADDR0     |  0x6    | RD/WR  | n/a     | Lower 32 bits of auto-address  |
| MIO_ADDR1     |  0x7    | RD/WR  | n/a     | Upper 32 bits of auto-address  |

**MIO_CONFIG:**

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [0]     | TX disable                          |
| [1]     | RX disable                          |
| [3:2]   | Transfer mode                       |
|         | 00=Emesh packet mode "emode"        |
|         | 01=Data streaming mode "dmode"      |
|         | 10=Auto address mode "amode"        |
| [11:4]  | Number of flits/packet              |
|         | For emode:
|         | 0=1 (byte)                          |
|         | 0=2 (16 bit)                        |

|         | 0=4 (32 bit)                        |
|         | 0=8 (64 bit)                        |
| [12]    | DDR mode                            |
| [13]    | Transfer MSB first                  |
| [18:14] | Emesh ctrlmode                      |


**MIO_STATUS:**

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [0]     | RX fifo empty                       |
| [1]     | RX programmable full reached        |
| [2]     | RX full reached                     |
| [3]     | TX fifo empty                       |
| [4]     | TX programmable full reached        |
| [5]     | TX full reached                     |
| [7:6]   | Reserved                            |
| [15:8]  | Sticky versions fo bit [7:0]        |


**MIO_CLKDIV:**

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [7:0]   | Clock period setting                |
|         | 0:clkout=clkin                      |
|         | 1:clkout=clkin/2                    |
|         | 2:clkout=clkin/3                    |
|         | 3:clkout=clkin/4                    |
|         | etc...                              |



**MIO_CLKPHASE:**

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [7:0]   | TX IO clock rising edge             |
| [15:8]  | TX IO clock falling edge            |
| [23:16] | TX transmit clock rising edge       |
| [31:24] | TX transmit clock rising edge       |

**MIO_ODELAY:**

* TBD

**MIO_IDELAY:**

* TBD

**MIO_ADDR0:**

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [31:0]  | Lower 32 bits of address in amode   |


**MIO_ADDR1:**

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [31:0]  | Upper 32 bits of address in amode   |

## Interface
| SIGNAL             | DIR| DESCRIPTION 
| -------------------|----|--------------
| access_in          | I  | Valid packet for TX
| data_in            | I  | Data for TX
| wait_out           | O  | Pushback from TX towards core side
| access_out         | I  | Valid packet from RX
| data_out           | I  | Data from RX
| wait_in            | O  | Pushback for RX from core side
| tx_access          | O  | TX packet framing signal
| tx_clk             | O  | TX clock aligned in the center of the data eye
| tx_data            | I  | TX DDR data                                    
| tx_wait            | I  | TX pushback from RX                            
| rx_access          | I  | RX packet framing signal
| rx_clk             | I  | RX center aligned clock 
| rx_data            | I  | RX DDR data
| rx_wait            | O  | RX pushback for TX
| clk                | I  | Core side clock
| nreset             | I  | Active low async reset
| io_clk             | I  | Clock for transmit side
| datasize[7:0]      | I  | Size of data to transmit (<PW)
| divcfg[7:0]        | I  | Divider setting for TX clock divider


## Parameters
* N : IO data width
* PW: core side packet width

## Code
* [mio.v](hdl/mio.v)
* [mio_regs.v](hdl/mio_regs.v)

## Authors
* Andreas Olofsson

## License
* MIT






