![alt tag](docs/elink_header.png)

ELINK INTRODUCTION
=====================================
The "elink" is a low-latency/high-speed interface for communicating between FPGAs and ASICs (such as Epiphany). The interface can achieve a peak throughput of 8 Gbit/s (duplex) in modern FPGAs using 24 LVDS signal pairs.  

###STRUCTURE

![alt tag](docs/elink.png)

```
elink
 |----emaxi (AXI master interface)
 |----esaxi (AXI slave interface)
 |----ereset (elink and chip reset generator)
 |----ecfg_clocks (elink clock and reset configuration)
 |----eclocks (PLL instantiation)
 |----ecfg_cdc (etx-->erx path for configuration register access)
 |----erx (receive path)
 |     |----erx_io (chip level I/O interface
 |     |----erx_core
 |     |     |----erx_protocol (elink protocol-->emesh packet converter)
 |     |     |----erx_remap (simple dstaddr remapping)
 |     |     |----erx_mmu (advanced dstaddr mapping)
 |     |     |----erx_cfgif (configuration interface)
 |     |     |----erx_cfg (basic rx config registers)
 |     |     |----erx_mailbox (fifo style mailbox with interrupt output)
 |     |     |----erx_dma (RX DMA)
 |     |     |----erx_arbiter (sends RX transaction to WR/RD/RR fifo)
 |     |----erx_fifo
 |           |----rxwr_fifo (write fifo)
 |           |----rxrd_fifo (read request fifo)
 |           |----rxrr_fifo (read response fifo)
 |----etx (transmit path)
       |----etx_io (chip level I/O interface)
       |----etx_core
       |     |----etx_protocol (emesh-->elink protocol converter)
       |     |----etx_remap (simple dstaddr remapping)
       |     |----etx_mmu (advanced dstaddr mapping)
       |     |----etx_cfgif (configuration interface)
       |     |----etx_cfg (basic rx config registers)
       |     |----etx_dma (DMA master)
       |     |----etx_arbiter (sends rx transaction to WR/RD/RR fifo)
       |----etx_fifo
             |----txwr_fifo (write fifo)     
             |----txrd_fifo (read request fifo)
             |----txrr_fifo (read response fifo)
 --------------------------------------------------------------------
```

###I/O PROTOCOL 
The default elink communication protocol uses source synchronous clocks, a packet frame signal, 8-bit wide dual data rate data bus, and separate read and write packet wait signals to implement a glueless point to point link. The elink has a modular structure allowing the default communication protocol to be easily changed by modifying  the "etx_protocol" and "erx_protocol" blocks.    

```
               ___     ___     ___     ___     ___     ___     ___     ___ 
 LCLK     \___/   \___/   \___/   \___/   \___/   \___/   \___/   \___/
           _______________________________________________________________
 FRAME   _/                                                        \______ 
               
 DATA   XXXX|B00|B01|B02|B03|B04|B05|B06|B07|B08|B09|B10|B11|B12|B13|B14.

```
           
BYTE     | DESCRIPTION 
---------|--------------
B00      | R0000000 (R bit set to 1 for read transaction)
B01      | {ctrlmode[3:0],dstaddr[31:28]}
B02      | dstaddr[27:20]
B03      | dstaddr[19:12]
B04      | dstaddr[11:4]
B05      | {dstaddr[3:0],datamode[1:0],write,access}
+B06     | data[31:24]
+B07     | data[23:16]
+B08     | data[15:8]
++B09    | data[7:0]
B10      | data[63:56] or srcaddr[31:24]
B11      | data[55:48] or srcaddr[23:16]
B12      | data[47:40] or srcaddr[15:8]
B13      | data[39:32] or srcaddr[7:0]
+++B14   | data[31:24] in 64 bit write burst mode only
B15      | data[23:16] in 64 bit write burst mode only
...      | ...

+B01-B06: srcaddr used for read request, otherwise data  
++B09: is the last byte of 32 bit write or read transaction    
+++B14: is the first data byte of bursting transaction  
 
