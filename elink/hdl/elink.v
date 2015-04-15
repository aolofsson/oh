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
   output 	cclk_p, cclk_n;        //high speed clock (1GHz) to Epiphany

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
   input 	 m_axi_aclk;
   input 	 m_axi_aresetn;

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
   
   //Buffered write response channel
   output 	 m_axi_bready;
   input [1:0] 	 m_axi_bresp;
   input 	 m_axi_bvalid;
   
   //Read channel
   input [63:0]  m_axi_rdata;
   input 	 m_axi_rlast;   //indicates last transfer of a burst
   output 	 m_axi_rready;  //read ready signal
   input [1:0] 	 m_axi_rresp;
   input 	 m_axi_rvalid;
   
   //Write channel
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
