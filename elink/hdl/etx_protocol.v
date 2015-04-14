/*
 ########################################################################
 EPIPHANY eLink TX Protocol block
 ########################################################################
 
 This block takes standard eMesh protocol (104-bit transactions) and
 encodes the bytes into 8-byte parallel outputs for the output 
 serializers.
 */

module etx_protocol (/*AUTOARG*/
   // Outputs
   etx_rd_wait, etx_wr_wait, etx_ack, tx_frame_par, tx_data_par,
   ecfg_tx_datain,
   // Inputs
   reset, etx_access, etx_write, etx_datamode, etx_ctrlmode,
   etx_dstaddr, etx_srcaddr, etx_data, tx_lclk_par, tx_rd_wait,
   tx_wr_wait
   );

   // System reset input
   input         reset;

   // Input from TX Arbiter
   input         etx_access;
   input         etx_write;
   input [1:0]   etx_datamode;
   input [3:0]   etx_ctrlmode;
   input [31:0]  etx_dstaddr;
   input [31:0]  etx_srcaddr;
   input [31:0]  etx_data;
   output        etx_rd_wait;
   output        etx_wr_wait;
   output        etx_ack;
   
   // Parallel interface, 8 eLink bytes at a time
   input         tx_lclk_par; // Parallel-rate clock from eClock block
   output [7:0]  tx_frame_par;
   output [63:0] tx_data_par;
   input         tx_rd_wait;  // The wait signals are passed through
   input         tx_wr_wait;  // to the emesh interfaces

   //Debug/gpio signals
   output [1:0]  ecfg_tx_datain; // {wr_wait, rd_wait}
   
   //############
   //# Local regs & wires
   //############
   reg           etx_ack;  // Acknowledge transaction
   reg [7:0]     tx_frame_par;
   reg [63:0]    tx_data_par;
   
   //############
   //# Logic
   //############

   // TODO: Bursts

   always @( posedge tx_lclk_par or posedge reset ) 
     begin
	if(reset) 
	  begin	     
             etx_ack          <= 1'b0;
             tx_frame_par[7:0] <= 8'd0;
             tx_data_par[63:0] <= 64'd0;	     
	  end 
	else 
	  begin
             if( etx_access & ~etx_ack ) 
	       begin
		  etx_ack  <= 1'b1;
		  tx_frame_par[7:0] <= 8'h3F;
		  tx_data_par[63:0]  <= {8'd0,  // Not used
					 8'd0,
					 ~etx_write, 7'd0, // B0-TODO: For bursts, add the inc bit
					 etx_ctrlmode[3:0], etx_dstaddr[31:28], // B1
					 etx_dstaddr[27:4],  // B2, B3, B4
					 etx_dstaddr[3:0], etx_datamode[1:0], etx_write, etx_access // B5
				   };
               end 
	     else if( etx_ack ) 
	       begin
		  etx_ack  <= 1'b0;
		  tx_frame_par[7:0] <= 8'hFF;
		  tx_data_par[63:0]  <= { etx_data[31:0], etx_srcaddr[31:0]};   
               end 
	     else 
	       begin
		  etx_ack    <= 1'b0;
		  tx_frame_par[7:0] <= 8'h00;
		  tx_data_par[63:0]  <= 64'd0;
               end
	  end // else: !if(reset)	
     end // always @ ( posedge txlclk_p or posedge reset )
   
   
   //#############################
   //# Wait signals
   //#############################

   reg     rd_wait_sync;
   reg     wr_wait_sync;
   reg     etx_rd_wait;
   reg     etx_wr_wait;
   
   always @ (posedge tx_lclk_par) 
     begin
	rd_wait_sync <= tx_rd_wait;
	etx_rd_wait <= rd_wait_sync;
	wr_wait_sync <= tx_wr_wait;
	etx_wr_wait <= wr_wait_sync;
     end

   assign ecfg_tx_datain[1:0] = {etx_wr_wait,
				 etx_rd_wait};
   
endmodule // etx_protocol


/*
  File: etx_protocol.v
 
  This file is part of the Parallella Project.

  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Fred Huettig <fred@adapteva.com>

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
