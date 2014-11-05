/*
  Copyright (C) 2013 Adapteva, Inc.
  Contributed by Andreas Olofsson, Roman Trogan <support@adapteva.com>

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
module fifo 
   (/*AUTOARG*/
   // Outputs
   rd_data, rd_fifo_empty, wr_fifo_full,
   // Inputs
   reset, wr_clk, rd_clk, wr_write, wr_data, rd_read
   );
   
   parameter DW = 104;
   parameter AW = 2;

   //##########
   //# INPUTS
   //##########
   input           reset;     
   input           wr_clk;    //write clock   
   input           rd_clk;    //read clock
   
   input           wr_write;   
   input  [DW-1:0] wr_data;
   input           rd_read;

   //###########
   //# OUTPUTS
   //###########
   output [DW-1:0] rd_data;
   output          rd_fifo_empty;
   output          wr_fifo_full;

   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [AW-1:0]	rd_addr;		// From fifo_empty_block of fifo_empty_block.v
   wire [AW:0]		rd_gray_pointer;	// From fifo_empty_block of fifo_empty_block.v
   wire [AW:0]		rd_wr_gray_pointer;	// From sync2rd_wr_gray_pointer of synchronizer.v
   wire [AW-1:0]	wr_addr;		// From fifo_full_block of fifo_full_block.v
   wire [AW:0]		wr_gray_pointer;	// From fifo_full_block of fifo_full_block.v
   wire [AW:0]		wr_rd_gray_pointer;	// From sync2wr_rd_gray_pointer of synchronizer.v
   // End of automatics
   
   
   //Dual Ported Memory
   fifo_mem #(.DW(DW),
	      .AW(AW)) fifo_mem (/*AUTOINST*/
				 // Outputs
				 .rd_data		(rd_data[DW-1:0]),
				 // Inputs
				 .wr_clk		(wr_clk),
				 .wr_write		(wr_write),
				 .wr_data		(wr_data[DW-1:0]),
				 .wr_addr		(wr_addr[AW-1:0]),
				 .rd_addr		(rd_addr[AW-1:0]));
   

   //Read State Machine
   fifo_empty_block #(.AW(AW)) fifo_empty_block(/*AUTOINST*/
						// Outputs
						.rd_fifo_empty	(rd_fifo_empty),
						.rd_addr	(rd_addr[AW-1:0]),
						.rd_gray_pointer(rd_gray_pointer[AW:0]),
						// Inputs
						.reset		(reset),
						.rd_clk		(rd_clk),
						.rd_wr_gray_pointer(rd_wr_gray_pointer[AW:0]),
						.rd_read	(rd_read));
   
   
   
   //Write State Machine
   fifo_full_block #(.AW(AW)) fifo_full_block(/*AUTOINST*/
					      // Outputs
					      .wr_fifo_full	(wr_fifo_full),
					      .wr_addr		(wr_addr[AW-1:0]),
					      .wr_gray_pointer	(wr_gray_pointer[AW:0]),
					      // Inputs
					      .reset		(reset),
					      .wr_clk		(wr_clk),
					      .wr_rd_gray_pointer(wr_rd_gray_pointer[AW:0]),
					      .wr_write		(wr_write));
   


   //Syncrhonizing Gray Pointers between rd/wr domains

   /*synchronizer AUTO_TEMPLATE (.clk  (@"(substring vl-cell-name  5 7)"_clk),
			         .reset(reset),
                                 .in   (@"(substring vl-cell-name  8)"[AW:0]),
                                 .out  (@"(substring vl-cell-name  5)"[AW:0]),
        );
    */

   synchronizer #(.DW(AW+1)) sync2wr_rd_gray_pointer (/*AUTOINST*/
						      // Outputs
						      .out		(wr_rd_gray_pointer[AW:0]), // Templated
						      // Inputs
						      .in		(rd_gray_pointer[AW:0]), // Templated
						      .clk		(wr_clk),	 // Templated
						      .reset		(reset));	 // Templated
   

   synchronizer #(.DW(AW+1)) sync2rd_wr_gray_pointer(/*AUTOINST*/
						     // Outputs
						     .out		(rd_wr_gray_pointer[AW:0]), // Templated
						     // Inputs
						     .in		(wr_gray_pointer[AW:0]), // Templated
						     .clk		(rd_clk),	 // Templated
						     .reset		(reset));	 // Templated
   


endmodule // fifo
