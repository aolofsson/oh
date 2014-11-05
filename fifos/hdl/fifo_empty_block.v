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
module fifo_empty_block (/*AUTOARG*/
   // Outputs
   rd_fifo_empty, rd_addr, rd_gray_pointer,
   // Inputs
   reset, rd_clk, rd_wr_gray_pointer, rd_read
   );

   parameter AW   = 2; // Number of bits to access all the entries 

   //##########
   //# INPUTS
   //##########
   input           reset;
   input           rd_clk;
   
   input [AW:0]    rd_wr_gray_pointer;//from other clock domain
   input           rd_read;
   
   //###########
   //# OUTPUTS
   //###########
   output          rd_fifo_empty;
   output [AW-1:0] rd_addr;
   output [AW:0]   rd_gray_pointer;
   
   //#########
   //# REGS
   //#########
   reg [AW:0]      rd_gray_pointer;
   reg [AW:0]      rd_binary_pointer;
   reg             rd_fifo_empty;

   //##########
   //# WIRES
   //##########
   wire 	   rd_fifo_empty_next;
   wire [AW:0]     rd_binary_next;
   wire [AW:0]     rd_gray_next;
   
   
   //Counter States
   always @(posedge rd_clk or posedge reset)
     if(reset)
       begin
	  rd_binary_pointer[AW:0]     <= {(AW+1){1'b0}};
	  rd_gray_pointer[AW:0]       <= {(AW+1){1'b0}};
       end
     else if(rd_read)
       begin
	  rd_binary_pointer[AW:0]     <= rd_binary_next[AW:0];	  
	  rd_gray_pointer[AW:0]       <= rd_gray_next[AW:0];	  
       end

   //Read Address
   assign rd_addr[AW-1:0]        = rd_binary_pointer[AW-1:0];

   //Updating binary pointer
   assign rd_binary_next[AW:0]  = rd_binary_pointer[AW:0] + 
				  {{(AW){1'b0}},rd_read};

   //Gray Pointer Conversion (for more reliable synchronization)!
   assign rd_gray_next[AW:0] = {1'b0,rd_binary_next[AW:1]} ^ 
			       rd_binary_next[AW:0];


   //# FIFO empty indication
   assign rd_fifo_empty_next = (rd_gray_next[AW:0]==rd_wr_gray_pointer[AW:0]);

   always @ (posedge rd_clk or posedge reset)
     if(reset)
       rd_fifo_empty <= 1'b1;
     else 
       rd_fifo_empty <= rd_fifo_empty_next;
 
endmodule // fifo_empty_block

