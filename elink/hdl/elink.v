/*
 ########################################################################
 DESCRIPTION
 ########################################################################
 The "eLink" is a low latency chip to chip interface used by for communication
 between Epiphany chips and FPGAs. The interface "should" achieve a peak
 throughput of 8 Gbit/s in FPGAs with 24 available LVDS signal pairs.  
 
  TRANSMIT
   
  SIGNAL         | DESCRIPTION 
  ---------------|--------------
  TXO_FRAME      | Packet framing signal. Rising edge signals new packet.
  TXO_LCLK       | A clock aligned in the center of the data eye
  TXO_DATA[7:0]  | Dual data rate (DDR) that transmits packet
  TXI_RD_WAIT    | Push back signal for read transactions
  TXI_WR_WAIT    | Push back signal for write transactions
 
  RECEIVE

 The elink has a 64 bit data AXI master and 32-bit data AXI slave interface 
 for connecting to a standard AXI network.
 
 PACKET SUBFIELD | DESCRIPTION 
 ----------------|----------------
 access          | Indicates a valid packet
 write           | A write transaction. Access & ~write indicates a read.
 datamode[1:0]   | Datasize (00=8b,01=16b,10=32b,11=64b)
 ctrlmode[3:0]   | Various packet modes for the Epiphany chip
 dstraddr[31:0]  | Address for write, read-request, or read-responses transaction
 data[31:0]      | Data for write transaction, return data for read response
 srcaddr[31:0]   | Return address for read-request, upper data for 64 bit write
 
 PACKET-FORMAT:
 
 The elink was born out of a need to connect multiple Epiphany chips together
 and uses the eMesh 104 bit atomic packet structure for communication. 
 The eMesh atomic packet consists of the following sub fields.

 
 FRAMING:
  
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
 
 PUSHBACK:
 
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
 
 ########################################################################
 ELINK MEMORY MAP
 ########################################################################
 The elink has an parameter called 'ELINKID' that can be configured by 
 the module instantiating the elink. 
 
 REGISTER    |   ADDRESS    | NOTES 
 ------------| -------------|------
 ESYSRESET   |   0xF0000    | Soft reset
 ESYSTX      |   0xF0004    | Elink tranmit config
 ESYSRX      |   0xF0008    | Elink receiver config
 ESYSCLK     |   0xF000C    | Clock config
 ESYSCOREID  |   0xF0010    | ID to drive to Epiphany chip
 ESYSVERSION |   0xF0014    | Platform version
 ESYSDATAIN  |   0xF0018    | Direct data from elink receiver
 ESYSDATAOUT |   0xF001C    | Direct data for elink transmitter
 ESYSDEBUG   |   0xF0020    | Various debug signals
---------------------------------------------------------------------------
 EMBOXLO     |   0xC0004    | Lower 32 bits of 64 bit wide mail box fifo
 EMBOXHI     |   0xC0008    | Upper 32 bits of 64 bit wide mail box fifo
---------------------------------------------------------------------------
 ESYSMMURX   |   0xE0000    | Start of receiver MMU lookup table
 ESYSMMUTX   |   0xD0000    | Start of transmit MMU lookup table (tbd)
          
 ########################################################################
 ELINK CONFIGURATION REGISTER (32bit access)
 ########################################################################
-------------------------------------------------------------
 ESYSRESET        ***Elink reset***
 [0]              0  - elink active 
                  1  - elink in reset
-------------------------------------------------------------
 ESYSTX           ***Elink transmitter configuration***
 [0]              0  - link TX disable
                  1  - link TX enable
 [1]              0  - normal pass through transaction mode
                  1  - mmu mode
 [3:2]            00 - normal mode
                  01 - gpio drive mode
                  10 - reserved
                  11 - reserved
 [7:4]            Transmit control mode for eMesh
 [8]             AXI slave read timeout enable
  -------------------------------------------------------------
 ESYSRX           ***Elink receiver configuration***
 [0]              0  - link RX disable
                  1  - link RX enable
 [1]              0  - normal transaction mode
                  1  - mmu mode
 [3:2]            00 - normal mode
                  01 - gpio sample mode (drive rd wait pins from registers)
                  10 - reserved
                  11 - reserved
  -------------------------------------------------------------
 ESYSCLK          ***Elink clock setting*** 
 [0]              Enable CCLK
 [1]              Enable TX_LCLK
 [2]              CCLK PLL bypass mode (cclk is set to clkin)
 [3]              LCLK PLL bypass mode (lclk is set to clkin) 
 [7:4]            CCLK PLL Divider (1<<reg)
                  0000 - CLKIN/1
                  0001 - CLKIN/2
                  0010 - CLKIN/4
                  0011 - CLKIN/8
                  0100 - CLKIN/16
                  0101 - CLKIN/32
                  0110 - CLKIN/64
                  0111 - CLKIN/128
                  1xxx - RESERVED                  
 [11:8]           Elink PLL Divider (1<<reg)
                  0000 - CLKIN/1
                  0001 - CLKIN/2
                  0010 - CLKIN/4
                  0011 - CLKIN/8
                  0100 - CLKIN/16
                  0101 - CLKIN/32
                  0110 - CLKIN/64
                  0111 - CLKIN/128
                  1xxx - RESERVED                 
 [15:12]          PLL Frequency
                  XXXX - TBD
 -------------------------------------------------------------
 ESYSCOREID     ***CORE ID***
 [5:0]          Column ID for connected Epiphany chip
 [11:6]         Row ID for connected Epiphany chip 
 -------------------------------------------------------------
 ESYSLATFORM   ***Platform ID (read only)***
 [7:0]          Platform model number
 -------------------------------------------------------------
 ESYSDATAIN     ***Data on elink input pins
 [7:0]          rx_data[7:0]         
 [8]            tx_frame
 [9]            tx_wait_rd
 [10]           tx_wait_wr
 -------------------------------------------------------------
 ESYSDATAOUT    ***Data on eLink output pins
 [7:0]          tx_data[7:0]         
 [8]            tx_frame
 [9]            rx_wait_rd
 [10]           rx_wait_wr
 -------------------------------------------------------------
 ESYSDEBUG      ***Various debug signals from elink 
 [31] embox_not_empty
 //RX signals
 [30] emesh_rx_rd_wait
 [29] emesh_rx_wr_wait
 [28] esaxi_emrr_rd_en
 [27] emrr_full
 [26] emrr_progfull
 [25] emrr_wr_en
 [24] emaxi_emrq_rd_en
 [23] emrq_progfull
 [22] emrq_wr_en
 [21] emaxi_emwr_rd_en
 [20] emwr_progfull
 [19] emwr_wr_en (rx)
 //TX signals
 [18] e_tx_rd_wait 
 [17] e_tx_wr_wait
 [16] emrr_rd_en
 [15] emaxi_emrr_prog_full
 [14] emaxi_emrr_wr_en
 [13] emrq_rd_en
 [12  esaxi_emrq_prog_full
 [11] esaxi_emrq_wr_en
 [10] emwr_rd_en
 [9]  esaxi_emwr_prog_full
 [8]  esaxi_emwr_wr_en  
 ##########Sticky signals below#############
 [7] reserved
 [6] emrr_full (rx)
 [5] emrq_full (rx)
 [4] emwr_full (rx)
 [3] emaxi_emrr_full (tx)
 [2] esaxi_emrq_full (tx)
 [1] esaxi_emwr_full (tx)
 [0] embox_full (mailbox)
  ########################################################################
 */

