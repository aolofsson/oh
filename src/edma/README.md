EDMA: A lightweight DMA engine
=============================================

1. [Features](#features)
2. [Registers](#registers)
3. [Interface](#interface)
4. [Parameters](#parameters)
5. [Code](#code)
6. [Driver](#driver)
7. [Authors](#authors)
8. [License](#license)

## Features

* 1D/2D transfers
* Variable strides
* 8/16/32/64 bit transfers
* Descriptor based and manual configuration
* Auto-chain mode
* Interrupt on completion

## Registers

| Register Name   |Addr[6:2]| Access | Default | Description                    | 
|-----------------|---------|--------|---------|--------------------------------|
| EDMA_CONFIG     |  0x0    | RD/WR  | L       | Configuration register         |
| EDMA_STRIDE     |  0x1    | RD/WR  | n/a     | Stride                         |
| EDMA_COUNT      |  0x2    | RD/WR  | n/a     | Transfer count                 |
| EDMA_SRCADDR    |  0x3    | RD/WR  | n/a     | Source address                 |
| EDMA_DSTADDR    |  0x4    | RD/WR  | n/a     | Destination address            |
| EDMA_SRCADDR64  |  0x5    | RD/WR  | n/a     | Upper source address (64b)     |
| EDMA_DSTADDR64  |  0x6    | RD/WR  | n/a     | Upper desination address (64b) |
| EDMA_STATUS     |  0x7    | RD/WR  | n/a     | Status register                |


**EDMA_CONFIG (0x0)**

The DMA configuration register is used to configure the type of DMA transfer. The following table shows the configuration options for each channel in the DMA engine.

| Bits   | Name       | Description                                      |
|--------|------------|--------------------------------------------------|
| [0]    | DMAEN      | Turns on DMA channel                             |
|        |            | 1=enabled                                        |
|        |            | 0=disabled                                       |
| [1]    | MASTER     | Sets up DMA channel to work in master made       |
|        |            | 1=master mode                                    |
|        |            | 0=slave mode                                     |
| [2]    | CHAINMODE  | Sets up DMA to fetch new descriptor at completion|
|        |            | 1=Chain mode                                     |
|        |            | 0=One-shot mode                                  |
| [3]    | STARTUP    | Forces fetch of new descriptor                   |
|        |            | 1=Fetch descriptor based on bits [31:16]         |
|        |            | 0=Manual operation (no fetch)                    |
| [4]    | IRQEN      | Enables interrupt at the end of transfer         |
|        |            | 1=Interrupt enabled                              |
|        |            | 0=Interrupt disabled                             |
| [6:5]  | DATASIZE   | Size of data transfer.                           |
|        |            | 00=byte, 01=half-word, 10=word, 11=double-word   |  
|[15:7]  |            | Reserved                                         |
| [31:16]| NEXT_PTR   | Address of next DMA descriptor                   |

**EDMA_STRIDE (0x1):**

The register contains two signed 16-bit values specifying the stride, in bytes, used to update the source and destination address register after a completed transaction. The lower 16 bits specify source address register update stride and the upper 16 bits specify the destination address stride. At the end of an inner-loop turn, this register is loaded with the outer-loop stride values to make address adjustments of the source and destination addresses before continuing with the next inner loop of data transfer. Before the next inner loop starts, the stride register is reloaded with the inner-loop stride values. The stride values are specified in bytes and should match the type of transfers being done. All DMA transactions must be aligned appropriately in memory.

**EDMA_COUNT (0x2):**

This register is used to set up the number of transactions in the inner and outer loops of the DMA transaction. The upper 16 bits specify the outer loop of the DMA transfer and the and lower 16 bits of the register specify the number of inner loops. The outer and inner loops must be set to a value of one or greater. The DMA block transfer is complete when the DMACOUNT register reaches zero. The inner count value is cleared to the initial count every time the outer loop is decremented.

| Bits  | Name       | Description                                     |
|-------|------------|-------------------------------------------------|
| [15:0]| INNER_COUNT| Transactions remaining within inner loop        |   
|[31:16]| OUTER_COUNT| Number of outer loop iterations remaining (“2D”)| 


**EDMA_SRCADDR (0x3):**

This register contains the 32-bit source address of the transaction currently being transferred. The address can be a local address (bits [31:20] all zero) or a global address. The register gets loaded when the descriptor is fetched from memory and is updated at the completion of every transaction. The updated address is equal to the old source address added with the value in the destination field in the stride register.

| Bits  | Name       | Description                                     |
|-------|------------|-------------------------------------------------|
|[31:0] | SRCADDR    | Current source address                          |

**EDMA_DSTADDR (0x4):**

This register contains the 32-bit address of the transaction currently being transferred. The address can be a local address (bits [31:20] all zero) or a global address. The register gets loaded when the descriptor is fetched from memory and is updated at the completion of every transaction. The updated address is equal to the old destination address added with the value in the destination field in the stride register.

| Bits  | Name       | Description                                     |
|-------|------------|-------------------------------------------------|
|[31:0] | DSTADDR    | Current destination address                     |

**EDMA_SRCADDR64 (0x5):**

This register contains the upper 32 bits of a the current 64-bit source address.

| Bits  | Name       | Description                                     |
|-------|------------|-------------------------------------------------|
|[31:0] | SRCADDR64  | Current source address                          |

**EDMA_DSTADDR64 (0x6):**

This register contains the upper 32 bits of a the current 64-bit desintation address.

| Bits  | Name       | Description                                     |
|-------|------------|-------------------------------------------------|
|[31:0] | DSTADDR64  | Current destination address                     |

**EDMA_STATUS (0x7):**

The DMA status register is used to hold the current descriptor and the state of the dma  engine. 

| Bits   | Name       | Description                                     |
|--------|------------|-------------------------------------------------|
| [3:0]  | STATE      | DMA State                                       |
| [31:16]| CURR_DESCR | Pointer to current descriptor                   |

## Parameters
* AW : Address width (32/64)

## Code
* [edma.v](hdl/edma.v)

## Authors
* Andreas Olofsson

## License
* MIT






