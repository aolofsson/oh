/*
  File: ewrapper_link_transmitter.v
 
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
module ewrapper_link_transmitter(/*AUTOARG*/
   // Outputs
   emesh_wr_wait_inb, emesh_rd_wait_inb, tx_in,
   // Inputs
   reset, txo_lclk, emesh_clk_inb, emesh_access_outb,
   emesh_write_outb, emesh_datamode_outb, emesh_ctrlmode_outb,
   emesh_dstaddr_outb, emesh_srcaddr_outb, emesh_data_outb,
   txi_wr_wait, txi_rd_wait, burst_en
   );

   //#########
   //# INPUTS
   //#########

   input          reset;     //reset input
   input 	  txo_lclk;  //transmitter clock

   input 	  emesh_clk_inb; // clock of the incoming emesh transaction

   //# From the Emesh
   input 	  emesh_access_outb;
   input 	  emesh_write_outb;
   input [1:0] 	  emesh_datamode_outb;
   input [3:0] 	  emesh_ctrlmode_outb;
   input [31:0]   emesh_dstaddr_outb;
   input [31:0]   emesh_srcaddr_outb;
   input [31:0]   emesh_data_outb;   

   //# From the receiver
   input 	  txi_wr_wait;  //wait indicator
   input 	  txi_rd_wait;  //wait indicator

   input 	  burst_en; // Burst enable control
   //##########
   //# OUTPUTS
   //##########

   //# To the Emesh
   output 	  emesh_wr_wait_inb;
   output 	  emesh_rd_wait_inb;

   //# To the lvds-serdes
   output [71:0]  tx_in;

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#########
   //# Regs
   //#########
   reg 		  wrfifo_rd_en;
   
   //#########
   //# Wires
   //#########
   wire [1:0] 	  txi_wait;
   wire [1:0] 	  txi_wait_sync;
   wire 	  txi_wr_wait_sync;
   wire 	  txi_rd_wait_sync;
   wire [103:0]   fifo_in;
   wire [103:0]   fifo_out;
   wire [107:0]   wrfifo_out;
   wire [107:0]   rdfifo_out;
   wire 	  wrfifo_wait;
   wire 	  rdfifo_wait;
   wire 	  wrfifo_rd_int;
   wire 	  rdfifo_rd_int;
   wire 	  wrfifo_rd;
   wire 	  rdfifo_rd;
   wire 	  wrfifo_wr;
   wire 	  rdfifo_wr;
   wire 	  rdfifo_empty;		
   wire 	  wrfifo_empty;	
   wire 	  txo_emesh_wait;	
   wire 	  txo_emesh_access;
   wire 	  txo_emesh_write;
   wire [1:0] 	  txo_emesh_datamode;
   wire [3:0] 	  txo_emesh_ctrlmode;
   wire [31:0] 	  txo_emesh_dstaddr;
   wire [31:0] 	  txo_emesh_srcaddr;
   wire [31:0] 	  txo_emesh_data;   


   //############################
   //# txo_wait synchronization
   //############################

   assign txi_wait[1:0] = {txi_rd_wait,txi_wr_wait};
   assign txi_wr_wait_sync = txi_wait_sync[0];
   assign txi_rd_wait_sync = txi_wait_sync[1];

   synchronizer #(.DW(2)) synchronizer(.out	(txi_wait_sync[1:0]),
			               .in	(txi_wait[1:0]),
				       .clk	(txo_lclk),
				       .reset	(reset));

   //#####################################
   //# lvds_link_txo instantiation
   //#####################################

   ewrapper_link_txo txo(/*AUTOINST*/
			 // Outputs
			 .txo_emesh_wait	(txo_emesh_wait),
			 .tx_in			(tx_in[71:0]),
			 // Inputs
			 .reset			(reset),
			 .txo_lclk		(txo_lclk),
			 .txo_emesh_access	(txo_emesh_access),
			 .txo_emesh_write	(txo_emesh_write),
			 .txo_emesh_datamode	(txo_emesh_datamode[1:0]),
			 .txo_emesh_ctrlmode	(txo_emesh_ctrlmode[3:0]),
			 .txo_emesh_dstaddr	(txo_emesh_dstaddr[31:0]),
			 .txo_emesh_srcaddr	(txo_emesh_srcaddr[31:0]),
			 .txo_emesh_data	(txo_emesh_data[31:0]),
			 .burst_en		(burst_en));

   //#####################################
   //# synchronization FIFOs (read/write)
   //#####################################

   //# FIFO writes
   assign wrfifo_wr = emesh_access_outb & emesh_write_outb & ~emesh_wr_wait_inb;
   assign rdfifo_wr = emesh_access_outb &~emesh_write_outb & ~emesh_rd_wait_inb;

   //# FIFO reads
   assign wrfifo_rd_int = ~(wrfifo_empty | txi_wr_wait_sync | txo_emesh_wait);
   assign rdfifo_rd_int = ~(rdfifo_empty | txi_rd_wait_sync | txo_emesh_wait);

   //# arbitration
   always @ (posedge txo_lclk or posedge reset)
     if(reset)
       wrfifo_rd_en <= 1'b0;
     else
       wrfifo_rd_en <= ~wrfifo_rd_en;
   
   assign wrfifo_rd     = wrfifo_rd_int & ( wrfifo_rd_en | ~rdfifo_rd_int);
   assign rdfifo_rd     = rdfifo_rd_int & (~wrfifo_rd_en | ~wrfifo_rd_int);

   //# FIFO input
   assign fifo_in[103:0] = {emesh_srcaddr_outb[31:0],
                            emesh_data_outb[31:0],
                            emesh_dstaddr_outb[31:0],
                            emesh_ctrlmode_outb[3:0],
                            emesh_datamode_outb[1:0],
                            emesh_write_outb,
                            emesh_access_outb};

   //# FIFO output
   assign fifo_out[103:0] = wrfifo_rd ? wrfifo_out[103:0] : rdfifo_out[103:0];

   assign txo_emesh_access        = wrfifo_rd | rdfifo_rd;
   assign txo_emesh_write         = fifo_out[1];
   assign txo_emesh_datamode[1:0] = fifo_out[3:2];
   assign txo_emesh_ctrlmode[3:0] = fifo_out[7:4];
   assign txo_emesh_dstaddr[31:0] = fifo_out[39:8];
   assign txo_emesh_data[31:0]    = fifo_out[71:40];   
   assign txo_emesh_srcaddr[31:0] = fifo_out[103:72];

   /*fifo AUTO_TEMPLATE(.rd_clk	       (txo_lclk),
                        .wr_clk	       (emesh_clk_inb),
		        .wr_data       (fifo_in[103:0]),
                        .rd_data       (wrfifo_out[103:0]), 
                        .rd_fifo_empty (wrfifo_empty),
                        .wr_fifo_full  (emesh_wr_wait_inb),
                        .wr_write      (wrfifo_wr),
                        .rd_read       (wrfifo_rd),
                       );
    */
   //# We have 4 entries of 104 bits each
   fifo #(.DW(104), .AW(2)) wrfifo_txo(/*AUTOINST*/
				       // Outputs
				       .rd_data		(wrfifo_out[103:0]), // Templated
				       .rd_fifo_empty	(wrfifo_empty),	 // Templated
				       .wr_fifo_full	(emesh_wr_wait_inb), // Templated
				       // Inputs
				       .reset		(reset),
				       .wr_clk		(emesh_clk_inb), // Templated
				       .rd_clk		(txo_lclk),	 // Templated
				       .wr_write	(wrfifo_wr),	 // Templated
				       .wr_data		(fifo_in[103:0]), // Templated
				       .rd_read		(wrfifo_rd));	 // Templated

   /*fifo AUTO_TEMPLATE(.rd_clk	       (txo_lclk),
                        .wr_clk	       (emesh_clk_inb),
		        .wr_data       (fifo_in[103:0]),
                        .rd_data       (rdfifo_out[103:0]), 
                        .rd_fifo_empty (rdfifo_empty),
                        .wr_fifo_full  (emesh_rd_wait_inb),
                        .wr_write      (rdfifo_wr),
                        .rd_read       (rdfifo_rd),
                       );
    */
   //# We have 4 entries of 104 bits each
   fifo #(.DW(104), .AW(2)) rdfifo_txo(/*AUTOINST*/
				       // Outputs
				       .rd_data		(rdfifo_out[103:0]), // Templated
				       .rd_fifo_empty	(rdfifo_empty),	 // Templated
				       .wr_fifo_full	(emesh_rd_wait_inb), // Templated
				       // Inputs
				       .reset		(reset),
				       .wr_clk		(emesh_clk_inb), // Templated
				       .rd_clk		(txo_lclk),	 // Templated
				       .wr_write	(rdfifo_wr),	 // Templated
				       .wr_data		(fifo_in[103:0]), // Templated
				       .rd_read		(rdfifo_rd));	 // Templated




endmodule // ewrapper_link_transmitter
