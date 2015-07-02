/* Model for xilinx async fifo*/
module fifo_async_104x32 
   (/*AUTOARG*/
   // Outputs
   full, prog_full, almost_full, dout, empty, valid,
   // Inputs
   wr_rst, rd_rst, wr_clk, rd_clk, wr_en, din, rd_en
   );
   
   parameter DW     = 104;//104 wide
   parameter DEPTH  = 16; //
   
   //##########
   //# RESET/CLOCK
   //##########
   input           wr_rst;     //asynchronous reset
   input           rd_rst;     //asynchronous reset
   input           wr_clk;    //write clock   
   input           rd_clk;    //read clock   

   //##########
   //# FIFO WRITE
   //##########
   input           wr_en;   
   input  [DW-1:0] din;
   output          full;
   output 	   prog_full;
   output 	   almost_full;
   
   //###########
   //# FIFO READ
   //###########
   input 	   rd_en;
   output [DW-1:0] dout;
   output          empty;
   output          valid;

   defparam fifo_model.DW=104;   
   defparam fifo_model.DEPTH=32;   

   fifo_async_model fifo_model (/*AUTOINST*/
				// Outputs
				.full		(full),
				.prog_full	(prog_full),
				.almost_full	(almost_full),
				.dout		(dout[DW-1:0]),
				.empty		(empty),
				.valid		(valid),
				// Inputs
				.wr_rst		(wr_rst),
				.rd_rst		(rd_rst),
				.wr_clk		(wr_clk),
				.rd_clk		(rd_clk),
				.wr_en		(wr_en),
				.din		(din[DW-1:0]),
				.rd_en		(rd_en));
      
      
endmodule // fifo_async
// Local Variables:
// verilog-library-directories:("." "../../memory/hdl")
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
