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

/*###########################################################################
 # Function: AXI slave wrapper for mailbox FIFO
 #
 ############################################################################
 */

module axi_embox (/*AUTOARG*/
   // Outputs
   s_axi_awready, s_axi_wready, s_axi_bresp, s_axi_bvalid,
   s_axi_arready, s_axi_rdata, s_axi_rresp, s_axi_rlast, s_axi_rvalid,
   embox_full, embox_empty,
   // Inputs
   s_axi_aclk, s_axi_aresetn, s_axi_awaddr, s_axi_awlen, s_axi_awsize,
   s_axi_awburst, s_axi_awlock, s_axi_awcache, s_axi_awprot,
   s_axi_awvalid, s_axi_wdata, s_axi_wstrb, s_axi_wlast, s_axi_wvalid,
   s_axi_bready, s_axi_araddr, s_axi_arlen, s_axi_arsize,
   s_axi_arburst, s_axi_arlock, s_axi_arcache, s_axi_arprot,
   s_axi_arvalid, s_axi_rready
   );
   parameter AW  = 32; //axi addr width  
   parameter DW  = 32; //axi data width
   parameter SW  = 4;  //==ADW/8
   parameter MAW = 6;  //memory side address width
   
   /*****************************/
   /*AXI SLAVE INTERFACE        */
   /*****************************/

   //Global signals
   input 	     s_axi_aclk;      //clock source for axi slave interfaces
   input 	     s_axi_aresetn;   //asynchronous reset signal, active low 
   
   //Write address channel
   input [AW-1:0]   s_axi_awaddr;    //write address
   input [3:0] 	     s_axi_awlen;     //burst length (number of data transfers)
   input [2:0] 	     s_axi_awsize;    //burst size (size of each transfer)
   input [1:0] 	     s_axi_awburst;   //burst type
   input [1:0] 	     s_axi_awlock;    //lock type (atomic characteristics)
   input [3:0] 	     s_axi_awcache;   //memory type
   input [2:0] 	     s_axi_awprot;    //protection type
   input 	     s_axi_awvalid;   //write address valid
   output 	     s_axi_awready;   //write address ready
   
   //Write data channel
   input [DW-1:0]    s_axi_wdata;     //write data
   input [SW-1:0]    s_axi_wstrb;     //write strobes
   input 	     s_axi_wlast;     //indicats last write transfer in burst
   input 	     s_axi_wvalid;    //write valid
   output            s_axi_wready;    //write channel ready
   
   //Buffered write response channel
   input 	     s_axi_bready;    //write ready
   output [1:0]      s_axi_bresp;     //write response
   output 	     s_axi_bvalid;    //write response valid
   
   //Read address channel
   input [AW-1:0]    s_axi_araddr;    //read address
   input [3:0] 	     s_axi_arlen;     //burst lenght (number of data transfers)
   input [2:0] 	     s_axi_arsize;    //burst size (size of each transfer)
   input [1:0] 	     s_axi_arburst;   //burst type
   input [1:0] 	     s_axi_arlock;    //lock type (atomic characteristics)
   input [3:0] 	     s_axi_arcache;   //memory type
   input [2:0] 	     s_axi_arprot;    //protection type
   input 	     s_axi_arvalid;   //read address valid
   output 	     s_axi_arready;   //read address ready
   
   //Read data channel
   output [DW-1:0]   s_axi_rdata;     //read data
   output [1:0]      s_axi_rresp;     //read response
   output 	     s_axi_rlast;     //indicates last read transfer in burst
   output 	     s_axi_rvalid;    //read valid
   input 	     s_axi_rready;    //read ready

   
   /*****************************/
   /*MAILBOX OUTPUTS            */
   /*****************************/
   output 	      embox_full;
   output 	      embox_empty;   


   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			mi_access;		// From axi_memif of axi_memif.v
   wire [MAW-1:0]	mi_addr;		// From axi_memif of axi_memif.v
   wire [DW-1:0]	mi_data_in;		// From axi_memif of axi_memif.v
   wire			mi_write;		// From axi_memif of axi_memif.v
   // End of automatics
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [DW-1:0]	mi_data_out;		// From embox of embox.v
  
   /*****************************/
   /*AXI INSTANCE               */
   /*****************************/

   axi_memif axi_memif(/*AUTOINST*/
		       // Outputs
		       .s_axi_awready	(s_axi_awready),
		       .s_axi_wready	(s_axi_wready),
		       .s_axi_bresp	(s_axi_bresp[1:0]),
		       .s_axi_bvalid	(s_axi_bvalid),
		       .s_axi_arready	(s_axi_arready),
		       .s_axi_rdata	(s_axi_rdata[DW-1:0]),
		       .s_axi_rresp	(s_axi_rresp[1:0]),
		       .s_axi_rlast	(s_axi_rlast),
		       .s_axi_rvalid	(s_axi_rvalid),
		       .mi_addr		(mi_addr[MAW-1:0]),
		       .mi_access	(mi_access),
		       .mi_write	(mi_write),
		       .mi_data_in	(mi_data_in[DW-1:0]),
		       // Inputs
		       .s_axi_aclk	(s_axi_aclk),
		       .s_axi_aresetn	(s_axi_aresetn),
		       .s_axi_awaddr	(s_axi_awaddr[AW-1:0]),
		       .s_axi_awlen	(s_axi_awlen[3:0]),
		       .s_axi_awsize	(s_axi_awsize[2:0]),
		       .s_axi_awburst	(s_axi_awburst[1:0]),
		       .s_axi_awlock	(s_axi_awlock[1:0]),
		       .s_axi_awcache	(s_axi_awcache[3:0]),
		       .s_axi_awprot	(s_axi_awprot[2:0]),
		       .s_axi_awvalid	(s_axi_awvalid),
		       .s_axi_wdata	(s_axi_wdata[DW-1:0]),
		       .s_axi_wstrb	(s_axi_wstrb[SW-1:0]),
		       .s_axi_wlast	(s_axi_wlast),
		       .s_axi_wvalid	(s_axi_wvalid),
		       .s_axi_bready	(s_axi_bready),
		       .s_axi_araddr	(s_axi_araddr[AW-1:0]),
		       .s_axi_arlen	(s_axi_arlen[3:0]),
		       .s_axi_arsize	(s_axi_arsize[2:0]),
		       .s_axi_arburst	(s_axi_arburst[1:0]),
		       .s_axi_arlock	(s_axi_arlock[1:0]),
		       .s_axi_arcache	(s_axi_arcache[3:0]),
		       .s_axi_arprot	(s_axi_arprot[2:0]),
		       .s_axi_arvalid	(s_axi_arvalid),
		       .s_axi_rready	(s_axi_rready),
		       .mi_data_out	(mi_data_out[DW-1:0]));
   
   
   /*****************************/
   /*EMBOX INSTANCE             */
   /*****************************/
   embox embox (.mi_addr		(mi_addr[5:0]),
		/*AUTOINST*/
		// Outputs
		.mi_data_out		(mi_data_out[DW-1:0]),
		.embox_full		(embox_full),
		.embox_empty		(embox_empty),
		// Inputs
		.reset			(reset),
		.clk			(clk),
		.mi_access		(mi_access),
		.mi_write		(mi_write),
		.mi_data_in		(mi_data_in[DW-1:0]));
   
   
endmodule // emmu
// Local Variables:
// verilog-library-directories:("." "../axi")
// End:


   