module elink(/*AUTOARG*/
   // Outputs
   colid, rowid, chip_resetb, cclk_p, cclk_n, rxo_wr_wait_p,
   rxo_wr_wait_n, rxo_rd_wait_p, rxo_rd_wait_n, txo_lclk_p,
   txo_lclk_n, txo_frame_p, txo_frame_n, txo_data_p, txo_data_n,
   m_axi_araddr, m_axi_arburst, m_axi_arcache, m_axi_arlen,
   m_axi_arprot, m_axi_arqos, m_axi_arsize, m_axi_arvalid,
   m_axi_awaddr, m_axi_awburst, m_axi_awcache, m_axi_awlen,
   m_axi_awprot, m_axi_awqos, m_axi_awsize, m_axi_awvalid,
   m_axi_bready, m_axi_rready, m_axi_wdata, m_axi_wlast, m_axi_wstrb,
   m_axi_wvalid, s_axi_arready, s_axi_awready, s_axi_bresp,
   s_axi_bvalid, s_axi_rdata, s_axi_rlast, s_axi_rresp, s_axi_rvalid,
   s_axi_wready, embox_not_empty, embox_full,
   // Inputs
   hard_reset, clkin, bypass_clocks, rxi_lclk_p, rxi_lclk_n,
   rxi_frame_p, rxi_frame_n, rxi_data_p, rxi_data_n, txi_wr_wait_p,
   txi_wr_wait_n, txi_rd_wait_p, txi_rd_wait_n, m_axi_aclk,
   m_axi_aresetn, m_axi_arready, m_axi_awready, m_axi_bresp,
   m_axi_bvalid, m_axi_rdata, m_axi_rlast, m_axi_rresp, m_axi_rvalid,
   m_axi_wready, s_axi_aclk, s_axi_aresetn, s_axi_araddr,
   s_axi_arburst, s_axi_arcache, s_axi_arlen, s_axi_arprot,
   s_axi_arqos, s_axi_arsize, s_axi_arvalid, s_axi_awaddr,
   s_axi_awburst, s_axi_awcache, s_axi_awlen, s_axi_awprot,
   s_axi_awqos, s_axi_awsize, s_axi_awvalid, s_axi_bready,
   s_axi_rready, s_axi_wdata, s_axi_wlast, s_axi_wstrb, s_axi_wvalid
   );
   
   parameter DEF_COREID  = 12'h810;
   parameter AW          = 32;
   parameter DW          = 32;
   parameter IDW         = 32;
   parameter RFAW        = 13;
   parameter MW          = 44;
   parameter INC_PLL     = 1;        //include pll
   parameter INC_SPI     = 1;        //include spi block
   parameter ELINKID     = 12'h810;  //elink ID (used for registers)

   /****************************/
   /*CLK AND RESET             */
   /****************************/
   input         hard_reset;          // active high synhcronous hardware reset
   input 	 clkin;               // clock for pll
   input [2:0] 	 bypass_clocks;       // bypass clocks for elinks w/o pll
                                      // "advanced", tie to zero if not used

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
   /*AXI master interface       */
   /*****************************/  
   //Clock and reset
   input 	 m_axi_aclk;    //axi master clock
   input 	 m_axi_aresetn; //axi master reset (active low)

   //Read address channel
   output [31:0] m_axi_araddr;  //read address
   output [1:0]  m_axi_arburst; //burst type
   output [3:0]  m_axi_arcache; //memory type
   output [7:0]  m_axi_arlen;   //burst length (number of data transfers)
   output [2:0]  m_axi_arprot;  //protection type
   output [3:0]  m_axi_arqos;   //quality of service (setting?)
   input 	 m_axi_arready; //read ready
   output [2:0]  m_axi_arsize;  //burst size (the size of each transfer)
   output 	 m_axi_arvalid; //write address valid

   //Write address channel
   output [31:0] m_axi_awaddr;
   output [1:0]  m_axi_awburst; 
   output [3:0]  m_axi_awcache;
   output [7:0]  m_axi_awlen;
   output [2:0]  m_axi_awprot;
   output [3:0]  m_axi_awqos;
   input 	 m_axi_awready;
   output [2:0]  m_axi_awsize;
   output 	 m_axi_awvalid;
   
   //Write response channel
   output 	 m_axi_bready;
   input [1:0] 	 m_axi_bresp;
   input 	 m_axi_bvalid;
   
   //Read data channel
   input [63:0]  m_axi_rdata;
   input 	 m_axi_rlast;   //indicates last transfer of a burst
   output 	 m_axi_rready;  //read ready signal
   input [1:0] 	 m_axi_rresp;
   input 	 m_axi_rvalid;
   
   //Write data channel
   output [63:0] m_axi_wdata;
   output 	 m_axi_wlast;   //indicates last transfer of a burs
   input 	 m_axi_wready;  //response ready
   output [7:0]  m_axi_wstrb;
   output 	 m_axi_wvalid;
   
   /*****************************/
   /*AXI slave interface        */
   /*****************************/  
   //Clock and reset
   input 	 s_axi_aclk;
   input 	 s_axi_aresetn;

   //Read address channel
   input [29:0]  s_axi_araddr;
   input [1:0] 	 s_axi_arburst;
   input [3:0] 	 s_axi_arcache;
   input [7:0] 	 s_axi_arlen;
   input [2:0] 	 s_axi_arprot;
   input [3:0] 	 s_axi_arqos;
   output 	 s_axi_arready;
   input [2:0] 	 s_axi_arsize;
   input 	 s_axi_arvalid;

   //Write address channel
   input [29:0]  s_axi_awaddr;
   input [1:0] 	 s_axi_awburst;
   input [3:0] 	 s_axi_awcache;
   input [7:0] 	 s_axi_awlen;
   input [2:0] 	 s_axi_awprot;
   input [3:0] 	 s_axi_awqos;
   output 	 s_axi_awready;
   input [2:0] 	 s_axi_awsize;
   input 	 s_axi_awvalid;

   //Buffered write response channel
   input 	 s_axi_bready;
   output [1:0]  s_axi_bresp;
   output 	 s_axi_bvalid;

   //Read channel
   output [31:0] s_axi_rdata;
   output 	 s_axi_rlast;
   input 	 s_axi_rready;
   output [1:0]  s_axi_rresp;
   output 	 s_axi_rvalid;
   
   //Write channel
   input [31:0]  s_axi_wdata;
   input 	 s_axi_wlast;
   output 	 s_axi_wready;
   input [3:0] 	 s_axi_wstrb;
   input 	 s_axi_wvalid;

   /*****************************/
   /*MAILBOX (interrupts)       */
   /*****************************/
   output       embox_not_empty;   
   output       embox_full;

   /*#############################################*/
   /*  END OF BLOCK INTERFACE                     */
   /*#############################################*/
   
   /*AUTOINPUT*/
   /*AUTOOUTPUT*/

   //wires
   wire [31:0] 	 mi_rd_data;
   wire [31:0] 	 mi_dout_ecfg;
   wire [31:0] 	 mi_dout_embox;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]		ecfg_clk_settings;	// From ecfg of ecfg.v
   wire [11:0]		ecfg_coreid;		// From ecfg of ecfg.v
   wire [10:0]		ecfg_dataout;		// From ecfg of ecfg.v
   wire [8:0]		ecfg_rx_datain;		// From erx of erx.v
   wire [15:0]		ecfg_rx_debug;		// From erx of erx.v
   wire			ecfg_rx_enable;		// From ecfg of ecfg.v
   wire			ecfg_rx_gpio_enable;	// From ecfg of ecfg.v
   wire			ecfg_rx_mmu_enable;	// From ecfg of ecfg.v
   wire			ecfg_timeout_enable;	// From ecfg of ecfg.v
   wire [3:0]		ecfg_tx_ctrlmode;	// From ecfg of ecfg.v
   wire [1:0]		ecfg_tx_datain;		// From etx of etx.v
   wire [15:0]		ecfg_tx_debug;		// From etx of etx.v
   wire			ecfg_tx_enable;		// From ecfg of ecfg.v
   wire			ecfg_tx_gpio_enable;	// From ecfg of ecfg.v
   wire			ecfg_tx_mmu_enable;	// From ecfg of ecfg.v
   wire			emaxi_emrq_access;	// From erx of erx.v
   wire [3:0]		emaxi_emrq_ctrlmode;	// From erx of erx.v
   wire [31:0]		emaxi_emrq_data;	// From erx of erx.v
   wire [1:0]		emaxi_emrq_datamode;	// From erx of erx.v
   wire [31:0]		emaxi_emrq_dstaddr;	// From erx of erx.v
   wire			emaxi_emrq_rd_en;	// From emaxi of emaxi.v
   wire [31:0]		emaxi_emrq_srcaddr;	// From erx of erx.v
   wire			emaxi_emrq_write;	// From erx of erx.v
   wire			emaxi_emrr_access;	// From emaxi of emaxi.v
   wire [3:0]		emaxi_emrr_ctrlmode;	// From emaxi of emaxi.v
   wire [31:0]		emaxi_emrr_data;	// From emaxi of emaxi.v
   wire [1:0]		emaxi_emrr_datamode;	// From emaxi of emaxi.v
   wire [31:0]		emaxi_emrr_dstaddr;	// From emaxi of emaxi.v
   wire			emaxi_emrr_progfull;	// From etx of etx.v
   wire [31:0]		emaxi_emrr_srcaddr;	// From emaxi of emaxi.v
   wire			emaxi_emrr_write;	// From emaxi of emaxi.v
   wire			emaxi_emwr_access;	// From erx of erx.v
   wire [3:0]		emaxi_emwr_ctrlmode;	// From erx of erx.v
   wire [31:0]		emaxi_emwr_data;	// From erx of erx.v
   wire [1:0]		emaxi_emwr_datamode;	// From erx of erx.v
   wire [31:0]		emaxi_emwr_dstaddr;	// From erx of erx.v
   wire			emaxi_emwr_rd_en;	// From emaxi of emaxi.v
   wire [31:0]		emaxi_emwr_srcaddr;	// From erx of erx.v
   wire			emaxi_emwr_write;	// From erx of erx.v
   wire			esaxi_emrq_access;	// From esaxi of esaxi.v
   wire [3:0]		esaxi_emrq_ctrlmode;	// From esaxi of esaxi.v
   wire [31:0]		esaxi_emrq_data;	// From esaxi of esaxi.v
   wire [1:0]		esaxi_emrq_datamode;	// From esaxi of esaxi.v
   wire [31:0]		esaxi_emrq_dstaddr;	// From esaxi of esaxi.v
   wire			esaxi_emrq_progfull;	// From etx of etx.v
   wire [31:0]		esaxi_emrq_srcaddr;	// From esaxi of esaxi.v
   wire			esaxi_emrq_write;	// From esaxi of esaxi.v
   wire			esaxi_emrr_access;	// From erx of erx.v
   wire [31:0]		esaxi_emrr_data;	// From erx of erx.v
   wire			esaxi_emrr_rd_en;	// From esaxi of esaxi.v
   wire			esaxi_emwr_access;	// From esaxi of esaxi.v
   wire [3:0]		esaxi_emwr_ctrlmode;	// From esaxi of esaxi.v
   wire [31:0]		esaxi_emwr_data;	// From esaxi of esaxi.v
   wire [1:0]		esaxi_emwr_datamode;	// From esaxi of esaxi.v
   wire [31:0]		esaxi_emwr_dstaddr;	// From esaxi of esaxi.v
   wire			esaxi_emwr_progfull;	// From etx of etx.v
   wire [31:0]		esaxi_emwr_srcaddr;	// From esaxi of esaxi.v
   wire			esaxi_emwr_write;	// From esaxi of esaxi.v
   wire [19:0]		mi_addr;		// From esaxi of esaxi.v
   wire			mi_clk;			// From esaxi of esaxi.v
   wire [31:0]		mi_din;			// From esaxi of esaxi.v
   wire [31:0]		mi_ecfg_dout;		// From ecfg of ecfg.v
   wire			mi_ecfg_sel;		// From esaxi of esaxi.v
   wire [DW-1:0]	mi_embox_dout;		// From embox of embox.v
   wire			mi_embox_sel;		// From esaxi of esaxi.v
   wire [31:0]		mi_rx_emmu_dout;	// From erx of erx.v
   wire			mi_rx_emmu_sel;		// From esaxi of esaxi.v
   wire [31:0]		mi_tx_emmu_dout;	// From etx of etx.v
   wire			mi_tx_emmu_sel;		// From esaxi of esaxi.v
   wire			mi_we;			// From esaxi of esaxi.v
   wire			reset;			// From ereset of ereset.v
   wire			soft_reset;		// From ecfg of ecfg.v
   wire			tx_lclk;		// From eclocks of eclocks.v
   wire			tx_lclk_out;		// From eclocks of eclocks.v
   wire			tx_lclk_par;		// From eclocks of eclocks.v
   // End of automatics
 
   
   /***********************************************************/
   /*AXI MASTER                                               */
   /***********************************************************/
  /*emaxi AUTO_TEMPLATE ( 
                        // Outputs
	                .m00_\(.*\)       (m_\1[]),
                        .em\(.*\)         (emaxi_em\1[]),  
                        );
   */
   
   emaxi emaxi(
	       /*AUTOINST*/
	       // Outputs
	       .emwr_rd_en		(emaxi_emwr_rd_en),	 // Templated
	       .emrq_rd_en		(emaxi_emrq_rd_en),	 // Templated
	       .emrr_access		(emaxi_emrr_access),	 // Templated
	       .emrr_write		(emaxi_emrr_write),	 // Templated
	       .emrr_datamode		(emaxi_emrr_datamode[1:0]), // Templated
	       .emrr_ctrlmode		(emaxi_emrr_ctrlmode[3:0]), // Templated
	       .emrr_dstaddr		(emaxi_emrr_dstaddr[31:0]), // Templated
	       .emrr_data		(emaxi_emrr_data[31:0]), // Templated
	       .emrr_srcaddr		(emaxi_emrr_srcaddr[31:0]), // Templated
	       .m_axi_awaddr		(m_axi_awaddr[31:0]),
	       .m_axi_awlen		(m_axi_awlen[7:0]),
	       .m_axi_awsize		(m_axi_awsize[2:0]),
	       .m_axi_awburst		(m_axi_awburst[1:0]),
	       .m_axi_awcache		(m_axi_awcache[3:0]),
	       .m_axi_awprot		(m_axi_awprot[2:0]),
	       .m_axi_awqos		(m_axi_awqos[3:0]),
	       .m_axi_awvalid		(m_axi_awvalid),
	       .m_axi_wdata		(m_axi_wdata[63:0]),
	       .m_axi_wstrb		(m_axi_wstrb[7:0]),
	       .m_axi_wlast		(m_axi_wlast),
	       .m_axi_wvalid		(m_axi_wvalid),
	       .m_axi_bready		(m_axi_bready),
	       .m_axi_araddr		(m_axi_araddr[31:0]),
	       .m_axi_arlen		(m_axi_arlen[7:0]),
	       .m_axi_arsize		(m_axi_arsize[2:0]),
	       .m_axi_arburst		(m_axi_arburst[1:0]),
	       .m_axi_arcache		(m_axi_arcache[3:0]),
	       .m_axi_arprot		(m_axi_arprot[2:0]),
	       .m_axi_arqos		(m_axi_arqos[3:0]),
	       .m_axi_arvalid		(m_axi_arvalid),
	       .m_axi_rready		(m_axi_rready),
	       // Inputs
	       .emwr_access		(emaxi_emwr_access),	 // Templated
	       .emwr_write		(emaxi_emwr_write),	 // Templated
	       .emwr_datamode		(emaxi_emwr_datamode[1:0]), // Templated
	       .emwr_ctrlmode		(emaxi_emwr_ctrlmode[3:0]), // Templated
	       .emwr_dstaddr		(emaxi_emwr_dstaddr[31:0]), // Templated
	       .emwr_data		(emaxi_emwr_data[31:0]), // Templated
	       .emwr_srcaddr		(emaxi_emwr_srcaddr[31:0]), // Templated
	       .emrq_access		(emaxi_emrq_access),	 // Templated
	       .emrq_write		(emaxi_emrq_write),	 // Templated
	       .emrq_datamode		(emaxi_emrq_datamode[1:0]), // Templated
	       .emrq_ctrlmode		(emaxi_emrq_ctrlmode[3:0]), // Templated
	       .emrq_dstaddr		(emaxi_emrq_dstaddr[31:0]), // Templated
	       .emrq_data		(emaxi_emrq_data[31:0]), // Templated
	       .emrq_srcaddr		(emaxi_emrq_srcaddr[31:0]), // Templated
	       .emrr_progfull		(emaxi_emrr_progfull),	 // Templated
	       .m_axi_aclk		(m_axi_aclk),
	       .m_axi_aresetn		(m_axi_aresetn),
	       .m_axi_awready		(m_axi_awready),
	       .m_axi_wready		(m_axi_wready),
	       .m_axi_bresp		(m_axi_bresp[1:0]),
	       .m_axi_bvalid		(m_axi_bvalid),
	       .m_axi_arready		(m_axi_arready),
	       .m_axi_rdata		(m_axi_rdata[63:0]),
	       .m_axi_rresp		(m_axi_rresp[1:0]),
	       .m_axi_rlast		(m_axi_rlast),
	       .m_axi_rvalid		(m_axi_rvalid));

   /***********************************************************/
   /*AXI SLAVE                                                */
   /***********************************************************/
   /*esaxi AUTO_TEMPLATE ( 
                        // Outputs
	                .s00_\(.*\)       (s_\1[]),
                        .emwr_\(.*\)      (esaxi_emwr_\1[]),
                        .emrq_\(.*\)      (esaxi_emrq_\1[]),
                        .emrr_\(.*\)      (esaxi_emrr_\1[]),
                        );
   */
   
   esaxi esaxi(
	       /*AUTOINST*/
	       // Outputs
	       .emwr_access		(esaxi_emwr_access),	 // Templated
	       .emwr_write		(esaxi_emwr_write),	 // Templated
	       .emwr_datamode		(esaxi_emwr_datamode[1:0]), // Templated
	       .emwr_ctrlmode		(esaxi_emwr_ctrlmode[3:0]), // Templated
	       .emwr_dstaddr		(esaxi_emwr_dstaddr[31:0]), // Templated
	       .emwr_data		(esaxi_emwr_data[31:0]), // Templated
	       .emwr_srcaddr		(esaxi_emwr_srcaddr[31:0]), // Templated
	       .emrq_access		(esaxi_emrq_access),	 // Templated
	       .emrq_write		(esaxi_emrq_write),	 // Templated
	       .emrq_datamode		(esaxi_emrq_datamode[1:0]), // Templated
	       .emrq_ctrlmode		(esaxi_emrq_ctrlmode[3:0]), // Templated
	       .emrq_dstaddr		(esaxi_emrq_dstaddr[31:0]), // Templated
	       .emrq_data		(esaxi_emrq_data[31:0]), // Templated
	       .emrq_srcaddr		(esaxi_emrq_srcaddr[31:0]), // Templated
	       .emrr_rd_en		(esaxi_emrr_rd_en),	 // Templated
	       .mi_clk			(mi_clk),
	       .mi_rx_emmu_sel		(mi_rx_emmu_sel),
	       .mi_tx_emmu_sel		(mi_tx_emmu_sel),
	       .mi_ecfg_sel		(mi_ecfg_sel),
	       .mi_embox_sel		(mi_embox_sel),
	       .mi_we			(mi_we),
	       .mi_addr			(mi_addr[19:0]),
	       .mi_din			(mi_din[31:0]),
	       .s_axi_arready		(s_axi_arready),
	       .s_axi_awready		(s_axi_awready),
	       .s_axi_bresp		(s_axi_bresp[1:0]),
	       .s_axi_bvalid		(s_axi_bvalid),
	       .s_axi_rdata		(s_axi_rdata[31:0]),
	       .s_axi_rlast		(s_axi_rlast),
	       .s_axi_rresp		(s_axi_rresp[1:0]),
	       .s_axi_rvalid		(s_axi_rvalid),
	       .s_axi_wready		(s_axi_wready),
	       // Inputs
	       .emwr_progfull		(esaxi_emwr_progfull),	 // Templated
	       .emrq_progfull		(esaxi_emrq_progfull),	 // Templated
	       .emrr_data		(esaxi_emrr_data[31:0]), // Templated
	       .emrr_access		(esaxi_emrr_access),	 // Templated
	       .mi_ecfg_dout		(mi_ecfg_dout[31:0]),
	       .mi_tx_emmu_dout		(mi_tx_emmu_dout[31:0]),
	       .mi_rx_emmu_dout		(mi_rx_emmu_dout[31:0]),
	       .mi_embox_dout		(mi_embox_dout[31:0]),
	       .ecfg_tx_ctrlmode	(ecfg_tx_ctrlmode[3:0]),
	       .ecfg_coreid		(ecfg_coreid[11:0]),
	       .ecfg_timeout_enable	(ecfg_timeout_enable),
	       .s_axi_aclk		(s_axi_aclk),
	       .s_axi_aresetn		(s_axi_aresetn),
	       .s_axi_araddr		(s_axi_araddr[29:0]),
	       .s_axi_arburst		(s_axi_arburst[1:0]),
	       .s_axi_arcache		(s_axi_arcache[3:0]),
	       .s_axi_arlen		(s_axi_arlen[7:0]),
	       .s_axi_arprot		(s_axi_arprot[2:0]),
	       .s_axi_arqos		(s_axi_arqos[3:0]),
	       .s_axi_arsize		(s_axi_arsize[2:0]),
	       .s_axi_arvalid		(s_axi_arvalid),
	       .s_axi_awaddr		(s_axi_awaddr[29:0]),
	       .s_axi_awburst		(s_axi_awburst[1:0]),
	       .s_axi_awcache		(s_axi_awcache[3:0]),
	       .s_axi_awlen		(s_axi_awlen[7:0]),
	       .s_axi_awprot		(s_axi_awprot[2:0]),
	       .s_axi_awqos		(s_axi_awqos[3:0]),
	       .s_axi_awsize		(s_axi_awsize[2:0]),
	       .s_axi_awvalid		(s_axi_awvalid),
	       .s_axi_bready		(s_axi_bready),
	       .s_axi_rready		(s_axi_rready),
	       .s_axi_wdata		(s_axi_wdata[31:0]),
	       .s_axi_wlast		(s_axi_wlast),
	       .s_axi_wstrb		(s_axi_wstrb[3:0]),
	       .s_axi_wvalid		(s_axi_wvalid));
   
   /***********************************************************/
   /*RECEIVER                                                 */
   /***********************************************************/
   /*erx AUTO_TEMPLATE ( 
	                .mi_dout      (mi_rx_emmu_dout[]),
                        .mi_en        (mi_rx_emmu_sel),
                        .emwr_\(.*\)  (emaxi_emwr_\1[]),
                        .emrq_\(.*\)  (emaxi_emrq_\1[]),
                        .emrr_\(.*\)  (esaxi_emrr_\1[]),
                        );
   */
   
   
   erx erx(
	   /*AUTOINST*/
	   // Outputs
	   .ecfg_rx_debug		(ecfg_rx_debug[15:0]),
	   .ecfg_rx_datain		(ecfg_rx_datain[8:0]),
	   .mi_dout			(mi_rx_emmu_dout[31:0]), // Templated
	   .emwr_access			(emaxi_emwr_access),	 // Templated
	   .emwr_write			(emaxi_emwr_write),	 // Templated
	   .emwr_datamode		(emaxi_emwr_datamode[1:0]), // Templated
	   .emwr_ctrlmode		(emaxi_emwr_ctrlmode[3:0]), // Templated
	   .emwr_dstaddr		(emaxi_emwr_dstaddr[31:0]), // Templated
	   .emwr_data			(emaxi_emwr_data[31:0]), // Templated
	   .emwr_srcaddr		(emaxi_emwr_srcaddr[31:0]), // Templated
	   .emrq_access			(emaxi_emrq_access),	 // Templated
	   .emrq_write			(emaxi_emrq_write),	 // Templated
	   .emrq_datamode		(emaxi_emrq_datamode[1:0]), // Templated
	   .emrq_ctrlmode		(emaxi_emrq_ctrlmode[3:0]), // Templated
	   .emrq_dstaddr		(emaxi_emrq_dstaddr[31:0]), // Templated
	   .emrq_data			(emaxi_emrq_data[31:0]), // Templated
	   .emrq_srcaddr		(emaxi_emrq_srcaddr[31:0]), // Templated
	   .emrr_access			(esaxi_emrr_access),	 // Templated
	   .emrr_data			(esaxi_emrr_data[31:0]), // Templated
	   .rxo_wr_wait_p		(rxo_wr_wait_p),
	   .rxo_wr_wait_n		(rxo_wr_wait_n),
	   .rxo_rd_wait_p		(rxo_rd_wait_p),
	   .rxo_rd_wait_n		(rxo_rd_wait_n),
	   // Inputs
	   .reset			(reset),
	   .s_axi_aclk			(s_axi_aclk),
	   .m_axi_aclk			(m_axi_aclk),
	   .ecfg_rx_enable		(ecfg_rx_enable),
	   .ecfg_rx_mmu_enable		(ecfg_rx_mmu_enable),
	   .ecfg_rx_gpio_enable		(ecfg_rx_gpio_enable),
	   .ecfg_dataout		(ecfg_dataout[1:0]),
	   .mi_clk			(mi_clk),
	   .mi_en			(mi_rx_emmu_sel),	 // Templated
	   .mi_we			(mi_we),
	   .mi_addr			(mi_addr[15:0]),
	   .mi_din			(mi_din[31:0]),
	   .emwr_rd_en			(emaxi_emwr_rd_en),	 // Templated
	   .emrq_rd_en			(emaxi_emrq_rd_en),	 // Templated
	   .emrr_rd_en			(esaxi_emrr_rd_en),	 // Templated
	   .rxi_lclk_p			(rxi_lclk_p),
	   .rxi_lclk_n			(rxi_lclk_n),
	   .rxi_frame_p			(rxi_frame_p),
	   .rxi_frame_n			(rxi_frame_n),
	   .rxi_data_p			(rxi_data_p[7:0]),
	   .rxi_data_n			(rxi_data_n[7:0]));

   /***********************************************************/
   /*TRANSMITTER                                              */
   /***********************************************************/
   /*etx AUTO_TEMPLATE ( 
	                .mi_dout      (mi_tx_emmu_dout[]),
                        .mi_en        (mi_tx_emmu_sel),
                        .emwr_\(.*\)  (esaxi_emwr_\1[]),
                        .emrq_\(.*\)  (esaxi_emrq_\1[]),
                        .emrr_\(.*\)  (emaxi_emrr_\1[]),
                       );
   */
   
   etx etx(
	   /*AUTOINST*/
	   // Outputs
	   .ecfg_tx_datain		(ecfg_tx_datain[1:0]),
	   .ecfg_tx_debug		(ecfg_tx_debug[15:0]),
	   .emrq_progfull		(esaxi_emrq_progfull),	 // Templated
	   .emwr_progfull		(esaxi_emwr_progfull),	 // Templated
	   .emrr_progfull		(emaxi_emrr_progfull),	 // Templated
	   .txo_lclk_p			(txo_lclk_p),
	   .txo_lclk_n			(txo_lclk_n),
	   .txo_frame_p			(txo_frame_p),
	   .txo_frame_n			(txo_frame_n),
	   .txo_data_p			(txo_data_p[7:0]),
	   .txo_data_n			(txo_data_n[7:0]),
	   .mi_dout			(mi_tx_emmu_dout[31:0]), // Templated
	   // Inputs
	   .reset			(reset),
	   .tx_lclk			(tx_lclk),
	   .tx_lclk_out			(tx_lclk_out),
	   .tx_lclk_par			(tx_lclk_par),
	   .s_axi_aclk			(s_axi_aclk),
	   .m_axi_aclk			(m_axi_aclk),
	   .ecfg_tx_enable		(ecfg_tx_enable),
	   .ecfg_tx_gpio_enable		(ecfg_tx_gpio_enable),
	   .ecfg_tx_mmu_enable		(ecfg_tx_mmu_enable),
	   .ecfg_dataout		(ecfg_dataout[8:0]),
	   .emrq_access			(esaxi_emrq_access),	 // Templated
	   .emrq_write			(esaxi_emrq_write),	 // Templated
	   .emrq_datamode		(esaxi_emrq_datamode[1:0]), // Templated
	   .emrq_ctrlmode		(esaxi_emrq_ctrlmode[3:0]), // Templated
	   .emrq_dstaddr		(esaxi_emrq_dstaddr[31:0]), // Templated
	   .emrq_data			(esaxi_emrq_data[31:0]), // Templated
	   .emrq_srcaddr		(esaxi_emrq_srcaddr[31:0]), // Templated
	   .emwr_access			(esaxi_emwr_access),	 // Templated
	   .emwr_write			(esaxi_emwr_write),	 // Templated
	   .emwr_datamode		(esaxi_emwr_datamode[1:0]), // Templated
	   .emwr_ctrlmode		(esaxi_emwr_ctrlmode[3:0]), // Templated
	   .emwr_dstaddr		(esaxi_emwr_dstaddr[31:0]), // Templated
	   .emwr_data			(esaxi_emwr_data[31:0]), // Templated
	   .emwr_srcaddr		(esaxi_emwr_srcaddr[31:0]), // Templated
	   .emrr_access			(emaxi_emrr_access),	 // Templated
	   .emrr_write			(emaxi_emrr_write),	 // Templated
	   .emrr_datamode		(emaxi_emrr_datamode[1:0]), // Templated
	   .emrr_ctrlmode		(emaxi_emrr_ctrlmode[3:0]), // Templated
	   .emrr_dstaddr		(emaxi_emrr_dstaddr[31:0]), // Templated
	   .emrr_data			(emaxi_emrr_data[31:0]), // Templated
	   .emrr_srcaddr		(emaxi_emrr_srcaddr[31:0]), // Templated
	   .txi_wr_wait_p		(txi_wr_wait_p),
	   .txi_wr_wait_n		(txi_wr_wait_n),
	   .txi_rd_wait_p		(txi_rd_wait_p),
	   .txi_rd_wait_n		(txi_rd_wait_n),
	   .mi_clk			(mi_clk),
	   .mi_en			(mi_tx_emmu_sel),	 // Templated
	   .mi_we			(mi_we),
	   .mi_addr			(mi_addr[15:0]),
	   .mi_din			(mi_din[31:0]));
   
   /***********************************************************/
   /*ELINK CONFIGURATION REGISTERES                           */
   /***********************************************************/
  
   /*ecfg AUTO_TEMPLATE ( 
	                .mi_dout    (mi_ecfg_dout[]),
                        .mi_en      (mi_ecfg_sel),
                        .ecfg_reset (reset),
                        .clk        (mi_clk),
                      );
   */
   
   
   ecfg ecfg(
	     /*AUTOINST*/
	     // Outputs
	     .soft_reset		(soft_reset),
	     .mi_dout			(mi_ecfg_dout[31:0]),	 // Templated
	     .ecfg_tx_enable		(ecfg_tx_enable),
	     .ecfg_tx_mmu_enable	(ecfg_tx_mmu_enable),
	     .ecfg_tx_gpio_enable	(ecfg_tx_gpio_enable),
	     .ecfg_tx_ctrlmode		(ecfg_tx_ctrlmode[3:0]),
	     .ecfg_timeout_enable	(ecfg_timeout_enable),
	     .ecfg_rx_enable		(ecfg_rx_enable),
	     .ecfg_rx_mmu_enable	(ecfg_rx_mmu_enable),
	     .ecfg_rx_gpio_enable	(ecfg_rx_gpio_enable),
	     .ecfg_clk_settings		(ecfg_clk_settings[15:0]),
	     .ecfg_coreid		(ecfg_coreid[11:0]),
	     .ecfg_dataout		(ecfg_dataout[10:0]),
	     .embox_not_empty		(embox_not_empty),
	     .embox_full		(embox_full),
	     // Inputs
	     .hard_reset		(hard_reset),
	     .mi_clk			(mi_clk),
	     .mi_en			(mi_ecfg_sel),		 // Templated
	     .mi_we			(mi_we),
	     .mi_addr			(mi_addr[19:0]),
	     .mi_din			(mi_din[31:0]),
	     .ecfg_rx_datain		(ecfg_rx_datain[8:0]),
	     .ecfg_tx_datain		(ecfg_tx_datain[1:0]),
	     .ecfg_tx_debug		(ecfg_tx_debug[15:0]),
	     .ecfg_rx_debug		(ecfg_rx_debug[15:0]));

   
   /***********************************************************/
   /*GENERAL PURPOSE MAILBOX                                  */
   /***********************************************************/
   /*embox AUTO_TEMPLATE ( 
	                .mi_dout    (mi_embox_dout[]),
                        .mi_en      (mi_embox_sel),
                      );
   */
   
   embox embox(.clk			(s_axi_aclk),
	       /*AUTOINST*/
	       // Outputs
	       .mi_dout			(mi_embox_dout[DW-1:0]), // Templated
	       .embox_full		(embox_full),
	       .embox_not_empty		(embox_not_empty),
	       // Inputs
	       .reset			(reset),
	       .mi_en			(mi_embox_sel),		 // Templated
	       .mi_we			(mi_we),
	       .mi_addr			(mi_addr[19:0]),
	       .mi_din			(mi_din[DW-1:0]));
   
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
		    .tx_lclk_out	(tx_lclk_out),
		    .tx_lclk_par	(tx_lclk_par),
		    // Inputs
		    .clkin		(clkin),
		    .hard_reset		(hard_reset),
		    .ecfg_clk_settings	(ecfg_clk_settings[15:0]),
		    .bypass_clocks	(bypass_clocks[2:0]));
         
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../embox/hdl" "../../erx/hdl" "../../etx/hdl" "../../axi/hdl" "../../ecfg/hdl" "../../eclock/hdl")
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
