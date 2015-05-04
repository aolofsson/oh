/*
 ########################################################################
 EPIPHANY eMesh Arbiter
 ########################################################################
 
 This block takes three FIFO inputs (write, read request, read response)
 and the DMA channel, arbitrates between the active channels, and forwards 
 the result to the transmit output pins.
 
 Arbitration Priority:
 1) host writes (highest)
 2) read requests from host
 3) read responses
 4) DMA (lowest)

 */

module etx_arbiter (/*AUTOARG*/
   // Outputs
   txwr_fifo_wait, txrd_fifo_wait, txrr_fifo_wait, edma_wait,
   etx_access, etx_packet, etx_rr,
   // Inputs
   clk, reset, txwr_fifo_access, txwr_fifo_packet, txrd_fifo_access,
   txrd_fifo_packet, txrr_fifo_access, txrr_fifo_packet, edma_access,
   edma_packet, etx_rd_wait, etx_wr_wait, etx_cfg_wait,
   ctrlmode_bypass, ctrlmode
   );

   parameter PW = 104;
   parameter ID = 0;
   
   //tx clock and reset
   input          clk;
   input          reset;

   //Write Request (from slave)
   input 	   txwr_fifo_access;
   input [PW-1:0]  txwr_fifo_packet;
   output          txwr_fifo_wait;
   
   //Read Request (from slave)
   input 	   txrd_fifo_access;
   input [PW-1:0]  txrd_fifo_packet;
   output          txrd_fifo_wait;
   
   //Read Response (from master)
   input 	   txrr_fifo_access;
   input [PW-1:0]  txrr_fifo_packet;
   output          txrr_fifo_wait;

   //DMA Master (not implemented, TODO)
   input 	   edma_access;
   input [PW-1:0]  edma_packet;
   output 	   edma_wait;

   //Wait signal inputs
   input           etx_rd_wait;
   input           etx_wr_wait;
   input 	   etx_cfg_wait;
   
   //ctrlmode for rd/wr transactions
   input 	   ctrlmode_bypass;
   input [3:0] 	   ctrlmode;
   
   //Transaction for IO protocol
   output          etx_access;
   output [PW-1:0] etx_packet;
   output 	   etx_rr;      //bypass translation on read response
    
   //regs
   reg 		   etx_access;
   reg [PW-1:0]    etx_packet;
   reg 		   etx_rr;     //bypass translation on read response
   
   //wires  
   wire [3:0] 	   txrd_ctrlmode;
   wire [3:0] 	   txwr_ctrlmode;
   wire 	   access_in;   
   wire [PW-1:0]   etx_packet_mux;
   wire 	   edma_grant;
   wire 	   txrr_grant;
   wire 	   txrd_grant;
   wire 	   txwr_grant;
   wire 	   edma_arb_wait;
   wire 	   txrr_arb_wait;
   wire 	   txrd_arb_wait;
   wire 	   txwr_arb_wait;
   wire [PW-1:0]   txrd_data;
   wire [PW-1:0]   txwr_data;
   wire [PW-1:0]   etx_mux;
   wire            write_in;

   //##########################################################################
   //# Insert special control mode
   //##########################################################################
   assign txrd_ctrlmode[3:0] =  ctrlmode_bypass ?  ctrlmode[3:0] : 
				                   txrd_fifo_packet[7:4];

   assign txrd_data[PW-1:0] = {txrd_fifo_packet[PW-1:8],   
                               txrd_ctrlmode[3:0], 
			       txrd_fifo_packet[3:0]};
 
   
   assign txwr_ctrlmode[3:0] =  ctrlmode_bypass ?  ctrlmode[3:0] : 
				                   txwr_fifo_packet[7:4];

   assign txwr_data[PW-1:0] = {txwr_fifo_packet[PW-1:8],   
                               txwr_ctrlmode[3:0], 
			       txwr_fifo_packet[3:0]};
 
   //##########################################################################
   //# Arbiter
   //##########################################################################
  
   
   arbiter_priority #(.ARW(4)) arbiter (.grant({edma_grant,//lowest priority
						txrr_grant,	
						txrd_grant,
						txwr_grant //highest priority
						}),
				        .await({edma_arb_wait,
						txrr_arb_wait,	
						txrd_arb_wait,
						txwr_arb_wait
						}),	
					.request({edma_access,
						txrr_fifo_access,	
						txrd_fifo_access,
						txwr_fifo_access
						})	
				  );
   //Priority Mux
   assign etx_mux[PW-1:0] =({(PW){txwr_grant}} & txwr_data[PW-1:0]) |
			   ({(PW){txrd_grant}} & txrd_data[PW-1:0]) |
			   ({(PW){txrr_grant}} & txrr_fifo_packet[PW-1:0]) |
			   ({(PW){edma_grant}} & edma_packet[PW-1:0]);
 
   //######################################################################
   //Pushback (stall) Signals
   //######################################################################
   
   //Write waits on pin wr wait or cfg_wait
   assign txwr_fifo_wait = etx_wr_wait | 
		           etx_cfg_wait;
   
   //Host read request (self throttling, one read at a time)
   assign txrd_fifo_wait = etx_rd_wait | 
		           etx_cfg_wait | 
		           txrd_arb_wait;
   //Read response
   assign txrr_fifo_wait = etx_wr_wait | 
		           etx_cfg_wait | 
		           txrr_arb_wait;

   //DMA (conservative)
   assign edma_wait = etx_wr_wait | etx_rd_wait  | 
		      etx_cfg_wait | 
		      edma_arb_wait;

   //#####################################################################
   //# Pipeline stage (arbiter+mux takes time..)
   //#####################################################################
   assign access_in = (txwr_grant & ~txwr_fifo_wait) |
		      (txrd_grant & ~txrd_fifo_wait) |
		      (txrr_grant & ~txrr_fifo_wait) |
		      (edma_grant & ~edma_wait);

   //Pipeline + stall
   assign write_in = etx_mux[1];

   always @ (posedge clk)
     if ((write_in & ~etx_wr_wait) | (~write_in & ~etx_rd_wait))
       begin
	  etx_access         <= access_in;
	  etx_packet[PW-1:0] <= etx_mux[PW-1:0];
	  etx_rr             <= txrr_grant;
       end
   
endmodule // etx_arbiter
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:


/*
  File: etx_arbiter.v

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
