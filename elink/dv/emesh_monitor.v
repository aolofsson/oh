/* verilator lint_off WIDTH */
module emesh_monitor(/*AUTOARG*/
   // Inputs
   clk, reset, itrace, etime, emesh_access, emesh_packet, emesh_wait
   );
   parameter AW     =  32;
   parameter DW     =  32;
   parameter NAME   =  "cpu";
   parameter PW     = 104;
   
   
   //BASIC INTERFACE
   input            clk;
   input            reset;
   input            itrace;
   input [31:0]     etime;
   
   //MESH TRANSCTION
   input            emesh_access;
   input [PW-1:0]   emesh_packet;   
   input            emesh_wait;

   //core name for trace
   reg [63:0]      name=NAME;
   reg [31:0] 	   ftrace;

   initial
     begin
        ftrace  = $fopen({NAME,".trace"}, "w");
     end

   always @ (posedge clk)
     if(itrace & ~reset & emesh_access & ~emesh_wait)
       begin	     	 
	  //$fwrite(ftrace, "TIME=%h\n",etime[31:0]);
	  $fwrite(ftrace, "%h_%h_%h_%h\n",emesh_packet[103:72], emesh_packet[71:40],emesh_packet[39:8],
		                          {emesh_packet[7:4],emesh_packet[3:2],emesh_packet[1],emesh_access});
       end   
endmodule // emesh_monitor


/*
 Copyright (C) 2014 Adapteva, Inc. 
 Contributed by Andreas Olofsson <andreas@adapteva.com>

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.This program is distributed in the hope 
 that it will be useful,but WITHOUT ANY WARRANTY; without even the implied 
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details. You should have received a copy 
 of the GNU General Public License along with this program (see the file 
 COPYING).  If not, see <http://www.gnu.org/licenses/>.
 */

   
