ELINK INTRODUCTION
=====================================
The "elink" is a low-latency/high-speed interface for communicating between 
FPGAs and ASICs (such as Epiphany) that uses 24 signals for full duplex 
communication. The interface can achieve a peak throughput of 8 Gbit/s (duplex)
in modern FPGAs using differential LVDS signaling.
    
###I/O INTERFACE
   
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



###SYSTEM SIDE INTERFACE

SIGNAL            |DIR| DESCRIPTION 
------------------|---|--------------
reset             | I | Reset input
clkin             | I | Clock input for CCLK/LCLK PLL
sys_clk           | I | System clock for FIFOs
clkbypass[2:0]    | I | Clocks inputs for bypassing PLL
testmode          | I | Puts elink transmitter in test mode
rx_lclk_div4      | O | rxi_lclk clock divided by 4
tx_lclk_div4      | O | txo_lclk clock divided by 4
embox_not_empty   | O | Mailbox not empty (connect to interrupt line)   
embox_full        | O | Mailbox is full indicator
timeout           | O | Read request timeout indicator
txwr_access       | I | TX write  
txwr_packet[103:0]| I | TX write packet
txwr_wait         | O | TX write wait (pushback)
txrd_access       | I | TX read  
txrd_packet[103:0]| I | TX read packet
txrd_wait         | O | TX read wait (pushback)
txrr_access       | I | TX read-response 
txrr_packet[103:0]| I | TX read-response packet
txrr_wait         | O | TX read-response wait (pushback)
rxwr_access       | O | RX write  
rxwr_packet[103:0]| O | RX write packet
txwr_wait         | I | RX write write (pushback)
rxrd_access       | O | RX read  
rxrd_packet[103:0]| O | RX read packet
rxrd_wait         | I | RX read wait (pushback)
rxrr_access       | O | RX read-response 
rxrr_packet[103:0]| O | RX read-response packet
rxrr_wait         | I | RX read-response wait (pushback)

###EPIPHANY SIGNALS

SIGNAL            |DIR| DESCRIPTION 
------------------|---|-------------- 
cclk_{p/n}        | O | Epiphany differential high speed clock
chip_resetb       | O | Epiphany reset (active low)
chipid[11:0]      | O | Epiphany chip-id selector

The Epiphany specific output signals can be left unconnected in systems that 
don't include Epiphany chips. 

###I/O PROTOCOL 
The default protocol for the elink is the Epiphany chip to chip interface. 
The Epiphany protocol uses a source synchronous clocks, a packet frame signal,
an 8-bit wide dual data rate data bus, and separate read and write packet wait
signals to implement a gluless point to point link.

```
                __     ___     ___     ___     ___     ___     ___     ___ 
 LCLK     \___/   \___/   \___/   \___/   \___/   \___/   \___/   \___/
           _______________________________________________________________
 FRAME   _/                                                        \______ 
               
 DATA   XXXX|B00|B01|B02|B03|B04|B05|B06|B07|B08|B09|B10|B11|B12|B13|B14.

```
           
BYTE     | DESCRIPTION 
---------|--------------
B00      | 00000000
B01      | {ctrlmode[3:0],dstaddr[31:28]}
B02      | dstaddr[27:20]
B03      | dstaddr[19:12]
B04      | dstaddr[11:4]
B05      | {dstaddr[3:0],datamode[1:0],write,access}
+B06     | data[31:24] / srcaddr[31:24]
+B07     | data[23:16] / srcaddr[23:16]
+B08     | data[15:8] / srcaddr[15:8]
+B09     | data[7:0] / srcaddr[7:0]
++B10    | data[63:56]  
B11      | data[55:48]  
B12      | data[47:40]  
B13      | data[39:32]  
+++B14   | data[31:24] in 64 bit write burst mode only
B15      | data[23:16] in 64 bit write burst mode only
...      | ...

+B01-B06: srcaddr used for read request, otherwise data
++B09: is the last byte of 32 bit write or read transaction  
+++B14: is the first data byte of bursting transaction  
 
The data captured  on the rising edge of the LCLK is considered to be B0 if 
the FRAME control captured at the same cycle is high but was low at the rising
edge of the previous LCLK cycle (ie rising edge). If the FRAME control signal
stays high after B13, then the the eLink goes into “bursting mode”, meaning 
that the  last byte of the previous transaction (B13) will be followed by B06
of a new transaction.  

The data is transmitted MSB first but in 32bits resolution. If we want to 
transmit 64 bits it will be bits 31:0 (msb first) and then 63:32 (msb first)  

The wait signals are used to stall transmission when a receiver is unable to 
accept more transactions. The receiver will raise its WAIT output signal during
an active transmission indicating that it can receive only one more transaction.
The wait signal seen by the transmitter is assumed to be of the unspecified 
phase delay (while still of the LCLK clock period) and therefore has to be 
sampled with the two-cycle synchronizer. Once synchronized to the transmitter's
LCLK clock domain, the WAIT control signals will prevent new transaction from 
being transmitted. If the transaction is in the middle of the transmission when
the synchronized WAIT control goes high, the transmission process is to 
completed without interruption.  
              
