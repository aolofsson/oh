module axislave_stub (/*AUTOARG*/
   // Outputs
   s_axi_arready, s_axi_awready, s_axi_bid, s_axi_bresp, s_axi_bvalid,
   s_axi_rid, s_axi_rdata, s_axi_rlast, s_axi_rresp, s_axi_rvalid,
   s_axi_wready,
   // Inputs
   s_axi_aclk, s_axi_aresetn, s_axi_arid, s_axi_araddr, s_axi_arburst,
   s_axi_arcache, s_axi_arlock, s_axi_arlen, s_axi_arprot,
   s_axi_arqos, s_axi_arsize, s_axi_arvalid, s_axi_awid, s_axi_awaddr,
   s_axi_awburst, s_axi_awcache, s_axi_awlock, s_axi_awlen,
   s_axi_awprot, s_axi_awqos, s_axi_awsize, s_axi_awvalid,
   s_axi_bready, s_axi_rready, s_axi_wid, s_axi_wdata, s_axi_wlast,
   s_axi_wstrb, s_axi_wvalid
   );

   parameter         S_IDW               = 12;
   
   /*****************************/
   /*AXI slave interface        */
   /*****************************/  
   //Clock and reset
   input 	  s_axi_aclk;
   input 	  s_axi_aresetn;
   
   //Read address channel
   input [S_IDW-1:0] s_axi_arid;    //write address ID
   input [31:0]    s_axi_araddr;
   input [1:0] 	   s_axi_arburst;
   input [3:0] 	   s_axi_arcache;
   input  	   s_axi_arlock;
   input [7:0] 	   s_axi_arlen;
   input [2:0] 	   s_axi_arprot;
   input [3:0] 	   s_axi_arqos;
   output 	   s_axi_arready;
   input [2:0] 	   s_axi_arsize;
   input 	   s_axi_arvalid;
   
   //Write address channel
   input [S_IDW-1:0] s_axi_awid;    //write address ID
   input [31:0]    s_axi_awaddr;
   input [1:0] 	   s_axi_awburst;
   input [3:0] 	   s_axi_awcache;
   input  	   s_axi_awlock;
   input [7:0] 	   s_axi_awlen;
   input [2:0] 	   s_axi_awprot;
   input [3:0] 	   s_axi_awqos;   
   input [2:0] 	   s_axi_awsize;
   input 	   s_axi_awvalid;
   output 	   s_axi_awready;
   
   //Buffered write response channel
   output [S_IDW-1:0] s_axi_bid;    //write address ID
   output [1:0]     s_axi_bresp;
   output 	    s_axi_bvalid;
   input 	    s_axi_bready;
   
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

   //read address chanel
   assign s_axi_arready        = 'b0;   

   //write address channel
   assign s_axi_awready        = 'b0;

   //buffered write response
   assign s_axi_bid[S_IDW-1:0] = 'b0;
   assign s_axi_bresp[1:0]     = 'b0;
   
   //read channel
   assign s_axi_rid[S_IDW-1:0] = 'b0;
   assign s_axi_rdata[31:0]    = 'b0;
   assign s_axi_rlast          = 'b0;
   assign s_axi_rresp[1:0]     = 'b0;
   assign s_axi_rvalid         = 'b0;

   //write channel
   assign s_axi_wready         = 'b0;
   
   
endmodule // saxi_tieoff
