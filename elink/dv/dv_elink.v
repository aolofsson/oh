module dv_elink(/*AUTOARG*/
   // Outputs
   dut_passed, dut_failed, dut_rd_wait, dut_wr_wait, dut_access,
   dut_write, dut_datamode, dut_ctrlmode, dut_dstaddr, dut_srcaddr,
   dut_data,
   // Inputs
   clk, reset, ext_access, ext_write, ext_datamode, ext_ctrlmode,
   ext_dstaddr, ext_data, ext_srcaddr, ext_rd_wait, ext_wr_wait
   );

   parameter AW=32;
   parameter DW=32;
   parameter CW=2;             //number of clocks to send int
   
   //Basic
   input  [CW-1:0] clk;        // Core clock
   input           reset;      // Reset
   output          dut_passed; // Indicates passing test
   output          dut_failed; // Indicates failing test

   //Input Transaction
   input           ext_access;
   input           ext_write;
   input [1:0] 	   ext_datamode;
   input [3:0]     ext_ctrlmode;            
   input [31:0]    ext_dstaddr;
   input [31:0]    ext_data;
   input [31:0]    ext_srcaddr;      
   output          dut_rd_wait;
   output          dut_wr_wait;

   //Output Transaction
   output          dut_access;
   output 	   dut_write;
   output [1:0]    dut_datamode;
   output [3:0]    dut_ctrlmode;            
   output [31:0]   dut_dstaddr;
   output [31:0]   dut_srcaddr;
   output [31:0]   dut_data;  
   input           ext_rd_wait;
   input           ext_wr_wait;

   
   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [7:0]		data_n;			// From elink of elink.v
   wire [7:0]		data_p;			// From elink of elink.v
   wire [31:0]		dv_axi_araddr;		// From emaxi of emaxi.v
   wire [1:0]		dv_axi_arburst;		// From emaxi of emaxi.v
   wire [3:0]		dv_axi_arcache;		// From emaxi of emaxi.v
   wire [7:0]		dv_axi_arlen;		// From emaxi of emaxi.v
   wire [2:0]		dv_axi_arprot;		// From emaxi of emaxi.v
   wire [3:0]		dv_axi_arqos;		// From emaxi of emaxi.v
   wire			dv_axi_arready;		// From elink of elink.v
   wire [2:0]		dv_axi_arsize;		// From emaxi of emaxi.v
   wire			dv_axi_arvalid;		// From emaxi of emaxi.v
   wire [31:0]		dv_axi_awaddr;		// From emaxi of emaxi.v
   wire [1:0]		dv_axi_awburst;		// From emaxi of emaxi.v
   wire [3:0]		dv_axi_awcache;		// From emaxi of emaxi.v
   wire [7:0]		dv_axi_awlen;		// From emaxi of emaxi.v
   wire [2:0]		dv_axi_awprot;		// From emaxi of emaxi.v
   wire [3:0]		dv_axi_awqos;		// From emaxi of emaxi.v
   wire			dv_axi_awready;		// From elink of elink.v
   wire [2:0]		dv_axi_awsize;		// From emaxi of emaxi.v
   wire			dv_axi_awvalid;		// From emaxi of emaxi.v
   wire			dv_axi_bready;		// From emaxi of emaxi.v
   wire [1:0]		dv_axi_bresp;		// From elink of elink.v
   wire			dv_axi_bvalid;		// From elink of elink.v
   wire			dv_axi_rlast;		// From elink of elink.v
   wire			dv_axi_rready;		// From emaxi of emaxi.v
   wire [1:0]		dv_axi_rresp;		// From elink of elink.v
   wire			dv_axi_rvalid;		// From elink of elink.v
   wire [63:0]		dv_axi_wdata;		// From emaxi of emaxi.v
   wire			dv_axi_wlast;		// From emaxi of emaxi.v
   wire			dv_axi_wready;		// From elink of elink.v
   wire [7:0]		dv_axi_wstrb;		// From emaxi of emaxi.v
   wire			dv_axi_wvalid;		// From emaxi of emaxi.v
   wire [31:0]		elink_axi_araddr;	// From elink of elink.v
   wire [1:0]		elink_axi_arburst;	// From elink of elink.v
   wire [3:0]		elink_axi_arcache;	// From elink of elink.v
   wire [7:0]		elink_axi_arlen;	// From elink of elink.v
   wire [2:0]		elink_axi_arprot;	// From elink of elink.v
   wire [3:0]		elink_axi_arqos;	// From elink of elink.v
   wire			elink_axi_arready;	// From esaxi of esaxi.v
   wire [2:0]		elink_axi_arsize;	// From elink of elink.v
   wire			elink_axi_arvalid;	// From elink of elink.v
   wire [31:0]		elink_axi_awaddr;	// From elink of elink.v
   wire [1:0]		elink_axi_awburst;	// From elink of elink.v
   wire [3:0]		elink_axi_awcache;	// From elink of elink.v
   wire [7:0]		elink_axi_awlen;	// From elink of elink.v
   wire [2:0]		elink_axi_awprot;	// From elink of elink.v
   wire [3:0]		elink_axi_awqos;	// From elink of elink.v
   wire			elink_axi_awready;	// From esaxi of esaxi.v
   wire [2:0]		elink_axi_awsize;	// From elink of elink.v
   wire			elink_axi_awvalid;	// From elink of elink.v
   wire			elink_axi_bready;	// From elink of elink.v
   wire [1:0]		elink_axi_bresp;	// From esaxi of esaxi.v
   wire			elink_axi_bvalid;	// From esaxi of esaxi.v
   wire [31:0]		elink_axi_rdata;	// From esaxi of esaxi.v
   wire			elink_axi_rlast;	// From esaxi of esaxi.v
   wire			elink_axi_rready;	// From elink of elink.v
   wire [1:0]		elink_axi_rresp;	// From esaxi of esaxi.v
   wire			elink_axi_rvalid;	// From esaxi of esaxi.v
   wire [63:0]		elink_axi_wdata;	// From elink of elink.v
   wire			elink_axi_wlast;	// From elink of elink.v
   wire			elink_axi_wready;	// From esaxi of esaxi.v
   wire [7:0]		elink_axi_wstrb;	// From elink of elink.v
   wire			elink_axi_wvalid;	// From elink of elink.v
   wire			frame_n;		// From elink of elink.v
   wire			frame_p;		// From elink of elink.v
   wire			lclk_n;			// From elink of elink.v
   wire			lclk_p;			// From elink of elink.v
   wire			rd_wait_n;		// From elink of elink.v
   wire			rd_wait_p;		// From elink of elink.v
   wire			wr_wait_n;		// From elink of elink.v
   wire			wr_wait_p;		// From elink of elink.v
   // End of automatics

   wire [63:0] 		dv_axi_rdata; //restricted to 32 bits here
   wire 		emaxi_emrq_rd_en;	// From emaxi of emaxi.v
   wire 		emaxi_emwr_rd_en;	// From emaxi of emaxi.v
   wire 		emaxi_emrq_access;	// To emaxi of emaxi.v
   wire [3:0]		emaxi_emrq_ctrlmode;	// To emaxi of emaxi.v
   wire [31:0]		emaxi_emrq_data;	// To emaxi of emaxi.v
   wire [1:0]		emaxi_emrq_datamode;	// To emaxi of emaxi.v
   wire [31:0]		emaxi_emrq_dstaddr;	// To emaxi of emaxi.v
   wire [31:0]		emaxi_emrq_srcaddr;	// To emaxi of emaxi.v
   wire 		emaxi_emrq_write;	// To emaxi of emaxi.v
   wire 		emaxi_emwr_access;	// To emaxi of emaxi.v
   wire [3:0]		emaxi_emwr_ctrlmode;	// To emaxi of emaxi.v
   wire [31:0]		emaxi_emwr_data;	// To emaxi of emaxi.v
   wire [1:0]		emaxi_emwr_datamode;	// To emaxi of emaxi.v
   wire [31:0]		emaxi_emwr_dstaddr;	// To emaxi of emaxi.v
   wire [31:0]		emaxi_emwr_srcaddr;	// To emaxi of emaxi.v
   wire 		emaxi_emwr_write;	// To emaxi of emaxi.v
   wire 		emaxi_emrr_access;	// To emaxi of emaxi.v
   wire [3:0]		emaxi_emrr_ctrlmode;	// To emaxi of emaxi.v
   wire [31:0]		emaxi_emrr_data;	// To emaxi of emaxi.v
   wire [1:0]		emaxi_emrr_datamode;	// To emaxi of emaxi.v
   wire [31:0]		emaxi_emrr_dstaddr;	// To emaxi of emaxi.v
   wire [31:0]		emaxi_emrr_srcaddr;	// To emaxi of emaxi.v
   wire 		emaxi_emrr_write;	// To emaxi of emaxi.v
   
   wire 		esaxi_emrq_access;	// From esaxi of esaxi.v
   wire [3:0]		esaxi_emrq_ctrlmode;	// From esaxi of esaxi.v
   wire [31:0] 		esaxi_emrq_data;	// From esaxi of esaxi.v
   wire [1:0] 		esaxi_emrq_datamode;	// From esaxi of esaxi.v
   wire [31:0] 		esaxi_emrq_dstaddr;	// From esaxi of esaxi.v
   wire [31:0] 		esaxi_emrq_srcaddr;	// From esaxi of esaxi.v
   wire 		esaxi_emrq_write;	// From esaxi of esaxi.v
   wire 		esaxi_emrr_rd_en;	// From esaxi of esaxi.v
   wire 		esaxi_emwr_access;	// From esaxi of esaxi.v
   wire [3:0] 		esaxi_emwr_ctrlmode;	// From esaxi of esaxi.v
   wire [31:0] 		esaxi_emwr_data;	// From esaxi of esaxi.v
   wire [1:0] 		esaxi_emwr_datamode;	// From esaxi of esaxi.v
   wire [31:0] 		esaxi_emwr_dstaddr;	// From esaxi of esaxi.v
   wire [31:0] 		esaxi_emwr_srcaddr;	// From esaxi of esaxi.v
   wire 		esaxi_emwr_write;	// From esaxi of esaxi.v
   wire [3:0] 		colid;
   wire [3:0] 		rowid;
   wire 		embox_full;
   wire 		embox_not_empty;
   wire 		cclk_p, cclk_n;
   wire 		chip_resetb;
   wire 		dut_access;		// To dut_monitor of emesh_monitor.v
   wire [3:0]		dut_ctrlmode;		// To dut_monitor of emesh_monitor.v
   wire [DW-1:0]	dut_data;		// To dut_monitor of emesh_monitor.v
   wire [1:0]		dut_datamode;		// To dut_monitor of emesh_monitor.v
   wire [AW-1:0]	dut_dstaddr;		// To dut_monitor of emesh_monitor.v
   wire [AW-1:0]	dut_srcaddr;		// To dut_monitor of emesh_monitor.v
   wire		dut_write;		// To dut_monitor of emesh_monitor.v
   

   //Clocks
   wire clkin         = clk[0];
   wire m_axi_aclk    = clk[1];
   wire s_axi_aclk    = clk[1];
   
   //Splitting transaction into read/write path

   //Read path
   assign emaxi_emrq_access        = ext_access & ~ext_write;
   assign emaxi_emrq_write         = 1'b0;
   assign emaxi_emrq_datamode[1:0] = ext_datamode[1:0];
   assign emaxi_emrq_ctrlmode[3:0] = ext_ctrlmode[3:0];
   assign emaxi_emrq_dstaddr[31:0] = ext_dstaddr[31:0];
   assign emaxi_emrq_data[31:0]    = ext_data[31:0];
   assign emaxi_emrq_srcaddr[31:0] = ext_srcaddr[31:0];
   
   //Write path
   assign emaxi_emwr_access        = ext_access & ext_write;
   assign emaxi_emwr_write         = 1'b1;
   assign emaxi_emwr_datamode[1:0] = ext_datamode[1:0];
   assign emaxi_emwr_ctrlmode[3:0] = ext_ctrlmode[3:0];
   assign emaxi_emwr_dstaddr[31:0] = ext_dstaddr[31:0];
   assign emaxi_emwr_data[31:0]    = ext_data[31:0];
   assign emaxi_emwr_srcaddr[31:0] = ext_srcaddr[31:0];

   //Master pushback
   assign dut_rd_wait           = ~emaxi_emrq_rd_en & emaxi_emrq_access;
   assign dut_wr_wait           = ~emaxi_emwr_rd_en & emaxi_emwr_access;
   
   //Getting results back
   //TODO: deal with collisions later
   //btw, as I write this muxes...feeling that a datapacket is in order after all.
   //maybe add a module for converting between packet and explicit signals....

   assign dut_access        = emaxi_emrr_access | esaxi_emwr_access | esaxi_emrq_access;

   assign dut_write         = emaxi_emrr_access ? emaxi_emrr_write :
			      esaxi_emwr_access ? esaxi_emwr_write :
                                                  esaxi_emrq_write;

   assign dut_datamode[1:0] = emaxi_emrr_access ? emaxi_emrr_datamode[1:0] :
			      esaxi_emwr_access ? esaxi_emwr_datamode[1:0] :
                                                  esaxi_emrq_datamode[1:0];


   assign dut_ctrlmode[3:0] = emaxi_emrr_access ? emaxi_emrr_ctrlmode[3:0] :
			       esaxi_emwr_access ? esaxi_emwr_ctrlmode[3:0] :
                                                   esaxi_emrq_ctrlmode[3:0];

   assign dut_dstaddr[31:0] = emaxi_emrr_access ? emaxi_emrr_dstaddr[31:0] :
 			      esaxi_emwr_access ? esaxi_emwr_dstaddr[31:0] :
                                                  esaxi_emrq_dstaddr[31:0];

   assign dut_data[31:0] = emaxi_emrr_access ? emaxi_emrr_data[31:0]    :
 			   esaxi_emwr_access ? esaxi_emwr_data[31:0] :
                                               esaxi_emrq_data[31:0];

   assign dut_srcaddr[31:0] = emaxi_emrr_access ? emaxi_emrr_srcaddr[31:0] :
 			      esaxi_emwr_access ? esaxi_emwr_srcaddr[31:0] :
                              esaxi_emrq_srcaddr[31:0];

   

  
   /*emaxi AUTO_TEMPLATE ( 
                        // Outputs
                        .m_\(.*\)         (dv_\1[]),
                        .em\(.*\)         (emaxi_em\1[]),
                        
                             );
   */
   
   //Drive the elink slave AXI interface
   emaxi emaxi(.emrr_progfull		(1'b0),
	       .m_axi_aresetn		(~reset),
	       .m_axi_aclk		(m_axi_aclk),
	       .emwr_rd_en		(emaxi_emwr_rd_en),
	       .emrq_rd_en		(emaxi_emrq_rd_en),
	       .emrr_access		(emaxi_emrr_access),
	       .emrr_write		(emaxi_emrr_write),
	       .emrr_datamode		(emaxi_emrr_datamode[1:0]),
	       .emrr_ctrlmode		(emaxi_emrr_ctrlmode[3:0]),
	       .emrr_dstaddr		(emaxi_emrr_dstaddr[31:0]),
	       .emrr_data		(emaxi_emrr_data[31:0]),
	       .emrr_srcaddr		(emaxi_emrr_srcaddr[31:0]),
	       /*AUTOINST*/
	       // Outputs
	       .m_axi_awaddr		(dv_axi_awaddr[31:0]),	 // Templated
	       .m_axi_awlen		(dv_axi_awlen[7:0]),	 // Templated
	       .m_axi_awsize		(dv_axi_awsize[2:0]),	 // Templated
	       .m_axi_awburst		(dv_axi_awburst[1:0]),	 // Templated
	       .m_axi_awcache		(dv_axi_awcache[3:0]),	 // Templated
	       .m_axi_awprot		(dv_axi_awprot[2:0]),	 // Templated
	       .m_axi_awqos		(dv_axi_awqos[3:0]),	 // Templated
	       .m_axi_awvalid		(dv_axi_awvalid),	 // Templated
	       .m_axi_wdata		(dv_axi_wdata[63:0]),	 // Templated
	       .m_axi_wstrb		(dv_axi_wstrb[7:0]),	 // Templated
	       .m_axi_wlast		(dv_axi_wlast),		 // Templated
	       .m_axi_wvalid		(dv_axi_wvalid),	 // Templated
	       .m_axi_bready		(dv_axi_bready),	 // Templated
	       .m_axi_araddr		(dv_axi_araddr[31:0]),	 // Templated
	       .m_axi_arlen		(dv_axi_arlen[7:0]),	 // Templated
	       .m_axi_arsize		(dv_axi_arsize[2:0]),	 // Templated
	       .m_axi_arburst		(dv_axi_arburst[1:0]),	 // Templated
	       .m_axi_arcache		(dv_axi_arcache[3:0]),	 // Templated
	       .m_axi_arprot		(dv_axi_arprot[2:0]),	 // Templated
	       .m_axi_arqos		(dv_axi_arqos[3:0]),	 // Templated
	       .m_axi_arvalid		(dv_axi_arvalid),	 // Templated
	       .m_axi_rready		(dv_axi_rready),	 // Templated
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
	       .m_axi_awready		(dv_axi_awready),	 // Templated
	       .m_axi_wready		(dv_axi_wready),	 // Templated
	       .m_axi_bresp		(dv_axi_bresp[1:0]),	 // Templated
	       .m_axi_bvalid		(dv_axi_bvalid),	 // Templated
	       .m_axi_arready		(dv_axi_arready),	 // Templated
	       .m_axi_rdata		(dv_axi_rdata[63:0]),	 // Templated
	       .m_axi_rresp		(dv_axi_rresp[1:0]),	 // Templated
	       .m_axi_rlast		(dv_axi_rlast),		 // Templated
	       .m_axi_rvalid		(dv_axi_rvalid));	 // Templated


   /*esaxi AUTO_TEMPLATE ( 
                        // Outputs
                        .s_\(.*\)         (elink_\1[]),
                        .mi_\(.*\)        (),
                        .em\(.*\)         (esaxi_em\1[]),
                        );
   */


   esaxi esaxi (.emwr_progfull		(1'b0),
		.emrq_progfull		(1'b0),
		.emrr_data		(32'b0),//no read from other side
		.emrr_access		(1'b0),
		.mi_ecfg_dout		(32'b0),
		.mi_tx_emmu_dout	(32'b0),
		.mi_rx_emmu_dout	(32'b0),
		.mi_embox_dout		(32'b0),
		.ecfg_tx_ctrlmode	(4'b0),
		.ecfg_coreid		(12'h808),
		.ecfg_timeout_enable	(1'b0),
		.s_axi_aresetn		(~reset),
		.s_axi_aclk		(s_axi_aclk),
		.emwr_access		(esaxi_emwr_access),
		.emwr_write		(esaxi_emwr_write),
		.emwr_datamode		(esaxi_emwr_datamode[1:0]),
		.emwr_ctrlmode		(esaxi_emwr_ctrlmode[3:0]),
		.emwr_dstaddr		(esaxi_emwr_dstaddr[31:0]),
		.emwr_data		(esaxi_emwr_data[31:0]),
		.emwr_srcaddr		(esaxi_emwr_srcaddr[31:0]),
		.emrq_access		(esaxi_emrq_access),
		.emrq_write		(esaxi_emrq_write),
		.emrq_datamode		(esaxi_emrq_datamode[1:0]),
		.emrq_ctrlmode		(esaxi_emrq_ctrlmode[3:0]),
		.emrq_dstaddr		(esaxi_emrq_dstaddr[31:0]),
		.emrq_data		(esaxi_emrq_data[31:0]),
		.emrq_srcaddr		(esaxi_emrq_srcaddr[31:0]),
		.emrr_rd_en		(esaxi_emrr_rd_en),
		/*AUTOINST*/
		// Outputs
		.mi_clk			(),			 // Templated
		.mi_rx_emmu_sel		(),			 // Templated
		.mi_tx_emmu_sel		(),			 // Templated
		.mi_ecfg_sel		(),			 // Templated
		.mi_embox_sel		(),			 // Templated
		.mi_we			(),			 // Templated
		.mi_addr		(),			 // Templated
		.mi_din			(),			 // Templated
		.s_axi_arready		(elink_axi_arready),	 // Templated
		.s_axi_awready		(elink_axi_awready),	 // Templated
		.s_axi_bresp		(elink_axi_bresp[1:0]),	 // Templated
		.s_axi_bvalid		(elink_axi_bvalid),	 // Templated
		.s_axi_rdata		(elink_axi_rdata[31:0]), // Templated
		.s_axi_rlast		(elink_axi_rlast),	 // Templated
		.s_axi_rresp		(elink_axi_rresp[1:0]),	 // Templated
		.s_axi_rvalid		(elink_axi_rvalid),	 // Templated
		.s_axi_wready		(elink_axi_wready),	 // Templated
		// Inputs
		.s_axi_araddr		(elink_axi_araddr[29:0]), // Templated
		.s_axi_arburst		(elink_axi_arburst[1:0]), // Templated
		.s_axi_arcache		(elink_axi_arcache[3:0]), // Templated
		.s_axi_arlen		(elink_axi_arlen[7:0]),	 // Templated
		.s_axi_arprot		(elink_axi_arprot[2:0]), // Templated
		.s_axi_arqos		(elink_axi_arqos[3:0]),	 // Templated
		.s_axi_arsize		(elink_axi_arsize[2:0]), // Templated
		.s_axi_arvalid		(elink_axi_arvalid),	 // Templated
		.s_axi_awaddr		(elink_axi_awaddr[29:0]), // Templated
		.s_axi_awburst		(elink_axi_awburst[1:0]), // Templated
		.s_axi_awcache		(elink_axi_awcache[3:0]), // Templated
		.s_axi_awlen		(elink_axi_awlen[7:0]),	 // Templated
		.s_axi_awprot		(elink_axi_awprot[2:0]), // Templated
		.s_axi_awqos		(elink_axi_awqos[3:0]),	 // Templated
		.s_axi_awsize		(elink_axi_awsize[2:0]), // Templated
		.s_axi_awvalid		(elink_axi_awvalid),	 // Templated
		.s_axi_bready		(elink_axi_bready),	 // Templated
		.s_axi_rready		(elink_axi_rready),	 // Templated
		.s_axi_wdata		(elink_axi_wdata[31:0]), // Templated
		.s_axi_wlast		(elink_axi_wlast),	 // Templated
		.s_axi_wstrb		(elink_axi_wstrb[3:0]),	 // Templated
		.s_axi_wvalid		(elink_axi_wvalid));	 // Templated
   
   
   /*elink AUTO_TEMPLATE ( 
                        // Outputs
                        .txo_\(.*\)       (\1[]),
                        .rxi_\(.*\)       (\1[]),  
                        .rxo_\(.*\)       (\1[]),
                        .txi_\(.*\)       (\1[]),  
                        .s_\(.*\)         (dv_\1[]),
                        .m_\(.*\)         (elink_\1[]),
                        .m_axi_rdata	  ({32'b0,elink_axi_rdata[31:0]}), //restricted to slave width
                        );
   */

   elink elink (.hard_reset		(reset),
		.embox_not_empty	(embox_full),
		.embox_full		(embox_not_empty),
		.chip_resetb		(chip_resetb),
		.colid			(colid[3:0]),
		.rowid			(rowid[3:0]),
		.s_axi_aresetn		(~reset),
		.m_axi_aresetn		(~reset),
		.s_axi_aclk		(s_axi_aclk),
		.m_axi_aclk		(m_axi_aclk),
		.cclk_p			(cclk_p),
		.cclk_n			(cclk_n),
		.clkin			(clkin),
		.bypass_clocks          ({clkin,clkin,clkin}),
		/*AUTOINST*/
		// Outputs
		.rxo_wr_wait_p		(wr_wait_p),		 // Templated
		.rxo_wr_wait_n		(wr_wait_n),		 // Templated
		.rxo_rd_wait_p		(rd_wait_p),		 // Templated
		.rxo_rd_wait_n		(rd_wait_n),		 // Templated
		.txo_lclk_p		(lclk_p),		 // Templated
		.txo_lclk_n		(lclk_n),		 // Templated
		.txo_frame_p		(frame_p),		 // Templated
		.txo_frame_n		(frame_n),		 // Templated
		.txo_data_p		(data_p[7:0]),		 // Templated
		.txo_data_n		(data_n[7:0]),		 // Templated
		.m_axi_araddr		(elink_axi_araddr[31:0]), // Templated
		.m_axi_arburst		(elink_axi_arburst[1:0]), // Templated
		.m_axi_arcache		(elink_axi_arcache[3:0]), // Templated
		.m_axi_arlen		(elink_axi_arlen[7:0]),	 // Templated
		.m_axi_arprot		(elink_axi_arprot[2:0]), // Templated
		.m_axi_arqos		(elink_axi_arqos[3:0]),	 // Templated
		.m_axi_arsize		(elink_axi_arsize[2:0]), // Templated
		.m_axi_arvalid		(elink_axi_arvalid),	 // Templated
		.m_axi_awaddr		(elink_axi_awaddr[31:0]), // Templated
		.m_axi_awburst		(elink_axi_awburst[1:0]), // Templated
		.m_axi_awcache		(elink_axi_awcache[3:0]), // Templated
		.m_axi_awlen		(elink_axi_awlen[7:0]),	 // Templated
		.m_axi_awprot		(elink_axi_awprot[2:0]), // Templated
		.m_axi_awqos		(elink_axi_awqos[3:0]),	 // Templated
		.m_axi_awsize		(elink_axi_awsize[2:0]), // Templated
		.m_axi_awvalid		(elink_axi_awvalid),	 // Templated
		.m_axi_bready		(elink_axi_bready),	 // Templated
		.m_axi_rready		(elink_axi_rready),	 // Templated
		.m_axi_wdata		(elink_axi_wdata[63:0]), // Templated
		.m_axi_wlast		(elink_axi_wlast),	 // Templated
		.m_axi_wstrb		(elink_axi_wstrb[7:0]),	 // Templated
		.m_axi_wvalid		(elink_axi_wvalid),	 // Templated
		.s_axi_arready		(dv_axi_arready),	 // Templated
		.s_axi_awready		(dv_axi_awready),	 // Templated
		.s_axi_bresp		(dv_axi_bresp[1:0]),	 // Templated
		.s_axi_bvalid		(dv_axi_bvalid),	 // Templated
		.s_axi_rdata		(dv_axi_rdata[31:0]),	 // Templated
		.s_axi_rlast		(dv_axi_rlast),		 // Templated
		.s_axi_rresp		(dv_axi_rresp[1:0]),	 // Templated
		.s_axi_rvalid		(dv_axi_rvalid),	 // Templated
		.s_axi_wready		(dv_axi_wready),	 // Templated
		// Inputs
		.rxi_lclk_p		(lclk_p),		 // Templated
		.rxi_lclk_n		(lclk_n),		 // Templated
		.rxi_frame_p		(frame_p),		 // Templated
		.rxi_frame_n		(frame_n),		 // Templated
		.rxi_data_p		(data_p[7:0]),		 // Templated
		.rxi_data_n		(data_n[7:0]),		 // Templated
		.txi_wr_wait_p		(wr_wait_p),		 // Templated
		.txi_wr_wait_n		(wr_wait_n),		 // Templated
		.txi_rd_wait_p		(rd_wait_p),		 // Templated
		.txi_rd_wait_n		(rd_wait_n),		 // Templated
		.m_axi_arready		(elink_axi_arready),	 // Templated
		.m_axi_awready		(elink_axi_awready),	 // Templated
		.m_axi_bresp		(elink_axi_bresp[1:0]),	 // Templated
		.m_axi_bvalid		(elink_axi_bvalid),	 // Templated
		.m_axi_rdata		({32'b0,elink_axi_rdata[31:0]}), // Templated
		.m_axi_rlast		(elink_axi_rlast),	 // Templated
		.m_axi_rresp		(elink_axi_rresp[1:0]),	 // Templated
		.m_axi_rvalid		(elink_axi_rvalid),	 // Templated
		.m_axi_wready		(elink_axi_wready),	 // Templated
		.s_axi_araddr		(dv_axi_araddr[29:0]),	 // Templated
		.s_axi_arburst		(dv_axi_arburst[1:0]),	 // Templated
		.s_axi_arcache		(dv_axi_arcache[3:0]),	 // Templated
		.s_axi_arlen		(dv_axi_arlen[7:0]),	 // Templated
		.s_axi_arprot		(dv_axi_arprot[2:0]),	 // Templated
		.s_axi_arqos		(dv_axi_arqos[3:0]),	 // Templated
		.s_axi_arsize		(dv_axi_arsize[2:0]),	 // Templated
		.s_axi_arvalid		(dv_axi_arvalid),	 // Templated
		.s_axi_awaddr		(dv_axi_awaddr[29:0]),	 // Templated
		.s_axi_awburst		(dv_axi_awburst[1:0]),	 // Templated
		.s_axi_awcache		(dv_axi_awcache[3:0]),	 // Templated
		.s_axi_awlen		(dv_axi_awlen[7:0]),	 // Templated
		.s_axi_awprot		(dv_axi_awprot[2:0]),	 // Templated
		.s_axi_awqos		(dv_axi_awqos[3:0]),	 // Templated
		.s_axi_awsize		(dv_axi_awsize[2:0]),	 // Templated
		.s_axi_awvalid		(dv_axi_awvalid),	 // Templated
		.s_axi_bready		(dv_axi_bready),	 // Templated
		.s_axi_rready		(dv_axi_rready),	 // Templated
		.s_axi_wdata		(dv_axi_wdata[31:0]),	 // Templated
		.s_axi_wlast		(dv_axi_wlast),		 // Templated
		.s_axi_wstrb		(dv_axi_wstrb[3:0]),	 // Templated
		.s_axi_wvalid		(dv_axi_wvalid));	 // Templated


   //Transaction Monitor
   reg [31:0] 		etime;  
   always @ (posedge clkin or posedge reset)
     if(reset)
       etime[31:0] <= 32'b0;
     else
       etime[31:0] <= etime[31:0]+1'b1;

   wire 		itrace = 1'b1;

  /*emesh_monitor AUTO_TEMPLATE ( 
                        // Outputs
                        .txo_\(.*\)       (\1[]),
                        .rxi_\(.*\)       (\1[]),  
                        .rxo_\(.*\)       (\1[]),
                        .txi_\(.*\)       (\1[]),  
                        .s_\(.*\)         (dv_\1[]),
                        .emesh_\(.*\)     (@"(substring vl-cell-name  0 3)"_\1[]),
                        .m_axi_rdata	  ({32'b0,elink_axi_rdata[31:0]}), //restricted to slave width
                        );
   */


   emesh_monitor #(.NAME("stimulus")) ext_monitor (.emesh_wait		((dut_rd_wait | dut_wr_wait)),//TODO:fix collisions
						   /*AUTOINST*/
						   // Inputs
						   .clk			(m_axi_aclk),
						   .reset		(reset),
						   .itrace		(itrace),
						   .etime		(etime[31:0]),
						   .emesh_access	(ext_access),	 // Templated
						   .emesh_write		(ext_write),	 // Templated
						   .emesh_datamode	(ext_datamode[1:0]), // Templated
						   .emesh_ctrlmode	(ext_ctrlmode[3:0]), // Templated
						   .emesh_dstaddr	(ext_dstaddr[AW-1:0]), // Templated
						   .emesh_data		(ext_data[DW-1:0]), // Templated
						   .emesh_srcaddr	(ext_srcaddr[AW-1:0])); // Templated
   
   emesh_monitor #(.NAME("dut")) dut_monitor (.emesh_wait	(1'b0),
					      /*AUTOINST*/
					      // Inputs
					      .clk		(s_axi_aclk),
					      .reset		(reset),
					      .itrace		(itrace),
					      .etime		(etime[31:0]),
					      .emesh_access	(dut_access),	 // Templated
					      .emesh_write	(dut_write),	 // Templated
					      .emesh_datamode	(dut_datamode[1:0]), // Templated
					      .emesh_ctrlmode	(dut_ctrlmode[3:0]), // Templated
					      .emesh_dstaddr	(dut_dstaddr[AW-1:0]), // Templated
					      .emesh_data	(dut_data[DW-1:0]), // Templated
					      .emesh_srcaddr	(dut_srcaddr[AW-1:0])); // Templated

endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl")
// End:

/*
 Copyright (C) 2014 Adapteva, Inc. 
 Contributed by Andreas Olofsson <andreas@adapteva.com>

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

