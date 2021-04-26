SPI: Serial Peripheral Interface
=======================================

1. [Features](#features)
2. [Examples](#examples)
3. [Master Registers](#master-registers)
4. [Slave Registers](#slave-registers)
5. [Interface](#interface)
6. [Code](#code)
7. [Driver](#driver)
8. [License](#license)
9. [Authors](#authors)

## Features
* Standalone general purpose SPI master
* Standalone general purpose SPI slave
* Available as configurable master/slave module
* Support for epiphany mesh transactions
* Support for 64 bit data and address

## Examples

**SPI_WRITE:**
```
DEADBEEF_00000020_00000008_01_0000 // write command + slave address
DEADBEEF_00000042_00000008_01_0100 // byte to write (42)
```

**SPI_READ:**
```
DEADBEEF_000000A0_00000008_01_0000 // read command + slave address
00000000_00000000_00000008_01_0100 // (dummy byte to generate sclk)
```

**REMOTE SPI WRITE:**
```
DEADBEEF_00000000_00000008_01_0000 // write command + slave config address
DEADBEEF_00000010_00000008_01_0200 // lsb-first config
DEADBEEF_00000010_00000000_03_0200 // configure master as lsbfirst
DEADBEEF_000007C1_00000008_03_0000 // remote write command + 1st emesh byte
00000000_82800000_00000008_05_0000 // 32b destination address
fedcba98_76543210_00000008_07_0400 // 64b data payload
```

## Master Registers
 
| Register Name |Addr[7:0]| Access | Default | Description                   | 
|---------------|---------|--------|---------|-------------------------------|
| SPI_CONFIG    |  0x0    | RD/WR  | L       | Configuration register        |
| SPI_STATUS    |  0x1    | RD/WR  | n/a     | Status register               |
| SPI_CLKDIV    |  0x2    | RD/WR  | H       | Baud rate setting             |
| SPI_TX        |  0x8    | WR     | n/a     | Transmit FIFO                 |
| SPI_RX        |  0x10   | RD     | n/a     | Receiver data register        |


**SPI_CONFIG:**

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [0]     | Disable spi controller              |
| [1]     | Enable output interrupt             |
| [2]     | cpol                                |
| [3]     | cpha                                |
| [4]     | LSB first transfer mode             |
| [5]     | SS control mode (1=manual mode)     |
| [6]     | Controls SS pin in manual SS mode   |

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
| SPI_USER      |  0x20   | RD/WR  | n/a     | User defined registers          |

**SPI_CONFIG (0x0): **

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [0]     | Disable spi                         |
| [1]     | Enable output interrupt             |
| [2]     | cpol                                |
| [3]     | cpha                                |
| [4]     | LSB first transfer                  |
| [5]     | User regs enable                    |

**SPI_STATUS (0x1): **

| FIELD   | DESCRIPTION                         |
|-------- |-------------------------------------| 
| [0]     | 1: Split transaction data is ready  |
 
**SPI_TX (0x8) :**
Eight readable byte wide registers. 

**SPI_RX (0x20) :**
Eight addressable byte wide registers. 

**SPI_USER:**
Up to 16 user specified byte wide registers

## Interface

```
   input           nreset;      // asynch active low reset
   input 	       clk;         // core clock
   output 	       spi_irq;     // interrupt output
   input 	       access_in;   // access from core
   input [PW-1:0]  packet_in;   // packet from core
   input 	       wait_in;     // pushback from core
   output 	       access_out;  // access to core
   output [PW-1:0] packet_out;  // packet to core
   output 	       wait_out;    // pushback to core
   output          m_sclk;      // master clock to IO
   output 	       m_mosi;      // master output to IO
   output 	       m_ss;        // slave select to IO
   input 	       m_miso;      // master input from IO
   input 	       s_sclk;      // slave clock from IO
   input 	       s_mosi;      // slave input from IO
   input 	       s_ss;        // slave select from IO
   output 	       s_miso;      // slave output to IO
```

## Code
* [spi.v](hdl/spi.v)

## Driver
* driver/spi_driver.c
* driver/spi_driver.h

## License
* MIT

## Authors
* Andreas Olofsson
