/*
 ########################################################################
 Generic Clock Domain Crossing Block
 ########################################################################
 */

module fifo_cdc (/*AUTOARG*/
   // Outputs
   wait_in, access_out, packet_out,
   // Inputs
   clk_in, clk_out, reset, access_in, packet_in, wait_out
   );

   parameter FD     = 16;         //minimum depth
   parameter AW     = $clog2(FD);   
   parameter PW     = 104;

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
   input [PW-1:0]   packet_in;   
   output 	    wait_in;   

   /********************************/
   /*Register RD/WR Packet to ERX*/
   /********************************/  
   output    	    access_out;   
   output [PW-1:0]  packet_out;   
   input 	    wait_out;   


   wire 	    we_en;
   wire 	    empty;
   wire 	    full;
   
   
   assign wr_en   = access_in & ~full;
   assign rd_en   = ~empty & ~wait_out;
   assign wait_in =  full;
   
   //Read response fifo (from master)
   fifo_async  #(.DW(PW), .AW(5)) txrr_fifo(
					     .prog_full		(),
					     .full		(full),
					     // Outputs
					     .dout		(packet_out[PW-1:0]),
					     .empty		(empty),
					     .valid		(access_out),
					     // Inputs
					     .reset		(reset),
					     .wr_clk		(clk_in),
					     .rd_clk		(clk_out),
					     .wr_en		(wr_en),
					     .din		(packet_in[PW-1:0]),
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
