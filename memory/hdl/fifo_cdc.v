/*
 ########################################################################
 Generic Clock Domain Crossing Block
 ########################################################################
 */

module fifo_cdc (/*AUTOARG*/
   // Outputs
   wait_out, access_out, packet_out,
   // Inputs
   clk_in, clk_out, reset, access_in, packet_in, wait_in
   );

   parameter FD     = 16;         //minimum depth
   parameter AW     = $clog2(FD);   
   parameter DW     = 104;

   /********************************/
   /*Clocks/reset                  */
   /********************************/  
   input            clk_in;   
   input            clk_out;   
   input            reset;

   /********************************/
   /*Input Packet*/
   /********************************/  
   input 	    access_in;   
   input [DW-1:0]   packet_in;   
   output 	    wait_out;   

   /********************************/
   /*Register RD/WR Packet to ERX*/
   /********************************/  
   output    	    access_out;   
   output [DW-1:0]  packet_out;   
   input 	    wait_in;   

   //Local wires
   wire 	    wr_en;
   wire 	    rd_en;   
   wire 	    empty;
   wire 	    full;
   reg 		    access_out;
   
   
   assign wr_en    = access_in & ~full;
   assign rd_en    = ~empty & ~wait_in;
   assign wait_out =  full;

   //Keep access high until "acknowledge"
   always @ (posedge clk_out)
     if(~wait_in)
       access_out <=rd_en;
   
   //Read response fifo (from master)
   fifo_async  #(.DW(DW), .AW(5)) fifo(
					     .prog_full		(),
					     .full		(full),
					     // Outputs
					     .dout		(packet_out[DW-1:0]),
					     .empty		(empty),
					     .valid		(), 
					     // Inputs
					     .reset		(reset),
					     .wr_clk		(clk_in),
					     .rd_clk		(clk_out),
					     .wr_en		(wr_en),
					     .din		(packet_in[DW-1:0]),
					     .rd_en		(rd_en)
					    );
      
endmodule // fifo_cdc

/*
  Copyright (C) 2013 Adapteva, Inc.
  Contributed by Andreas Olofsson <andreas@adapteva.com>
 
   This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.This program is distributed in the hope 
  that it will be useful,but WITHOUT ANY WARRANTY; without even the implied 
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details. You should have received a copy 
  of the GNU General Public License along with this program (see the file 
  COPYING).  If not, see <http://www.gnu.org/licenses/>.
*/
