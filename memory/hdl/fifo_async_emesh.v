
/*
 Emesh interface wrapper for asynchronous fifo
 
 */

module fifo_async_emesh (/*AUTOARG*/
   // Outputs
   emesh_access_out, emesh_write_out, emesh_datamode_out,
   emesh_ctrlmode_out, emesh_dstaddr_out, emesh_data_out,
   emesh_srcaddr_out, fifo_full, fifo_progfull,
   // Inputs
   rd_clk, wr_clk, reset, emesh_access_in, emesh_write_in,
   emesh_datamode_in, emesh_ctrlmode_in, emesh_dstaddr_in,
   emesh_data_in, emesh_srcaddr_in, fifo_read
   );

   //Clocks
   input         rd_clk;
   input         wr_clk;
   input 	 reset;
   
   //input-data
   input 	 emesh_access_in;
   input 	 emesh_write_in;
   input [1:0] 	 emesh_datamode_in;
   input [3:0] 	 emesh_ctrlmode_in;
   input [31:0]  emesh_dstaddr_in;
   input [31:0]  emesh_data_in;
   input [31:0]  emesh_srcaddr_in;

   //output-data
   output        emesh_access_out;
   output        emesh_write_out;
   output [1:0]  emesh_datamode_out;
   output [3:0]  emesh_ctrlmode_out;
   output [31:0] emesh_dstaddr_out;
   output [31:0] emesh_data_out;
   output [31:0] emesh_srcaddr_out;

   //FIFO controls
   input         fifo_read;
   
   output 	 fifo_full;
   output 	 fifo_progfull;
   
   //wires
   wire [103:0]  fifo_din;
   wire [103:0]  fifo_dout;
   wire 	 fifo_empty;
   
   //Inputs to FIFO
   assign fifo_din[103:0]={emesh_srcaddr_in[31:0],
			   emesh_data_in[31:0],
			   emesh_dstaddr_in[31:0],
			   emesh_ctrlmode_in[3:0],
			   emesh_datamode_in[1:0],
			   emesh_write_in,
			   1'b0
			   };
   
   //Outputs
   assign emesh_access_out         = ~fifo_empty;
   assign emesh_write_out          =  fifo_dout[1];
   assign emesh_datamode_out[1:0]  =  fifo_dout[3:2];
   assign emesh_ctrlmode_out[3:0]  =  fifo_dout[7:4];
   assign emesh_dstaddr_out[31:0]  =  fifo_dout[39:8];
   assign emesh_data_out[31:0]     =  fifo_dout[71:40];
   assign emesh_srcaddr_out[31:0]  =  fifo_dout[103:72];

`ifdef TARGET_XILINX   
   fifo_async_104x32 fifo_async_104x32 (.dout		(fifo_dout[103:0]),
					.full		(fifo_full),
					.empty		(fifo_empty),
					.prog_full	(fifo_progfull),
					//inputs
					.rst		(reset),
					.wr_clk		(wr_clk),
					.rd_clk		(rd_clk),
					.din		(fifo_din[103:0]),
					.wr_en		(emesh_access_in),
					.rd_en		(fifo_read)
					);
   
`elsif TARGET_CLEAN

   wire 	 tmp_progfull;    
   assign fifo_progfull = tmp_progfull | fifo_full;//HACK, need to fix this
   

  fifo_async #(.DW(104), .AW(5))  fifo_async (
					.rd_data	  (fifo_dout[103:0]),
					.wr_fifo_progfull (tmp_progfull),
					.wr_fifo_full	  (fifo_full),
					.rd_fifo_empty	  (fifo_empty),
					//inputs
					.reset		(reset),
					.wr_clk		(wr_clk),
					.rd_clk		(rd_clk),
					.wr_data	(fifo_din[103:0]),
					.wr_write	(emesh_access_in),
					.rd_read	(fifo_read)
					);
`elsif TARGET_ALTERA
  //SOMETHING
`endif

   
endmodule // fifo_sync
// Local Variables:
// verilog-library-directories:("." "../../stubs/hdl")
// End:

/*
 Copyright (C) 2014 Adapteva, Inc.
 Contributed by Andreas Olofsson <andreas@adapteva.com>
 
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
