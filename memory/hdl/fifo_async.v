
module fifo_async 
   (/*AUTOARG*/
   // Outputs
   full, prog_full, dout, empty, valid,
   // Inputs
   wr_rst, rd_rst, wr_clk, rd_clk, wr_en, din, rd_en
   );
   
   parameter WIDTH   = 104;        //FIFO width
   parameter DEPTH   = 16;          //FIFO depth
     
   //##########
   //# RESET/CLOCK
   //##########
   input 	   wr_rst;    //write reset
   input 	   rd_rst;    //read reset 
   input           wr_clk;    //write clock   
   input           rd_clk;    //read clock   

   //##########
   //# FIFO WRITE
   //##########
   input             wr_en;   
   input [WIDTH-1:0] din;
   output            full;
   output            prog_full;

   //###########
   //# FIFO READ
   //###########
   input 	      rd_en;
   output [WIDTH-1:0] dout;
   output 	      empty;
   output 	      valid;
   
`ifdef TARGET_CLEAN

   parameter AW  = $clog2(DEPTH); //FIFO address width (for model)
   
   //Wires
   wire [WIDTH/8-1:0] wr_vec;
   wire [AW:0] 	      wr_rd_gray_pointer;
   wire [AW:0] 	      rd_wr_gray_pointer;
   wire [AW:0] 	      wr_gray_pointer;
   wire [AW:0] 	      rd_gray_pointer;
   wire [AW-1:0]      rd_addr;
   wire [AW-1:0]      wr_addr;
   reg 		      valid;
   
   assign wr_vec[WIDTH/8-1:0] = {(WIDTH/8){wr_en}};

   //Valid data at output
   always @ (posedge rd_clk or posedge rd_rst)
     if(rd_rst)
       valid <=1'b0;
     else
       valid <= rd_en;
   
   memory_dp #(.FW(WIDTH),.AW(AW)) memory_dp (
					   // Outputs
					   .rd_data	(dout[WIDTH-1:0]),
					   // Inputs
					   .wr_clk	(wr_clk),
					   .wr_en	(wr_vec[WIDTH/8-1:0]),
					   .wr_addr	(wr_addr[AW-1:0]),
					   .wr_data	(din[WIDTH-1:0]),
					   .rd_clk	(rd_clk),
					   .rd_en	(rd_en),
					   .rd_addr	(rd_addr[AW-1:0]));

   //Read State Machine
   fifo_empty_block #(.AW(AW)) fifo_empty_block(
						// Outputs
						.rd_fifo_empty	(empty),
						.rd_addr	(rd_addr[AW-1:0]),
						.rd_gray_pointer(rd_gray_pointer[AW:0]),
						// Inputs
						.reset		(rd_rst),
						.rd_clk		(rd_clk),
						.rd_wr_gray_pointer(rd_wr_gray_pointer[AW:0]),
						.rd_read	(rd_en));
   
   //Write State Machine
   fifo_full_block #(.AW(AW)) fifo_full_block(
					      // Outputs
					      .wr_fifo_prog_full(prog_full),
					      .wr_fifo_full	(full),					      
					      .wr_addr		(wr_addr[AW-1:0]),
					      .wr_gray_pointer	(wr_gray_pointer[AW:0]),
					      // Inputs
					      .reset		(wr_rst),
					      .wr_clk		(wr_clk),
					      .wr_rd_gray_pointer(wr_rd_gray_pointer[AW:0]),
					      .wr_write		(wr_en));
   

   synchronizer #(.DW(AW+1)) rd2wr_sync (.out		(wr_rd_gray_pointer[AW:0]),
					 .in		(rd_gray_pointer[AW:0]),
                                         .reset		(wr_rst),
					 .clk		(wr_clk));
   

   synchronizer #(.DW(AW+1)) wr2rd_sync (.out		(rd_wr_gray_pointer[AW:0]),
					 .in		(wr_gray_pointer[AW:0]),
                                         .reset		(rd_rst),
					 .clk		(rd_clk));
   
`elsif TARGET_XILINX   
   generate
      if((WIDTH==104) & (DEPTH==16))
	fifo_async_104x16 fifo_async_104x16 (
					     .wr_clk(wr_clk),
					     .wr_rst(wr_rst),
					     .rd_clk(rd_clk),
					     .rd_rst(rd_rst),
					     .din(din[WIDTH-1:0]),
					     .wr_en(wr_en),
					     .rd_en(rd_en),
					     .dout(dout[WIDTH-1:0]),
					     .full(full),
					     .empty(empty),
					     .valid(valid)
					     );	   
   endgenerate
   
      
`endif // !`elsif TARGET_XILINX
   
   
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
