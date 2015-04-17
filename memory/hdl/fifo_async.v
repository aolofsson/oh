
module fifo_async 
   (/*AUTOARG*/
   // Outputs
   rd_data, rd_fifo_empty, wr_fifo_full, wr_fifo_progfull,
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
   output          wr_fifo_progfull;

   //Wires
   wire [DW/8-1:0] wr_en;
   wire [AW:0]	   wr_rd_gray_pointer;
   wire [AW:0] 	   rd_wr_gray_pointer;
   wire [AW:0] 	   wr_gray_pointer;
   wire [AW:0] 	   rd_gray_pointer;
   wire [AW-1:0]   rd_addr;
   wire [AW-1:0]   wr_addr;

   
   assign wr_en[DW/8-1:0] = {(DW/8){wr_write}};
   
   memory_dp #(.DW(DW),.AW(AW)) memory_dp (
					   // Outputs
					   .rd_data	(rd_data[DW-1:0]),
					   // Inputs
					   .wr_clk	(wr_clk),
					   .wr_en	(wr_en[DW/8-1:0]),
					   .wr_addr	(wr_addr[AW-1:0]),
					   .wr_data	(wr_data[DW-1:0]),
					   .rd_clk	(rd_clk),
					   .rd_en	(1'b1),
					   .rd_addr	(rd_addr[AW-1:0]));

   //Read State Machine
   fifo_empty_block #(.AW(AW)) fifo_empty_block(
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
   fifo_full_block #(.AW(AW)) fifo_full_block(
					      // Outputs
					      .wr_fifo_progfull	(wr_fifo_progfull),
					      .wr_fifo_full	(wr_fifo_full),					      
					      .wr_addr		(wr_addr[AW-1:0]),
					      .wr_gray_pointer	(wr_gray_pointer[AW:0]),
					      // Inputs
					      .reset		(reset),
					      .wr_clk		(wr_clk),
					      .wr_rd_gray_pointer(wr_rd_gray_pointer[AW:0]),
					      .wr_write		(wr_write));
   

   synchronizer #(.DW(AW+1)) rd2wr_sync (.out		(wr_rd_gray_pointer[AW:0]),
					 .in		(rd_gray_pointer[AW:0]),
                                         .reset		(reset),
					 .clk		(wr_clk));
   

   synchronizer #(.DW(AW+1)) wr2rd_sync (.out		(rd_wr_gray_pointer[AW:0]),
					 .in		(wr_gray_pointer[AW:0]),
                                         .reset		(reset),
					 .clk		(rd_clk));
   


endmodule // fifo_async
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

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
