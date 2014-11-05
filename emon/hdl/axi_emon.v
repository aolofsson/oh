/*
  Copyright (C) 2013 Adapteva, Inc.
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

/*########################################################################
 AXI WRAPPER FOR EMON BLOCK
 ########################################################################
 */
module axi_mon (/*AUTOARG*/
   // Outputs
   s_axi_awready, s_axi_wready, s_axi_bresp, s_axi_bvalid,
   s_axi_arready, s_axi_rdata, s_axi_rresp, s_axi_rvalid,
   emon_zero_flag,
   // Inputs
   s_axi_aclk, s_axi_aresetn, s_axi_awaddr, s_axi_awprot,
   s_axi_awvalid, s_axi_wdata, s_axi_wstrb, s_axi_wvalid,
   s_axi_bready, s_axi_araddr, s_axi_arprot, s_axi_arvalid,
   s_axi_rready, erx_rdfifo_access, erx_rdfifo_wait,
   erx_wrfifo_access, erx_wrfifo_wait, erx_wbfifo_access,
   erx_wbfifo_wait, etx_rdfifo_access, etx_rdfifo_wait,
   etx_wrfifo_access, etx_wrfifo_wait, etx_wbfifo_access,
   etx_wbfifo_wait
   );
   //Register file parameters

/*
 #####################################################################
 COMPILE TIME PARAMETERS 
 ######################################################################
 */
   parameter DW   = 32;   //elink monitor register width
   parameter AW   = 32;   //mmu table address width
   parameter SW   = DW/8; //mmu table address width
   parameter MAW  = 6;    //register file address width
   parameter MDW  = 32;   //


   /*****************************/
   /*AXI SLAVE INTERFACE (LITE) */
   /*****************************/

   //Global signals
   input 	     s_axi_aclk;      //clock source for axi slave interfaces
   input 	     s_axi_aresetn;   //asynchronous reset signal, active low 
   
   //Write address channel
   input [AW-1:0]    s_axi_awaddr;    //write address
   input [2:0] 	     s_axi_awprot;    //write protection type
   input 	     s_axi_awvalid;   //write address valid
   output 	     s_axi_awready;   //write address ready
   
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
   input [2:0] 	     s_axi_arprot;    //read protection type
   input 	     s_axi_arvalid;   //read address valid
   output 	     s_axi_arready;   //read address ready
   
   //Read data channel
   output [DW-1:0]   s_axi_rdata;     //read data
   output [1:0]      s_axi_rresp;     //read response
   output 	     s_axi_rvalid;    //read valid
   input 	     s_axi_rready;    //read ready
   
   
   /*****************************/
   /*EMON SIGNALS               */
   /*****************************/
   input 	     erx_rdfifo_access;
   input 	     erx_rdfifo_wait;
   input 	     erx_wrfifo_access;
   input 	     erx_wrfifo_wait;
   input 	     erx_wbfifo_access;
   input 	     erx_wbfifo_wait;   
   input 	     etx_rdfifo_access;
   input 	     etx_rdfifo_wait;
   input 	     etx_wrfifo_access;
   input 	     etx_wrfifo_wait;
   input 	     etx_wbfifo_access;
   input 	     etx_wbfifo_wait;
   output [5:0]      emon_zero_flag;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			mi_access;		// From axi_memif of axi_memif.v
   wire [MAW-1:0]	mi_addr;		// From axi_memif of axi_memif.v
   wire [MDW-1:0]	mi_data_in;		// From axi_memif of axi_memif.v
   wire [DW-1:0]	mi_data_out;		// From emon of emon.v
   wire			mi_write;		// From axi_memif of axi_memif.v
   // End of automatics
   
   /*****************************/
   /*AXI INTERFACE              */
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
		       .s_axi_rvalid	(s_axi_rvalid),
		       .mi_addr		(mi_addr[MAW-1:0]),
		       .mi_access	(mi_access),
		       .mi_write	(mi_write),
		       .mi_data_in	(mi_data_in[MDW-1:0]),
		       // Inputs
		       .s_axi_aclk	(s_axi_aclk),
		       .s_axi_aresetn	(s_axi_aresetn),
		       .s_axi_awaddr	(s_axi_awaddr[AW-1:0]),
		       .s_axi_awprot	(s_axi_awprot[2:0]),
		       .s_axi_awvalid	(s_axi_awvalid),
		       .s_axi_wdata	(s_axi_wdata[DW-1:0]),
		       .s_axi_wstrb	(s_axi_wstrb[SW-1:0]),
		       .s_axi_wvalid	(s_axi_wvalid),
		       .s_axi_bready	(s_axi_bready),
		       .s_axi_araddr	(s_axi_araddr[AW-1:0]),
		       .s_axi_arprot	(s_axi_arprot[2:0]),
		       .s_axi_arvalid	(s_axi_arvalid),
		       .s_axi_rready	(s_axi_rready),
		       .mi_data_out	(mi_data_out[MDW-1:0]));
   
   /*****************************/
   /*EMON                       */
   /*****************************/
   emon emon(
	     /*AUTOINST*/
	     // Outputs
	     .mi_data_out		(mi_data_out[DW-1:0]),
	     .emon_zero_flag		(emon_zero_flag[5:0]),
	     // Inputs
	     .clk			(clk),
	     .reset			(reset),
	     .mi_access			(mi_access),
	     .mi_write			(mi_write),
	     .mi_addr			(mi_addr[5:0]),
	     .mi_data_in		(mi_data_in[DW-1:0]),
	     .erx_rdfifo_access		(erx_rdfifo_access),
	     .erx_rdfifo_wait		(erx_rdfifo_wait),
	     .erx_wrfifo_access		(erx_wrfifo_access),
	     .erx_wrfifo_wait		(erx_wrfifo_wait),
	     .erx_wbfifo_access		(erx_wbfifo_access),
	     .erx_wbfifo_wait		(erx_wbfifo_wait),
	     .etx_rdfifo_access		(etx_rdfifo_access),
	     .etx_rdfifo_wait		(etx_rdfifo_wait),
	     .etx_wrfifo_access		(etx_wrfifo_access),
	     .etx_wrfifo_wait		(etx_wrfifo_wait),
	     .etx_wbfifo_access		(etx_wbfifo_access),
	     .etx_wbfifo_wait		(etx_wbfifo_wait));

   
endmodule // axi_mon
// Local Variables:
// verilog-library-directories:("." "../axi")
// End:


