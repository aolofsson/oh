/* verilator lint_off WIDTH */
module emesh_monitor(/*AUTOARG*/
   // Inputs
   clk, reset, itrace, etime, emesh_access, emesh_write,
   emesh_datamode, emesh_ctrlmode, emesh_dstaddr, emesh_data,
   emesh_srcaddr, emesh_wait
   );
   parameter AW     =  32;
   parameter DW     =  32;
   parameter NAME   =  "cpu";

   //BASIC INTERFACE
   input            clk;
   input            reset;
   input            itrace;
   input [31:0]     etime;
   
   //MESH TRANSCTION
   input            emesh_access;
   input            emesh_write;
   input [1:0]      emesh_datamode;
   input [3:0] 	    emesh_ctrlmode;
   input [AW-1:0]   emesh_dstaddr;
   input [DW-1:0]   emesh_data;
   input [AW-1:0]   emesh_srcaddr;
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
	  $fwrite(ftrace, "%h_%h_%h_%h_%h\n",emesh_srcaddr[AW-1:0], emesh_data[DW-1:0],emesh_dstaddr[DW-1:0],emesh_ctrlmode[3:0],{emesh_datamode[1:0],emesh_write,emesh_access});
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

   
