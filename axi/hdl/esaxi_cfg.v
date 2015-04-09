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

module esaxi_cfg (/*AUTOARG*/
   // Outputs
   s_axi_arready, s_axi_awready, s_axi_bresp, s_axi_bvalid,
   s_axi_rdata, s_axi_rresp, s_axi_rvalid, s_axi_wready, mi_clk,
   mi_en, mi_we, mi_addr, mi_din,
   // Inputs
   s_axi_aclk, s_axi_aresetn, s_axi_araddr, s_axi_arprot,
   s_axi_arvalid, s_axi_awaddr, s_axi_awprot, s_axi_awvalid,
   s_axi_bready, s_axi_rready, s_axi_wdata, s_axi_wstrb, s_axi_wvalid,
   mi_rd_data
   );
   
   parameter RFAW      = 13;      

   /*****************************/
   /*AXI 32 bit lite interface  */
   /*****************************/  
   input          s_axi_aclk;
   input 	  s_axi_aresetn;
   
   //read address channel
   input [15:0]  s_axi_araddr;
   input [2:0] 	 s_axi_arprot;
   output 	 s_axi_arready;
   input 	 s_axi_arvalid;
   
   //write address channel
   input [15:0]  s_axi_awaddr;
   input [2:0] 	 s_axi_awprot;
   output 	 s_axi_awready;
   input 	 s_axi_awvalid;
   
   //buffered read response channel
   input 	 s_axi_bready;
   output [1:0]  s_axi_bresp;
   output 	 s_axi_bvalid;
   
   //read channel
   output [31:0] s_axi_rdata;
   input 	 s_axi_rready;
   output [1:0]  s_axi_rresp;
   output 	 s_axi_rvalid;
   
   //write channel
   input [31:0]  s_axi_wdata;
   output 	 s_axi_wready;
   input [3:0] 	 s_axi_wstrb;
   input 	 s_axi_wvalid;

   /*****************************/
   /*Simple memory interface    */
   /*****************************/  
   output 	 mi_clk;
   output 	 mi_en;
   output [3:0]  mi_we;
   output [15:0] mi_addr;
   output [31:0] mi_din;   
   input [31:0]  mi_rd_data;   


`ifdef TARGET_XILINX

   /*axi_bram_ctrl_16b AUTO_TEMPLATE ( 
                                       //Outputs
                                       .bram_rst_a	(),
				       .bram_clk_a	(mi_clk),
				       .bram_en_a	(mi_en),
				       .bram_we_a	(mi_we[3:0]),
				       .bram_addr_a	(mi_addr[15:0]),
				       .bram_wrdata_a	(mi_din[31:0]),
                                       .bram_rddata_a	(mi_rd_data[31:0]),
                        );
   */
   
   axi_bram_ctrl_16b axi_bram_ctrl_16b(/*AUTOINST*/
				       // Outputs
				       .s_axi_awready	(s_axi_awready),
				       .s_axi_wready	(s_axi_wready),
				       .s_axi_bresp	(s_axi_bresp[1:0]),
				       .s_axi_bvalid	(s_axi_bvalid),
				       .s_axi_arready	(s_axi_arready),
				       .s_axi_rdata	(s_axi_rdata[31:0]),
				       .s_axi_rresp	(s_axi_rresp[1:0]),
				       .s_axi_rvalid	(s_axi_rvalid),
				       .bram_rst_a	(),		 // Templated
				       .bram_clk_a	(mi_clk),	 // Templated
				       .bram_en_a	(mi_en),	 // Templated
				       .bram_we_a	(mi_we[3:0]),	 // Templated
				       .bram_addr_a	(mi_addr[15:0]), // Templated
				       .bram_wrdata_a	(mi_din[31:0]),	 // Templated
				       // Inputs
				       .s_axi_aclk	(s_axi_aclk),
				       .s_axi_aresetn	(s_axi_aresetn),
				       .s_axi_awaddr	(s_axi_awaddr[15:0]),
				       .s_axi_awprot	(s_axi_awprot[2:0]),
				       .s_axi_awvalid	(s_axi_awvalid),
				       .s_axi_wdata	(s_axi_wdata[31:0]),
				       .s_axi_wstrb	(s_axi_wstrb[3:0]),
				       .s_axi_wvalid	(s_axi_wvalid),
				       .s_axi_bready	(s_axi_bready),
				       .s_axi_araddr	(s_axi_araddr[15:0]),
				       .s_axi_arprot	(s_axi_arprot[2:0]),
				       .s_axi_arvalid	(s_axi_arvalid),
				       .s_axi_rready	(s_axi_rready),
				       .bram_rddata_a	(mi_rd_data[31:0])); // Templated
   
				       
`endif //  `ifdef TARGET_XILINX
   
   
endmodule // esaxi_cfg

// Local Variables:
// verilog-library-directories:("." "../../stubs/hdl")
// End:
