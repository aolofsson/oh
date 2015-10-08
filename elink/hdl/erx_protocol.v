/*
 This block handles the autoincrement needed for bursting and detects 
 read responses
 */
`include "elink_regmap.v"
module erx_protocol (/*AUTOARG*/
   // Outputs
   erx_test_access, erx_test_data, erx_rdwr_access, erx_rr_access,
   erx_packet,
   // Inputs
   clk, test_mode, rx_packet, rx_burst, rx_access
   );

   parameter AW   = 32;
   parameter DW   = 32;
   parameter PW   = 104;
   parameter ID   = 12'h800; //link id

   
   // System reset input
   input           clk;

   //test mode
   input 	   test_mode; //block all traffic in test mode
   output 	   erx_test_access;
   output [31:0]   erx_test_data;
   
   // Parallel interface, 8 eLink bytes at a time
   
   input [PW-1:0]  rx_packet;
   input 	   rx_burst;
   input 	   rx_access;
   
   // Output to MMU / filter
   output          erx_rdwr_access;
   output          erx_rr_access;
   output [PW-1:0] erx_packet;

   //wires
   reg [31:0] 	   dstaddr_reg;   
   wire [31:0] 	   dstaddr_next;
   wire [31:0] 	   dstaddr_mux;
   reg 		   erx_rdwr_access;
   reg 		   erx_rr_access;
   reg [PW-1:0]    erx_packet;
   wire [11:0] 	   myid;
   wire [31:0] 	   rx_addr;
   wire 	   read_response;
   reg 		   erx_test_access;
   
   //parsing inputs
   assign 	 myid[11:0]     = ID;   
   assign        rx_addr[31:0]  = rx_packet[39:8];
   
   //Address generator for bursting
   always @ (posedge clk)
     if(rx_access)
       dstaddr_reg[31:0]    <= dstaddr_mux[31:0];

   assign dstaddr_next[31:0] = dstaddr_reg[31:0] + 4'b1000;
   
   assign dstaddr_mux[31:0]  =  rx_burst ? dstaddr_next[31:0] :
			                  rx_addr[31:0];
      
   
   //Read response detector
   assign read_response = (rx_addr[31:20] == myid[11:0]) & 
			  (rx_addr[19:16] == `EGROUP_RR);
      
   
   //Pipeline stage and decode  
   always @ (posedge clk)
     begin
	  //Write/read request
	  erx_rdwr_access     <= ~test_mode & rx_access & ~read_response;      
	  //Read response
	  erx_rr_access       <= ~test_mode & rx_access & read_response;	  
	  //Test packet
	  erx_test_access     <= test_mode  & rx_access & ~read_response;	  
	  //Common packet
	  erx_packet[PW-1:0]  <= {rx_packet[PW-1:40],
				  dstaddr_mux[31:0],
				  rx_packet[7:0]
				  };
     end

   //Testdata to write
   assign erx_test_data[31:0] = erx_packet[71:40];
     
endmodule // erx_protocol
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

/*
  Copyright (C) 2015 Adapteva, Inc.
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
