module axi_etrace (/*AUTOARG*/
   // Outputs
   wr_wait, txwr_packet, txwr_access, txrd_packet, txrd_access,
   rxwr_wait, rxrr_wait, rd_wait, emesh_packet, emesh_access,
   data_packet_out, data_access_out, cfg_packet_out, cfg_access_out,
   m_axi_awid, m_axi_awaddr, m_axi_awlen, m_axi_awsize, m_axi_awburst,
   m_axi_awlock, m_axi_awcache, m_axi_awprot, m_axi_awqos,
   m_axi_awvalid, m_axi_wid, m_axi_wdata, m_axi_wstrb, m_axi_wlast,
   m_axi_wvalid, m_axi_bready, m_axi_arid, m_axi_araddr, m_axi_arlen,
   m_axi_arsize, m_axi_arburst, m_axi_arlock, m_axi_arcache,
   m_axi_arprot, m_axi_arqos, m_axi_arvalid, m_axi_rready,
   s_axi_arready, s_axi_awready, s_axi_bid, s_axi_bresp, s_axi_bvalid,
   s_axi_rid, s_axi_rdata, s_axi_rlast, s_axi_rresp, s_axi_rvalid,
   s_axi_wready,
   // Inputs
   wr_packet, wr_access, txwr_wait, txrd_wait, trace_vector,
   trace_trigger, trace_clk, rxwr_packet, rxwr_access, rxrr_packet,
   rxrr_access, rd_packet, rd_access, emesh_wait, cfg_packet_in,
   cfg_access_in, m_axi_aclk, m_axi_aresetn, m_axi_awready,
   m_axi_wready, m_axi_bid, m_axi_bresp, m_axi_bvalid, m_axi_arready,
   m_axi_rid, m_axi_rdata, m_axi_rresp, m_axi_rlast, m_axi_rvalid,
   s_axi_aclk, s_axi_aresetn, s_axi_arid, s_axi_araddr, s_axi_arburst,
   s_axi_arcache, s_axi_arlock, s_axi_arlen, s_axi_arprot,
   s_axi_arqos, s_axi_arsize, s_axi_arvalid, s_axi_awid, s_axi_awaddr,
   s_axi_awburst, s_axi_awcache, s_axi_awlock, s_axi_awlen,
   s_axi_awprot, s_axi_awqos, s_axi_awsize, s_axi_awvalid,
   s_axi_bready, s_axi_rready, s_axi_wid, s_axi_wdata, s_axi_wlast,
   s_axi_wstrb, s_axi_wvalid
   );

   parameter AW          = 32;
   parameter DW          = 32; 
   parameter PW          = 104;      //packet width   
   parameter ID          = 12'h810;
   parameter S_IDW       = 12;       //ID width for S_AXI
   parameter M_IDW       = 6;        //ID width for M_AXI
   
   //########################
   //AXI MASTER INTERFACE
   //########################

   //clk+reset
   input	      m_axi_aclk;
   input  	      m_axi_aresetn; // global reset singal.

   //Write address channel
   output [M_IDW-1:0] m_axi_awid;    // write address ID
   output [31 : 0]    m_axi_awaddr;  // master interface write address   
   output [7 : 0]     m_axi_awlen;   // burst length.
   output [2 : 0]     m_axi_awsize;  // burst size.
   output [1 : 0]     m_axi_awburst; // burst type.
   output 	      m_axi_awlock;  // lock type   
   output [3 : 0]     m_axi_awcache; // memory type.
   output [2 : 0]     m_axi_awprot;  // protection type.
   output [3 : 0]     m_axi_awqos;   // quality of service
   output 	      m_axi_awvalid; // write address valid
   input 	      m_axi_awready; // write address ready
   
   //Write data channel
   output [M_IDW-1:0] m_axi_wid;     
   output [63 : 0]    m_axi_wdata;   // master interface write data.
   output [7 : 0]     m_axi_wstrb;   // byte write strobes
   output 	      m_axi_wlast;   // last transfer in a write burst.
   output 	      m_axi_wvalid;  // indicates data is ready to go
   input 	      m_axi_wready;  // slave is ready for data

   //Write response channel
   input [M_IDW-1:0]  m_axi_bid;
   input [1 : 0]      m_axi_bresp;   // status of the write transaction.
   input 	      m_axi_bvalid;  // valid write response
   output 	      m_axi_bready;  // master can accept write response.
   
   //Read address channel
   output [M_IDW-1:0] m_axi_arid;    // read address ID
   output [31 : 0]    m_axi_araddr;  // initial address of a read burst
   output [7 : 0]     m_axi_arlen;   // burst length
   output [2 : 0]     m_axi_arsize;  // burst size
   output [1 : 0]     m_axi_arburst; // burst type
   output 	      m_axi_arlock;  // lock type   
   output [3 : 0]     m_axi_arcache; // memory type
   output [2 : 0]     m_axi_arprot;  // protection type
   output [3 : 0]     m_axi_arqos;   // --
   output 	      m_axi_arvalid; // read address and control is valid
   input 	      m_axi_arready; // slave is ready to accept an address
   
   //Read data channel   
   input [M_IDW-1:0]  m_axi_rid; 
   input [63 : 0]     m_axi_rdata;   // master read data
   input [1 : 0]      m_axi_rresp;   // status of the read transfer
   input 	      m_axi_rlast;   // signals last transfer in a read burst
   input 	      m_axi_rvalid;  // signaling the required read data
   output 	      m_axi_rready;  // master can accept the readback data

   //########################
   //AXI SLAVE INTERFACE
   //########################

   //clk+reset
   input 	      s_axi_aclk;   
   input 	      s_axi_aresetn;
   
   //Read address channel
   input [S_IDW-1:0]  s_axi_arid;    //write address ID
   input [31:0]       s_axi_araddr;
   input [1:0] 	      s_axi_arburst;
   input [3:0] 	      s_axi_arcache;
   input  	      s_axi_arlock;
   input [7:0] 	      s_axi_arlen;
   input [2:0] 	      s_axi_arprot;
   input [3:0] 	      s_axi_arqos;
   output 	      s_axi_arready;
   input [2:0] 	      s_axi_arsize;
   input 	      s_axi_arvalid;
   
   //Write address channel
   input [S_IDW-1:0]  s_axi_awid;    //write address ID
   input [31:0]       s_axi_awaddr;
   input [1:0] 	      s_axi_awburst;
   input [3:0] 	      s_axi_awcache;
   input      s_axi_awlock;
   input [7:0] 	      s_axi_awlen;
   input [2:0] 	      s_axi_awprot;
   input [3:0] 	      s_axi_awqos;   
   input [2:0] 	      s_axi_awsize;
   input 	      s_axi_awvalid;
   output 	      s_axi_awready;
   
   //Buffered write response channel
   output [S_IDW-1:0] s_axi_bid;    //write address ID
   output [1:0]       s_axi_bresp;
   output 	      s_axi_bvalid;
   input 	      s_axi_bready;
   
   //Read channel
   output [S_IDW-1:0] s_axi_rid;    //write address ID
   output [31:0]      s_axi_rdata;
   output 	      s_axi_rlast;   
   output [1:0]       s_axi_rresp;
   output 	      s_axi_rvalid;
   input 	      s_axi_rready;

   //Write channel
   input [S_IDW-1:0]  s_axi_wid;    //write address ID
   input [31:0]       s_axi_wdata;
   input 	      s_axi_wlast;   
   input [3:0] 	      s_axi_wstrb;
   input 	      s_axi_wvalid;
   output 	      s_axi_wready;
    
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		cfg_access_in;		// To etrace of etrace.v
   input [PW-1:0]	cfg_packet_in;		// To etrace of etrace.v
   input		emesh_wait;		// To emesh_mux of emesh_mux.v
   input		rd_access;		// To emesh_mux of emesh_mux.v
   input [PW-1:0]	rd_packet;		// To emesh_mux of emesh_mux.v
   input		rxrr_access;		// To esaxi of esaxi.v
   input [PW-1:0]	rxrr_packet;		// To esaxi of esaxi.v
   input		rxwr_access;		// To emaxi of emaxi.v
   input [PW-1:0]	rxwr_packet;		// To emaxi of emaxi.v
   input		trace_clk;		// To etrace of etrace.v
   input		trace_trigger;		// To etrace of etrace.v
   input [VW-1:0]	trace_vector;		// To etrace of etrace.v
   input		txrd_wait;		// To esaxi of esaxi.v
   input		txwr_wait;		// To esaxi of esaxi.v
   input		wr_access;		// To emesh_mux of emesh_mux.v
   input [PW-1:0]	wr_packet;		// To emesh_mux of emesh_mux.v
   // End of automatics
   /*AUTOOUTPUT*/  
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		cfg_access_out;		// From etrace of etrace.v
   output [PW-1:0]	cfg_packet_out;		// From etrace of etrace.v
   output		data_access_out;	// From etrace of etrace.v
   output [PW-1:0]	data_packet_out;	// From etrace of etrace.v
   output		emesh_access;		// From emesh_mux of emesh_mux.v
   output [PW-1:0]	emesh_packet;		// From emesh_mux of emesh_mux.v
   output		rd_wait;		// From emesh_mux of emesh_mux.v
   output		rxrr_wait;		// From esaxi of esaxi.v
   output		rxwr_wait;		// From emaxi of emaxi.v
   output		txrd_access;		// From esaxi of esaxi.v
   output [PW-1:0]	txrd_packet;		// From esaxi of esaxi.v
   output		txwr_access;		// From esaxi of esaxi.v
   output [PW-1:0]	txwr_packet;		// From esaxi of esaxi.v
   output		wr_wait;		// From emesh_mux of emesh_mux.v
   // End of automatics

   emaxi emaxi (.rxrd_access		(1'b0),//no reads generated, just push
		.rxrd_packet		({(PW){1'b0}}),
		.rxrd_wait		(),
		.txrr_access		(),//no reads, so no responses
		.txrr_packet		(),
		.txrr_wait		(1'b0),
		/*AUTOINST*/
		// Outputs
		.rxwr_wait		(rxwr_wait),
		.m_axi_awid		(m_axi_awid[M_IDW-1:0]),
		.m_axi_awaddr		(m_axi_awaddr[31:0]),
		.m_axi_awlen		(m_axi_awlen[7:0]),
		.m_axi_awsize		(m_axi_awsize[2:0]),
		.m_axi_awburst		(m_axi_awburst[1:0]),
		.m_axi_awlock		(m_axi_awlock),
		.m_axi_awcache		(m_axi_awcache[3:0]),
		.m_axi_awprot		(m_axi_awprot[2:0]),
		.m_axi_awqos		(m_axi_awqos[3:0]),
		.m_axi_awvalid		(m_axi_awvalid),
		.m_axi_wid		(m_axi_wid[M_IDW-1:0]),
		.m_axi_wdata		(m_axi_wdata[63:0]),
		.m_axi_wstrb		(m_axi_wstrb[7:0]),
		.m_axi_wlast		(m_axi_wlast),
		.m_axi_wvalid		(m_axi_wvalid),
		.m_axi_bready		(m_axi_bready),
		.m_axi_arid		(m_axi_arid[M_IDW-1:0]),
		.m_axi_araddr		(m_axi_araddr[31:0]),
		.m_axi_arlen		(m_axi_arlen[7:0]),
		.m_axi_arsize		(m_axi_arsize[2:0]),
		.m_axi_arburst		(m_axi_arburst[1:0]),
		.m_axi_arlock		(m_axi_arlock),
		.m_axi_arcache		(m_axi_arcache[3:0]),
		.m_axi_arprot		(m_axi_arprot[2:0]),
		.m_axi_arqos		(m_axi_arqos[3:0]),
		.m_axi_arvalid		(m_axi_arvalid),
		.m_axi_rready		(m_axi_rready),
		// Inputs
		.rxwr_access		(rxwr_access),
		.rxwr_packet		(rxwr_packet[PW-1:0]),
		.m_axi_aclk		(m_axi_aclk),
		.m_axi_aresetn		(m_axi_aresetn),
		.m_axi_awready		(m_axi_awready),
		.m_axi_wready		(m_axi_wready),
		.m_axi_bid		(m_axi_bid[M_IDW-1:0]),
		.m_axi_bresp		(m_axi_bresp[1:0]),
		.m_axi_bvalid		(m_axi_bvalid),
		.m_axi_arready		(m_axi_arready),
		.m_axi_rid		(m_axi_rid[M_IDW-1:0]),
		.m_axi_rdata		(m_axi_rdata[63:0]),
		.m_axi_rresp		(m_axi_rresp[1:0]),
		.m_axi_rlast		(m_axi_rlast),
		.m_axi_rvalid		(m_axi_rvalid));

   esaxi esaxi (/*AUTOINST*/
		// Outputs
		.txwr_access		(txwr_access),
		.txwr_packet		(txwr_packet[PW-1:0]),
		.txrd_access		(txrd_access),
		.txrd_packet		(txrd_packet[PW-1:0]),
		.rxrr_wait		(rxrr_wait),
		.s_axi_arready		(s_axi_arready),
		.s_axi_awready		(s_axi_awready),
		.s_axi_bid		(s_axi_bid[S_IDW-1:0]),
		.s_axi_bresp		(s_axi_bresp[1:0]),
		.s_axi_bvalid		(s_axi_bvalid),
		.s_axi_rid		(s_axi_rid[S_IDW-1:0]),
		.s_axi_rdata		(s_axi_rdata[31:0]),
		.s_axi_rlast		(s_axi_rlast),
		.s_axi_rresp		(s_axi_rresp[1:0]),
		.s_axi_rvalid		(s_axi_rvalid),
		.s_axi_wready		(s_axi_wready),
		// Inputs
		.txwr_wait		(txwr_wait),
		.txrd_wait		(txrd_wait),
		.rxrr_access		(rxrr_access),
		.rxrr_packet		(rxrr_packet[PW-1:0]),
		.s_axi_aclk		(s_axi_aclk),
		.s_axi_aresetn		(s_axi_aresetn),
		.s_axi_arid		(s_axi_arid[S_IDW-1:0]),
		.s_axi_araddr		(s_axi_araddr[31:0]),
		.s_axi_arburst		(s_axi_arburst[1:0]),
		.s_axi_arcache		(s_axi_arcache[3:0]),
		.s_axi_arlock		(s_axi_arlock),
		.s_axi_arlen		(s_axi_arlen[7:0]),
		.s_axi_arprot		(s_axi_arprot[2:0]),
		.s_axi_arqos		(s_axi_arqos[3:0]),
		.s_axi_arsize		(s_axi_arsize[2:0]),
		.s_axi_arvalid		(s_axi_arvalid),
		.s_axi_awid		(s_axi_awid[S_IDW-1:0]),
		.s_axi_awaddr		(s_axi_awaddr[31:0]),
		.s_axi_awburst		(s_axi_awburst[1:0]),
		.s_axi_awcache		(s_axi_awcache[3:0]),
		.s_axi_awlock		(s_axi_awlock),
		.s_axi_awlen		(s_axi_awlen[7:0]),
		.s_axi_awprot		(s_axi_awprot[2:0]),
		.s_axi_awqos		(s_axi_awqos[3:0]),
		.s_axi_awsize		(s_axi_awsize[2:0]),
		.s_axi_awvalid		(s_axi_awvalid),
		.s_axi_bready		(s_axi_bready),
		.s_axi_rready		(s_axi_rready),
		.s_axi_wid		(s_axi_wid[S_IDW-1:0]),
		.s_axi_wdata		(s_axi_wdata[31:0]),
		.s_axi_wlast		(s_axi_wlast),
		.s_axi_wstrb		(s_axi_wstrb[3:0]),
		.s_axi_wvalid		(s_axi_wvalid));


   //mux the read/write together
   emesh_mux emesh_mux (/*AUTOINST*/
			// Outputs
			.rd_wait	(rd_wait),
			.wr_wait	(wr_wait),
			.emesh_access	(emesh_access),
			.emesh_packet	(emesh_packet[PW-1:0]),
			// Inputs
			.rd_access	(rd_access),
			.rd_packet	(rd_packet[PW-1:0]),
			.wr_access	(wr_access),
			.wr_packet	(wr_packet[PW-1:0]),
			.emesh_wait	(emesh_wait));

   //tracing unit
   etrace etrace (/*AUTOINST*/
		  // Outputs
		  .data_access_out	(data_access_out),
		  .data_packet_out	(data_packet_out[PW-1:0]),
		  .cfg_access_out	(cfg_access_out),
		  .cfg_packet_out	(cfg_packet_out[PW-1:0]),
		  // Inputs
		  .trace_clk		(trace_clk),
		  .trace_trigger	(trace_trigger),
		  .trace_vector		(trace_vector[VW-1:0]),
		  .cfg_access_in	(cfg_access_in),
		  .cfg_packet_in	(cfg_packet_in[PW-1:0]));

   
   
   
endmodule // axi_etrace
// Local Variables:
// verilog-library-directories:("." "../../axi/hdl" "../../emesh/hdl")
// End:
