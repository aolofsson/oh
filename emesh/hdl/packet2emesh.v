module packet2emesh(/*AUTOARG*/
   // Outputs
   write_out, datamode_out, ctrlmode_out, data_out, dstaddr_out,
   srcaddr_out,
   // Inputs
   packet_in
   );

   parameter PW      = 104;   //packet width
   parameter DW      = 32;    //data width
   parameter AW      = 32;    //addess width

   //Input packet
   input [PW-1:0]   packet_in;

   //Emesh signal bundle 
   output 	        write_out;
   output [1:0] 	datamode_out;
   output [3:0] 	ctrlmode_out;
   output [DW-1:0] 	data_out; //TODO: fix to make relative to PW
   output [AW-1:0]      dstaddr_out;
   output [AW-1:0]      srcaddr_out;
      
   assign write_out             = packet_in[1];   
   assign datamode_out[1:0]     = packet_in[3:2];   
   assign ctrlmode_out[3:0]     = packet_in[7:4];   
   assign dstaddr_out[31:0]     = packet_in[39:8]; 	 
   assign srcaddr_out[31:0]     = packet_in[103:72];  
   assign data_out[31:0]        = packet_in[71:40];  
      
endmodule // packet2emesh



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
