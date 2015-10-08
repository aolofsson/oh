`include "elink_regmap.v"
module erx_arbiter (/*AUTOARG*/
   // Outputs
   rx_rd_wait, rx_wr_wait, edma_wait, ecfg_wait, rxwr_access,
   rxwr_packet, rxrd_access, rxrd_packet, rxrr_access, rxrr_packet,
   // Inputs
   erx_rr_access, erx_packet, emmu_access, emmu_packet, edma_access,
   edma_packet, ecfg_access, ecfg_packet, timeout, rxwr_wait,
   rxrd_wait, rxrr_wait
   );

   parameter AW   = 32;
   parameter DW   = 32;
   parameter PW   = 104;
   parameter ID   = 12'h800; //link id
   parameter RFAW = 6;
   
   
   //From IO (for rr)   
   input           erx_rr_access;
   input [PW-1:0]  erx_packet;
   output          rx_rd_wait; //for IO
   output          rx_wr_wait; //for IO

   
   //From EMMU (writes)  
   input           emmu_access;
   input [PW-1:0]  emmu_packet;

   //From DMA
   input           edma_access;
   input [PW-1:0]  edma_packet;
   output 	   edma_wait;

   //From ETX
   input           ecfg_access;
   input [PW-1:0]  ecfg_packet;
   output 	   ecfg_wait;

   //From timeout circuit
   input 	   timeout;
   
   //To Master Write FIFO
   output 	   rxwr_access;
   output [PW-1:0] rxwr_packet;   
   input           rxwr_wait;
   
   //To Master Read FIFO
   output 	   rxrd_access;
   output [PW-1:0] rxrd_packet;   
   input           rxrd_wait;
   
   //To Slave Read Response FIFO
   output 	   rxrr_access;
   output [PW-1:0] rxrr_packet;   
   input           rxrr_wait;

   //wires
   wire            emmu_write;
   wire 	   emmu_read;
   
   wire [11:0] 	   myid;

   //####################################
   //Splicing pakets
   //####################################
   assign 	 myid[11:0] = ID;   
   
   //####################################
   //Read response path (from IO or cfg)
   //####################################
   
   assign rxrr_access         = erx_rr_access   |
			        ecfg_access;
   
   assign rxrr_packet[PW-1:0] = erx_rr_access ?  erx_packet[PW-1:0] :
			 	                 ecfg_packet[PW-1:0];

   assign ecfg_wait           = erx_rr_access;

   //####################################
   //Write Path (direct)
   //####################################
   assign emmu_write          = emmu_packet[1];

   assign rxwr_access         = emmu_access & emmu_write;
   
   assign rxwr_packet[PW-1:0] = emmu_packet[PW-1:0];
         
   //####################################
   //Read Request Path 
   //####################################

   assign emmu_read           = emmu_access & ~emmu_write;
   
   assign rxrd_access         = emmu_read | edma_access;
   
   assign rxrd_packet[PW-1:0] = emmu_read ? emmu_packet[PW-1:0] : 
				            edma_packet[PW-1:0];
   
   //####################################
   //Wait Signals
   //####################################   
   
   assign rx_rd_wait    = rxrd_wait;
   assign rx_wr_wait    = rxwr_wait | rxrr_wait;
   assign edma_wait     = rxrd_wait | emmu_read;
   assign erx_cfg_wait  = rxwr_wait | rxrr_wait;   
   
endmodule // erx_arbiter

// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emmu/hdl")
// End:

//#############################################################################
/*
  This file is part of the Parallella Project.

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
