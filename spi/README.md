SPI: Serial Peripheral Interface
=======================================

1. [Features](#features)
2. [Master Registers](#master-registers)
3. [Slave Registers](#slave-registers)
4. [Interface](#interface)
5. [Parameters](#parameters)
6. [Code](#code)
7. [Driver](#driver)

## Features
* Standalone general purpose SPI master
* Standalone general purpose SPI slave
* Available as configurable master/slave module
* Support for epiphany mesh transactions
* Support for 64 bit data and address

## Master Registers
 
| Register Name |Addr[7:0]| Access | Default | Description                     | 
|---------------|---------|--------|---------|---------------------------------|
| SPI_CONFIG    |  0x0    | RD/WR  | L       | Configuration register          |
| SPI_STATUS    |  0x1    | RD/WR  | n/a     | Status register                 |
| SPI_CLKDIV    |  0x2    | RD/WR  | H       | Baud rate setting               |
| SPI_CMD       |  0x3    | RD/WR  | n/a     | Optional command register       |
| SPI_TX        |  0x8    | WR     | n/a     | Transmit FIFO                   |
| SPI_RX        |  0x10   | RD     | n/a     | Receiver data register          |


**SPI_CONFIG:**

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [0]     | Disable spi                         |
| [1]     | Enable output interrupt             |
| [2]     | cpol                                |
| [3]     | cpha                                |
| [4]     | LSB first transfer                  |
| [5]     | Manual ss control                   |
| [6]     | Epiphany transfer mode              |

**SPI_STATUS:**

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [0]     | 1: Split transaction data is ready  |
| [1]     | 1: SPI transfer active              |
| [2]     | 1: TX FIFO at half full             |

**SPI_CLKDIV:**

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [7:0]   | Clock divider value                 |
|         | Ratio=1<<clkdiv[7:0]                |

**SPI_CMD:** 
Byte wide command register for emode

**SPI_TX:**
Eight readable byte wide registers. 

**SPI_RX:**
Eight addressable byte wide registers. 

**SPI_USER:**
Up to 16 user specified byte wide registers

## Slave Registers

| Register Name |Addr[7:0]| Access | Default | Description                     | 
|---------------|---------|--------|---------|---------------------------------|
| SPI_CONFIG    |  0x0    | RD/WR  | L       | Configuration register          |
| SPI_STATUS    |  0x1    | RD/WR  | n/a     | Status register                 |
| SPI_TX        |  0x8    | RD     | n/a     | Split transaction return data   |
| SPI_RX        |  0x10   | RD/WR  | n/a     | Receiver data register          |

**SPI_CONFIG:**

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [0]     | Disable spi                         |
| [1]     | Enable output interrupt             |
| [2]     | cpol                                |
| [3]     | cpha                                |
| [4]     | LSB first transfer                  |
| [5]     | User regs enable                    |
| [6]     | Epiphany transfer mode              |

**SPI_STATUS:**

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [0]     | 1: Split transaction data is ready  |
 
**SPI_TX:**
Eight readable byte wide registers. 

**SPI_RX:**
Eight addressable byte wide registers. 

**SPI_USER:**
Up to 16 user specified byte wide registers

## Interface

```
   //clk, reset, irq
   input           nreset;      // asynch active low reset
   input 	   clk;         // core clock   
   input 	   master_mode; // master/slave selector
      
   //interrupt output
   output 	   spi_irq;     // interrupt output
   
   //packet from core
   input 	   access_in;   // access from core
   input [PW-1:0]  packet_in;   // packet from core
   input 	   wait_in;     // pushback from io   

   //packet to core
   output 	   access_out;  // access to core
   output [PW-1:0] packet_out;  // packet to core
   output 	   wait_out;    // pushback from core

   //master io interface
   output          m_sclk;      // master clock
   output 	   m_mosi;      // master output
   output 	   m_ss;        // slave select
   input 	   m_miso;      // master input
    
   //slave io interface
   input 	   s_sclk;      // slave clock
   input 	   s_mosi;      // slave input
   input 	   s_ss;        // slave select
   output 	   s_miso;      // slave output
```

## Parameters
* AW : address space width (32/64)

## Code
* [spi.v](hdl/spi.v)

## Driver
* driver/spi_driver.c
* driver/spi_driver.h

## Authors
* Andreas Olofsson

## License
* MIT

## References
* [Wikipedia](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus)

