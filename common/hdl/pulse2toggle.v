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
module pulse2toggle(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, in, reset
   );

   
   //clocks
   input  clk; 
   
   input  in;   
   output out;

   //reset
   input  reset;  


   reg 	  out;
   wire   toggle;
   
   //if input goes high, toggle output
   //note1: input can only be high for one clock cycle
   //note2: be careful with clock gating

   assign toggle = in ? ~out :
		         out;
   

   always @ (posedge clk or posedge reset)
     if(reset)
       out <= 1'b0;
     else
       out <= toggle;
   
endmodule // pulse2toggle




