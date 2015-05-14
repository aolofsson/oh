/*
 ########################################################################
 EPIPHANY eLink RX Protocol block
 ########################################################################
 
 This block takes the parallel output of the input deserializers, locates
 valid frame transitions, and decodes the bytes into standard eMesh 
 protocol (104-bit transactions).
 */

module erx_protocol (/*AUTOARG*/
   // Outputs
   erx_access, erx_packet, remap_bypass,
   // Inputs
   reset, rx_enable, clk, rx_packet, rx_burst, rx_access
   );

   parameter AW   = 32;
   parameter DW   = 32;
   parameter PW   = 104;
   parameter ID   = 0;

   
   // System reset input
   input           reset;
   input 	   rx_enable;//Enables receiver

   // Parallel interface, 8 eLink bytes at a time
   input           clk;
   input [PW-1:0]  rx_packet;
   input 	   rx_burst;
   input 	   rx_access;
   
   // Output to MMU / filter
   output          erx_access;
   output [PW-1:0] erx_packet;
   output 	   remap_bypass;    //needed for remapping logic

   assign erx_access          = rx_access;
   assign erx_packet[PW-1:0]  = rx_packet[PW-1:0];
   

endmodule // erx_protocol
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

/*
  This file is part of the Parallella Project.

  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Fred Huettig <fred@adapteva.com>
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
