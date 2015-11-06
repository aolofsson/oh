/*
 ########################################################################
 Generic small FIFO using distributed memory
 
 Caution:  There is no protection against overflow or underflow,
           driving logic should avoid wen on full or ren on empty.
 ########################################################################
 */

module fifo_sync
  #(
    // Address width (must be 5 => 32-deep FIFO)
    parameter AW = 5,
    // Data width
    parameter DW = 16
    )
   (
    input                clk,
    input                reset,
    input [DW-1:0]       wr_data,
    input                wr_en,
    input                rd_en,
    output wire [DW-1:0] rd_data,
    output reg           rd_empty,
    output reg           wr_full
    );
   
   reg [AW-1:0]          wr_addr;
   reg [AW-1:0]          rd_addr;
   reg [AW-1:0]          count;
   
   always @ ( posedge clk or posedge reset ) begin
      if( reset ) 
	begin	   
           wr_addr[AW-1:0] <= 'd0;
           rd_addr[AW-1:0] <= 'b0;
           count[AW-1:0] <= 'b0;
           rd_empty      <= 1'b1;
           wr_full       <= 1'b0;         
      end else 
	begin
           if( wr_en & rd_en ) 
	     begin
		wr_addr <= wr_addr + 'd1;
		rd_addr <= rd_addr + 'd1;	      
             end 
	   else if( wr_en ) 
	     begin
		wr_addr <= wr_addr + 'd1;
		count <= count + 'd1;
		rd_empty <= 1'b0;
		if( & count )
		  wr_full <= 1'b1;		
         end 
	   else if( rd_en ) 
	   begin	      
              rd_addr <= rd_addr + 'd1;
              count <= count - 'd1;
              wr_full <= 1'b0;
              if( count == 'd1 )
		rd_empty <= 1'b1;	      
           end
	end // else: !if( reset )
   end // always @ ( posedge clk )
      

   defparam mem.DW=DW;
   defparam mem.AW=AW;   
   memory_dp mem (
			// Outputs
			.rd_data	(rd_data[DW-1:0]),
			// Inputs
			.wr_clk		(clk),
			.wr_en		({(DW/8){wr_en}}),
			.wr_addr	(wr_addr[AW-1:0]),
			.wr_data	(wr_data[DW-1:0]),
			.rd_clk		(clk),
			.rd_en		(rd_en),
			.rd_addr	(rd_addr[AW-1:0]));

   
endmodule // fifo_sync

// Local Variables:
// verilog-library-directories:(".")
// End:

/*
 Copyright (C) 2014 Adapteva, Inc.
 Contributed by Fred Huettig <fred@adapteva.com>
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
