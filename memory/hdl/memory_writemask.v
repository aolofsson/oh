module memory_writemask(/*AUTOARG*/
   // Outputs
   we,
   // Inputs
   write, datamode, addr
   );

   input         write;   
   input [1:0]   datamode;   
   input [2:0]   addr;
   output [7:0]  we;

   reg [7:0] 	 we;

   //Write mask
   always@*
     casez({write, datamode[1:0],addr[2:0]})
       //Byte
       6'b100000 : we[7:0] = 8'b00000001;
       6'b100001 : we[7:0] = 8'b00000010;
       6'b100010 : we[7:0] = 8'b00000100;
       6'b100011 : we[7:0] = 8'b00001000;
       6'b100100 : we[7:0] = 8'b00010000;
       6'b100101 : we[7:0] = 8'b00100000;
       6'b100110 : we[7:0] = 8'b01000000;
       6'b100111 : we[7:0] = 8'b10000000;
       //Short
       6'b10100? : we[7:0] = 8'b00000011;
       6'b10101? : we[7:0] = 8'b00001100;
       6'b10110? : we[7:0] = 8'b00110000;
       6'b10111? : we[7:0] = 8'b11000000;
       //Word
       6'b1100?? : we[7:0] = 8'b00001111;
       6'b1101?? : we[7:0] = 8'b11110000;       
       //Double
       6'b111??? : we[7:0] = 8'b11111111;
       default   : we[7:0] = 8'b00000000;
     endcase // casez ({write, datamode[1:0],addr[2:0]})
   

endmodule // memory_writemask

/*
 Copyright (C) 2014 Adapteva, Inc.
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


