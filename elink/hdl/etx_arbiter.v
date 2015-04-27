/*
 ########################################################################
 EPIPHANY eMesh Arbiter
 ########################################################################
 
 This block takes three FIFO inputs (write, read request, read response),
 arbitrates between the active channels, and forwards the result on to
 the transmit channel.
 
 The arbitration order is (fixed, highest to lowest)
 1) host writes
 2) read requests from host
 3) read responses

 */

module etx_arbiter (/*AUTOARG*/
   // Outputs
   txwr_fifo_read, txrd_fifo_read, txrr_fifo_read, etx_access,
   etx_packet, etx_rr, etx_read,
   // Inputs
   tx_lclk_div4, reset, ecfg_tx_ctrlmode_bp, ecfg_tx_ctrlmode,
   txwr_fifo_empty, txwr_fifo_packet, txrd_fifo_empty,
   txrd_fifo_packet, txrr_fifo_empty, txrr_fifo_packet, etx_rd_wait,
   etx_wr_wait, etx_io_wait
   );

   parameter PW = 104;
   parameter ID = 0;
   
   // tx clock and reset
   input          tx_lclk_div4;
   input          reset;

   //ctrlmode for slave transactions
   input 	  ecfg_tx_ctrlmode_bp;
   input [3:0] 	  ecfg_tx_ctrlmode;
   
   //Write Request (from slave)
   input 	  txwr_fifo_empty;
   input [PW-1:0] txwr_fifo_packet;
   output         txwr_fifo_read;
   
   //Read Request (from slave)
   input 	  txrd_fifo_empty;
   input [PW-1:0] txrd_fifo_packet;
   output         txrd_fifo_read;
   
   //Read Response (from master)
   input 	  txrr_fifo_empty;
   input [PW-1:0] txrr_fifo_packet;
   output         txrr_fifo_read;

   //Transaction for IO
   output          etx_access;
   output [PW-1:0] etx_packet;
   output 	   etx_rr; 
   input           etx_rd_wait;
   input           etx_wr_wait;
   input 	   etx_io_wait;   

   //For ERX timeout circuit
   output 	   etx_read;
     
   //regs
   reg 		   etx_access;
   reg [PW-1:0]    etx_packet;
   reg 		   etx_rr;     //bypass translation on read request
   
   //wires
   wire 	   rr_ready;
   wire 	   rd_ready;
   wire 	   wr_ready;
   wire [3:0] 	   txrd_ctrlmode;
   wire [3:0] 	   txwr_ctrlmode;
   
   //##########################################################################
   //# Arbitrate & forward
   //##########################################################################
   //TODO: Add weighted round robin arbiter
   //Host-slave should always be able to get "1" read or write in there.
   //Current implementation can deadlock!! (move rd below rr)   
   
   // priority-based ready signals
   assign wr_ready = ~txwr_fifo_empty & ~etx_wr_wait;   //highest
   assign rd_ready = ~txrd_fifo_empty & ~etx_rd_wait & ~wr_ready;
   assign rr_ready = ~txrr_fifo_empty & ~etx_wr_wait & ~wr_ready & ~rd_ready;//lowest
   
   // FIFO read enables (one hot)
   // Hold until transaction has been accepted by IO
   assign txrr_fifo_read = rr_ready & (~etx_access | etx_io_wait);
   assign txrd_fifo_read = rd_ready & (~etx_access | etx_io_wait);
   assign txwr_fifo_read = wr_ready & (~etx_access | etx_io_wait);
   
   //Selecting control mode on slave transcations
   assign txrd_ctrlmode[3:0] =  ecfg_tx_ctrlmode_bp ? ecfg_tx_ctrlmode[3:0] : 
				                      txrd_fifo_packet[7:4];

   assign txwr_ctrlmode[3:0] =  ecfg_tx_ctrlmode_bp ? ecfg_tx_ctrlmode[3:0] : 
				                      txwr_fifo_packet[7:4];

   always @ (posedge tx_lclk_div4)
      if( reset ) 
	begin
           etx_access         <= 1'b0;
	   etx_rr             <= 1'b0;//only way to diff between 'rr' and 'wr'
	   etx_packet[PW-1:0] <= 'd0;
	end 
      else if (txrr_fifo_read | txrd_fifo_read | txwr_fifo_read )
	begin
	   etx_rr             <= txrr_fifo_read;	   
	   etx_access         <= 1'b1;	   	   
 	   etx_packet[PW-1:0] <= txrr_fifo_read ? txrr_fifo_packet[PW-1:0]   : 
 			         txrd_fifo_read ? {txrd_fifo_packet[PW-1:8], 
						   txrd_ctrlmode[3:0],
						   txrd_fifo_packet[3:0]}    : 
                                                  {txwr_fifo_packet[PW-1:8], 
						   txwr_ctrlmode[3:0],
						   txwr_fifo_packet[3:0]};
 	end   
      else if (~etx_io_wait)
	begin
	   etx_access <= 1'b0;	   
	end   
   	              

   assign etx_read = txrd_fifo_read;
   
                              
endmodule // etx_arbiter
/*
  File: etx_arbiter.v
 
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
