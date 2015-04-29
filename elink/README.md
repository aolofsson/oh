###DESCRIPTION
The "elink" is a low-latency/high-speed interface for communicating between 
FPGAs and ASICs (such as Epiphany). The interface "should" achieve a peak 
throughput of 8 Gbit/s (duplex) in modern FPGAs using 24 available LVDS signal 
pairs.
  
###ELINK I/O Interface  
   
SIGNAL            |DIR| DESCRIPTION 
------------------|---|--------------
txo_frame_{p/n}   | O | TX packet framing signal.
txo_lclk{p/n}     | O | TX clock aligned in the center of the data eye
txo_data{p/n}[7:0]| O | TX dual data rate (DDR) that transmits packet
txi_rd_wait{p/n}  | I | TX push back (input) for read transactions
txi_wd_wait{p/n}  | I | TX push back (input) for write transactions
rxi_frame{p/n}    | I | RX packet framing signal.
rxi_lclk{p/n}     | I | RX clock aligned in the center of the data eye
rxi_data{p/n}[7:0]| I | RX dual data rate (DDR) that transmits packet
rxo_rd_wait{p/n}  | O | RX push back (output) for read transactions
rxo_wr_wait{p/n}  | O | RX push back (output) for write transactions
hard_reset        | I | Reset input
clkin             | I | Clock input for CCLK/LCLK PLL
clkbypass[2:0]    | I | Clocks inputs for bypassing PLL
cclk_{p/n}        | O | Differential clock output for Epiphany  
chip_resetb       | O | Reset for Epiphany (active low)
colid[3:0]        | O | Column chip coordinate pins for Epiphany 
rowid[3:0]        | O | Row chip coordinate pins for Epiphany 
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

###ELINK I/O PROTOCOL  
The default protocol for the elink is the Epiphany chip to chip interface. 
The Epiphany protocol uses a source synchronous clocks, a packet frame signal,
an 8-bit wide dual data rate data bus, and separate read and write packet wait
signals to implement a gluless point to point link.

        __     ___     ___     ___     ___     ___     ___     ___     ___
 LCLK     \___/   \___/   \___/   \___/   \___/   \___/   \___/   \___/
           _______________________________________________________________
 FRAME   _/                                                        \______ 
               
 DATA   XXXX|B00|B01|B02|B03|B04|B05|B06|B07|B08|B09|B10|B11|B12|B13|B14.
           
BYTE     | DESCRIPTION 
---------|--------------
B00      | 00000000
B01      | ctrlmode[3:0],dstaddr[31:28]
B02      | dstaddr[27:20]
B03      | dstaddr[19:12]
B04      | dstaddr[11:4]
B05      | dstaddr[3:0],datamode[1:0],write,access
B06      | data[31:24] (or srcaddr[31:24] if read transaction)
B07      | data[23:16] (or srcaddr[23:16] if read transaction)
B08      | data[15:8]  (or srcaddr[15:8]  if read transaction)
B09      | data[7:0]   (or srcaddr[7:0]   if read transaction)
*B10     | data[63:56]  
B11      | data[55:48]  
B12      | data[47:40]  
B13      | data[39:32]  
**B14    | data[31:24]  (in 64 bit write burst mode)
B15      | data[23:16]  (in 64 bit write burst mode)
...      | ...

* byte9 is the last byte of 32 bit write or read transaction 
   
** if 64 bit write transaction, data of byte14 is the first data byte of
   bursting transaction
 
The data captured  on the rising edge of the LCLK is considered to be B0 if 
the FRAME control captured at the same cycle is high but was low at the rising
edge of the previous LCLK cycle (ie rising edge). If the FRAME control signal
stays high after B13, then the the eLink goes into “bursting mode”, meaning 
that the  last byte of the previous transaction (B13) will be followed by B06
of a new transaction.

The data is transmitted MSB first but in 32bits resolution. If we want to 
transmit 64 bits it will be [31:0] (msb first) and then [63:32] (msb first)

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
              
###BUS PROTOCOL  
Communication between the elink and the system side (i.e. the AXI side) is done
using the rx and tx parallel interfaces. Read, write, and read response 
transactions have independent channels into the elink. Data from a receiver 
read request is expected to return on the read response transmit chanel.   

The "access" signals indicate a valid transaction. The wait signals indicate
that the receiving block is not ready to receive the packet. 

The elink packets haave the following bit ordering.

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

(link) 
 
###ELINK REGISTER MAP  
 
The elink has a 12 bit ID that maps to address bits [31:20].
As an example, if the ID is set to 0x810, then writing to the E_RESET 
register would be done to address 0x810E0040
 
