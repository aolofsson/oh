//`timescale 1 ns / 100 ps
module dv_elink();

   parameter DW = 32;
   parameter AW = 32;
   
   //Basic stimulus to drive
   reg        reset_in;        //active high asynchronous hardware reset
   reg 	      clkin;           //primary clock reg
   reg        rx_lclk_p;       //linkh speed clock reg (up to 500MHz)
   reg	      rx_lclk_n;
   reg        rx_frame_p;      //transaction frame signal
   wire        rx_frame_n;
   reg [7:0]  rx_data_p;       //receive data (dual data rate)
   wire [7:0]  rx_data_n;
   reg 	      tx_wr_wait_p;    //incoming pushback on write transactions
   wire	      tx_wr_wait_n;    
   reg 	      tx_rd_wait_p;    //incoming pushback on read transactions
   wire	      tx_rd_wait_n;    
   reg 	      m_axi_aclk;
   reg 	      m_axi_aresetn;
   reg 	      m_axi_arready; //read ready
   reg 	      m_axi_awready;
   reg [0:0]  m_axi_bid;    //response tag
   reg [1:0]  m_axi_bresp;
   reg 	      m_axi_bvalid;
   reg [63:0] m_axi_rdata;
   reg [0:0]  m_axi_rid;     //read id tag
   reg 	      m_axi_rlast;   //indicates last transfer of a burst
   reg [1:0]  m_axi_rresp;
   reg 	      m_axi_rvalid;
   reg 	      m_axi_wready;  //response ready
   reg 	      s_axi_aclk;
   reg 	      s_axi_aresetn;
   reg [29:0] s_axi_araddr;
   reg [1:0]  s_axi_arburst;
   reg [3:0]  s_axi_arcache;
   reg [11:0] s_axi_arid;
   reg [7:0]  s_axi_arlen;
   reg [0:0]  s_axi_arlock;
   reg [2:0]  s_axi_arprot;
   reg [3:0]  s_axi_arqos;
   reg [3:0]  s_axi_arregion;
   reg [2:0]  s_axi_arsize;
   reg 	      s_axi_arvalid;
   reg [29:0] s_axi_awaddr;
   reg [1:0]  s_axi_awburst;
   reg [3:0]  s_axi_awcache;
   reg [11:0] s_axi_awid;
   reg [7:0]  s_axi_awlen;
   reg [0:0]  s_axi_awlock;
   reg [2:0]  s_axi_awprot;
   reg [3:0]  s_axi_awqos;
   reg [3:0]  s_axi_awregion;
   reg [2:0]  s_axi_awsize;
   reg 	      s_axi_awvalid;
   reg 	      s_axi_bready;
   reg 	      s_axi_rready;
   reg [31:0] s_axi_wdata;
   reg 	      s_axi_wlast;
   reg [3:0]  s_axi_wstrb;
   reg 	      s_axi_wvalid;
   reg 	      s_axicfg_aclk;
   reg 	      s_axicfg_aresetn;
   reg [12:0] s_axicfg_araddr;
   reg [2:0]  s_axicfg_arprot;
   reg 	      s_axicfg_arvalid;
   reg [12:0] s_axicfg_awaddr;
   reg [2:0]  s_axicfg_awprot;
   reg 	      s_axicfg_bready;
   reg 	      s_axicfg_rready;
   reg [31:0] s_axicfg_wdata;
   reg [3:0]  s_axicfg_wstrb;
   reg 	      s_axicfg_wvalid;
   reg 	      s_axicfg_awvalid;
   
    //Reset
   initial
     begin
	$display($time, " << Starting the Simulation >>");	
	#0
	reset_in          = 1'b1;
	clkin             = 1'b0;
        rx_lclk_p         = 1'b0;
	rx_lclk_n         = 1'b1;
        rx_frame_p        = 1'b0;
	rx_data_p[7:0]    = 8'h00; 
    	tx_wr_wait_p      = 1'b0;
    	tx_rd_wait_p      = 1'b0;
    	m_axi_aclk        = 1'b0;
    	m_axi_aresetn     = 1'b0;
    	m_axi_arready     = 1'b0;
    	m_axi_awready     = 1'b0;
	m_axi_bid         = 1'b0;  
	m_axi_bresp[1:0]  = 2'b0;
    	m_axi_bvalid      = 1'b0;
	m_axi_rdata[63:0] = 64'b0;
	m_axi_rid[0:0]    = 1'b0;
    	m_axi_rlast       = 1'b0;
	m_axi_rresp[1:0]  = 2'b0; 
    	m_axi_rvalid      = 1'b0;
    	m_axi_wready      = 1'b0;
    	s_axi_aclk        = 1'b0;
    	s_axi_aresetn     = 1'b0;
	s_axi_araddr[29:0]= 30'b0;
	s_axi_arburst[1:0]= 2'b0;
	s_axi_arcache[3:0]= 4'b0;
	s_axi_arid[11:0]  = 12'b0;
	s_axi_arlen[7:0]  = 8'b0;
	s_axi_arlock[0:0] = 1'b0;
	s_axi_arprot[2:0] = 2'b0;
	s_axi_arqos[3:0]  = 4'b0;
	s_axi_arregion[3:0]=4'b0;	
	s_axi_arsize[2:0] = 2'b0;
    	s_axi_arvalid     = 1'b0;
	s_axi_awaddr[29:0]= 30'b0;
	s_axi_awburst[1:0]= 2'b0;
	s_axi_awcache[3:0]= 4'b0;
	s_axi_awid[11:0]  = 12'b0;
	s_axi_awlen[7:0]  = 8'b0;
	s_axi_awlock[0:0] = 1'b0;	
	s_axi_awprot[2:0] = 3'b0;
	s_axi_awqos[3:0]  = 4'b0;
	s_axi_awregion[3:0]= 4'b0;
	s_axi_awsize[2:0]  = 3'b0;
    	s_axi_awvalid      = 1'b0;
    	s_axi_bready       = 1'b0;
    	s_axi_rready       = 1'b0;
	s_axi_wdata[31:0]  = 32'b0;
    	s_axi_wlast        = 1'b0;
	s_axi_wstrb[3:0]   = 4'b0;
    	s_axi_wvalid       = 1'b0;
	s_axicfg_aclk        = 1'b0;
    	s_axicfg_aresetn     = 1'b0;
	s_axicfg_araddr[12:0]=13'b0;
	s_axicfg_arprot[2:0] = 1'b0;
    	s_axicfg_arvalid     = 1'b0;
	s_axicfg_awaddr[12:0]= 13'b0;
	s_axicfg_awprot[2:0] = 3'b0;
    	s_axicfg_bready      = 1'b0;
	s_axicfg_awvalid     = 1'b0;	
    	s_axicfg_rready      = 1'b0;
	s_axicfg_wdata[31:0] = 32'b0;
	s_axicfg_wstrb[3:0]  = 4'b0;
        s_axicfg_wvalid      = 1'b0;
       
	#100 
	  reset_in           = 1'b0;    // at time 100 release reset
   	  s_axi_aresetn      = 1'b1;
   	  s_axicfg_aresetn   = 1'b1;
   	  m_axi_aresetn      = 1'b1;
	#10000	  
	  $finish;
     end
   
   //Clock
   always
     begin
       #10 
	 begin
	    clkin      = ~clkin;
	    rx_lclk_p  = ~rx_lclk_p;
	    rx_lclk_n  = ~rx_lclk_n;
	    s_axi_aclk = ~s_axi_aclk;
	    m_axi_aclk = ~m_axi_aclk;
	    s_axicfg_aclk=~s_axicfg_aclk;	    
	 end
     end

   //Driving differentials
   assign rx_frame_n   = ~rx_frame_p;
   assign rx_data_n    = ~rx_data_p;
   assign tx_wr_wait_n = ~tx_wr_wait_p;
   assign tx_rd_wait_n = ~tx_rd_wait_p;   

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			cclk_n;			// From elink of elink.v
   wire			cclk_p;			// From elink of elink.v
   wire			embox_full;		// From elink of elink.v
   wire			embox_not_empty;	// From elink of elink.v
   wire [31:0]		m_axi_araddr;		// From elink of elink.v
   wire [1:0]		m_axi_arburst;		// From elink of elink.v
   wire [3:0]		m_axi_arcache;		// From elink of elink.v
   wire [0:0]		m_axi_arid;		// From elink of elink.v
   wire [7:0]		m_axi_arlen;		// From elink of elink.v
   wire [0:0]		m_axi_arlock;		// From elink of elink.v
   wire [2:0]		m_axi_arprot;		// From elink of elink.v
   wire [3:0]		m_axi_arqos;		// From elink of elink.v
   wire [2:0]		m_axi_arsize;		// From elink of elink.v
   wire			m_axi_arvalid;		// From elink of elink.v
   wire [31:0]		m_axi_awaddr;		// From elink of elink.v
   wire [1:0]		m_axi_awburst;		// From elink of elink.v
   wire [3:0]		m_axi_awcache;		// From elink of elink.v
   wire [0:0]		m_axi_awid;		// From elink of elink.v
   wire [7:0]		m_axi_awlen;		// From elink of elink.v
   wire [0:0]		m_axi_awlock;		// From elink of elink.v
   wire [2:0]		m_axi_awprot;		// From elink of elink.v
   wire [3:0]		m_axi_awqos;		// From elink of elink.v
   wire [2:0]		m_axi_awsize;		// From elink of elink.v
   wire			m_axi_awvalid;		// From elink of elink.v
   wire			m_axi_bready;		// From elink of elink.v
   wire			m_axi_rready;		// From elink of elink.v
   wire [63:0]		m_axi_wdata;		// From elink of elink.v
   wire			m_axi_wlast;		// From elink of elink.v
   wire [7:0]		m_axi_wstrb;		// From elink of elink.v
   wire			m_axi_wvalid;		// From elink of elink.v
   wire			resetb_out;		// From elink of elink.v
   wire			rx_rd_wait_n;		// From elink of elink.v
   wire			rx_rd_wait_p;		// From elink of elink.v
   wire			rx_wr_wait_n;		// From elink of elink.v
   wire			rx_wr_wait_p;		// From elink of elink.v
   wire			s_axi_arready;		// From elink of elink.v
   wire			s_axi_awready;		// From elink of elink.v
   wire [11:0]		s_axi_bid;		// From elink of elink.v
   wire [1:0]		s_axi_bresp;		// From elink of elink.v
   wire			s_axi_bvalid;		// From elink of elink.v
   wire [31:0]		s_axi_rdata;		// From elink of elink.v
   wire [11:0]		s_axi_rid;		// From elink of elink.v
   wire			s_axi_rlast;		// From elink of elink.v
   wire [1:0]		s_axi_rresp;		// From elink of elink.v
   wire			s_axi_rvalid;		// From elink of elink.v
   wire			s_axi_wready;		// From elink of elink.v
   wire			s_axicfg_arready;	// From elink of elink.v
   wire			s_axicfg_awready;	// From elink of elink.v
   wire [1:0]		s_axicfg_bresp;		// From elink of elink.v
   wire			s_axicfg_bvalid;	// From elink of elink.v
   wire [31:0]		s_axicfg_rdata;		// From elink of elink.v
   wire [1:0]		s_axicfg_rresp;		// From elink of elink.v
   wire			s_axicfg_rvalid;	// From elink of elink.v
   wire			s_axicfg_wready;	// From elink of elink.v
   wire [7:0]		tx_data_n;		// From elink of elink.v
   wire [7:0]		tx_data_p;		// From elink of elink.v
   wire			tx_frame_n;		// From elink of elink.v
   wire			tx_frame_p;		// From elink of elink.v
   wire			tx_lclk_n;		// From elink of elink.v
   wire			tx_lclk_p;		// From elink of elink.v
   // End of automatics
   
   elink elink (/*AUTOINST*/
		// Outputs
		.resetb_out		(resetb_out),
		.cclk_p			(cclk_p),
		.cclk_n			(cclk_n),
		.rx_wr_wait_p		(rx_wr_wait_p),
		.rx_wr_wait_n		(rx_wr_wait_n),
		.rx_rd_wait_p		(rx_rd_wait_p),
		.rx_rd_wait_n		(rx_rd_wait_n),
		.tx_lclk_p		(tx_lclk_p),
		.tx_lclk_n		(tx_lclk_n),
		.tx_frame_p		(tx_frame_p),
		.tx_frame_n		(tx_frame_n),
		.tx_data_p		(tx_data_p[7:0]),
		.tx_data_n		(tx_data_n[7:0]),
		.embox_not_empty	(embox_not_empty),
		.embox_full		(embox_full),
		.m_axi_araddr		(m_axi_araddr[31:0]),
		.m_axi_arburst		(m_axi_arburst[1:0]),
		.m_axi_arcache		(m_axi_arcache[3:0]),
		.m_axi_arid		(m_axi_arid[0:0]),
		.m_axi_arlen		(m_axi_arlen[7:0]),
		.m_axi_arlock		(m_axi_arlock[0:0]),
		.m_axi_arprot		(m_axi_arprot[2:0]),
		.m_axi_arqos		(m_axi_arqos[3:0]),
		.m_axi_arsize		(m_axi_arsize[2:0]),
		.m_axi_arvalid		(m_axi_arvalid),
		.m_axi_awaddr		(m_axi_awaddr[31:0]),
		.m_axi_awburst		(m_axi_awburst[1:0]),
		.m_axi_awcache		(m_axi_awcache[3:0]),
		.m_axi_awid		(m_axi_awid[0:0]),
		.m_axi_awlen		(m_axi_awlen[7:0]),
		.m_axi_awlock		(m_axi_awlock[0:0]),
		.m_axi_awprot		(m_axi_awprot[2:0]),
		.m_axi_awqos		(m_axi_awqos[3:0]),
		.m_axi_awsize		(m_axi_awsize[2:0]),
		.m_axi_awvalid		(m_axi_awvalid),
		.m_axi_bready		(m_axi_bready),
		.m_axi_rready		(m_axi_rready),
		.m_axi_wdata		(m_axi_wdata[63:0]),
		.m_axi_wlast		(m_axi_wlast),
		.m_axi_wstrb		(m_axi_wstrb[7:0]),
		.m_axi_wvalid		(m_axi_wvalid),
		.s_axi_arready		(s_axi_arready),
		.s_axi_awready		(s_axi_awready),
		.s_axi_bid		(s_axi_bid[11:0]),
		.s_axi_bresp		(s_axi_bresp[1:0]),
		.s_axi_bvalid		(s_axi_bvalid),
		.s_axi_rdata		(s_axi_rdata[31:0]),
		.s_axi_rid		(s_axi_rid[11:0]),
		.s_axi_rlast		(s_axi_rlast),
		.s_axi_rresp		(s_axi_rresp[1:0]),
		.s_axi_rvalid		(s_axi_rvalid),
		.s_axi_wready		(s_axi_wready),
		.s_axicfg_arready	(s_axicfg_arready),
		.s_axicfg_awready	(s_axicfg_awready),
		.s_axicfg_bresp		(s_axicfg_bresp[1:0]),
		.s_axicfg_bvalid	(s_axicfg_bvalid),
		.s_axicfg_rdata		(s_axicfg_rdata[31:0]),
		.s_axicfg_rresp		(s_axicfg_rresp[1:0]),
		.s_axicfg_rvalid	(s_axicfg_rvalid),
		.s_axicfg_wready	(s_axicfg_wready),
		// Inputs
		.reset_in		(reset_in),
		.clkin			(clkin),
		.rx_lclk_p		(rx_lclk_p),
		.rx_lclk_n		(rx_lclk_n),
		.rx_frame_p		(rx_frame_p),
		.rx_frame_n		(rx_frame_n),
		.rx_data_p		(rx_data_p[7:0]),
		.rx_data_n		(rx_data_n[7:0]),
		.tx_wr_wait_p		(tx_wr_wait_p),
		.tx_wr_wait_n		(tx_wr_wait_n),
		.tx_rd_wait_p		(tx_rd_wait_p),
		.tx_rd_wait_n		(tx_rd_wait_n),
		.m_axi_aclk		(m_axi_aclk),
		.m_axi_aresetn		(m_axi_aresetn),
		.m_axi_arready		(m_axi_arready),
		.m_axi_awready		(m_axi_awready),
		.m_axi_bid		(m_axi_bid[0:0]),
		.m_axi_bresp		(m_axi_bresp[1:0]),
		.m_axi_bvalid		(m_axi_bvalid),
		.m_axi_rdata		(m_axi_rdata[63:0]),
		.m_axi_rid		(m_axi_rid[0:0]),
		.m_axi_rlast		(m_axi_rlast),
		.m_axi_rresp		(m_axi_rresp[1:0]),
		.m_axi_rvalid		(m_axi_rvalid),
		.m_axi_wready		(m_axi_wready),
		.s_axi_aclk		(s_axi_aclk),
		.s_axi_aresetn		(s_axi_aresetn),
		.s_axi_araddr		(s_axi_araddr[29:0]),
		.s_axi_arburst		(s_axi_arburst[1:0]),
		.s_axi_arcache		(s_axi_arcache[3:0]),
		.s_axi_arid		(s_axi_arid[11:0]),
		.s_axi_arlen		(s_axi_arlen[7:0]),
		.s_axi_arlock		(s_axi_arlock[0:0]),
		.s_axi_arprot		(s_axi_arprot[2:0]),
		.s_axi_arqos		(s_axi_arqos[3:0]),
		.s_axi_arregion		(s_axi_arregion[3:0]),
		.s_axi_arsize		(s_axi_arsize[2:0]),
		.s_axi_arvalid		(s_axi_arvalid),
		.s_axi_awaddr		(s_axi_awaddr[29:0]),
		.s_axi_awburst		(s_axi_awburst[1:0]),
		.s_axi_awcache		(s_axi_awcache[3:0]),
		.s_axi_awid		(s_axi_awid[11:0]),
		.s_axi_awlen		(s_axi_awlen[7:0]),
		.s_axi_awlock		(s_axi_awlock[0:0]),
		.s_axi_awprot		(s_axi_awprot[2:0]),
		.s_axi_awqos		(s_axi_awqos[3:0]),
		.s_axi_awregion		(s_axi_awregion[3:0]),
		.s_axi_awsize		(s_axi_awsize[2:0]),
		.s_axi_awvalid		(s_axi_awvalid),
		.s_axi_bready		(s_axi_bready),
		.s_axi_rready		(s_axi_rready),
		.s_axi_wdata		(s_axi_wdata[31:0]),
		.s_axi_wlast		(s_axi_wlast),
		.s_axi_wstrb		(s_axi_wstrb[3:0]),
		.s_axi_wvalid		(s_axi_wvalid),
		.s_axicfg_aclk		(s_axicfg_aclk),
		.s_axicfg_aresetn	(s_axicfg_aresetn),
		.s_axicfg_araddr	(s_axicfg_araddr[15:0]),
		.s_axicfg_arprot	(s_axicfg_arprot[2:0]),
		.s_axicfg_arvalid	(s_axicfg_arvalid),
		.s_axicfg_awaddr	(s_axicfg_awaddr[15:0]),
		.s_axicfg_awprot	(s_axicfg_awprot[2:0]),
		.s_axicfg_awvalid	(s_axicfg_awvalid),
		.s_axicfg_bready	(s_axicfg_bready),
		.s_axicfg_rready	(s_axicfg_rready),
		.s_axicfg_wdata		(s_axicfg_wdata[31:0]),
		.s_axicfg_wstrb		(s_axicfg_wstrb[3:0]),
		.s_axicfg_wvalid	(s_axicfg_wvalid));

   //Waveform dump
   initial
     begin
        $dumpfile("test.vcd");
        $dumpvars(0, dv_elink);
     end

   
endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl")
// End:
