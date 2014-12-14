/*
 Copyright (C) 2014 Adapteva, Inc.
 
 Contributed by Fred Huettig <fred@adapteva.com>
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

module esaxilite (/*AUTOARG*/
   // Outputs
   s_axicfg_arready, s_axicfg_awready, s_axicfg_bresp,
   s_axicfg_bvalid, s_axicfg_rdata, s_axicfg_rresp, s_axicfg_rvalid,
   s_axicfg_wready, mi_clk, mi_en, mi_we, mi_addr, mi_din,
   // Inputs
   s_axicfg_araddr, s_axicfg_arprot, s_axicfg_arvalid,
   s_axicfg_awaddr, s_axicfg_awprot, s_axicfg_awvalid,
   s_axicfg_bready, s_axicfg_rready, s_axicfg_wdata, s_axicfg_wstrb,
   s_axicfg_wvalid, mi_rd_data
   );
   
   parameter RFAW      = 16;      

   /*****************************/
   /*AXI 32 bit lite interface  */
   /*****************************/  
   
   //read address channel
   input [15:0]  s_axicfg_araddr;
   input [2:0] 	 s_axicfg_arprot;
   output 	 s_axicfg_arready;
   input 	 s_axicfg_arvalid;
   
   //write address channel
   input [15:0]  s_axicfg_awaddr;
   input [2:0] 	 s_axicfg_awprot;
   output 	 s_axicfg_awready;
   input 	 s_axicfg_awvalid;
   
   //buffered read response channel
   input 	 s_axicfg_bready;
   output [1:0]  s_axicfg_bresp;
   output 	 s_axicfg_bvalid;
   
   //read channel
   output [31:0] s_axicfg_rdata;
   input 	 s_axicfg_rready;
   output [1:0]  s_axicfg_rresp;
   output 	 s_axicfg_rvalid;
   
   //write channel
   input [31:0]  s_axicfg_wdata;
   output 	 s_axicfg_wready;
   input [3:0] 	 s_axicfg_wstrb;
   input 	 s_axicfg_wvalid;

   /*****************************/
   /*Simple memory interface    */
   /*****************************/  
   output             mi_clk;
   output 	      mi_en;
   output 	      mi_we;
   output [RFAW-1:0]  mi_addr;
   output [31:0]      mi_din;   
   input [31:0]       mi_rd_data;   

   //muxing done outside
   
   
endmodule // esaxilite
