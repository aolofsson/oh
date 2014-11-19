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

module axi_slave_memif (/*AUTOARG*/
   // Outputs
   s_axi_awready, s_axi_wready, s_axi_bresp, s_axi_bvalid,
   s_axi_arready, s_axi_rdata, s_axi_rresp, s_axi_rvalid, mi_addr,
   mi_access, mi_write, mi_data_in,
   // Inputs
   s_axi_aclk, s_axi_aresetn, s_axi_awaddr, s_axi_awprot,
   s_axi_awvalid, s_axi_wdata, s_axi_wstrb, s_axi_wvalid,
   s_axi_bready, s_axi_araddr, s_axi_arprot, s_axi_arvalid,
   s_axi_rready, mi_readback_data
   );

   parameter AW  = 32;  //axi addr width  
   parameter DW  = 32;  //axi data width
   parameter SW  = DW/8;//==ADW/8
   
   /*****************************/
   /*AXI SLAVE INTERFACE        */
   /*****************************/

   //Global signals
   input 	     s_axi_aclk;      //clock source for axi slave interfaces
   input 	     s_axi_aresetn;   //synchronous reset signal, active low 
   
   //Write address channel
   input [AW-1:0]   s_axi_awaddr;    //write address
   input [2:0] 	    s_axi_awprot;    //protection type
   input 	    s_axi_awvalid;   //write address valid
   output 	    s_axi_awready;   //write address ready
   
   //Write data channel
   input [DW-1:0]    s_axi_wdata;     //write data
   input [SW-1:0]    s_axi_wstrb;     //write strobes
   input 	     s_axi_wvalid;    //write valid
   output            s_axi_wready;    //write channel ready
   
   //Buffered write response channel
   input 	     s_axi_bready;    //write ready
   output [1:0]      s_axi_bresp;     //write response
   output 	     s_axi_bvalid;    //write response valid
   
   //Read address channel
   input [AW-1:0]    s_axi_araddr;    //read address
   input [2:0] 	     s_axi_arprot;    //protection type
   input 	     s_axi_arvalid;   //read address valid
   output 	     s_axi_arready;   //read address ready
   
   //Read data channel
   output [DW-1:0]   s_axi_rdata;     //read data
   output [1:0]      s_axi_rresp;     //read response
   output 	     s_axi_rvalid;    //read valid
   input 	     s_axi_rready;    //read ready
     
   /*****************************/
   /*MEORY INTERFACE            */
   /*****************************/
   output [19:0]     mi_addr;
   output 	     mi_access;
   output 	     mi_write;
   output [DW-1:0]   mi_data_in;
   input  [DW-1:0]   mi_readback_data;
   

   //Dummy interface, need to instantiate IP!!!
   //this will lock up AXI bus
`ifdef CFG_XILINX
   
`endif
   
endmodule // axi_memif

