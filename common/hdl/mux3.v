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
module mux3(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   in0, in1, in2, sel0, sel1, sel2
   );

   parameter DW=99;
   
   //data inputs
   input [DW-1:0]  in0;
   input [DW-1:0]  in1;
   input [DW-1:0]  in2;
   
   //select inputs
   input           sel0;
   input           sel1;
   input           sel2;

   output [DW-1:0] out;
   
  
   assign out[DW-1:0] = ({(DW){sel0}} & in0[DW-1:0] |
			 {(DW){sel1}} & in1[DW-1:0] |
			 {(DW){sel2}} & in2[DW-1:0]);
   			
   // synthesis translate_off
   always @*
     if((sel0+sel1+sel2>1) && ($time>0))
       $display("ERROR>>Arbitration failure in cell %m");
   // synthesis translate_on
  
endmodule // mux3
