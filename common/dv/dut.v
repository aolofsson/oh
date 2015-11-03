// Standardized "DUT"
module dut (/*AUTOARG*/
   // Outputs
   dut_active, access_out, packet_out, wait_out,
   // Inputs
   clk, nreset, vdd, vss, access_in, packet_in, wait_in
   );
 
   parameter PW = 99;
   parameter N  = 99;
   
   //#######################################
   //# CLOCK AND RESET
   //#######################################
   input            clk;
   input            nreset;
   input [N*N-1:0]  vdd;
   input 	    vss;
   output 	    dut_active; //dut ready to go after reset
      
   //#######################################
   //#EMESH INTERFACE 
   //#######################################
   
   //North side
   input [N-1:0]     access_in;
   input [N*PW-1:0]  packet_in;
   input [N-1:0]     wait_in;
   output [N-1:0]    access_out;
   output [N*PW-1:0] packet_out;
   output [N-1:0]    wait_out;
    
   /*AUTOINPUT*/
   /*AUTOINPUT*/
   /*AUTOWIRE*/
   
   //Drive dummy interface
   //This module should be replaced with actual device under test
   assign access_out  ='b0;
   assign packet_out  ='b0;
   assign wait_out    ='b0;
   assign reset_done  = 1'b1;
   
endmodule // dut

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



