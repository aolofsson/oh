module fifo_full_block (/*AUTOARG*/
   // Outputs
   wr_fifo_full, wr_fifo_progfull, wr_addr, wr_gray_pointer,
   // Inputs
   reset, wr_clk, wr_rd_gray_pointer, wr_write
   );

   parameter AW   = 2; // Number of bits to access all the entries 

   //##########
   //# INPUTS
   //##########
   input           reset;
   input           wr_clk;

   input [AW:0]    wr_rd_gray_pointer;//synced from read domain
   input           wr_write;
   
   //###########
   //# OUTPUTS
   //###########
   output           wr_fifo_full;
   output           wr_fifo_progfull;//TODO: hack!, fix this properly
                                     //also make, programmable
   
   output [AW-1:0]  wr_addr;
   output [AW:0]    wr_gray_pointer;//for read domain

   //#########
   //# REGS
   //#########
   reg [AW:0]      wr_gray_pointer;
   reg [AW:0]      wr_binary_pointer;
   reg             wr_fifo_full;

   //##########
   //# WIRES
   //##########
   wire            wr_fifo_full_next;
   wire [AW:0]     wr_gray_next;
   wire [AW:0]     wr_binary_next;
   
   wire 	   wr_fifo_progfull_next;
   reg 		   wr_fifo_progfull;
   
   //Counter States
   always @(posedge wr_clk or posedge reset)
     if(reset)
       begin
	  wr_binary_pointer[AW:0]     <= {(AW+1){1'b0}};
	  wr_gray_pointer[AW:0]       <= {(AW+1){1'b0}};
       end
     else if(wr_write)
       begin
	  wr_binary_pointer[AW:0]     <= wr_binary_next[AW:0];	  
	  wr_gray_pointer[AW:0]       <= wr_gray_next[AW:0];	  
       end

   //Write Address
   assign wr_addr[AW-1:0]       = wr_binary_pointer[AW-1:0];

   //Updating binary pointer
   assign wr_binary_next[AW:0]  = wr_binary_pointer[AW:0] + 
				  {{(AW){1'b0}},wr_write};

   //Gray Pointer Conversion (for more reliable synchronization)!
   assign wr_gray_next[AW:0]    = {1'b0,wr_binary_next[AW:1]} ^ 
				  wr_binary_next[AW:0];

   //FIFO full indication
   assign wr_fifo_full_next =
			 (wr_gray_next[AW-2:0] == wr_rd_gray_pointer[AW-2:0]) &
			 (wr_gray_next[AW]     ^  wr_rd_gray_pointer[AW])     &
			 (wr_gray_next[AW-1]   ^  wr_rd_gray_pointer[AW-1]);

 

   //FIFO almost full
   assign wr_fifo_progfull_next =
			 (wr_gray_next[AW-3:0] == wr_rd_gray_pointer[AW-3:0]) &
			 (wr_gray_next[AW]     ^  wr_rd_gray_pointer[AW])     &
			 (wr_gray_next[AW-1]   ^  wr_rd_gray_pointer[AW-1])   &
			 (wr_gray_next[AW-2]   ^  wr_rd_gray_pointer[AW-2]);

   always @ (posedge wr_clk or posedge reset)
     if(reset)
       wr_fifo_full <= 1'b0;
     else
       wr_fifo_full <=wr_fifo_full_next;


   always @ (posedge wr_clk or posedge reset)
     if(reset)
       wr_fifo_progfull <= 1'b0;
     else
       wr_fifo_progfull <=wr_fifo_progfull_next;

endmodule // fifo_full_block

   
		 
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
