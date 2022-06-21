//########################
//AXI MASTER INTERFACE
//########################
module aximaster_stub (/*AUTOARG*/
   // Outputs
   m_axi_awid, m_axi_awaddr, m_axi_awlen, m_axi_awsize, m_axi_awburst,
   m_axi_awlock, m_axi_awcache, m_axi_awprot, m_axi_awqos,
   m_axi_awvalid, m_axi_wid, m_axi_wdata, m_axi_wstrb, m_axi_wlast,
   m_axi_wvalid, m_axi_bready, m_axi_arid, m_axi_araddr, m_axi_arlen,
   m_axi_arsize, m_axi_arburst, m_axi_arlock, m_axi_arcache,
   m_axi_arprot, m_axi_arqos, m_axi_arvalid, m_axi_rready,
   // Inputs
   m_axi_aclk, m_axi_aresetn, m_axi_awready, m_axi_wready, m_axi_bid,
   m_axi_bresp, m_axi_bvalid, m_axi_arready, m_axi_rid, m_axi_rdata,
		  m_axi_rresp, m_axi_rlast, m_axi_rvalid
   );

   parameter M_IDW  = 12;

   //reset+clock
   input  	       m_axi_aclk;    // global clock signal.
   input  	       m_axi_aresetn; // global reset singal.

   //Write address channel
   output [M_IDW-1:0]  m_axi_awid;    // write address ID
   output [31 : 0]     m_axi_awaddr;  // master interface write address   
   output [7 : 0]      m_axi_awlen;   // burst length.
   output [2 : 0]      m_axi_awsize;  // burst size.
   output [1 : 0]      m_axi_awburst; // burst type.
   output              m_axi_awlock;  // lock type   
   output [3 : 0]      m_axi_awcache; // memory type.
   output [2 : 0]      m_axi_awprot;  // protection type.
   output [3 : 0]      m_axi_awqos;   // quality of service
   output 	       m_axi_awvalid; // write address valid
   input 	       m_axi_awready; // write address ready

   //Write data channel
   output [M_IDW-1:0]  m_axi_wid;     
   output [63 : 0]     m_axi_wdata;   // master interface write data.
   output [7 : 0]      m_axi_wstrb;   // byte write strobes
   output 	       m_axi_wlast;   // indicates last transfer in a write burst.
   output 	       m_axi_wvalid;  // indicates data is ready to go
   input 	       m_axi_wready;  // indicates that the slave is ready for data

   //Write response channel
   input [M_IDW-1:0]     m_axi_bid;
   input [1 : 0]       m_axi_bresp;   // status of the write transaction.
   input 	       m_axi_bvalid;  // channel is signaling a valid write response
   output 	       m_axi_bready;  // master can accept write response.

   //Read address channel
   output [M_IDW-1:0]  m_axi_arid;    // read address ID
   output [31 : 0]     m_axi_araddr;  // initial address of a read burst
   output [7 : 0]      m_axi_arlen;   // burst length
   output [2 : 0]      m_axi_arsize;  // burst size
   output [1 : 0]      m_axi_arburst; // burst type
   output              m_axi_arlock;  //lock type   
   output [3 : 0]      m_axi_arcache; // memory type
   output [2 : 0]      m_axi_arprot;  // protection type
   output [3 : 0]      m_axi_arqos;   // 
   output 	       m_axi_arvalid; // valid read address and control information
   input 	       m_axi_arready; // slave is ready to accept an address

   //Read data channel   
   input [M_IDW-1:0]   m_axi_rid; 
   input [63 : 0]      m_axi_rdata;   // master read data
   input [1 : 0]       m_axi_rresp;   // status of the read transfer
   input 	       m_axi_rlast;   // signals last transfer in a read burst
   input 	       m_axi_rvalid;  // signaling the required read data
   output 	       m_axi_rready;  // master can accept the readback data
  
   
   //tieoffs
   assign   m_axi_awid    ='b0;
   assign   m_axi_awaddr  ='b0;
   assign   m_axi_awlen   ='b0;
   assign   m_axi_awsize  ='b0;
   assign   m_axi_awburst ='b0;
   assign   m_axi_awlock  ='b0;
   assign   m_axi_awcache ='b0;
   assign   m_axi_awprot  ='b0;
   assign   m_axi_awqos   ='b0;
   assign   m_axi_awvalid ='b0;
   assign   m_axi_wid     ='b0;
   assign   m_axi_wdata   ='b0;
   assign   m_axi_wstrb   ='b0;
   assign   m_axi_wlast   ='b0;
   assign   m_axi_wvalid  ='b0;
   assign   m_axi_bready  ='b0;
   assign   m_axi_arid    ='b0;
   assign   m_axi_araddr  ='b0;
   assign   m_axi_arlen   ='b0;
   assign   m_axi_arsize  ='b0;
   assign   m_axi_arburst ='b0;
   assign   m_axi_arlock  ='b0;
   assign   m_axi_arcache ='b0;
   assign   m_axi_arprot  ='b0;
   assign   m_axi_arqos   ='b0;
   assign   m_axi_arvalid ='b0;
   assign   m_axi_rready  ='b0;
   
endmodule // maxi_stub