REGISTER       | ADDRESS | DESCRIPTION 
---------------|---------|------------------
E_RESET        | 0xD0000 | Soft reset
E_CLK          | 0xD0004 | Clock configuration
E_CHIPID       | 0xD0008 | Chip ID to drive to Epiphany pins
E_VERSION      | 0xD000C | Version number
ETX_CFG        | 0xD0040 | TX configuration
ETX_STATUS     | 0xD0044 | TX status
ETX_GPIO       | 0xD0048 | TX data in GPIO mode
ETX_TEST       | 0xD0050 | TX test mode configuration
ETX_DSTADDR    | 0xD0054 | TX destination address for test mode
ETX_DATA       | 0xD0058 | TX data for test mode
ETX_SRCADDR    | 0xD005c | TX return address for read in test mode
ETX_MMU        | 0xD8000 | TX MMU table 
ERX_CFG        | 0xE0000 | RX configuration
ERX_STATUS     | 0xE0004 | RX status register
ERX_GPIO       | 0xE0008 | RX data in GPIO mode
ERX_RRR        | 0xE000c | RX read response address
ERX_OFFSET     | 0xE0000 | RX memory offset in remap mode
ERX_MAILBOXLO  | 0xE0040 | RX mailbox (lower 32 bit)
ERX_MAILBOXHI  | 0xE0044 | RX mailbox (upper 32 bits)
ERX_DMACFG     | 0xE0080 | RX DMA configuration
ERX_DMACOUNT   | 0xE0084 | RX DMA count
ERX_DMASTRIDE  | 0xE0088 | RX DMA stride
ERX_DMASRCADDR | 0xE008c | RX DMA source addres
ERX_DMADSTADDR | 0xE0090 | RX DMA destination address
ERX_DMASTATUS  | 0xE0094 | RX DMA status
ERX_MMU        | 0xE8000 | RX MMU table 

          
###ELINK REGISTER DESCRIPTIONS
 REGISTER   | DESCRIPTION 
 ---------- | --------------------------------------------------
 ELRESET    | (elink reset register)
 [0]        | 0:  elink is active
            | 1:  elink in reset
 ---------- |---------------------------------------------------
 ELTX       | (elink transmit configuration register)
 [0]        | 0:  TX disable
            | 1:  TX enable
 [1]        | 0:  static address translation
            | 1:  enables MMU based address translation
 [3:2]      | 00: default elink packet transfer mode
            | 01: forces values from ESYSDATAOUT on output pins
            | 1x: reserved
 [7:4]      | Transmit control mode for eMesh
 [8]        | AXI slave read timeout enable
 -----------|----------------------------------------------------
 ELRX       | (elink receive configuration register)
 [0]        | 0:  elink RX disable
            | 1:  elink RX enable
 [1]        | 0:  static address translation
            | 1:  enables MMU based address translation
 [3:2]      | 00: default elink packet receive mode
            | 01: stores input pin data in ESYSDATAIN register
            | 1x: reserved
 -----------|---------------------------------------------------
 ELCLK      | (elink PLL configuration register)
 [0]        | 0:cclk clock disabled
            | 1:cclk clock enabled 
 [1]        | 0:tx_lclk clock disabled
            | 1:tx_lclk clock enabled 
 [2]        | 0: cclk driven from internal PLL
            | 1: cclk driven from clkbypass[2:0] input 
 [3]        | 0: lclk driven from internal PLL
            | 1: lclk driven from clkbypass[2:0] input   
 [7:4]      | 0000: cclk=pllclk/1
            | 0001: cclk=pllclk/2
            | 0010: cclk=pllclk/4
            | 0011: cclk=pllclk/8
            | 0100: cclk=pllclk/16
            | 0101: cclk=pllclk/32
            | 0110: cclk=pllclk/64
            | 0111: cclk=pllclk/128
            | 1xxx: RESERVED
 [11:8]     | 0000: lclk=pllclk/1
            | 0001: lclk=pllclk/2
            | 0010: lclk=pllclk/4
            | 0011: lclk=pllclk/8
            | 0100: lclk=pllclk/16
            | 0101: lclk=pllclk/32
            | 0110: lclk=pllclk/64
            | 0111: lclk=pllclk/128
            | 1xxx: RESERVED        
 [15:12]    | PLL frequency
 -----------|-------------------------------------------------
 ELCOREID   | (coordinate ID for Epiphany)
 [5:0]      | Column ID for connected Epiphany chip
 [11:6]     | Row ID for connected Epiphany chip  
 -----------|-------------------------------------------------
 ELVERSION  | (platform and version ID)
 [7:0]      | Platform model number
 [7:0]      | Revision number
 -----------|-------------------------------------------------
 EDATAIN    | (data on elink input pins)
 [7:0]      | rx_data[7:0]         
 [8]        | tx_frame
 [9]        | tx_wait_rd
 [10]       | tx_wait_wr
 -----------|-------------------------------------------------

