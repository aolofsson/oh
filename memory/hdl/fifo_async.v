
module fifo_async 
   (/*AUTOARG*/
   // Outputs
   full, prog_full, dout, empty,
   // Inputs
   reset, wr_clk, rd_clk, wr_en, din, rd_en
   );
   
   parameter DW = 104;
   parameter AW = 2;


   //##########
   //# RESET/CLOCK
   //##########
   input           reset;     
   input           wr_clk;    //write clock   
   input           rd_clk;    //read clock   

   //##########
   //# FIFO WRITE
   //##########
   input           wr_en;   
   input  [DW-1:0] din;
   output          full;
   output          prog_full;

   //###########
   //# FIFO READ
   //###########
   input 	   rd_en;
   output [DW-1:0] dout;
   output          empty;


`ifdef TARGET_CLEAN
   //Wires
   wire [DW/8-1:0] wr_vec;
   wire [AW:0]	   wr_rd_gray_pointer;
   wire [AW:0] 	   rd_wr_gray_pointer;
   wire [AW:0] 	   wr_gray_pointer;
   wire [AW:0] 	   rd_gray_pointer;
   wire [AW-1:0]   rd_addr;
   wire [AW-1:0]   wr_addr;

   
   assign wr_vec[DW/8-1:0] = {(DW/8){wr_en}};
   
   memory_dp #(.DW(DW),.AW(AW)) memory_dp (
					   // Outputs
					   .rd_data	(dout[DW-1:0]),
					   // Inputs
					   .wr_clk	(wr_clk),
					   .wr_en	(wr_vec[DW/8-1:0]),
					   .wr_addr	(wr_addr[AW-1:0]),
					   .wr_data	(din[DW-1:0]),
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
						.rd_read	(rd_en));
   
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
					      .wr_write		(wr_wen));
   

   synchronizer #(.DW(AW+1)) rd2wr_sync (.out		(wr_rd_gray_pointer[AW:0]),
					 .in		(rd_gray_pointer[AW:0]),
                                         .reset		(reset),
					 .clk		(wr_clk));
   

   synchronizer #(.DW(AW+1)) wr2rd_sync (.out		(rd_wr_gray_pointer[AW:0]),
					 .in		(wr_gray_pointer[AW:0]),
                                         .reset		(reset),
					 .clk		(rd_clk));
   

`elsif TARGET_XILINX 

   //insert generate FIFO

`endif //  `ifdef TARGET_CLEAN
   
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
