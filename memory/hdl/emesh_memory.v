module emesh_memory(/*AUTOARG*/
   // Outputs
   wait_out, access_out, write_out, datamode_out, ctrlmode_out,
   dstaddr_out, data_out, srcaddr_out,
   // Inputs
   clk, reset, access_in, write_in, datamode_in, ctrlmode_in,
   dstaddr_in, data_in, srcaddr_in, wait_in
   );

   parameter DW  = 32;   
   parameter AW  = 32;   
   parameter MAW = 10;
   parameter LSB = $clog2(DW/8);
   
   //Basic Interface
   input            clk;
   input 	    reset;  

   //incoming read/write
   input 	    access_in;
   input 	    write_in;   
   input [1:0] 	    datamode_in;
   input [3:0] 	    ctrlmode_in;
   input [AW-1:0]   dstaddr_in;
   input [DW-1:0]   data_in;   
   input [AW-1:0]   srcaddr_in;   
   output 	    wait_out;   //pushback
     
   //back to mesh (readback data)
   output 	    access_out;
   output 	    write_out;   
   output [1:0]     datamode_out;
   output [3:0]     ctrlmode_out;
   output [AW-1:0]  dstaddr_out;
   output [DW-1:0]  data_out;   
   output [AW-1:0]  srcaddr_out;   
   input 	    wait_in;   //pushback
   
   
endmodule // emesh_memory
// Local Variables:
// verilog-library-directories:("." )
// End:


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