The rising edge FRAME signal (sampled on the positive edge of LCLK) indicates the start of a new transmission. The byte captured on the first positive clock edge of the new packet is B00.  If the FRAME control signal stays high after B13, then the the elink automatically enters “bursting mode”, meaning that the  last byte of the previous transaction (B13) will be followed by B06 of a new transaction.  

Read and write wait signals are used to stall transmission when a receiver is unable to accept more transactions. The receiver will raise its WAIT output signal during an active transmission indicating that it can receive only one more transaction. The wait signal seen by the transmitter is of unspecified phase delay (while still of the LCLK clock period) and therefore has to be sampled with the two-cycle synchronizer.  If the transaction is in the middle of the transmission when the synchronized WAIT control goes high, the transmission process is to be completed without interruption.    
              
###SYSTEM SIDE PROTOCOL  

Communication between the elink and the system side (i.e. the AXI side) is done using 104 bit parallel packet interfaces. Read, write, and read response transactions have independent channels into the elink. Data from a receiver read request is expected to return on the read response transmit channel.   

The "access" signals indicate a valid transaction. The wait signals indicate that the receiving block is not ready to receive the packet. An elink packet has the following bit ordering.  

 PACKET FIELD  | BITS    | DESCRIPTION 
 --------------|---------|----------
 access        | [0]     | Indicates a valid transaction
 write         | [1]     | Indicates a write transaction
 datamode[1:0] | [3:2]   | Datasize (00=8b,01=16b,10=32b,11=64b)
 ctrlmode[3:0] | [7:4]   | Various special modes for the Epiphany chip
 dstraddr[31:0]| [39:8]  | Address for write, read-request, or read-responses
 data[31:0]    | [71:40] | Data for write transaction, data for read response
 srcaddr[31:0] | [103:72]| Return address for read-request, upper data for write

###Clocking and Reset
The elink has the following clock domains:

*sys_clk : used by the axi interfaces  
*rxi_lclk_div4: Used for the erx_core logic  
*txo_lclk_div: Used for the etx_core logic  
*rxi_lclk: Used by the erx_io for clocking in dual data rate data at pins  
*txo_lclk: Used by the etx_io for transmitting dual rate data at pins  
*txo_lclk90: The txo_lclk phase shifted by 90 degrees. Used by RX to sample the dual data rate data.  

    
###INTERFACE SIGNALS
   
SIGNAL            |DIR| DESCRIPTION 
------------------|---|--------------
txo_frame_{p/n}   | O | TX packet framing signal
txo_lclk{p/n}     | O | TX clock aligned in the center of the data eye
txo_data{p/n}[7:0]| O | TX dual data rate (DDR) that transmits packet
txi_rd_wait{p/n}  | I | TX push back (input) for read transactions
txi_wd_wait{p/n}  | I | TX push back (input) for write transactions
rxi_frame{p/n}    | I | RX packet framing signal.
rxi_lclk{p/n}     | I | RX clock aligned in the center of the data eye
rxi_data{p/n}[7:0]| I | RX dual data rate (DDR) that transmits packet
rxo_rd_wait{p/n}  | O | RX push back (output) for read transactions
rxo_wr_wait{p/n}  | O | RX push back (output) for write transactions
reset             | I | Reset input
pll_clk           | I | Clock input for CCLK/LCLK PLL
sys_clk           | I | System clock for FIFOs
embox_not_empty   | O | Mailbox not empty (connect to interrupt line)   
embox_full        | O | Mailbox is full indicator
m_*               |IO | AXI master interface
s_*               |IO | AXI slave interface 

###FPGA RESOURCE USAGE
The following table shows the rough resource usage of the elink structure.
(as of May 12, 2015)  

