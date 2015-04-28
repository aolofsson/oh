module erx_disty (/*AUTOARG*/
   // Outputs
   erx_wait, rx_rd_wait, rx_wr_wait, edma_wait, rxwr_fifo_access,
   rxwr_fifo_packet, rxrd_fifo_access, rxrd_fifo_packet,
   rxrr_fifo_access, rxrr_fifo_packet,
   // Inputs
   erx_access, erx_packet, emmu_access, emmu_packet, edma_access,
   edma_packet, rxwr_fifo_wait, rxrd_fifo_wait, rxrr_fifo_wait,
   timeout
   );

   parameter AW   = 32;
   parameter DW   = 32;
   parameter PW   = 104;
   parameter ID   = 12'h800; //link id
   parameter RFAW = 4;
   
   
   //From IO
   input           erx_access;
   input [PW-1:0]  erx_packet;
   output          erx_wait;   //for emmu/remap
   output          rx_rd_wait; //for IO
   output          rx_wr_wait; //for IO

   //From EMMU
   input           emmu_access;
   input [PW-1:0]  emmu_packet;
   
   //From DMA
   input           edma_access;
   input [PW-1:0]  edma_packet;
   output 	   edma_wait;
   
   //To Master Write FIFO
   output 	   rxwr_fifo_access;
   output [PW-1:0] rxwr_fifo_packet;   
   input           rxwr_fifo_wait;
   
   //To Master Read FIFO
   output 	   rxrd_fifo_access;
   output [PW-1:0] rxrd_fifo_packet;   
   input           rxrd_fifo_wait;
   
   //To Slave Read Response FIFO
   output 	   rxrr_fifo_access;
   output [PW-1:0] rxrr_fifo_packet;   
   input           rxrr_fifo_wait;

   //Timeout indicator
   input 	   timeout;
      
   //wires
   wire            emmu_write;
   wire [1:0]      emmu_datamode;
   wire [3:0]      emmu_ctrlmode;
   wire [31:0]     emmu_dstaddr;
   wire [31:0]     emmu_srcaddr;
   wire [31:0]     emmu_data;
   wire 	   emmu_read;

   wire            erx_write;
   wire [1:0]      erx_datamode;
   wire [3:0]      erx_ctrlmode;
   wire [31:0]     erx_dstaddr;
   wire [31:0]     erx_srcaddr;
   wire [31:0]     erx_data;
   wire 	   erx_read;
   
   //####################################
   //Splicing pakets
   //####################################

   packet2emesh p2e_erx (// Outputs
		     .access_out	(),
		     .write_out		(erx_write),
		     .datamode_out	(erx_datamode[1:0]),
		     .ctrlmode_out	(erx_ctrlmode[3:0]),
		     .dstaddr_out	(erx_dstaddr[AW-1:0]),
		     .data_out		(erx_data[DW-1:0]),
		     .srcaddr_out	(erx_srcaddr[AW-1:0]),
		     // Inputs
		     .packet_in		(erx_packet[PW-1:0])
		     );

   packet2emesh p2e_mmu (// Outputs
		     .access_out	(),
		     .write_out		(emmu_write),
		     .datamode_out	(emmu_datamode[1:0]),
		     .ctrlmode_out	(emmu_ctrlmode[3:0]),
		     .dstaddr_out	(emmu_dstaddr[AW-1:0]),
		     .data_out		(emmu_data[DW-1:0]),
		     .srcaddr_out	(emmu_srcaddr[AW-1:0]),
		     // Inputs
		     .packet_in		(emmu_packet[PW-1:0])
		     );
   
   //####################################
   //Read response path (direct)
   //####################################

   assign rxrr_fifo_access         = timeout |
				     (erx_access & 
				     erx_write & 
				     (erx_dstaddr[31:20] == ID) & 
				     (erx_dstaddr[19:16]==`EGROUP_RX) &
				     (erx_dstaddr[RFAW+1:2]==`ELRXRR)
				      );
   
   assign rxrr_fifo_packet[PW-1:0] = timeout ? {32'h0,32'hDEADBEEF,
				  	        ID,`EGROUP_RX,16'h0000,
                                                8'h03} : 
   				                erx_packet[PW-1:0];
      
   //####################################
   //Write Path (direct)
   //####################################

   assign rxwr_fifo_access        = emmu_access & 
			            emmu_write;

   assign rxwr_fifo_packet[PW-1:0] = emmu_packet[PW-1:0];
         
   //####################################
   //Read Path 
   //####################################

   assign emmu_read               = (emmu_access & ~emmu_write);
   
   assign rxrd_fifo_access         = emmu_read | edma_access;
   
   assign rxrd_fifo_packet[PW-1:0] = emmu_read ? emmu_packet[PW-1:0] : 
				                 edma_packet[PW-1:0];
   
   //####################################
   //Wait Signals
   //####################################   

   assign        rx_rd_wait = rxrd_fifo_wait;
   assign        rx_wr_wait = rxwr_fifo_wait | rxrr_fifo_wait;
   assign        edma_wait  = rxrd_fifo_wait | emmu_read;
   assign        erx_wait   = rx_rd_wait |  rx_wr_wait;
  
   
endmodule // erx_disty
// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emmu/hdl")
// End:

//#############################################################################
/*
  This file is part of the Parallella Project.

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
