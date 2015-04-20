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
   
   always @ ( posedge clk ) begin
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
      
`ifdef TARGET_XILINX 
   genvar               dn;   
   generate for(dn=0; dn<DW; dn=dn+1)
     begin : genbits
        RAM32X1D RAM32X1D_inst
          (
           .DPO(rd_data[dn] ),   // Read-only 1-bit data output
           .SPO(),            // Rw/ 1-bit data output
           .A0(wr_addr[0]),     // Rw/ address[0] input bit
           .A1(wr_addr[1]),     // Rw/ address[1] input bit
           .A2(wr_addr[2]),     // Rw/ address[2] input bit
           .A3(wr_addr[3]),     // Rw/ address[3] input bit
           .A4(wr_addr[4]),     // Rw/ address[4] input bit
           .D(wr_data[dn]),     // Write 1-bit data input
           .DPRA0(rd_addr[0]),  // Read-only address[0] input bit
           .DPRA1(rd_addr[1]),  // Read-only address[1] input bit
           .DPRA2(rd_addr[2]),  // Read-only address[2] input bit
           .DPRA3(rd_addr[3]),  // Read-only address[3] input bit
           .DPRA4(rd_addr[4]),  // Read-only address[4] input bit
           .WCLK(clk),        // Write clock input
           .WE(wr_en)           // Write enable input
           );
     end
   endgenerate
`elsif TARGET_CLEAN

   defparam mem.DW=DW;
   defparam mem.AW=AW;
   
   memory_dp mem (
			// Outputs
			.rd_data	(rd_data[DW-1:0]),
			// Inputs
			.wr_clk		(clk),
			.wr_en		({(DW/8){we_en}}),
			.wr_addr	(wr_addr[AW-1:0]),
			.wr_data	(wr_data[DW-1:0]),
			.rd_clk		(clk),
			.rd_en		(rd_en),
			.rd_addr	(rd_addr[AW-1:0]));

`endif

   
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