Instance             |Module                   |Cells 
---------------------|-------------------------|------
  elink              |elink                    |  9809
    ecfg_cdc         |fifo_cdc                 |   994
    eclocks          |eclocks                  |     3
    erx              |erx                      |  5200
      erx_core       |erx_core                 |  2450
        erx_cfg      |erx_cfg                  |   174
        erx_cfgif    |ecfg_if                  |   106
        erx_mailbox  |emailbox                 |   952
        erx_mmu      |emmu_1                   |   233
        erx_protocol |erx_protocol             |   880
        erx_remap    |erx_remap                |   105
      erx_fifo       |erx_fifo                 |  2711
        rxrd_fifo    |fifo_cdc                 |   865
        rxrr_fifo    |fifo_cdc                 |   857
        rxwr_fifo    |fifo_cdc                 |   989
      erx_io         |erx_io                   |    34
    etx              |etx                      |  3596
      etx_core       |etx_core                 |   890
        etx_arbiter  |etx_arbiter              |   197
        etx_cfg      |etx_cfg                  |    61
        etx_cfgif    |ecfg_if                  |   122
        etx_mmu      |emmu                     |   219
        etx_protocol |etx_protocol             |   187
        etx_remap    |etx_remap                |   104
      etx_fifo       |etx_fifo                 |  2685
        txrd_fifo    |fifo_cdc                 |   867
        txrr_fifo    |fifo_cdc                 |   859
        txwr_fifo    |fifo_cdc                 |   959
      etx_io         |etx_io                   |    21

###REGISTER MAP  
 
The full 32 bit physical address of an elink register is the address seen below added to the 12 bit elink ID that maps to address bits 31:20.  As an example, if the elink ID is 0x810, then writing to the E_RESET register would be done to address 0x810F0200. Readback is done through the txrd channel with the source address sub field set to 810Dxxxx;
 
REGISTER       | AC | ADDRESS | DESCRIPTION 
---------------|----|---------|------------------
E_RESET        | -W | 0xF0200 | Soft reset
E_CLK          | -W | 0xF0204 | Clock configuration
E_CHIPID       | RW | 0xF0208 | Chip ID to drive to Epiphany pins
***************|****|*********|********************
E_VERSION      | RW | 0xF020C | Version number (static)
ETX_CFG        | RW | 0xF0210 | TX configuration
ETX_STATUS     | R- | 0xF0214 | TX status
ETX_GPIO       | RW | 0xF0218 | TX data in GPIO mode
ETX_DMACFG     | RW | 0xF0500 | RX DMA configuration
ETX_DMACOUNT   | RW | 0xF0504 | RX DMA count
ETX_DMASTRIDE  | RW | 0xF0508 | RX DMA stride
ETX_DMASRCADDR | RW | 0xF050c | RX DMA source addres
ETX_DMADSTADDR | RW | 0xF0510 | RX DMA slave buffer (lo)
ETX_DMAAUTO0   | RW | 0xF0514 | RX DMA slave buffer (hi)
ETX_DMAAUTO1   | RW | 0xF0518 | RX DMA slave buffer (hi)
ETX_DMASTATUS  | RW | 0xF051c | RX DMA status
***************|****|*********|********************
ETX_MMU        | -W | 0xE0000 | TX MMU table 
***************|****|*********|********************
ERX_CFG        | RW | 0xF0300 | RX configuration
ERX_STATUS     | R- | 0xF0304 | RX status register
ERX_GPIO       | R  | 0xF0308 | RX data in GPIO mode
ERX_OFFSET     | RW | 0xF030C | RX memory offset in remap mode
E_MAILBOXLO    | RW | 0xF0310 | RX mailbox (lower 32 bit)
E_MAILBOXHI    | RW | 0xF0314 | RX mailbox (upper 32 bits)
ERX_DMACFG     | RW | 0xF0520 | TX DMA configuration
ERX_DMACOUNT   | RW | 0xF0524 | TX DMA count
ERX_DMASTRIDE  | RW | 0xF0528 | TX DMA stride
ETX_DMASRCADDR | RW | 0xF052c | TX DMA source addres
ERX_DMADSTADDR | RW | 0xF0530 | TX DMA destination address
ERX_DMAAUTO0   | RW | 0xF0534 | TX DMA slave buffer (lo)
ERX_DMAAUTO1   | RW | 0xF0538 | TX DMA slERXave buffer (hi)
ERX_DMASTATUS  | RW | 0xF053c | TX DMA status      
***************|****|*********|********************
ERX_MMU        | -W | 0xE8000 | RX MMU table 

