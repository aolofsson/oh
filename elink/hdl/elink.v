module elink(/*AUTOARG*/
   // Outputs
   colid, rowid, resetb_out, cclk_p, cclk_n, rx_wr_wait_p,
   rx_wr_wait_n, rx_rd_wait_p, rx_rd_wait_n, tx_lclk_p, tx_lclk_n,
   tx_frame_p, tx_frame_n, tx_data_p, tx_data_n, m_axi_araddr,
   m_axi_arburst, m_axi_arcache, m_axi_arid, m_axi_arlen,
   m_axi_arlock, m_axi_arprot, m_axi_arqos, m_axi_arsize,
   m_axi_arvalid, m_axi_awaddr, m_axi_awburst, m_axi_awcache,
   m_axi_awid, m_axi_awlen, m_axi_awlock, m_axi_awprot, m_axi_awqos,
   m_axi_awsize, m_axi_awvalid, m_axi_bready, m_axi_rready,
   m_axi_wdata, m_axi_wlast, m_axi_wstrb, m_axi_wvalid, s_axi_arready,
   s_axi_awready, s_axi_bid, s_axi_bresp, s_axi_bvalid, s_axi_rdata,
   s_axi_rid, s_axi_rlast, s_axi_rresp, s_axi_rvalid, s_axi_wready,
   embox_not_empty, embox_full,
   // Inputs
   reset_in, clkin, flag, rx_lclk_p, rx_lclk_n, rx_frame_p,
   rx_frame_n, rx_data_p, rx_data_n, tx_wr_wait_p, tx_wr_wait_n,
   tx_rd_wait_p, tx_rd_wait_n, m_axi_aclk, m_axi_aresetn,
   m_axi_arready, m_axi_awready, m_axi_bid, m_axi_bresp, m_axi_bvalid,
   m_axi_rdata, m_axi_rid, m_axi_rlast, m_axi_rresp, m_axi_rvalid,
   m_axi_wready, s_axi_aclk, s_axi_aresetn, s_axi_araddr,
   s_axi_arburst, s_axi_arcache, s_axi_arid, s_axi_arlen,
   s_axi_arlock, s_axi_arprot, s_axi_arqos, s_axi_arregion,
   s_axi_arsize, s_axi_arvalid, s_axi_awaddr, s_axi_awburst,
   s_axi_awcache, s_axi_awid, s_axi_awlen, s_axi_awlock, s_axi_awprot,
   s_axi_awqos, s_axi_awregion, s_axi_awsize, s_axi_awvalid,
   s_axi_bready, s_axi_rready, s_axi_wdata, s_axi_wlast, s_axi_wstrb,
   s_axi_wvalid
   );
   parameter DEF_COREID  = 12'h810;
   parameter AW          = 32;
   parameter DW          = 32;
   parameter IDW         = 32;
   parameter RFAW        = 13;
   parameter MW          = 44;
   parameter FW          = 1;
   /****************************/
   /*BASIC INPUTS              */
   /****************************/
   input        reset_in;       //active high synhcronous hardware reset
   input 	clkin;          //primary clock input
   
   /********************************/
   /*EPIPHANY INTERFACE (I/O PINS) */
   /********************************/          

   //Basic
   input  [FW-1:0] flag;                   //elag interrupts (1 per chip)
   output [3:0]    colid;                  //epiphany colid
   output [3:0]    rowid;                  //epiphany rowid
   output 	   resetb_out;             //chip reset for Epiphany (active low)
   output 	   cclk_p, cclk_n;         //high speed clock (1GHz) to Epiphany

   //Receiver
   input        rx_lclk_p,   rx_lclk_n;    //link rx clock input
   input        rx_frame_p,  rx_frame_n;   //link rx frame signal
   input [7:0] 	rx_data_p,   rx_data_n;    //link rx data
   output       rx_wr_wait_p,rx_wr_wait_n; //link rx write pushback output
   output       rx_rd_wait_p,rx_rd_wait_n; //link rx read pushback output
   
   //Transmitter
   output       tx_lclk_p,   tx_lclk_n;    //link tx clock output
   output       tx_frame_p,  tx_frame_n;   //link tx frame signal
   output [7:0] tx_data_p,   tx_data_n;    //link tx data
   input 	tx_wr_wait_p,tx_wr_wait_n; //link tx write pushback input
   input 	tx_rd_wait_p,tx_rd_wait_n; //link tx read pushback input

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
   output [0:0]  m_axi_arid;    //address ID
   output [7:0]  m_axi_arlen;   //burst length (number of data transfers)
   output [0:0]  m_axi_arlock;  //lock type (atomic characteristics)
   output [2:0]  m_axi_arprot;  //protection type
   output [3:0]  m_axi_arqos;   //quality of service (setting?)
   input 	 m_axi_arready; //read ready
   output [2:0]  m_axi_arsize;  //burst size (the size of each transfer)
   output 	 m_axi_arvalid; //write address valid

   //Write address channel
   output [31:0] m_axi_awaddr;
   output [1:0]  m_axi_awburst; 
   output [3:0]  m_axi_awcache;
   output [0:0]  m_axi_awid;
   output [7:0]  m_axi_awlen;
   output [0:0]  m_axi_awlock;
   output [2:0]  m_axi_awprot;
   output [3:0]  m_axi_awqos;
   input 	 m_axi_awready;
   output [2:0]  m_axi_awsize;
   output 	 m_axi_awvalid;
   
   //Buffered write response channel
   input [0:0] 	 m_axi_bid;    //response tag
   output 	 m_axi_bready;
   input [1:0] 	 m_axi_bresp;
   input 	 m_axi_bvalid;
   
   //Read channel
   input [63:0]  m_axi_rdata;
   input [0:0] 	 m_axi_rid;     //read id tag
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
   input [11:0]  s_axi_arid;
   input [7:0] 	 s_axi_arlen;
   input [0:0] 	 s_axi_arlock;
   input [2:0] 	 s_axi_arprot;
   input [3:0] 	 s_axi_arqos;
   output 	 s_axi_arready;
   input [3:0] 	 s_axi_arregion;
   input [2:0] 	 s_axi_arsize;
   input 	 s_axi_arvalid;

   //Write address channel
   input [29:0]  s_axi_awaddr;
   input [1:0] 	 s_axi_awburst;
   input [3:0] 	 s_axi_awcache;
   input [11:0]  s_axi_awid;
   input [7:0] 	 s_axi_awlen;
   input [0:0] 	 s_axi_awlock;
   input [2:0] 	 s_axi_awprot;
   input [3:0] 	 s_axi_awqos;
   output 	 s_axi_awready;
   input [3:0] 	 s_axi_awregion;
   input [2:0] 	 s_axi_awsize;
   input 	 s_axi_awvalid;

   //Buffered write response channel
   output [11:0] s_axi_bid;
   input 	 s_axi_bready;
   output [1:0]  s_axi_bresp;
   output 	 s_axi_bvalid;

   //Read channel
   output [31:0] s_axi_rdata;
   output [11:0] s_axi_rid;
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
   wire			ecfg_axi_timeout_enable;// From ecfg of ecfg.v
   wire			ecfg_cclk_bypass;	// From ecfg of ecfg.v
   wire [3:0]		ecfg_cclk_div;		// From ecfg of ecfg.v
   wire			ecfg_cclk_en;		// From ecfg of ecfg.v
   wire [3:0]		ecfg_cclk_pllcfg;	// From ecfg of ecfg.v
   wire [11:0]		ecfg_coreid;		// From ecfg of ecfg.v
   wire [10:0]		ecfg_dataout;		// From ecfg of ecfg.v
   wire [8:0]		ecfg_rx_datain;		// From erx of erx.v
   wire [15:0]		ecfg_rx_debug;		// From erx of erx.v
   wire			ecfg_rx_enable;		// From ecfg of ecfg.v
   wire			ecfg_rx_gpio_enable;	// From ecfg of ecfg.v
   wire			ecfg_rx_mmu_enable;	// From ecfg of ecfg.v
   wire			ecfg_tx_clkbypass;	// From ecfg of ecfg.v
   wire [3:0]		ecfg_tx_clkdiv;		// From ecfg of ecfg.v
   wire [3:0]		ecfg_tx_ctrlmode;	// From ecfg of ecfg.v
   wire [1:0]		ecfg_tx_datain;		// From etx of etx.v
   wire [15:0]		ecfg_tx_debug;		// From etx of etx.v
   wire			ecfg_tx_enable;		// From ecfg of ecfg.v
   wire			ecfg_tx_gpio_enable;	// From ecfg of ecfg.v
   wire			ecfg_tx_mmu_enable;	// From ecfg of ecfg.v
   wire			emaxi_emrq_empty;	// From erx of erx.v
   wire [102:0]		emaxi_emrq_rd_data;	// From erx of erx.v
   wire			emaxi_emrq_rd_en;	// From emaxi of emaxi.v
   wire			emaxi_emrr_full;	// From etx of etx.v
   wire			emaxi_emrr_prog_full;	// From etx of etx.v
   wire [102:0]		emaxi_emrr_wr_data;	// From emaxi of emaxi.v
   wire			emaxi_emrr_wr_en;	// From emaxi of emaxi.v
   wire			emaxi_emwr_empty;	// From erx of erx.v
   wire [102:0]		emaxi_emwr_rd_data;	// From erx of erx.v
   wire			emaxi_emwr_rd_en;	// From emaxi of emaxi.v
   wire			emrq_full;		// From esaxi_mux of esaxi_mux.v
   wire			emrq_prog_full;		// From esaxi_mux of esaxi_mux.v
   wire [102:0]		emrq_wr_data;		// From esaxi of esaxi.v
   wire			emrq_wr_en;		// From esaxi of esaxi.v
   wire			emrr_empty;		// From esaxi_mux of esaxi_mux.v
   wire [31:0]		emrr_rd_data;		// From esaxi_mux of esaxi_mux.v
   wire			emrr_rd_en;		// From esaxi of esaxi.v
   wire			emwr_full;		// From esaxi_mux of esaxi_mux.v
   wire			emwr_prog_full;		// From esaxi_mux of esaxi_mux.v
   wire [102:0]		emwr_wr_data;		// From esaxi of esaxi.v
   wire			emwr_wr_en;		// From esaxi of esaxi.v
   wire			esaxi_emrq_full;	// From etx of etx.v
   wire			esaxi_emrq_prog_full;	// From etx of etx.v
   wire [102:0]		esaxi_emrq_wr_data;	// From esaxi_mux of esaxi_mux.v
   wire			esaxi_emrq_wr_en;	// From esaxi_mux of esaxi_mux.v
   wire			esaxi_emrr_empty;	// From erx of erx.v
   wire [102:0]		esaxi_emrr_rd_data;	// From erx of erx.v
   wire			esaxi_emrr_rd_en;	// From esaxi_mux of esaxi_mux.v
   wire			esaxi_emwr_full;	// From etx of etx.v
   wire			esaxi_emwr_prog_full;	// From etx of etx.v
   wire [102:0]		esaxi_emwr_wr_data;	// From esaxi_mux of esaxi_mux.v
   wire			esaxi_emwr_wr_en;	// From esaxi_mux of esaxi_mux.v
   wire [19:0]		mi_addr;		// From esaxi_mux of esaxi_mux.v
   wire			mi_clk;			// From esaxi_mux of esaxi_mux.v
   wire [31:0]		mi_din;			// From esaxi_mux of esaxi_mux.v
   wire [31:0]		mi_ecfg_dout;		// From ecfg of ecfg.v
   wire			mi_ecfg_en;		// From esaxi_mux of esaxi_mux.v
   wire [DW-1:0]	mi_embox_dout;		// From embox of embox.v
   wire			mi_embox_en;		// From esaxi_mux of esaxi_mux.v
   wire [31:0]		mi_rx_emmu_dout;	// From erx of erx.v
   wire			mi_rx_emmu_en;		// From esaxi_mux of esaxi_mux.v
   wire [31:0]		mi_tx_emmu_dout;	// From etx of etx.v
   wire			mi_tx_emmu_en;		// From esaxi_mux of esaxi_mux.v
   wire			mi_we;			// From esaxi_mux of esaxi_mux.v
   wire			reset;			// From ecfg of ecfg.v
   wire			tx_lclk;		// From eclock of eclock.v
   wire			tx_lclk_out;		// From eclock of eclock.v
   wire			tx_lclk_par;		// From eclock of eclock.v
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
   
   emaxi emaxi(.m00_axi_awuser		(),
	       .m00_axi_wuser		(),
	       .m00_axi_aruser          (),
	       .m00_axi_buser		(1'b0), 
	       .m00_axi_ruser		(1'b0),
	       .m00_axi_awid		(m_axi_awid[0:0]),
	       .m00_axi_awaddr		(m_axi_awaddr[31:0]),
	       .m00_axi_wdata		(m_axi_wdata[63:0]),
	       .m00_axi_wstrb		(m_axi_wstrb[7:0]),
	       .m00_axi_arid		(m_axi_arid[0:0]),
	       .m00_axi_araddr		(m_axi_araddr[31:0]),
	       .m00_axi_rid		(m_axi_rid[0:0]),
	       .m00_axi_rdata		(m_axi_rdata[63:0]),
	       .m00_axi_bid		(m_axi_bid[0:0]),
	       /*AUTOINST*/
	       // Outputs
	       .emwr_rd_en		(emaxi_emwr_rd_en),	 // Templated
	       .emrq_rd_en		(emaxi_emrq_rd_en),	 // Templated
	       .emrr_wr_data		(emaxi_emrr_wr_data[102:0]), // Templated
	       .emrr_wr_en		(emaxi_emrr_wr_en),	 // Templated
	       .m00_axi_awlen		(m_axi_awlen[7:0]),	 // Templated
	       .m00_axi_awsize		(m_axi_awsize[2:0]),	 // Templated
	       .m00_axi_awburst		(m_axi_awburst[1:0]),	 // Templated
	       .m00_axi_awlock		(m_axi_awlock),		 // Templated
	       .m00_axi_awcache		(m_axi_awcache[3:0]),	 // Templated
	       .m00_axi_awprot		(m_axi_awprot[2:0]),	 // Templated
	       .m00_axi_awqos		(m_axi_awqos[3:0]),	 // Templated
	       .m00_axi_awvalid		(m_axi_awvalid),	 // Templated
	       .m00_axi_wlast		(m_axi_wlast),		 // Templated
	       .m00_axi_wvalid		(m_axi_wvalid),		 // Templated
	       .m00_axi_bready		(m_axi_bready),		 // Templated
	       .m00_axi_arlen		(m_axi_arlen[7:0]),	 // Templated
	       .m00_axi_arsize		(m_axi_arsize[2:0]),	 // Templated
	       .m00_axi_arburst		(m_axi_arburst[1:0]),	 // Templated
	       .m00_axi_arlock		(m_axi_arlock),		 // Templated
	       .m00_axi_arcache		(m_axi_arcache[3:0]),	 // Templated
	       .m00_axi_arprot		(m_axi_arprot[2:0]),	 // Templated
	       .m00_axi_arqos		(m_axi_arqos[3:0]),	 // Templated
	       .m00_axi_arvalid		(m_axi_arvalid),	 // Templated
	       .m00_axi_rready		(m_axi_rready),		 // Templated
	       // Inputs
	       .emwr_rd_data		(emaxi_emwr_rd_data[102:0]), // Templated
	       .emwr_empty		(emaxi_emwr_empty),	 // Templated
	       .emrq_rd_data		(emaxi_emrq_rd_data[102:0]), // Templated
	       .emrq_empty		(emaxi_emrq_empty),	 // Templated
	       .emrr_full		(emaxi_emrr_full),	 // Templated
	       .emrr_prog_full		(emaxi_emrr_prog_full),	 // Templated
	       .m00_axi_aclk		(m_axi_aclk),		 // Templated
	       .m00_axi_aresetn		(m_axi_aresetn),	 // Templated
	       .m00_axi_awready		(m_axi_awready),	 // Templated
	       .m00_axi_wready		(m_axi_wready),		 // Templated
	       .m00_axi_bresp		(m_axi_bresp[1:0]),	 // Templated
	       .m00_axi_bvalid		(m_axi_bvalid),		 // Templated
	       .m00_axi_arready		(m_axi_arready),	 // Templated
	       .m00_axi_rresp		(m_axi_rresp[1:0]),	 // Templated
	       .m00_axi_rlast		(m_axi_rlast),		 // Templated
	       .m00_axi_rvalid		(m_axi_rvalid));		 // Templated

   /***********************************************************/
   /*AXI SLAVE                                                */
   /***********************************************************/
   /*esaxi AUTO_TEMPLATE ( 
                        // Outputs
	                .s00_\(.*\)       (s_\1[]),
                        );
   */
   
   esaxi esaxi(.s00_axi_buser		(),
	       .s00_axi_ruser		(),
	       .s00_axi_awuser		(),
	       .s00_axi_wuser		(1'b0),
	       .s00_axi_aruser		(1'b0),
	       .s00_axi_bid		(s_axi_bid[11:0]),
	       .s00_axi_rid		(s_axi_rid[11:0]),
	       .s00_axi_rdata		(s_axi_rdata[31:0]),
	       .s00_axi_awid		(s_axi_awid[11:0]),
	       .s00_axi_awaddr		(s_axi_awaddr[29:0]),
	       .s00_axi_wdata		(s_axi_wdata[31:0]),
	       .s00_axi_wstrb		(s_axi_wstrb[3:0]),
	       .s00_axi_arid		(s_axi_arid[11:0]),
	       .s00_axi_araddr		(s_axi_araddr[29:0]),
	       /*AUTOINST*/
	       // Outputs
	       .emwr_wr_data		(emwr_wr_data[102:0]),
	       .emwr_wr_en		(emwr_wr_en),
	       .emrq_wr_data		(emrq_wr_data[102:0]),
	       .emrq_wr_en		(emrq_wr_en),
	       .emrr_rd_en		(emrr_rd_en),
	       .s00_axi_awready		(s_axi_awready),	 // Templated
	       .s00_axi_wready		(s_axi_wready),		 // Templated
	       .s00_axi_bresp		(s_axi_bresp[1:0]),	 // Templated
	       .s00_axi_bvalid		(s_axi_bvalid),		 // Templated
	       .s00_axi_arready		(s_axi_arready),	 // Templated
	       .s00_axi_rresp		(s_axi_rresp[1:0]),	 // Templated
	       .s00_axi_rlast		(s_axi_rlast),		 // Templated
	       .s00_axi_rvalid		(s_axi_rvalid),		 // Templated
	       // Inputs
	       .emwr_full		(emwr_full),
	       .emwr_prog_full		(emwr_prog_full),
	       .emrq_full		(emrq_full),
	       .emrq_prog_full		(emrq_prog_full),
	       .emrr_rd_data		(emrr_rd_data[102:0]),
	       .emrr_empty		(emrr_empty),
	       .ecfg_tx_ctrlmode	(ecfg_tx_ctrlmode[3:0]),
	       .ecfg_coreid		(ecfg_coreid[11:0]),
	       .ecfg_axi_timeout_enable	(ecfg_axi_timeout_enable),
	       .s00_axi_aclk		(s_axi_aclk),		 // Templated
	       .s00_axi_aresetn		(s_axi_aresetn),	 // Templated
	       .s00_axi_awlen		(s_axi_awlen[7:0]),	 // Templated
	       .s00_axi_awsize		(s_axi_awsize[2:0]),	 // Templated
	       .s00_axi_awburst		(s_axi_awburst[1:0]),	 // Templated
	       .s00_axi_awlock		(s_axi_awlock),		 // Templated
	       .s00_axi_awcache		(s_axi_awcache[3:0]),	 // Templated
	       .s00_axi_awprot		(s_axi_awprot[2:0]),	 // Templated
	       .s00_axi_awqos		(s_axi_awqos[3:0]),	 // Templated
	       .s00_axi_awregion	(s_axi_awregion[3:0]),	 // Templated
	       .s00_axi_awvalid		(s_axi_awvalid),	 // Templated
	       .s00_axi_wlast		(s_axi_wlast),		 // Templated
	       .s00_axi_wvalid		(s_axi_wvalid),		 // Templated
	       .s00_axi_bready		(s_axi_bready),		 // Templated
	       .s00_axi_arlen		(s_axi_arlen[7:0]),	 // Templated
	       .s00_axi_arsize		(s_axi_arsize[2:0]),	 // Templated
	       .s00_axi_arburst		(s_axi_arburst[1:0]),	 // Templated
	       .s00_axi_arlock		(s_axi_arlock),		 // Templated
	       .s00_axi_arcache		(s_axi_arcache[3:0]),	 // Templated
	       .s00_axi_arprot		(s_axi_arprot[2:0]),	 // Templated
	       .s00_axi_arqos		(s_axi_arqos[3:0]),	 // Templated
	       .s00_axi_arregion	(s_axi_arregion[3:0]),	 // Templated
	       .s00_axi_arvalid		(s_axi_arvalid),	 // Templated
	       .s00_axi_rready		(s_axi_rready));		 // Templated
   
   /***********************************************************/
   /*ELINK CLOCK GENERATOR                                    */
   /***********************************************************/

   eclock eclock(
		 /*AUTOINST*/
		 // Outputs
		 .cclk_p		(cclk_p),
		 .cclk_n		(cclk_n),
		 .tx_lclk		(tx_lclk),
		 .tx_lclk_out		(tx_lclk_out),
		 .tx_lclk_par		(tx_lclk_par),
		 // Inputs
		 .clkin			(clkin),
		 .reset			(reset),
		 .ecfg_cclk_en		(ecfg_cclk_en),
		 .ecfg_cclk_div		(ecfg_cclk_div[3:0]),
		 .ecfg_cclk_pllcfg	(ecfg_cclk_pllcfg[3:0]),
		 .ecfg_cclk_bypass	(ecfg_cclk_bypass),
		 .ecfg_tx_clkbypass	(ecfg_tx_clkbypass));
   
   /***********************************************************/
   /*RECEIVER                                                 */
   /***********************************************************/
   /*erx AUTO_TEMPLATE ( 
	                .mi_dout   (mi_rx_emmu_dout[]),
                        .mi_en     (mi_rx_emmu_en),
                        );
   */
   
   
   erx erx(
	   /*AUTOINST*/
	   // Outputs
	   .ecfg_rx_debug		(ecfg_rx_debug[15:0]),
	   .ecfg_rx_datain		(ecfg_rx_datain[8:0]),
	   .mi_dout			(mi_rx_emmu_dout[31:0]), // Templated
	   .emaxi_emwr_empty		(emaxi_emwr_empty),
	   .emaxi_emwr_rd_data		(emaxi_emwr_rd_data[102:0]),
	   .emaxi_emrq_empty		(emaxi_emrq_empty),
	   .emaxi_emrq_rd_data		(emaxi_emrq_rd_data[102:0]),
	   .esaxi_emrr_empty		(esaxi_emrr_empty),
	   .esaxi_emrr_rd_data		(esaxi_emrr_rd_data[102:0]),
	   .rx_wr_wait_p		(rx_wr_wait_p),
	   .rx_wr_wait_n		(rx_wr_wait_n),
	   .rx_rd_wait_p		(rx_rd_wait_p),
	   .rx_rd_wait_n		(rx_rd_wait_n),
	   // Inputs
	   .reset			(reset),
	   .s_axi_aclk			(s_axi_aclk),
	   .m_axi_aclk			(m_axi_aclk),
	   .ecfg_rx_enable		(ecfg_rx_enable),
	   .ecfg_rx_mmu_enable		(ecfg_rx_mmu_enable),
	   .ecfg_rx_gpio_enable		(ecfg_rx_gpio_enable),
	   .ecfg_dataout		(ecfg_dataout[1:0]),
	   .mi_clk			(mi_clk),
	   .mi_en			(mi_rx_emmu_en),	 // Templated
	   .mi_we			(mi_we),
	   .mi_addr			(mi_addr[15:0]),
	   .mi_din			(mi_din[31:0]),
	   .emaxi_emwr_rd_en		(emaxi_emwr_rd_en),
	   .emaxi_emrq_rd_en		(emaxi_emrq_rd_en),
	   .esaxi_emrr_rd_en		(esaxi_emrr_rd_en),
	   .rx_lclk_p			(rx_lclk_p),
	   .rx_lclk_n			(rx_lclk_n),
	   .rx_frame_p			(rx_frame_p),
	   .rx_frame_n			(rx_frame_n),
	   .rx_data_p			(rx_data_p[7:0]),
	   .rx_data_n			(rx_data_n[7:0]));

   /***********************************************************/
   /*TRANSMITTER                                              */
   /***********************************************************/
   /*etx AUTO_TEMPLATE ( 
	                .mi_dout   (mi_tx_emmu_dout[]),
                        .mi_en     (mi_tx_emmu_en),
                        );
   */
   
   etx etx(
	   /*AUTOINST*/
	   // Outputs
	   .ecfg_tx_datain		(ecfg_tx_datain[1:0]),
	   .ecfg_tx_debug		(ecfg_tx_debug[15:0]),
	   .esaxi_emrq_full		(esaxi_emrq_full),
	   .esaxi_emrq_prog_full	(esaxi_emrq_prog_full),
	   .esaxi_emwr_full		(esaxi_emwr_full),
	   .esaxi_emwr_prog_full	(esaxi_emwr_prog_full),
	   .emaxi_emrr_full		(emaxi_emrr_full),
	   .emaxi_emrr_prog_full	(emaxi_emrr_prog_full),
	   .tx_lclk_p			(tx_lclk_p),
	   .tx_lclk_n			(tx_lclk_n),
	   .tx_frame_p			(tx_frame_p),
	   .tx_frame_n			(tx_frame_n),
	   .tx_data_p			(tx_data_p[7:0]),
	   .tx_data_n			(tx_data_n[7:0]),
	   .mi_dout			(mi_tx_emmu_dout[31:0]), // Templated
	   // Inputs
	   .reset			(reset),
	   .tx_lclk			(tx_lclk),
	   .tx_lclk_out			(tx_lclk_out),
	   .tx_lclk_par			(tx_lclk_par),
	   .s_axi_aclk			(s_axi_aclk),
	   .m_axi_aclk			(m_axi_aclk),
	   .ecfg_tx_clkdiv		(ecfg_tx_clkdiv[3:0]),
	   .ecfg_tx_enable		(ecfg_tx_enable),
	   .ecfg_tx_gpio_enable		(ecfg_tx_gpio_enable),
	   .ecfg_tx_mmu_enable		(ecfg_tx_mmu_enable),
	   .ecfg_dataout		(ecfg_dataout[8:0]),
	   .esaxi_emrq_wr_en		(esaxi_emrq_wr_en),
	   .esaxi_emrq_wr_data		(esaxi_emrq_wr_data[102:0]),
	   .esaxi_emwr_wr_en		(esaxi_emwr_wr_en),
	   .esaxi_emwr_wr_data		(esaxi_emwr_wr_data[102:0]),
	   .emaxi_emrr_wr_en		(emaxi_emrr_wr_en),
	   .emaxi_emrr_wr_data		(emaxi_emrr_wr_data[102:0]),
	   .tx_wr_wait_p		(tx_wr_wait_p),
	   .tx_wr_wait_n		(tx_wr_wait_n),
	   .tx_rd_wait_p		(tx_rd_wait_p),
	   .tx_rd_wait_n		(tx_rd_wait_n),
	   .mi_clk			(mi_clk),
	   .mi_en			(mi_tx_emmu_en),	 // Templated
	   .mi_we			(mi_we),
	   .mi_addr			(mi_addr[15:0]),
	   .mi_din			(mi_din[31:0]));
   
   /***********************************************************/
   /*ELINK CONFIGURATION REGISTERES                           */
   /***********************************************************/
  
   /*ecfg AUTO_TEMPLATE ( 
	                .mi_dout    (mi_ecfg_dout[]),
                        .mi_en      (mi_ecfg_en),
                        .ecfg_reset (reset),
                        .clk        (mi_clk),
                      );
   */
   
   
   ecfg ecfg(
	     .ecfg_resetb		(resetb_out),
	     .hw_reset			(reset_in),
	     /*AUTOINST*/
	     // Outputs
	     .mi_dout			(mi_ecfg_dout[31:0]),	 // Templated
	     .ecfg_reset		(reset),		 // Templated
	     .ecfg_tx_enable		(ecfg_tx_enable),
	     .ecfg_tx_mmu_enable	(ecfg_tx_mmu_enable),
	     .ecfg_tx_gpio_enable	(ecfg_tx_gpio_enable),
	     .ecfg_tx_ctrlmode		(ecfg_tx_ctrlmode[3:0]),
	     .ecfg_tx_clkdiv		(ecfg_tx_clkdiv[3:0]),
	     .ecfg_tx_clkbypass		(ecfg_tx_clkbypass),
	     .ecfg_axi_timeout_enable	(ecfg_axi_timeout_enable),
	     .ecfg_rx_enable		(ecfg_rx_enable),
	     .ecfg_rx_mmu_enable	(ecfg_rx_mmu_enable),
	     .ecfg_rx_gpio_enable	(ecfg_rx_gpio_enable),
	     .ecfg_cclk_en		(ecfg_cclk_en),
	     .ecfg_cclk_div		(ecfg_cclk_div[3:0]),
	     .ecfg_cclk_pllcfg		(ecfg_cclk_pllcfg[3:0]),
	     .ecfg_cclk_bypass		(ecfg_cclk_bypass),
	     .ecfg_coreid		(ecfg_coreid[11:0]),
	     .ecfg_dataout		(ecfg_dataout[10:0]),
	     .embox_not_empty		(embox_not_empty),
	     .embox_full		(embox_full),
	     // Inputs
	     .clk			(mi_clk),		 // Templated
	     .mi_en			(mi_ecfg_en),		 // Templated
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
                        .mi_en      (mi_embox_en),
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
	       .mi_en			(mi_embox_en),		 // Templated
	       .mi_we			(mi_we),
	       .mi_addr			(mi_addr[19:0]),
	       .mi_din			(mi_din[DW-1:0]));
   
   /***********************************************************/
   /*REGISTER INTERFACE MUXING                                */
   /***********************************************************/

   esaxi_mux esaxi_mux(.clk		(s_axi_aclk),
		       /*AUTOINST*/
		       // Outputs
		       .emwr_full	(emwr_full),
		       .emwr_prog_full	(emwr_prog_full),
		       .emrq_full	(emrq_full),
		       .emrq_prog_full	(emrq_prog_full),
		       .emrr_rd_data	(emrr_rd_data[31:0]),
		       .emrr_empty	(emrr_empty),
		       .esaxi_emwr_wr_data(esaxi_emwr_wr_data[102:0]),
		       .esaxi_emwr_wr_en(esaxi_emwr_wr_en),
		       .esaxi_emrq_wr_data(esaxi_emrq_wr_data[102:0]),
		       .esaxi_emrq_wr_en(esaxi_emrq_wr_en),
		       .esaxi_emrr_rd_en(esaxi_emrr_rd_en),
		       .mi_clk		(mi_clk),
		       .mi_rx_emmu_en	(mi_rx_emmu_en),
		       .mi_tx_emmu_en	(mi_tx_emmu_en),
		       .mi_ecfg_en	(mi_ecfg_en),
		       .mi_embox_en	(mi_embox_en),
		       .mi_we		(mi_we),
		       .mi_addr		(mi_addr[19:0]),
		       .mi_din		(mi_din[31:0]),
		       // Inputs
		       .emwr_wr_data	(emwr_wr_data[102:0]),
		       .emwr_wr_en	(emwr_wr_en),
		       .emrq_wr_data	(emrq_wr_data[102:0]),
		       .emrq_wr_en	(emrq_wr_en),
		       .emrr_rd_en	(emrr_rd_en),
		       .esaxi_emwr_full	(esaxi_emwr_full),
		       .esaxi_emwr_prog_full(esaxi_emwr_prog_full),
		       .esaxi_emrq_full	(esaxi_emrq_full),
		       .esaxi_emrq_prog_full(esaxi_emrq_prog_full),
		       .esaxi_emrr_rd_data(esaxi_emrr_rd_data[31:0]),
		       .esaxi_emrr_empty(esaxi_emrr_empty),
		       .mi_ecfg_dout	(mi_ecfg_dout[DW-1:0]),
		       .mi_tx_emmu_dout	(mi_tx_emmu_dout[DW-1:0]),
		       .mi_rx_emmu_dout	(mi_rx_emmu_dout[DW-1:0]),
		       .mi_embox_dout	(mi_embox_dout[DW-1:0]));

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