###SYSTEM SIDE PROTOCOL  

Communication between the elink and the system side (i.e. the AXI side) is done
using the rx and tx parallel interfaces. Read, write, and read response 
transactions have independent channels into the elink. Data from a receiver 
read request is expected to return on the read response transmit chanel.   

The "access" signals indicate a valid transaction. The wait signals indicate 
that the receiving block is not ready to receive the packet. An elink packet 
has the following bit ordering.  

 PACKET FIELD  | BITS    | DESCRIPTION 
 --------------|---------|----------
 access        | [0]     | Indicates a valid transaction
 write         | [1]     | Indicates a write transaction
 datamode[1:0] | [3:2]   | Datasize (00=8b,01=16b,10=32b,11=64b)
 ctrlmode[3:0] | [7:4]   | Various special modes for the Epiphany chip
 dstraddr[31:0]| [39:8]  | Address for write, read-request, or read-responses
 data[31:0]    | [71:40] | Data for write transaction, data for read response
 srcaddr[31:0] | [103:72]| Return address for read-request, upper data for write

###INTERNAL STRUCTURE
```
elink
 |----ereset
 |----ecfg_clocks
 |----eclocks
 |----ecfg_cdc
 |----erx
 |     |----erx_io (chip level I/O interface
 |     |----erx_protocol (elink protocol-->emesh packet converter)
 |     |----erx_remap (simple dstaddr remapping)
 |     |----erx_mmu (advanced dstaddr mapping)
 |     |----erx_cfgif (configuration interface)
 |     |----erx_cfg (basic rx config registers)
 |     |----erx_mailbox (fifo mailbox)
 |     |----erx_dma (DMA master)
 |     |----erx_disty (sends rx transaction to WR/RD/RR fifo)
 |     |----rxwr_fifo (write fifo)
 |     |----rxrd_fifo (read request fifo)
 |     |----rxrr_fifo (read response fifo)
 |----etx
 |     |----etx_io (chip level I/O interface)
 |     |----etx_protocol (emesh-->elink protocol converter)
 |     |----etx_remap (simple dstaddr remapping)
 |     |----etx_mmu (advanced dstaddr mapping)
 |     |----etx_cfgif (configuration interface)
 |     |----etx_cfg (basic rx config registers)
 |     |----etx_dma (DMA master)
 |     |----etx_arbiter (sends rx transaction to WR/RD/RR fifo)
 |     |----txwr_fifo (write fifo)
 |     |----txrd_fifo (read request fifo)
 |     |----txrr_fifo (read response fifo)
 |--------------------------------------------------------------------
```

###REGISTER MAP  
 
The full 32 bit physical address of an elink register is the address seen below
added to the 12 bit elink ID that maps to address bits 31:20.  As an example,
if the elink ID is 0x810, then writing to the E_RESET register would be done to 
address 0x810D0000.
 
REGISTER       | AC | ADDRESS | DESCRIPTION 
---------------|----|---------|------------------
E_RESET        | -W | 0xF0200 | Soft reset
E_CLK          | -W | 0xF0204 | Clock configuration
***************|****|*********|********************
E_CHIPID       | RW | 0xF0208 | Chip ID to drive to Epiphany pins
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
ETX_DMADESCR0  | RW | 0xF0580 | RX DMA {reserved,config}
ETX_DMADESCR1  | RW | 0xF0584 | TX DMA {dst_stride[15:0],src_stride[15:0]}      
ETX_DMADESCR2  | RW | 0xF0588 | TX DMA {reserved,count[15:0]}
ETX_DMADESCR3  | RW | 0xF058c | TX reserved
ETX_DMADESCR4  | RW | 0xF0590 | TX DMA srcaddr[31:0]
ETX_DMADESCR5  | RW | 0xF0594 | TX DMA dstaddr[31:0]
***************|****|*********|********************
ETX_MMU        | -W | 0xE0000 | TX MMU table 
***************|****|*********|********************
ERX_CFG        | RW | 0xF0300 | RX configuration
ERX_STATUS     | R- | 0xF0304 | RX status register
ERX_GPIO       | R  | 0xF0308 | RX data in GPIO mode
ERX_RR         | RW | 0xF030c | RX read response address
ERX_OFFSET     | RW | 0xF0310 | RX memory offset in remap mode
ERX_MAILBOXLO  | RW | 0xF0314 | RX mailbox (lower 32 bit)
ERX_MAILBOXHI  | RW | 0xF0318 | RX mailbox (upper 32 bits)
ERX_DMACFG     | RW | 0xF0520 | TX DMA configuration
ERX_DMACOUNT   | RW | 0xF0524 | TX DMA count
ERX_DMASTRIDE  | RW | 0xF0528 | TX DMA stride
ETX_DMASRCADDR | RW | 0xF050c | TX DMA source addres
ERX_DMADSTADDR | RW | 0xF0530 | TX DMA destination address
ERX_DMAAUTO0   | RW | 0xF0534 | TX DMA slave buffer (lo)
ERX_DMAAUTO1   | RW | 0xF0538 | TX DMA slERXave buffer (hi)
ERX_DMASTATUS  | RW | 0xF053c | TX DMA status      
ERX_DMADESCR0  | RW | 0xF05A0 | RX DMA {reserved,config}       
ERX_DMADESCR1  | RW | 0xF05A4 | RX DMA {dst_stride[15:0],src_stride[15:0]}      
ERX_DMADESCR2  | RW | 0xF05A8 | RX DMA {reserved,count[15:0]}
ERX_DMADESCR3  | RW | 0xF05B0 | RX DMA srcaddr[31:0]
ERX_DMADESCR5  | RW | 0xF05B4 | RX DMA dstaddr[31:0]
***************|****|*********|********************
ERX_MMU        | -W | 0xE8000 | RX MMU table 