REGISTER DESCRIPTIONS
===========================================

###E_RESET (0xF0200)
Reset control register for the elink and Epiphany chip

FIELD    | DESCRIPTION 
-------- | --------------------------------------------------
 [0]     | 0: elink is active
         | 1: elink in reset
 [1]     | 0: epiphany chip is active
         | 1: epiphany chip in reset
 [2]     | 1: Starts an internal reset and clock sequnce block
         |    (self resetting bit)

###E_CLK (0xF0204)  
Transmit and Epiphany clock settings.
(NOTE: Current PLL only supports fixed frequency)  
  
FIELD    | DESCRIPTION 
---------| --------------------------------------------------
 [0]     | 0: cclk clock disabled
         | 1: cclk clock enabled 
 [1]     | 0: tx_lclk clock disabled
         | 1: tx_lclk clock enabled 
 [2]     | 0: cclk driven from internal PLL
         | 1: cclk driven from clkbypass[0] input 
 [3]     | 0: lclk driven from internal PLL
         | 1: lclk driven from clkbypass[1] input
 [7:4]   | 0000: cclk=pllclk/1 (MAX)
         | 0001: cclk=pllclk/2
         | 0010: cclk=pllclk/4
         | 0011: cclk=pllclk/8
         | 0100: cclk=pllclk/16
         | 0101: cclk=pllclk/32
         | 0110: cclk=pllclk/64
         | 0111: cclk=pllclk/128 (MIN)
         | 1xxx: RESERVED
 [11:8]  | 0000: lclk=pllclk/1
         | 0001: lclk=pllclk/2
         | 0010: lclk=pllclk/4
         | 0011: lclk=pllclk/8
         | 0100: lclk=pllclk/16
         | 0101: lclk=pllclk/32
         | 0110: lclk=pllclk/64 (not supported yet)
         | 0111: lclk=pllclk/128 (not supported yet)
         | 1xxx: RESERVED        
 [15:12] | PLL frequency (TBD)

###E_CHIPID (0xF0208)
Column and row chip id pins to the Epiphany chip.

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [5:2]   | Column chip  ID for Epiphany chip
 [11:8]  | Row chip ID for Epiphany chip

###E_VERSION
Platform and revision number.

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [7:0]   | Platform version
 [15:8]  | Revision number

###ETX_CFG (0xF020C)
TX configuration settings

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [0]     | 0:  TX disable
         | 1:  TX enable
 [1]     | 0:  MMU disabled
         | 1:  MMU enabled
 [3:2]   | 00: Address remapping disabled
         | 01: TX addr_out = {addr[29:16],|addr[17:16]?11:00,addr[15:0]}
         | 1x: Reserved
 [7:4]   | Epiphany routing control mode bits
         | 0000: Normal routing
         | 0001: Force NORTH routing on address match (instead of "into" core)
         | 0101: Force EAST routing on address match (instead of "into" core)
         | 1001: Force SOUTH routing on address match (instead of "into" core)
         | 1101: Force WEST routing on address match (instead of "into" core)
         | 0011: Multicast routing (LABS)
 [8]     | Control mode select for TXRD/TXWR channels
         | 0: ctrlmode field taken from incoming transmit packet
         | 1: ctrlmode field taken E_TXCFG
 [11:9]  | 00: Normal transmit mode
         | 01: GPIO direct drive mode

###ETX_STATUS (0xF0214)
TX status register

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [15:0]  | TBD

###ETX_GPIO (0xF0218)
Data to drive on txo_data and txo_frame pins in gpio mode
 
FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [7:0]   | Data for txo_data pins
 [8]     | Data for txo_frame pin


