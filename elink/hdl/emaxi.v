
`timescale 1 ns / 1 ps

	module emaxi #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Master Bus Interface M00_AXI
		parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
		parameter integer C_M00_AXI_BURST_LEN	= 16,
		parameter integer C_M00_AXI_ID_WIDTH	= 1,
		parameter integer C_M00_AXI_ADDR_WIDTH	= 32,
		parameter integer C_M00_AXI_DATA_WIDTH	= 64,
		parameter integer C_M00_AXI_AWUSER_WIDTH	= 0,
		parameter integer C_M00_AXI_ARUSER_WIDTH	= 0,
		parameter integer C_M00_AXI_WUSER_WIDTH	= 0,
		parameter integer C_M00_AXI_RUSER_WIDTH	= 0,
		parameter integer C_M00_AXI_BUSER_WIDTH	= 0
	)
	(
		// Users to add ports here
		   // FIFO read-master port, writes from RX channel
         input [102:0] 			       emwr_rd_data,
         output 			       emwr_rd_en,
         input 				       emwr_empty,
  
        // FIFO read-master port, read requests from RX channel
         input [102:0] 			       emrq_rd_data,
         output 			       emrq_rd_en,
         input 				       emrq_empty,
     
        // FIFO write-master port, read responses to TX channel
         output [102:0] 		       emrr_wr_data,
         output 			       emrr_wr_en,
         input 				       emrr_full,
         input 				       emrr_prog_full,

	 // Ports of Axi Master Bus Interface M00_AXI
	 input 				       m00_axi_aclk,
	 input 				       m00_axi_aresetn,
	 output [C_M00_AXI_ID_WIDTH-1 : 0]     m00_axi_awid,
	 output [C_M00_AXI_ADDR_WIDTH-1 : 0]   m00_axi_awaddr,
	 output [7 : 0] 		       m00_axi_awlen,
	 output [2 : 0] 		       m00_axi_awsize,
	 output [1 : 0] 		       m00_axi_awburst,
	 output 			       m00_axi_awlock,
	 output [3 : 0] 		       m00_axi_awcache,
	 output [2 : 0] 		       m00_axi_awprot,
	 output [3 : 0] 		       m00_axi_awqos,
	 output [C_M00_AXI_AWUSER_WIDTH-1 : 0] m00_axi_awuser,
	 output 			       m00_axi_awvalid,
	 input 				       m00_axi_awready,
	 output [C_M00_AXI_DATA_WIDTH-1 : 0]   m00_axi_wdata,
	 output [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
	 output 			       m00_axi_wlast,
	 output [C_M00_AXI_WUSER_WIDTH-1 : 0]  m00_axi_wuser,
	 output 			       m00_axi_wvalid,
	 input 				       m00_axi_wready,
	 input [C_M00_AXI_ID_WIDTH-1 : 0]      m00_axi_bid,
	 input [1 : 0] 			       m00_axi_bresp,
	 input [C_M00_AXI_BUSER_WIDTH-1 : 0]   m00_axi_buser,
	 input 				       m00_axi_bvalid,
	 output 			       m00_axi_bready,
	 output [C_M00_AXI_ID_WIDTH-1 : 0]     m00_axi_arid,
	 output [C_M00_AXI_ADDR_WIDTH-1 : 0]   m00_axi_araddr,
	 output [7 : 0] 		       m00_axi_arlen,
	 output [2 : 0] 		       m00_axi_arsize,
	 output [1 : 0] 		       m00_axi_arburst,
	 output 			       m00_axi_arlock,
	 output [3 : 0] 		       m00_axi_arcache,
	 output [2 : 0] 		       m00_axi_arprot,
	 output [3 : 0] 		       m00_axi_arqos,
	 output [C_M00_AXI_ARUSER_WIDTH-1 : 0] m00_axi_aruser,
	 output 			       m00_axi_arvalid,
	 input 				       m00_axi_arready,
	 input [C_M00_AXI_ID_WIDTH-1 : 0]      m00_axi_rid,
	 input [C_M00_AXI_DATA_WIDTH-1 : 0]    m00_axi_rdata,
	 input [1 : 0] 			       m00_axi_rresp,
	 input 				       m00_axi_rlast,
	 input [C_M00_AXI_RUSER_WIDTH-1 : 0]   m00_axi_ruser,
	 input 				       m00_axi_rvalid,
	 output 			       m00_axi_rready
	);
// Instantiation of Axi Bus Interface M00_AXI
	emaxi_logic # ( 
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M00_AXI_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_BURST_LEN(C_M00_AXI_BURST_LEN),
		.C_M_AXI_ID_WIDTH(C_M00_AXI_ID_WIDTH),
		.C_M_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH),
		.C_M_AXI_AWUSER_WIDTH(C_M00_AXI_AWUSER_WIDTH),
		.C_M_AXI_ARUSER_WIDTH(C_M00_AXI_ARUSER_WIDTH),
		.C_M_AXI_WUSER_WIDTH(C_M00_AXI_WUSER_WIDTH),
		.C_M_AXI_RUSER_WIDTH(C_M00_AXI_RUSER_WIDTH),
		.C_M_AXI_BUSER_WIDTH(C_M00_AXI_BUSER_WIDTH)
	) emaxi_logic (
                               
        .emwr_rd_data(emwr_rd_data),
        .emwr_rd_en(emwr_rd_en),
        .emwr_empty(emwr_empty),
        .emrq_rd_data(emrq_rd_data),
        .emrq_rd_en(emrq_rd_en),
        .emrq_empty(emrq_empty),
        .emrr_wr_data(emrr_wr_data),
        .emrr_wr_en(emrr_wr_en),
        .emrr_full(emrr_full),
        .emrr_prog_full(emrr_prog_full),

		.M_AXI_ACLK(m00_axi_aclk),
		.M_AXI_ARESETN(m00_axi_aresetn),
		.M_AXI_AWID(m00_axi_awid),
		.M_AXI_AWADDR(m00_axi_awaddr),
		.M_AXI_AWLEN(m00_axi_awlen),
		.M_AXI_AWSIZE(m00_axi_awsize),
		.M_AXI_AWBURST(m00_axi_awburst),
		.M_AXI_AWLOCK(m00_axi_awlock),
		.M_AXI_AWCACHE(m00_axi_awcache),
		.M_AXI_AWPROT(m00_axi_awprot),
		.M_AXI_AWQOS(m00_axi_awqos),
		.M_AXI_AWUSER(m00_axi_awuser),
		.M_AXI_AWVALID(m00_axi_awvalid),
		.M_AXI_AWREADY(m00_axi_awready),
		.M_AXI_WDATA(m00_axi_wdata),
		.M_AXI_WSTRB(m00_axi_wstrb),
		.M_AXI_WLAST(m00_axi_wlast),
		.M_AXI_WUSER(m00_axi_wuser),
		.M_AXI_WVALID(m00_axi_wvalid),
		.M_AXI_WREADY(m00_axi_wready),
		.M_AXI_BID(m00_axi_bid),
		.M_AXI_BRESP(m00_axi_bresp),
		.M_AXI_BUSER(m00_axi_buser),
		.M_AXI_BVALID(m00_axi_bvalid),
		.M_AXI_BREADY(m00_axi_bready),
		.M_AXI_ARID(m00_axi_arid),
		.M_AXI_ARADDR(m00_axi_araddr),
		.M_AXI_ARLEN(m00_axi_arlen),
		.M_AXI_ARSIZE(m00_axi_arsize),
		.M_AXI_ARBURST(m00_axi_arburst),
		.M_AXI_ARLOCK(m00_axi_arlock),
		.M_AXI_ARCACHE(m00_axi_arcache),
		.M_AXI_ARPROT(m00_axi_arprot),
		.M_AXI_ARQOS(m00_axi_arqos),
		.M_AXI_ARUSER(m00_axi_aruser),
		.M_AXI_ARVALID(m00_axi_arvalid),
		.M_AXI_ARREADY(m00_axi_arready),
		.M_AXI_RID(m00_axi_rid),
		.M_AXI_RDATA(m00_axi_rdata),
		.M_AXI_RRESP(m00_axi_rresp),
		.M_AXI_RLAST(m00_axi_rlast),
		.M_AXI_RUSER(m00_axi_ruser),
		.M_AXI_RVALID(m00_axi_rvalid),
		.M_AXI_RREADY(m00_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
