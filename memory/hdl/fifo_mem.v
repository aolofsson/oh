/*
  Copyright (C) 2013 Adapteva, Inc.
  Contributed by Roman Trogan <support@adapteva.com>

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
module fifo_mem (/*AUTOARG*/
   // Outputs
   rd_data,
   // Inputs
   wr_clk, wr_write, wr_data, wr_addr, rd_addr
   );

   parameter  DW = 104;
   parameter  AW = 2;
   localparam MD = 1<<AW;

   //#########
   //# INPUTS
   //#########
   input           wr_clk;      //write clock   
   input           wr_write;   
   input [DW-1:0]  wr_data;
   input [AW-1:0]  wr_addr;
   input [AW-1:0]  rd_addr;

   //##########
   //# OUTPUTS
   //##########
    output [DW-1:0] rd_data;

   //########
   //# REGS
   //########
   reg [DW-1:0]     mem[MD-1:0];
   
   //Write
   always @(posedge wr_clk)
     if(wr_write)
       mem[wr_addr[AW-1:0]] <= wr_data[DW-1:0];
   
   //Read
   assign rd_data[DW-1:0] = mem[rd_addr[AW-1:0]];

endmodule // fifo_mem

				
   