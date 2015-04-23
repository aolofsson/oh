/*
 ########################################################################
 EPIPHANY eMesh Filter / Distributor
 ########################################################################
 
 This block takes one eMesh input, selected from two available 
 (MMU or direct), and distributes the transactions based on type
 (write, read request, read response).
 */

module erx_disty (/*AUTOARG*/
   // Outputs
   rx_rd_wait, rx_wr_wait, edma_wait, rxwr_fifo_access,
   rxwr_fifo_packet, rxrd_fifo_access, rxrd_fifo_packet,
   rxrr_fifo_access, rxrr_fifo_packet,
   // Inputs
   clk, mmu_en, emmu_access, emmu_packet, edma_access, edma_packet,
   rxwr_fifo_wait, rxrd_fifo_wait, rxrr_fifo_wait
   );

   parameter [11:0]  C_READ_TAG_ADDR = 12'h810;
   parameter AW = 32;
   parameter DW = 32;
   parameter PW = 104;

   // RX clock
   input         clk;

   // MMU enable
   input 	 mmu_en;

   //Transaction from MMU
   input           emmu_access;
   input [PW-1:0]  emmu_packet;
   output          rx_rd_wait;
   output          rx_wr_wait;

   //Transaction from DMA
   input           edma_access;
   input [PW-1:0]  edma_packet;
   output 	   edma_wait;
   
   // Master FIFO port, writes
   output 	   rxwr_fifo_access;
   output [PW-1:0] rxwr_fifo_packet;   
   input           rxwr_fifo_wait;
   
   // Master FIFO port, read requests
   output 	   rxrd_fifo_access;
   output [PW-1:0] rxrd_fifo_packet;   
   input           rxrd_fifo_wait;
   
   // Master FIFO port, read responses
   output 	   rxrr_fifo_access;
   output [PW-1:0] rxrr_fifo_packet;   
   input           rxrr_fifo_wait;
   
   //wires
   wire            emmu_write;
   wire [1:0]      emmu_datamode;
   wire [3:0]      emmu_ctrlmode;
   wire [31:0]     emmu_dstaddr;
   wire [31:0]     emmu_srcaddr;
   wire [31:0]     emmu_data;
   wire 	   emmu_read;
   
   //regs
   reg 		   rxrd_fifo_access;
   reg 		   rxrr_fifo_access;
   reg 		   rxwr_fifo_access;
   reg [PW-1:0]    rxrd_fifo_packet;
   reg [PW-1:0]    rxwr_fifo_packet;
   
   packet2emesh p2e (// Outputs
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
    
   //Read requests (emmu has priority over edma)
   assign emmu_read = (emmu_access & ~emmu_write);

   always @ (posedge clk) 
     if(emmu_read | edma_access )
       begin
	  rxrd_fifo_access         <= 1'b1;
	  rxrd_fifo_packet[PW-1:0] <= emmu_read ? emmu_packet[PW-1:0] :
			   	                  edma_packet[PW-1:0];
       end
     else
       begin
	  rxrd_fifo_access  <= 1'b0;
       end

   //Write and read response from emmu
   always @ (posedge clk) 
     if(emmu_access) 
       begin	  
	  rxwr_fifo_packet[PW-1:0] <= emmu_packet[PW-1:0];	    
          rxrr_fifo_access         <= emmu_write & (emmu_dstaddr[31:20] == C_READ_TAG_ADDR);
          rxwr_fifo_access         <= emmu_write & (emmu_dstaddr[31:20] != C_READ_TAG_ADDR);
       end
     else
       begin
	  rxrr_fifo_access  <= 1'b0;
	  rxwr_fifo_access  <= 1'b0;	  
       end

   assign rxrr_fifo_packet[PW-1:0] = rxwr_fifo_packet[PW-1:0];
   
   //wait signals   
   assign        rx_rd_wait = rxrd_fifo_wait;
   assign        rx_wr_wait = rxwr_fifo_wait | rxrr_fifo_wait;
   assign        edma_wait   = rxrd_fifo_wait | emmu_read;
   
endmodule // erx_disty
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

//#############################################################################
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
