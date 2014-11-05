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
module toggle2pulse(/*AUTOARG*/
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
   reg 	  out_reg;
         
   always @ (posedge clk or posedge reset)
     if(reset)
       out_reg <= 1'b0;
     else
       out_reg <= in;
      
   assign out = in ^ out_reg;

endmodule 