REGISTER DESCRIPTIONS
===========================================

###E_RESET
Reset control register for the elink and Epiphany chip

FIELD    | DESCRIPTION 
-------- | --------------------------------------------------
 [0]     | 0: elink is active
         | 1: elink in reset
 [1]     | 0: epiphany chip is active
         | 1: epiphany chip in reset
 [2]     | 1: Starts an internal reset and clock sequnce block
         |    (self resetting bit)

###E_CLK (LABS)
Transmit and Epiphany clock settings.
(NOTE: not currently implemented)  
  
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
 [7:4]   | 0000: cclk=pllclk/1
         | 0001: cclk=pllclk/2
         | 0010: cclk=pllclk/4
         | 0011: cclk=pllclk/8
         | 0100: cclk=pllclk/16
         | 0101: cclk=pllclk/32
         | 0110: cclk=pllclk/64
         | 0111: cclk=pllclk/128
         | 1xxx: RESERVED
 [11:8]  | 0000: lclk=pllclk/1
         | 0001: lclk=pllclk/2
         | 0010: lclk=pllclk/4
         | 0011: lclk=pllclk/8
         | 0100: lclk=pllclk/16
         | 0101: lclk=pllclk/32
         | 0110: lclk=pllclk/64
         | 0111: lclk=pllclk/128
         | 1xxx: RESERVED        
 [15:12] | PLL frequency (TBD)


###E_CHIPID
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

###ETX_CFG
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
         | 10: Enables test pattern generator for IO (LABS)

###ETX_STATUS
TX status register

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [15:0]  | TBD

###ETX_GPIO
Data to drive on txo_data and txo_frame pins in gpio mode
 
FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [7:0]   | Data for txo_data pins
 [8]     | Data for txo_frame pin

###ETX_MMU
A table of N entries for translating incoming 12 bit address
to a new value. Entries are aligned on 8 byte boundaroies
 
FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [11:0]  | Output address bits 31:20
 [43:12] | Output address bits 63:32 (TBD)

###ERX_CFG
RX configuration register

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [0]     | 0: RX disabled
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

###ERX_STATUS
RX status register

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [15:0]  | TBD

###ERX_GPIO
RX status register
Data sampled on  rxi_data and rxi_frame pins in gpio mode

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [7:0]   | Data from rxi_data pins
 [8]     | Data from rxi_frame pin

###ERX_RR
Last read response data that was received on rxrr_packet[103:0].  

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | Read response data (lower 32 bits)

###ERX_OFFSET
Address offset used in the dynamic address remapping mode.

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | Memory offset

###ERX_MAILBOXLO
Lower 32 bit word of current entry of RX 64-bit wide mailbox FIFO. This 
register should be read before the ERX_MAILBOXHI. 

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | Lower data of RX FIFO

###ERX_MAILBOXHI
Upper 32 bit word of current entry of RX 64-bit wide mailbox FIFO. Reading this
register causes the RX FIFO read pointer to increment by one.

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | Upper data of RX FIFO

###DMACFG
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
         
###DMACOUNT
The number of DMA left to complete The DMA transfer is complete when the 
DMACOUNT register reaches zero.

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | The number of transfers remaining

###DMADSTADDR
The current 32-bit address being transferred.

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | Current transaction destination address to write to

###DMASRCADDR
The current 32-bit address being read from in master mode.

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | Current transaction destination address to write to


###DMASTRIDE
Two signed 16-bit values specifying the stride, in bytes, used to update the 
DMASRCADDR and DMADSTADDR after each completed transfer. 

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [15:0]  | Value to add to DMASRCADDR after each transaction
 [31:16] | Value to add to DMADSTADDR after each transaction

###DMASTRIDE
Status of DMA

FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [31:0]  | TBD

###ERX_MMU
A table of N entries for translating incoming 12 bit address to a new value. 
Entries are aligned on 8 byte boundaries.
 
FIELD    | DESCRIPTION 
-------- |---------------------------------------------------
 [11:0]  | Output address bits 31:20
 [43:12] | Output address bits 63:32 (TBD)
