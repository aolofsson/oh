/*Converts an emesh bundle into a 104 bit packet*/
module packet2emesh(/*AUTOARG*/
   // Outputs
   access_out, write_out, datamode_out, ctrlmode_out, dstaddr_out,
   data_out, srcaddr_out,
   // Inputs
   packet_in
   );

   parameter AW=32;
   parameter DW=32;
   parameter PW=104;
   
   //Emesh signal bundle
   output 	    access_out;
   output 	    write_out;   
   output [1:0]     datamode_out;
   output [3:0]     ctrlmode_out;   
   output [AW-1:0]  dstaddr_out;
   output [DW-1:0]  data_out;   
   output [AW-1:0]  srcaddr_out;   
   
   //Output packet
   input [PW-1:0]   packet_in;

   assign access_out          = packet_in[0];
   assign write_out           = packet_in[1];
   assign datamode_out[1:0]   = packet_in[3:2];
   assign ctrlmode_out[3:0]   = packet_in[7:4];
   assign dstaddr_out[AW-1:0] = packet_in[39:8];
   assign data_out[AW-1:0]    = packet_in[71:40];
   assign srcaddr_out[AW-1:0] = packet_in[103:72];
     
endmodule // emesh2packet
/*
  Copyright (C) 2015 Adapteva, Inc.
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
