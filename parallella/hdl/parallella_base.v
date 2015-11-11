//NOTE: module name differs from file name to simplify Vivado block design
//Many verilog versions to one block design...
module parallella_base(/*AUTOARG*/
   // Outputs
   s_axi_wready, s_axi_rvalid, s_axi_rresp, s_axi_rlast, s_axi_rid,
   s_axi_rdata, s_axi_bvalid, s_axi_bresp, s_axi_bid, s_axi_awready,
   s_axi_arready, m_axi_wvalid, m_axi_wstrb, m_axi_wlast, m_axi_wid,
   m_axi_wdata, m_axi_rready, m_axi_bready, m_axi_awvalid,
   m_axi_awsize, m_axi_awqos, m_axi_awprot, m_axi_awlock, m_axi_awlen,
   m_axi_awid, m_axi_awcache, m_axi_awburst, m_axi_awaddr,
   m_axi_arvalid, m_axi_arsize, m_axi_arqos, m_axi_arprot,
   m_axi_arlock, m_axi_arlen, m_axi_arid, m_axi_arcache,
   m_axi_arburst, m_axi_araddr, cclk_n, cclk_p, chip_nreset, chipid,
   elink_active, mailbox_not_empty, timeout, i2c_scl_i, i2c_sda_i,
   ps_gpio_i, txo_data_n, txo_data_p, txo_frame_n, txo_frame_p,
   txo_lclk_n, txo_lclk_p, rxo_rd_wait_n, rxo_rd_wait_p,
   rxo_wr_wait_n, rxo_wr_wait_p,
   // Inouts
   i2c_scl, i2c_sda, gpio_n, gpio_p,
   // Inputs
   s_axi_wvalid, s_axi_wstrb, s_axi_wlast, s_axi_wid, s_axi_wdata,
   s_axi_rready, s_axi_bready, s_axi_awvalid, s_axi_awsize,
   s_axi_awqos, s_axi_awprot, s_axi_awlock, s_axi_awlen, s_axi_awid,
   s_axi_awcache, s_axi_awburst, s_axi_awaddr, s_axi_arvalid,
   s_axi_arsize, s_axi_arqos, s_axi_arprot, s_axi_arlock, s_axi_arlen,
   s_axi_arid, s_axi_aresetn, s_axi_arcache, s_axi_arburst,
   s_axi_araddr, m_axi_wready, m_axi_rvalid, m_axi_rresp, m_axi_rlast,
   m_axi_rid, m_axi_rdata, m_axi_bvalid, m_axi_bresp, m_axi_bid,
   m_axi_awready, m_axi_arready, m_axi_aresetn, sys_clk, sys_nreset,
   i2c_scl_o, i2c_scl_t, i2c_sda_o, i2c_sda_t, ps_gpio_o, ps_gpio_t,
   txi_rd_wait_n, txi_rd_wait_p, txi_wr_wait_n, txi_wr_wait_p,
   rxi_data_n, rxi_data_p, rxi_frame_n, rxi_frame_p, rxi_lclk_n,
   rxi_lclk_p
   );

   parameter AW          = 32;
   parameter DW          = 32; 
   parameter PW          = 104;      //packet width   
   parameter ID          = 12'h810;
   parameter S_IDW       = 12;       //ID width for S_AXI
   parameter M_IDW       = 6;        //ID width for M_AXI
   parameter IOSTD_ELINK = "LVDS_25";
   parameter NGPIO       = 24;
   parameter NPS         = 64;       //Number of PS signals

   //RESET+CLK
   input		sys_clk;		// To axe_elink of axi_elink.v
   input		sys_nreset;		// To axe_elink of axi_elink.v

   //MISC
   output		cclk_n;			// From axe_elink of axi_elink.v
   output		cclk_p;			// From axe_elink of axi_elink.v
   output		chip_nreset;		// From axe_elink of axi_elink.v
   output [11:0]	chipid;			// From axe_elink of axi_elink.v
   output		elink_active;		// From axe_elink of axi_elink.v
   output		mailbox_not_empty;	// From axe_elink of axi_elink.v
   output		timeout;		// From axe_elink of axi_elink.v
   
   //I2C
   output		i2c_scl_i;		// From pi2c of pi2c.v
   output		i2c_sda_i;		// From pi2c of pi2c.v
   input		i2c_scl_o;		// To pi2c of pi2c.v
   input		i2c_scl_t;		// To pi2c of pi2c.v
   input		i2c_sda_o;		// To pi2c of pi2c.v
   input		i2c_sda_t;		// To pi2c of pi2c.v
    inout		i2c_scl;		// To/From pi2c of pi2c.v
   inout		i2c_sda;		// To/From pi2c of pi2c.v

   //GPIO
   input [NPS-1:0]	ps_gpio_o;		// To pgpio of pgpio.v
   input [NPS-1:0]	ps_gpio_t;		// To pgpio of pgpio.v
   output [NPS-1:0] 	ps_gpio_i;		// From pgpio of pgpio.v
   inout [NGPIO-1:0] 	gpio_n;			// To/From pgpio of pgpio.v
   inout [NGPIO-1:0]	gpio_p;			// To/From pgpio of pgpio.v

   //TX
   output [7:0] 	txo_data_n;		// From axe_elink of axi_elink.v
   output [7:0]		txo_data_p;		// From axe_elink of axi_elink.v
   output		txo_frame_n;		// From axe_elink of axi_elink.v
   output		txo_frame_p;		// From axe_elink of axi_elink.v
   output		txo_lclk_n;		// From axe_elink of axi_elink.v
   output		txo_lclk_p;		// From axe_elink of axi_elink.v
   input		txi_rd_wait_n;		// To axe_elink of axi_elink.v
   input		txi_rd_wait_p;		// To axe_elink of axi_elink.v
   input		txi_wr_wait_n;		// To axe_elink of axi_elink.v
   input		txi_wr_wait_p;		// To axe_elink of axi_elink.v

   //RX
   input [7:0] 		rxi_data_n;		// To axe_elink of axi_elink.v
   input [7:0]		rxi_data_p;		// To axe_elink of axi_elink.v
   input		rxi_frame_n;		// To axe_elink of axi_elink.v
   input		rxi_frame_p;		// To axe_elink of axi_elink.v
   input		rxi_lclk_n;		// To axe_elink of axi_elink.v
   input		rxi_lclk_p;		// To axe_elink of axi_elink.v
   output		rxo_rd_wait_n;		// From axe_elink of axi_elink.v
   output		rxo_rd_wait_p;		// From axe_elink of axi_elink.v
   output		rxo_wr_wait_n;		// From axe_elink of axi_elink.v
   output		rxo_wr_wait_p;		// From axe_elink of axi_elink.v
   
   /*AUTOINOUT*/
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]	m_axi_araddr;		// From axe_elink of axi_elink.v
   output [1:0]		m_axi_arburst;		// From axe_elink of axi_elink.v
   output [3:0]		m_axi_arcache;		// From axe_elink of axi_elink.v
   output [M_IDW-1:0]	m_axi_arid;		// From axe_elink of axi_elink.v
   output [7:0]		m_axi_arlen;		// From axe_elink of axi_elink.v
   output		m_axi_arlock;		// From axe_elink of axi_elink.v
   output [2:0]		m_axi_arprot;		// From axe_elink of axi_elink.v
   output [3:0]		m_axi_arqos;		// From axe_elink of axi_elink.v
   output [2:0]		m_axi_arsize;		// From axe_elink of axi_elink.v
   output		m_axi_arvalid;		// From axe_elink of axi_elink.v
   output [31:0]	m_axi_awaddr;		// From axe_elink of axi_elink.v
   output [1:0]		m_axi_awburst;		// From axe_elink of axi_elink.v
   output [3:0]		m_axi_awcache;		// From axe_elink of axi_elink.v
   output [M_IDW-1:0]	m_axi_awid;		// From axe_elink of axi_elink.v
   output [7:0]		m_axi_awlen;		// From axe_elink of axi_elink.v
   output		m_axi_awlock;		// From axe_elink of axi_elink.v
   output [2:0]		m_axi_awprot;		// From axe_elink of axi_elink.v
   output [3:0]		m_axi_awqos;		// From axe_elink of axi_elink.v
   output [2:0]		m_axi_awsize;		// From axe_elink of axi_elink.v
   output		m_axi_awvalid;		// From axe_elink of axi_elink.v
   output		m_axi_bready;		// From axe_elink of axi_elink.v
   output		m_axi_rready;		// From axe_elink of axi_elink.v
   output [63:0]	m_axi_wdata;		// From axe_elink of axi_elink.v
   output [M_IDW-1:0]	m_axi_wid;		// From axe_elink of axi_elink.v
   output		m_axi_wlast;		// From axe_elink of axi_elink.v
   output [7:0]		m_axi_wstrb;		// From axe_elink of axi_elink.v
   output		m_axi_wvalid;		// From axe_elink of axi_elink.v
   output		s_axi_arready;		// From axe_elink of axi_elink.v
   output		s_axi_awready;		// From axe_elink of axi_elink.v
   output [S_IDW-1:0]	s_axi_bid;		// From axe_elink of axi_elink.v
   output [1:0]		s_axi_bresp;		// From axe_elink of axi_elink.v
   output		s_axi_bvalid;		// From axe_elink of axi_elink.v
   output [31:0]	s_axi_rdata;		// From axe_elink of axi_elink.v
   output [S_IDW-1:0]	s_axi_rid;		// From axe_elink of axi_elink.v
   output		s_axi_rlast;		// From axe_elink of axi_elink.v
   output [1:0]		s_axi_rresp;		// From axe_elink of axi_elink.v
   output		s_axi_rvalid;		// From axe_elink of axi_elink.v
   output		s_axi_wready;		// From axe_elink of axi_elink.v
   // End of automatics
   /*AUTOINPUT*/   
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		m_axi_aresetn;		// To axe_elink of axi_elink.v
   input		m_axi_arready;		// To axe_elink of axi_elink.v
   input		m_axi_awready;		// To axe_elink of axi_elink.v
   input [M_IDW-1:0]	m_axi_bid;		// To axe_elink of axi_elink.v
   input [1:0]		m_axi_bresp;		// To axe_elink of axi_elink.v
   input		m_axi_bvalid;		// To axe_elink of axi_elink.v
   input [63:0]		m_axi_rdata;		// To axe_elink of axi_elink.v
   input [M_IDW-1:0]	m_axi_rid;		// To axe_elink of axi_elink.v
   input		m_axi_rlast;		// To axe_elink of axi_elink.v
   input [1:0]		m_axi_rresp;		// To axe_elink of axi_elink.v
   input		m_axi_rvalid;		// To axe_elink of axi_elink.v
   input		m_axi_wready;		// To axe_elink of axi_elink.v
   input [31:0]		s_axi_araddr;		// To axe_elink of axi_elink.v
   input [1:0]		s_axi_arburst;		// To axe_elink of axi_elink.v
   input [3:0]		s_axi_arcache;		// To axe_elink of axi_elink.v
   input		s_axi_aresetn;		// To axe_elink of axi_elink.v
   input [S_IDW-1:0]	s_axi_arid;		// To axe_elink of axi_elink.v
   input [7:0]		s_axi_arlen;		// To axe_elink of axi_elink.v
   input		s_axi_arlock;		// To axe_elink of axi_elink.v
   input [2:0]		s_axi_arprot;		// To axe_elink of axi_elink.v
   input [3:0]		s_axi_arqos;		// To axe_elink of axi_elink.v
   input [2:0]		s_axi_arsize;		// To axe_elink of axi_elink.v
   input		s_axi_arvalid;		// To axe_elink of axi_elink.v
   input [31:0]		s_axi_awaddr;		// To axe_elink of axi_elink.v
   input [1:0]		s_axi_awburst;		// To axe_elink of axi_elink.v
   input [3:0]		s_axi_awcache;		// To axe_elink of axi_elink.v
   input [S_IDW-1:0]	s_axi_awid;		// To axe_elink of axi_elink.v
   input [7:0]		s_axi_awlen;		// To axe_elink of axi_elink.v
   input		s_axi_awlock;		// To axe_elink of axi_elink.v
   input [2:0]		s_axi_awprot;		// To axe_elink of axi_elink.v
   input [3:0]		s_axi_awqos;		// To axe_elink of axi_elink.v
   input [2:0]		s_axi_awsize;		// To axe_elink of axi_elink.v
   input		s_axi_awvalid;		// To axe_elink of axi_elink.v
   input		s_axi_bready;		// To axe_elink of axi_elink.v
   input		s_axi_rready;		// To axe_elink of axi_elink.v
   input [31:0]		s_axi_wdata;		// To axe_elink of axi_elink.v
   input [S_IDW-1:0]	s_axi_wid;		// To axe_elink of axi_elink.v
   input		s_axi_wlast;		// To axe_elink of axi_elink.v
   input [3:0]		s_axi_wstrb;		// To axe_elink of axi_elink.v
   input		s_axi_wvalid;		// To axe_elink of axi_elink.v
   // End of automatics
   /*AUTOWIRE*/
   

   /*axi_elink AUTO_TEMPLATE ( 
	                .m_axi_\(.*\) (m_axi_\1[]),
                        .s_axi_\(.*\) (s_axi_\1[]),
                       );
   */
   defparam axi_elink.ID=ID;   
   axi_elink axe_elink (.mailbox_full	(),
			/*AUTOINST*/
			// Outputs
			.elink_active	(elink_active),
			.rxo_wr_wait_p	(rxo_wr_wait_p),
			.rxo_wr_wait_n	(rxo_wr_wait_n),
			.rxo_rd_wait_p	(rxo_rd_wait_p),
			.rxo_rd_wait_n	(rxo_rd_wait_n),
			.txo_lclk_p	(txo_lclk_p),
			.txo_lclk_n	(txo_lclk_n),
			.txo_frame_p	(txo_frame_p),
			.txo_frame_n	(txo_frame_n),
			.txo_data_p	(txo_data_p[7:0]),
			.txo_data_n	(txo_data_n[7:0]),
			.chipid		(chipid[11:0]),
			.chip_nreset	(chip_nreset),
			.cclk_p		(cclk_p),
			.cclk_n		(cclk_n),
			.mailbox_not_empty(mailbox_not_empty),
			.m_axi_awid	(m_axi_awid[M_IDW-1:0]), // Templated
			.m_axi_awaddr	(m_axi_awaddr[31:0]),	 // Templated
			.m_axi_awlen	(m_axi_awlen[7:0]),	 // Templated
			.m_axi_awsize	(m_axi_awsize[2:0]),	 // Templated
			.m_axi_awburst	(m_axi_awburst[1:0]),	 // Templated
			.m_axi_awlock	(m_axi_awlock),		 // Templated
			.m_axi_awcache	(m_axi_awcache[3:0]),	 // Templated
			.m_axi_awprot	(m_axi_awprot[2:0]),	 // Templated
			.m_axi_awqos	(m_axi_awqos[3:0]),	 // Templated
			.m_axi_awvalid	(m_axi_awvalid),	 // Templated
			.m_axi_wid	(m_axi_wid[M_IDW-1:0]),	 // Templated
			.m_axi_wdata	(m_axi_wdata[63:0]),	 // Templated
			.m_axi_wstrb	(m_axi_wstrb[7:0]),	 // Templated
			.m_axi_wlast	(m_axi_wlast),		 // Templated
			.m_axi_wvalid	(m_axi_wvalid),		 // Templated
			.m_axi_bready	(m_axi_bready),		 // Templated
			.m_axi_arid	(m_axi_arid[M_IDW-1:0]), // Templated
			.m_axi_araddr	(m_axi_araddr[31:0]),	 // Templated
			.m_axi_arlen	(m_axi_arlen[7:0]),	 // Templated
			.m_axi_arsize	(m_axi_arsize[2:0]),	 // Templated
			.m_axi_arburst	(m_axi_arburst[1:0]),	 // Templated
			.m_axi_arlock	(m_axi_arlock),		 // Templated
			.m_axi_arcache	(m_axi_arcache[3:0]),	 // Templated
			.m_axi_arprot	(m_axi_arprot[2:0]),	 // Templated
			.m_axi_arqos	(m_axi_arqos[3:0]),	 // Templated
			.m_axi_arvalid	(m_axi_arvalid),	 // Templated
			.m_axi_rready	(m_axi_rready),		 // Templated
			.s_axi_arready	(s_axi_arready),	 // Templated
			.s_axi_awready	(s_axi_awready),	 // Templated
			.s_axi_bid	(s_axi_bid[S_IDW-1:0]),	 // Templated
			.s_axi_bresp	(s_axi_bresp[1:0]),	 // Templated
			.s_axi_bvalid	(s_axi_bvalid),		 // Templated
			.s_axi_rid	(s_axi_rid[S_IDW-1:0]),	 // Templated
			.s_axi_rdata	(s_axi_rdata[31:0]),	 // Templated
			.s_axi_rlast	(s_axi_rlast),		 // Templated
			.s_axi_rresp	(s_axi_rresp[1:0]),	 // Templated
			.s_axi_rvalid	(s_axi_rvalid),		 // Templated
			.s_axi_wready	(s_axi_wready),		 // Templated
			.timeout	(timeout),
			// Inputs
			.sys_nreset	(sys_nreset),
			.sys_clk	(sys_clk),
			.rxi_lclk_p	(rxi_lclk_p),
			.rxi_lclk_n	(rxi_lclk_n),
			.rxi_frame_p	(rxi_frame_p),
			.rxi_frame_n	(rxi_frame_n),
			.rxi_data_p	(rxi_data_p[7:0]),
			.rxi_data_n	(rxi_data_n[7:0]),
			.txi_wr_wait_p	(txi_wr_wait_p),
			.txi_wr_wait_n	(txi_wr_wait_n),
			.txi_rd_wait_p	(txi_rd_wait_p),
			.txi_rd_wait_n	(txi_rd_wait_n),
			.m_axi_aresetn	(m_axi_aresetn),	 // Templated
			.m_axi_awready	(m_axi_awready),	 // Templated
			.m_axi_wready	(m_axi_wready),		 // Templated
			.m_axi_bid	(m_axi_bid[M_IDW-1:0]),	 // Templated
			.m_axi_bresp	(m_axi_bresp[1:0]),	 // Templated
			.m_axi_bvalid	(m_axi_bvalid),		 // Templated
			.m_axi_arready	(m_axi_arready),	 // Templated
			.m_axi_rid	(m_axi_rid[M_IDW-1:0]),	 // Templated
			.m_axi_rdata	(m_axi_rdata[63:0]),	 // Templated
			.m_axi_rresp	(m_axi_rresp[1:0]),	 // Templated
			.m_axi_rlast	(m_axi_rlast),		 // Templated
			.m_axi_rvalid	(m_axi_rvalid),		 // Templated
			.s_axi_aresetn	(s_axi_aresetn),	 // Templated
			.s_axi_arid	(s_axi_arid[S_IDW-1:0]), // Templated
			.s_axi_araddr	(s_axi_araddr[31:0]),	 // Templated
			.s_axi_arburst	(s_axi_arburst[1:0]),	 // Templated
			.s_axi_arcache	(s_axi_arcache[3:0]),	 // Templated
			.s_axi_arlock	(s_axi_arlock),		 // Templated
			.s_axi_arlen	(s_axi_arlen[7:0]),	 // Templated
			.s_axi_arprot	(s_axi_arprot[2:0]),	 // Templated
			.s_axi_arqos	(s_axi_arqos[3:0]),	 // Templated
			.s_axi_arsize	(s_axi_arsize[2:0]),	 // Templated
			.s_axi_arvalid	(s_axi_arvalid),	 // Templated
			.s_axi_awid	(s_axi_awid[S_IDW-1:0]), // Templated
			.s_axi_awaddr	(s_axi_awaddr[31:0]),	 // Templated
			.s_axi_awburst	(s_axi_awburst[1:0]),	 // Templated
			.s_axi_awcache	(s_axi_awcache[3:0]),	 // Templated
			.s_axi_awlock	(s_axi_awlock),		 // Templated
			.s_axi_awlen	(s_axi_awlen[7:0]),	 // Templated
			.s_axi_awprot	(s_axi_awprot[2:0]),	 // Templated
			.s_axi_awqos	(s_axi_awqos[3:0]),	 // Templated
			.s_axi_awsize	(s_axi_awsize[2:0]),	 // Templated
			.s_axi_awvalid	(s_axi_awvalid),	 // Templated
			.s_axi_bready	(s_axi_bready),		 // Templated
			.s_axi_rready	(s_axi_rready),		 // Templated
			.s_axi_wid	(s_axi_wid[S_IDW-1:0]),	 // Templated
			.s_axi_wdata	(s_axi_wdata[31:0]),	 // Templated
			.s_axi_wlast	(s_axi_wlast),		 // Templated
			.s_axi_wstrb	(s_axi_wstrb[3:0]),	 // Templated
			.s_axi_wvalid	(s_axi_wvalid));		 // Templated

   pgpio pgpio (/*AUTOINST*/
		// Outputs
		.ps_gpio_i		(ps_gpio_i[NPS-1:0]),
		// Inouts
		.gpio_p			(gpio_p[NGPIO-1:0]),
		.gpio_n			(gpio_n[NGPIO-1:0]),
		// Inputs
		.ps_gpio_o		(ps_gpio_o[NPS-1:0]),
		.ps_gpio_t		(ps_gpio_t[NPS-1:0]));
   
   pi2c pi2c (/*AUTOINST*/
	      // Outputs
	      .i2c_sda_i		(i2c_sda_i),
	      .i2c_scl_i		(i2c_scl_i),
	      // Inouts
	      .i2c_sda			(i2c_sda),
	      .i2c_scl			(i2c_scl),
	      // Inputs
	      .i2c_sda_o		(i2c_sda_o),
	      .i2c_sda_t		(i2c_sda_t),
	      .i2c_scl_o		(i2c_scl_o),
	      .i2c_scl_t		(i2c_scl_t));
   
   

endmodule // parallella_generic
// Local Variables:
// verilog-library-directories:("." "../../elink/hdl")
// End:

