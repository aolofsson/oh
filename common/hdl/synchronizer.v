/*
 #######################################################
 # Synchronizer circuit
 #######################################################
  */
module synchronizer (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   in, clk
   );

   parameter DW = 32;
   
   //Input Side   
   input  [DW-1:0] in;   
   input           clk;      
   
   //Output Side
   output [DW-1:0] out;

   //Three stages
   reg [DW-1:0] sync_reg0;
   reg [DW-1:0] out;
     
   //We use two flip-flops for metastability improvement
   always @ (posedge clk)
     begin
	sync_reg0[DW-1:0] <= in[DW-1:0];
	out[DW-1:0]       <= sync_reg0[DW-1:0];
     end
   

endmodule // synchronizer

/*
  Copyright (C) 2013 Adapteva, Inc.
  Contributed by Andreas Olofsson <support@adapteva.com>

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
