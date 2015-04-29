/*

 ###DESCRIPTION
 The "elink" is a low-latency/high-speed interface for communicating between 
 FPGAs and ASICs (such as Epiphany). The interface "should" achieve a peak throughput of 
 8 Gbit/s (duplex) in modern FPGAs using 24 available LVDS signal pairs.  
 
 ###ELINK INTERFACE I/O SIGNALS
   
  SIGNAL         |DIR| DESCRIPTION 
  ---------------|---|--------------
  txo_frame      | O | TX Packet framing signal.
  txo_lclk       | O | TX A clock aligned in the center of the data eye
  txo_data[7:0]  | O | TX Dual data rate (DDR) that transmits packet
  txi_rd_wait    | I | TX Push back (input) for read transactions
  txi_wd_wait    | I | TX Push back (input) for write transactions
  rxi_frame      | I | RX Packet framing signal. Rising edge signals new packet.
  rxi_lclk       | I | RX A clock aligned in the center of the data eye
  rxi_data[7:0]  | I | RX Dual data rate (DDR) that transmits packet
  rxo_rd_wait    | O | RX Push back (output) for read transactions
  rxo_wr_wait    | O | RX Push back (output) for write transactions
  m_axi*         | - | AXI master interface
  s_axi*         | - | AXI slave interface
  hard_reset     | I | Reset input
  clkin          | I | Input clock for PLL
  clkbypass[2:0] | I | Input clocks for bypassing PLL
  cclk_n/cclk_p  | O | Differential clock output for Epiphany  
  chip_resetb    | O | Reset for Epiphany
  colid[3:0]     | O | Column coordinate pins for Epiphany 
  rowid[3:0]     | O | Row coordinate pins for Epiphany 
  embox_not_empty| O | Mailbox not empty (connect to interrupt line)   
  embox_full     | O | Mailbox is full indicator
 
 ###SYSTEM INTERFACE

 
 The elink has a 64 bit data AXI master and 32-bit data AXI slave interface 
 for connecting to a standard AXI network.
 
 ###EMESH PACKET
 
 PACKET SUBFIELD | DESCRIPTION 
 ----------------|----------------
 access          | Indicates a valid packet
 write           | A write transaction. Access & ~write indicates a read.
 datamode[1:0]   | Datasize (00=8b,01=16b,10=32b,11=64b)
 ctrlmode[3:0]   | Various packet modes for the Epiphany chip
 dstraddr[31:0]  | Address for write, read-request, or read-responses
 data[31:0]      | Data for write transaction, return data for read response
 srcaddr[31:0]   | Return address for read-request, upper data for 64 bit write
 
 ###PACKET-FORMAT:
 
 The elink was born out of a need to connect multiple Epiphany chips together
 and uses the eMesh 104 bit atomic packet structure for communication. 
 The eMesh atomic packet consists of the following sub fields.

 
 ###FRAMING:
  
 The number of bytes to be received is determined by the data of the first 
 “valid” byte (byte0) and the level of the FRAME signal. The data captured 
 on the rising edge of the LCLK is considered to be byte0 if the FRAME control
 captured at the same cycle is high but was low at the rising edge of the 
 previous LCLK cycle (ie rising edge).  The cycle after the last byte of the 
 transaction (byte8 or byte12) will determine if the receiver should go into 
 data streaming mode based on the level of the FRAME control signal. If the 
 FRAME signal is low, the transaction is complete. If the FRAME control 
 signal stays high, the eLink goes into “streaming mode”, meaning that the 
 last byte of the previous transaction (byte8 or byte12) will be followed 
 by byte5 of the new transaction. 
 
 ###PUSHBACK:
 
 The WAIT_RD and WAIT_WR signals are used to stall transmission when a receiver
 is unable to accept more transactions. The receiver will raise its WAIT output
 signal on the second rising edge of LCLK input following the capturing rising
 edge of the last transaction byte (byte8 or byte12) but will be ready to 
 accept one more full transaction (byte0 through byte8/byte12). The WAIT 
 signal seen by the transmitter is assumed to be of the “unspecified” phase 
 delay (while still of the LCLK clock period) and therefore has to be sampled
 with the two-cycle synchronizer. Once synchronized to the transmitter's LCLK 
 clock domain, the WAIT control signals will prevent new transaction from 
 being transmitted. If the transaction is in the middle of the transmission 
 when the synchronized WAIT control goes high, the transmission process is to 
 be completed without interruption. The txo_* interface driven out from the 
 E16G301 uses a divided version of the core cock frequency (RXI_WE_CCLK_{P,N}).
 The transmit clock is automatically aligned in the middle of the data eye 
 by the eLink on chip transmit logic. The receiver logic assumes the clock is 
 aligned at the center of the receiver data eye. The “wait” signals are used 
 to indicate to the transmit logic that no more transactions can be received 
 because the receiver buffer full. 
 
 ###ELINK MEMORY MAP
 
 Each elink has a 12 bit ID that that gets matched to bits [31:20] of the 
 incoming address.
 
 ESYSRX      | 0xF0008 | Elink receiver config
 ESYSCLK     | 0xF000C | Clock config
 ESYSCOREID  | 0xF0010 | ID to drive to Epiphany chip
 ESYSVERSION | 0xF0014 | Platform version
 ESYSDATAIN  | 0xF0018 | Direct data from elink receiver
 ESYSDATAOUT | 0xF001C | Direct data for elink transmitter
 ESYSDEBUG   | 0xF0020 | Various debug signals
 EMBOXLO     | 0xC0004 | Lower 32 bits of 64 bit wide mail box fifo
 EMBOXHI     | 0xC0008 | Upper 32 bits of 64 bit wide mail box fifo
 ESYSMMURX   | 0xE0000 | Start of receiver MMU lookup table
 ESYSMMUTX   | 0xD0000 | Start of transmit MMU lookup table (tbd)
          
 ###ELINK CONFIGURATION REGISTERS

 
 REGISTER   | ADDR | DESCRIPTION 
 ---------- | --------------
 ESYSRESET  | (elink reset register)
 [0]        | 0:  elink is active
            | 1:  elink in reset
 ---------- |-------------------
 ESYSTX     | (elink transmit configuration register)
 [0]        | 0:  TX disable
            | 1:  TX enable
 [1]        | 0:  static address translation
            | 1:  enables MMU based address translation
 [3:2]      | 00: default elink packet transfer mode
            | 01: forces values from ESYSDATAOUT on output pins
            | 1x: reserved
 [7:4]      | Transmit control mode for eMesh
 [8]        | AXI slave read timeout enable
 ---------- |-------------------
 ESYSRX     | (elink receive configuration register)
 [0]        | 0:  elink RX disable
            | 1:  elink RX enable
 [1]        | 0:  static address translation
            | 1:  enables MMU based address translation
 [3:2]      | 00: default elink packet receive mode
            | 01: stores input pin data in ESYSDATAIN register
            | 1x: reserved
 ---------- |-------------------
 ESYSCLk    | (elink PLL configuration register)
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
 ---------- |-------------------
 ESYSCOREID | (coordinate ID for Epiphany)
 [5:0]      | Column ID for connected Epiphany chip
 [11:6]     | Row ID for connected Epiphany chip  
 -------------------------------------------------------------
 ESYSLATFORM| (platform ID)
 [7:0]      | Platform model number
 [7:0]      | Revision number
 -------------------------------------------------------------
 ESYSDATAIN | (data on elink input pins)
 [7:0]      | rx_data[7:0]         
 [8]        | tx_frame
 [9]        | tx_wait_rd
 [10]       | tx_wait_wr
 -------------------------------------------------------------
 ESYSDATAOUT| (data on eLink output pins)
 [7:0]      | tx_data[7:0]         
 [8]        | tx_frame
 [9]        | rx_wait_rd
 [10]       | rx_wait_wr
 -------------------------------------------------------------


###INTERNAL STRUCTURE
```
elink               -  Top level level AXI elink peripheral  
  etx               -  Elink transmit block
      ecfg_tx       -  TX config
      etx_io        -  Converts packet to high speed serial
      etx_protocol  -  Creates an elink transaction packet
      etx_arbiter   -  Selects one of three AXI traffic sources (rd, wr, rr)
      emmu          -  Translates the dstaddr of incoming transaction  
      txrd_fifo     -  Read request fifo for slave AXI interface
      txwr_fifo     -  Write request fifo for slave AXI interface
      txrr_fifo     -  Read response fifo for master AXI interface 
  erx               -  Elink receiver block
      ecfg_rx       -  RX config
      etx_io        -  Converts serial packet received to parallel
      etx_protocol  -  Converts the elink packet to 104 bit emesh packet
      etx_disty     -  Distributes emesh packet to correct fifo
      emmu          -  Translates the dstaddr of incoming packet  
      emailbox      -  Mailbox with interrupt output
      edma         -   Master DMA for rxrd_fifo
      rxrd_fifo     -  Read request fifo for master AXI interface
      rxwr_fifo     -  Write request fifo for master AXI interface
      rxrr_fifo     -  Read response fifo for slave AXI interface 
  ecfg_base         -  General elink config
  eclocks           -  PLL/clock generator
  ereset            -  Reset generator

 */

