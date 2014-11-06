/*
  File: ewrapper_link_receiver.v
 
  This file is part of the Parallella FPGA Reference Design.

  Copyright (C) 2013 Adapteva, Inc.
  Contributed by Roman Trogan <support@adapteva.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program (see the file COPYING).  If not, see
  <http://www.gnu.org/licenses/>.
*/
module ewrapper_link_receiver (/*AUTOARG*/
   // Outputs
   rxo_wr_wait, rxo_rd_wait, emesh_clk_inb, emesh_access_inb,
   emesh_write_inb, emesh_datamode_inb, emesh_ctrlmode_inb,
   emesh_dstaddr_inb, emesh_srcaddr_inb, emesh_data_inb,
   // Inputs
   reset, rxi_data, rxi_lclk, rxi_frame, emesh_wr_wait_outb,
   emesh_rd_wait_outb
   );

   //#########
   //# INPUTS
   //#########

   input          reset;       //reset input

   //# From the lvds-serdes
   input [63:0]   rxi_data;  //Eight Parallel Byte words
   input 	  rxi_lclk;  //receive clock (synchronized to the data)
   input [7:0] 	  rxi_frame; //Parallel frame signals representing 
                             // 4 transmission clock cycles
   //# From the emesh interface
   input 	  emesh_wr_wait_outb; 
   input 	  emesh_rd_wait_outb; 

   //##########
   //# OUTPUTS
   //##########

   //# To the transmitter
   output 	  rxo_wr_wait;  //wait indicator
   output 	  rxo_rd_wait;  //wait indicator

   //# To the emesh interface
   output 	  emesh_clk_inb;
   output 	  emesh_access_inb;
   output 	  emesh_write_inb;
   output [1:0]   emesh_datamode_inb;
   output [3:0]   emesh_ctrlmode_inb;
   output [31:0]  emesh_dstaddr_inb;
   output [31:0]  emesh_srcaddr_inb;
   output [31:0]  emesh_data_inb;  

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#########
   //# Wires
   //#########
   wire 	  emesh_wr_access_inb;
   wire 	  emesh_wr_write_inb;
   wire [1:0] 	  emesh_wr_datamode_inb;
   wire [3:0] 	  emesh_wr_ctrlmode_inb;
   wire [31:0] 	  emesh_wr_dstaddr_inb;
   wire [31:0] 	  emesh_wr_srcaddr_inb;
   wire [31:0] 	  emesh_wr_data_inb;  

   wire 	  emesh_rd_access_inb;
   wire 	  emesh_rd_write_inb;
   wire [1:0] 	  emesh_rd_datamode_inb;
   wire [3:0] 	  emesh_rd_ctrlmode_inb;
   wire [31:0] 	  emesh_rd_dstaddr_inb;
   wire [31:0] 	  emesh_rd_srcaddr_inb;
   wire [31:0] 	  emesh_rd_data_inb;  

   wire 	  select_write_tran;
   wire 	  wr_wait;
   wire 	  rd_wait;
   wire  	  emesh_access_tmp;

   //###############
   //# Emesh clock
   //###############

   assign emesh_clk_inb = rxi_lclk;

   //######################################
   //# Write-Read Transactions Arbitration
   //# Write has a higher priority ALWAYS
   //######################################

   assign select_write_tran = emesh_wr_access_inb & ~emesh_wr_wait_outb;

   assign emesh_access_inb = emesh_access_tmp & ~emesh_wr_wait_outb;

   assign wr_wait = emesh_wr_wait_outb;
   assign rd_wait = emesh_rd_access_inb & select_write_tran | 
		    (emesh_wr_wait_outb | emesh_rd_wait_outb);

   assign emesh_srcaddr_inb[31:0] = 
			      select_write_tran ? emesh_wr_srcaddr_inb[31:0] :
				                  emesh_rd_srcaddr_inb[31:0];

   assign emesh_dstaddr_inb[31:0] = 
			      select_write_tran ? emesh_wr_dstaddr_inb[31:0] :
				                  emesh_rd_dstaddr_inb[31:0];

   assign emesh_datamode_inb[1:0] = 
			      select_write_tran ? emesh_wr_datamode_inb[1:0] :
				                  emesh_rd_datamode_inb[1:0];

   assign emesh_ctrlmode_inb[3:0] = 
			      select_write_tran ? emesh_wr_ctrlmode_inb[3:0] :
				                  emesh_rd_ctrlmode_inb[3:0];

   assign emesh_data_inb[31:0] = select_write_tran ? emesh_wr_data_inb[31:0] :
				                     emesh_rd_data_inb[31:0];

   assign emesh_access_tmp = select_write_tran ? emesh_wr_access_inb :
			                         emesh_rd_access_inb;

   assign emesh_write_inb = select_write_tran ? emesh_wr_write_inb :
			                        emesh_rd_write_inb;

   //############################################
   //# Write Transactions Receiver Instantiation
   //############################################

   /*ewrapper_link_rxi AUTO_TEMPLATE(
                                 .rxi_rd	  (1'b0),
                                 .emesh_wait_outb (wr_wait),
                                 .rxo_wait	  (rxo_wr_wait),
                                 .emesh_\(.*\)    (emesh_wr_\1[]),
                                );
    */

   ewrapper_link_rxi wr_rxi(/*AUTOINST*/
			    // Outputs
			    .rxo_wait		(rxo_wr_wait),	 // Templated
			    .emesh_access_inb	(emesh_wr_access_inb), // Templated
			    .emesh_write_inb	(emesh_wr_write_inb), // Templated
			    .emesh_datamode_inb	(emesh_wr_datamode_inb[1:0]), // Templated
			    .emesh_ctrlmode_inb	(emesh_wr_ctrlmode_inb[3:0]), // Templated
			    .emesh_dstaddr_inb	(emesh_wr_dstaddr_inb[31:0]), // Templated
			    .emesh_srcaddr_inb	(emesh_wr_srcaddr_inb[31:0]), // Templated
			    .emesh_data_inb	(emesh_wr_data_inb[31:0]), // Templated
			    // Inputs
			    .reset		(reset),
			    .rxi_data		(rxi_data[63:0]),
			    .rxi_lclk		(rxi_lclk),
			    .rxi_frame		(rxi_frame[7:0]),
			    .emesh_wait_outb	(wr_wait),	 // Templated
			    .rxi_rd		(1'b0));		 // Templated

   //############################################
   //# Read Transactions Receiver Instantiation
   //############################################

   /*ewrapper_link_rxi AUTO_TEMPLATE(
                                 .rxi_rd	  (1'b1),
                                 .emesh_wait_outb (rd_wait),
                                 .rxo_wait	  (rxo_rd_wait),
                                 .emesh_\(.*\)    (emesh_rd_\1[]),
                                );
    */

   ewrapper_link_rxi rd_rxi(/*AUTOINST*/
			    // Outputs
			    .rxo_wait		(rxo_rd_wait),	 // Templated
			    .emesh_access_inb	(emesh_rd_access_inb), // Templated
			    .emesh_write_inb	(emesh_rd_write_inb), // Templated
			    .emesh_datamode_inb	(emesh_rd_datamode_inb[1:0]), // Templated
			    .emesh_ctrlmode_inb	(emesh_rd_ctrlmode_inb[3:0]), // Templated
			    .emesh_dstaddr_inb	(emesh_rd_dstaddr_inb[31:0]), // Templated
			    .emesh_srcaddr_inb	(emesh_rd_srcaddr_inb[31:0]), // Templated
			    .emesh_data_inb	(emesh_rd_data_inb[31:0]), // Templated
			    // Inputs
			    .reset		(reset),
			    .rxi_data		(rxi_data[63:0]),
			    .rxi_lclk		(rxi_lclk),
			    .rxi_frame		(rxi_frame[7:0]),
			    .emesh_wait_outb	(rd_wait),	 // Templated
			    .rxi_rd		(1'b1));		 // Templated


endmodule // ewrapper_link_receiver