###ERX_CFG (0xF0300)
RX configuration register

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [0]     | 0: RX frame signal disabled
         | 1: RX enabled
 [1]     | 0: MMU disabled
         | 1: MMU enabled
 [3:2]   | RX address remapping mode
         | 00: pass-through mode, remapping disabled
         | 01: "static" remap_addr =  
         | (remap_sel[11:0] & remap_pattern[11:0]) |
	 | (~remap_sel[11:0] & addr_in[31:20]); 
         | 10: "dynamic" remap_addr = 
         | addr_in[31:0]
	 | - (colid << 20)
	 | + ERX_OFFSET[31:0]
         | - (addr_in[31:26]<<clog2(colid));
 [15:4]  | Remap selection for "01" remap method 
         | "1" means remap bit is selected
 [27:16] | Remap values (for addr[31:20)
 [29:28] | Read request timeout counter configuration
         | 00: Timeout counter turned off
         | 01: Timeout value set to 000000FF
         | 10: Timeout value set to 0000FFFF
         | 11: Timeout value set to FFFFFFFF

###ERX_STATUS (0xF0304)
RX status register

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [15:0]  | TBD

###ERX_GPIO (0xF0308)
RX status register. Data sampled on  rxi_data and rxi_frame pins in gpio mode

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [7:0]   | Data from rxi_data pins
 [8]     | Data from rxi_frame pin

###ERX_OFFSET (0xF030C)
Address offset used in the dynamic address remapping mode.

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | Memory offset

###E_MAILBOXLO (0xF0310)
Lower 32 bit word of current entry of RX 64-bit wide mailbox FIFO. This register should be read before the E_MAILBOXHI. 

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | Lower data of RX FIFO

###E_MAILBOXHI (0xF0314)
Upper 32 bit word of current entry of RX 64-bit wide mailbox FIFO. Reading this register causes the RX FIFO read pointer to increment by one.

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | Upper data of RX FIFO

###DMACFG (0xF0500/0xF0520)
Configuration register for DMA.

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [0]     | 0: DMA disabled
         | 1: DMA enabled 
 [1]     | 0: Slave mode
         | 1: Master mode
 [6:5]   | 00: byte transfers
         | 01: half-word transfers
         | 10: word transfers
         | 11: double word transfers
 [10]    | 0: Message mode disabled
         | 1: Enables special message mode
 [11]    | 0: Source address shift disabled
         | 1: Left shifts stride by 16 bits
 [12]    | 0: Destination address shift disabled
         | 1: Left shifts stride by 16 bits
         
###DMACOUNT (0xF0504/0xF0524)
The number of DMA left to complete The DMA transfer is complete when the DMACOUNT register reaches zero.

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | The number of transfers remaining

###DMASTRIDE (0xF0508/0xF0528)
Two signed 16-bit values specifying the stride, in bytes, used to update the DMASRCADDR and DMADSTADDR after each completed transfer. 

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [15:0]  | Value to add to DMASRCADDR after each transaction
 [31:16] | Value to add to DMADSTADDR after each transaction

###DMASRCADDR (0xF050C/0xF052C)
The current 32-bit address being read from in master mode.

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | Current transaction destination address to write to

###DMADSTADDR (0xF0510/0xF0530)
The current 32-bit address being transferred.

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | Current transaction destination address to write to



###DMAAUTO0 (0xF0514/0xF0534)
Auto DMA register

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | TBD


###DMAAUTO1 (0xF0518/0xF0538)
Auto DMA register

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | TBD

###DMASTATUS (0xF051c/0xF053c)
DMA status register

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | TBD


###ETX_MMU (0xE0000)
A table of N entries for translating incoming 12 bit address to a new value. Entries are aligned on 8 byte boundaries
 
FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [11:0]  | Output address bits 31:20
 [43:12] | Output address bits 63:32 (TBD)

###ERX_MMU (0xE8000)
A table of N entries for translating incoming 12 bit address to a new value. Entries are aligned on 8 byte boundaries.
 
FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [11:0]  | Output address bits 31:20
 [43:12] | Output address bits 63:32 (TBD)

###ERX_READBACK (0xDxxxx)
Source address to specify for slave (host) read requests
 