module elink(/*AUTOARG*/
   // Outputs
   mi_tx_we, mi_tx_mmu_en, mi_tx_din, mi_tx_cfg_en, mi_tx_addr,
   mi_rx_we, mi_rx_mmu_en, mi_rx_dma_en, mi_rx_din, mi_rx_cfg_en,
   mi_rx_addr, rx_lclk_div4, tx_lclk_div4, colid, rowid, chip_resetb,
   cclk_p, cclk_n, rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p,
   rxo_rd_wait_n, txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n,
   txo_data_p, txo_data_n, mailbox_not_empty, mailbox_full, timeout,
   rxwr_access, rxwr_packet, rxrd_access, rxrd_packet, rxrr_access,
   rxrr_packet, txwr_wait, txrd_wait, txrr_wait,
   // Inputs
   mi_txmmu_en, mi_txcfg_en, mi_rxmmu_en, mi_rxcfg_en, mi_dma_en,
   hard_reset, clkin, clkbypass, rxi_lclk_p, rxi_lclk_n, rxi_frame_p,
   rxi_frame_n, rxi_data_p, rxi_data_n, txi_wr_wait_p, txi_wr_wait_n,
   txi_rd_wait_p, txi_rd_wait_n, sys_clk, mi_en, mi_we, mi_addr,
   mi_din, mi_dout, rxwr_wait, rxrd_wait, rxrr_wait, txwr_access,
   txwr_packet, txrd_access, txrd_packet, txrr_access, txrr_packet
   );
   
   parameter AW          = 32;
   parameter DW          = 32; 
   parameter PW          = 104;      //packet width   
   parameter ID          = 12'h810;

   /****************************/
   /*CLK AND RESET             */
   /****************************/
   input        hard_reset;          // active high synhcronous hardware reset
   input 	clkin;               // clock for pll
   input [2:0] 	clkbypass;           // bypass clocks for elinks w/o pll
   output 	rx_lclk_div4;        // rxi_lclk clock divided by 4
   output 	tx_lclk_div4;        // txo_lclk clock divided by 4
   
   /********************************/
   /*EPIPHANY INTERFACE (I/O PINS) */
   /********************************/          

   //Basic
   output [3:0] colid;                //epiphany colid
   output [3:0] rowid;                //epiphany rowid
   output 	chip_resetb;          //chip reset for Epiphany (active low)
   output 	cclk_p, cclk_n;       //high speed clock (1GHz) to Epiphany

   //Receiver
   input        rxi_lclk_p,  rxi_lclk_n;     //link rx clock input
   input        rxi_frame_p,  rxi_frame_n;   //link rx frame signal
   input [7:0] 	rxi_data_p,   rxi_data_n;    //link rx data
   output       rxo_wr_wait_p,rxo_wr_wait_n; //link rx write pushback output
   output       rxo_rd_wait_p,rxo_rd_wait_n; //link rx read pushback output
   
   //Transmitter
   output       txo_lclk_p,   txo_lclk_n;    //link tx clock output
   output       txo_frame_p,  txo_frame_n;   //link tx frame signal
   output [7:0] txo_data_p,   txo_data_n;    //link tx data
   input 	txi_wr_wait_p,txi_wr_wait_n; //link tx write pushback input
   input 	txi_rd_wait_p,txi_rd_wait_n; //link tx read pushback input

   /*****************************/
   /*MAILBOX (interrupts)       */
   /*****************************/
   output       mailbox_not_empty;   
   output       mailbox_full;

   /*****************************/tx
   /*READBACK TIMEOUT           */
   /*****************************/
   output 	timeout;

   /*****************************/
   /*"System" Interface         */
   /*****************************/   
   //One clock to rule them all..
   input 	   sys_clk;

   //Primary configuration interface
   input 	   mi_en;
   input 	   mi_we;  //only 32 aligned accesses allowed
   input [19:0]    mi_addr;//address is complete byte address
   input [31:0]    mi_din;
   input [31:0]    mi_dout;
      
   //Master Write (from RX)
   output 	   rxwr_access;
   output [PW-1:0] rxwr_packet;
   input 	   rxwr_wait;
      
   //Master Read Request (from RX)
   output 	   rxrd_access;
   output [PW-1:0] rxrd_packet;
   input 	   rxrd_wait;
   
   //Slave Read Response (from RX)
   output 	   rxrr_access;
   output [PW-1:0] rxrr_packet;
   input 	   rxrr_wait;

   //Slave Write (to TX)
   input 	   txwr_access;
   input [PW-1:0]  txwr_packet;
   output 	   txwr_wait;

   //Slave Read Request (to TX) 
   input 	   txrd_access;
   input [PW-1:0]  txrd_packet;
   output 	   txrd_wait;
   
   //Master Read Response (to TX)
   input 	   txrr_access;
   input [PW-1:0]  txrr_packet;
   output 	   txrr_wait;
      
   /*#############################################*/
   /*  END OF BLOCK INTERFACE                     */
   /*#############################################*/
   
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		mi_dma_en;		// To erx of erx.v
   input		mi_rxcfg_en;		// To erx of erx.v
   input		mi_rxmmu_en;		// To erx of erx.v
   input		mi_txcfg_en;		// To etx of etx.v
   input		mi_txmmu_en;		// To etx of etx.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [19:0]	mi_rx_addr;		// From ecfg_if of ecfg_if.v
   output		mi_rx_cfg_en;		// From ecfg_if of ecfg_if.v
   output [63:0]	mi_rx_din;		// From ecfg_if of ecfg_if.v
   output		mi_rx_dma_en;		// From ecfg_if of ecfg_if.v
   output		mi_rx_mmu_en;		// From ecfg_if of ecfg_if.v
   output		mi_rx_we;		// From ecfg_if of ecfg_if.v
   output [19:0]	mi_tx_addr;		// From ecfg_if of ecfg_if.v
   output		mi_tx_cfg_en;		// From ecfg_if of ecfg_if.v
   output [63:0]	mi_tx_din;		// From ecfg_if of ecfg_if.v
   output		mi_tx_mmu_en;		// From ecfg_if of ecfg_if.v
   output		mi_tx_we;		// From ecfg_if of ecfg_if.v
   // End of automatics

   //wires
   wire [31:0] 	 mi_rd_data;
   wire [31:0] 	 mi_dout_ecfg;
   wire [31:0] 	 mi_dout_embox;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]		ecfg_clk_settings;	// From ecfg_base of ecfg_base.v
   wire			etx_read;		// From etx of etx.v
   wire			mi_basecfg_en;		// From ecfg_if of ecfg_if.v
   wire [31:0]		mi_el_dout;		// From ecfg_base of ecfg_base.v
   wire [31:0]		mi_mailbox_dout;	// From emailbox of emailbox.v
   wire			mi_mailbox_en;		// From ecfg_if of ecfg_if.v
   wire [31:0]		mi_rx_dout;		// From erx of erx.v
   wire [31:0]		mi_tx_dout;		// From etx of etx.v
   wire			reset;			// From ereset of ereset.v
   wire			soft_reset;		// From ecfg_base of ecfg_base.v
   wire			tx_lclk;		// From eclocks of eclocks.v
   wire			tx_lclk90;		// From eclocks of eclocks.v
   // End of automatics

   /***********************************************************/
   /*ELINK CONFIGURATION INTERFACE                            */
   /***********************************************************/
   defparam ecfg_if.ID=ID;
       
   ecfg_if ecfg_if(
		   /*AUTOINST*/
		   // Outputs
		   .txwr_wait		(txwr_wait),
		   .txrd_wait		(txrd_wait),
		   .mi_tx_cfg_en	(mi_tx_cfg_en),
		   .mi_tx_mmu_en	(mi_tx_mmu_en),
		   .mi_tx_we		(mi_tx_we),
		   .mi_tx_addr		(mi_tx_addr[19:0]),
		   .mi_tx_din		(mi_tx_din[63:0]),
		   .mi_rx_cfg_en	(mi_rx_cfg_en),
		   .mi_rx_dma_en	(mi_rx_dma_en),
		   .mi_rx_mmu_en	(mi_rx_mmu_en),
		   .mi_rx_we		(mi_rx_we),
		   .mi_rx_addr		(mi_rx_addr[19:0]),
		   .mi_rx_din		(mi_rx_din[63:0]),
		   .mi_basecfg_en	(mi_basecfg_en),
		   .mi_mailbox_en	(mi_mailbox_en),
		   .mi_we		(mi_we),
		   .mi_addr		(mi_addr[19:0]),
		   .mi_din		(mi_din[63:0]),
		   // Inputs
		   .sys_clk		(sys_clk),
		   .tx_lclk_div4	(tx_lclk_div4),
		   .rx_lclk_div4	(rx_lclk_div4),
		   .reset		(reset),
		   .txwr_access		(txwr_access),
		   .txwr_packet		(txwr_packet[PW-1:0]),
		   .txrd_access		(txrd_access),
		   .txrd_packet		(txrd_packet[PW-1:0]),
		   .rxwr_access		(rxwr_access),
		   .rxwr_packet		(rxwr_packet[PW-1:0]),
		   .mi_el_dout		(mi_el_dout[31:0]),
		   .mi_rx_dout		(mi_rx_dout[DW-1:0]),
		   .mi_tx_dout		(mi_tx_dout[DW-1:0]),
		   .mi_mailbox_dout	(mi_mailbox_dout[DW-1:0]));

   /***********************************************************/
   /*ELINK CONFIGURATION REGISTERES                           */
   /***********************************************************/
  
   /*ecfg_base AUTO_TEMPLATE ( 
	                .mi_dout    (mi_el_dout[]),
                        .mi_en      (mi_basecfg_en[]),
                        .ecfg_reset (reset),
                        .clk        (mi_clk),
                      )
   */

   defparam ecfg_base.GROUP=`EGROUP_TX;
   ecfg_base ecfg_base(
		       /*AUTOINST*/
		       // Outputs
		       .soft_reset	(soft_reset),
		       .mi_dout		(mi_el_dout[31:0]),	 // Templated
		       .ecfg_clk_settings(ecfg_clk_settings[15:0]),
		       .colid		(colid[3:0]),
		       .rowid		(rowid[3:0]),
		       // Inputs
		       .hard_reset	(hard_reset),
		       .sys_clk		(sys_clk),
		       .mi_en		(mi_basecfg_en),	 // Templated
		       .mi_we		(mi_we),
		       .mi_addr		(mi_addr[19:0]),
		       .mi_din		(mi_din[31:0]));
   
   /***********************************************************/
   /*RESET CIRCUITRY                                          */
   /***********************************************************/
   ereset ereset (/*AUTOINST*/
		  // Outputs
		  .reset		(reset),
		  .chip_resetb		(chip_resetb),
		  // Inputs
		  .hard_reset		(hard_reset),
		  .soft_reset		(soft_reset));

   /***********************************************************/
   /*CLOCKS                                                   */
   /***********************************************************/
   eclocks eclocks (
		    /*AUTOINST*/
		    // Outputs
		    .cclk_p		(cclk_p),
		    .cclk_n		(cclk_n),
		    .tx_lclk		(tx_lclk),
		    .tx_lclk90		(tx_lclk90),
		    .tx_lclk_div4	(tx_lclk_div4),
		    // Inputs
		    .clkin		(clkin),
		    .hard_reset		(hard_reset),
		    .ecfg_clk_settings	(ecfg_clk_settings[15:0]),
		    .clkbypass		(clkbypass[2:0]));
   

   /***********************************************************/
   /*MAILBOX                                                  */
   /***********************************************************/
   /*emailbox AUTO_TEMPLATE ( 
	                .mi_dout    (mi_mailbox_dout[]),
                         .mi_en	    (mi_mailbox_en),
                      );
   */
   
   emailbox emailbox (
		    /*AUTOINST*/
		      // Outputs
		      .mi_dout		(mi_mailbox_dout[31:0]), // Templated
		      .mailbox_full	(mailbox_full),
		      .mailbox_not_empty(mailbox_not_empty),
		      // Inputs
		      .reset		(reset),
		      .sys_clk		(sys_clk),
		      .mi_en		(mi_mailbox_en),	 // Templated
		      .mi_we		(mi_we),
		      .mi_addr		(mi_addr[19:0]),
		      .mi_din		(mi_din[63:0]));
   

 
   /***********************************************************/
   /*RECEIVER                                                 */
   /***********************************************************/
   /*erx AUTO_TEMPLATE ( 
	                .mi_dout      (mi_rx_dout[]),
                        .emwr_\(.*\)  (emaxi_emwr_\1[]),
                        .emrq_\(.*\)  (emaxi_emrq_\1[]),
                        .emrr_\(.*\)  (esaxi_emrr_\1[]),
                        );
   */
   
   defparam erx.ID=ID;
   erx erx(
	   /*AUTOINST*/
	   // Outputs
	   .rxo_wr_wait_p		(rxo_wr_wait_p),
	   .rxo_wr_wait_n		(rxo_wr_wait_n),
	   .rxo_rd_wait_p		(rxo_rd_wait_p),
	   .rxo_rd_wait_n		(rxo_rd_wait_n),
	   .rxwr_access			(rxwr_access),
	   .rxwr_packet			(rxwr_packet[PW-1:0]),
	   .rxrd_access			(rxrd_access),
	   .rxrd_packet			(rxrd_packet[PW-1:0]),
	   .rxrr_access			(rxrr_access),
	   .rxrr_packet			(rxrr_packet[PW-1:0]),
	   .mi_dout			(mi_rx_dout[31:0]),	 // Templated
	   .rx_lclk_div4		(rx_lclk_div4),
	   .timeout			(timeout),
	   // Inputs
	   .reset			(reset),
	   .rxi_lclk_p			(rxi_lclk_p),
	   .rxi_lclk_n			(rxi_lclk_n),
	   .rxi_frame_p			(rxi_frame_p),
	   .rxi_frame_n			(rxi_frame_n),
	   .rxi_data_p			(rxi_data_p[7:0]),
	   .rxi_data_n			(rxi_data_n[7:0]),
	   .rxwr_wait			(rxwr_wait),
	   .rxrd_wait			(rxrd_wait),
	   .rxrr_wait			(rxrr_wait),
	   .mi_rxcfg_en			(mi_rxcfg_en),
	   .mi_dma_en			(mi_dma_en),
	   .mi_rxmmu_en			(mi_rxmmu_en),
	   .mi_we			(mi_we),
	   .mi_addr			(mi_addr[19:0]),
	   .mi_din			(mi_din[31:0]),
	   .etx_read			(etx_read));

   /***********************************************************/
   /*TRANSMITTER                                              */
   /***********************************************************/
   /*etx AUTO_TEMPLATE (.mi_dout      (mi_tx_dout[]),
                        .emwr_\(.*\)  (esaxi_emwr_\1[]),
                        .emrq_\(.*\)  (esaxi_emrq_\1[]),
                        .emrr_\(.*\)  (emaxi_emrr_\1[]),
                       );
   */

   defparam etx.ID=ID;
   etx etx(
	   /*AUTOINST*/
	   // Outputs
	   .mi_dout			(mi_tx_dout[31:0]),	 // Templated
	   .txrd_wait			(txrd_wait),
	   .txwr_wait			(txwr_wait),
	   .txrr_wait			(txrr_wait),
	   .etx_read			(etx_read),
	   .txo_lclk_p			(txo_lclk_p),
	   .txo_lclk_n			(txo_lclk_n),
	   .txo_frame_p			(txo_frame_p),
	   .txo_frame_n			(txo_frame_n),
	   .txo_data_p			(txo_data_p[7:0]),
	   .txo_data_n			(txo_data_n[7:0]),
	   // Inputs
	   .reset			(reset),
	   .tx_lclk			(tx_lclk),
	   .tx_lclk90			(tx_lclk90),
	   .tx_lclk_div4		(tx_lclk_div4),
	   .mi_txcfg_en			(mi_txcfg_en),
	   .mi_txmmu_en			(mi_txmmu_en),
	   .mi_we			(mi_we),
	   .mi_addr			(mi_addr[19:0]),
	   .mi_din			(mi_din[31:0]),
	   .txrd_access			(txrd_access),
	   .txrd_packet			(txrd_packet[PW-1:0]),
	   .txwr_access			(txwr_access),
	   .txwr_packet			(txwr_packet[PW-1:0]),
	   .txrr_access			(txrr_access),
	   .txrr_packet			(txrr_packet[PW-1:0]),
	   .txi_wr_wait_p		(txi_wr_wait_p),
	   .txi_wr_wait_n		(txi_wr_wait_n),
	   .txi_rd_wait_p		(txi_rd_wait_p),
	   .txi_rd_wait_n		(txi_rd_wait_n));
   
 
         
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../emailbox/hdl" "../../erx/hdl" "../../etx/hdl" "../../axi/hdl" "../../ecfg/hdl" "../../eclock/hdl")
// End:

/*
 Copyright (C) 2014 Adapteva, Inc.
 
 Contributed by Andreas Olofsson <andreas@adapteva.com>
 Contributed by Fred Huettig <fred@adapteva.com>
 Contributed by Roman Trogan <roman@adapteva.com>

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.This program is distributed in the hope 
 that it will be useful,but WITHOUT ANY WARRANTY; without even the implied 
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details. You should have received a copy 
 of the GNU General Public License along with this program (see the file 
 COPYING).  If not, see <http://www.gnu.org/licenses/>.
 */
