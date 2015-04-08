/*
  File: e_tx_protocol.v
 
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
   e_tx_rd_wait, e_tx_wr_wait, e_tx_ack, tx_frame_par, tx_data_par,
   ecfg_tx_datain,
   // Inputs
   reset, e_tx_access, e_tx_write, e_tx_datamode, e_tx_ctrlmode,
   e_tx_dstaddr, e_tx_srcaddr, e_tx_data, tx_lclk_par, tx_rd_wait,
   tx_wr_wait
   );

   // System reset input
   input         reset;

   // Input from TX Arbiter
   input         e_tx_access;
   input         e_tx_write;
   input [1:0]   e_tx_datamode;
   input [3:0]   e_tx_ctrlmode;
   input [31:0]  e_tx_dstaddr;
   input [31:0]  e_tx_srcaddr;
   input [31:0]  e_tx_data;
   output        e_tx_rd_wait;
   output        e_tx_wr_wait;
   output        e_tx_ack;
   
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
   reg           e_tx_ack;  // Acknowledge transaction
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
             e_tx_ack          <= 1'b0;
             tx_frame_par[7:0] <= 8'd0;
             tx_data_par[63:0] <= 64'd0;	     
	  end 
	else 
	  begin
             if( e_tx_access & ~e_tx_ack ) 
	       begin
		  e_tx_ack  <= 1'b1;
		  tx_frame_par[7:0] <= 8'h3F;
		  tx_data_par[63:0]  <= {8'd0,  // Not used
					 8'd0,
					 ~e_tx_write, 7'd0, // B0-TODO: For bursts, add the inc bit
					 e_tx_ctrlmode[3:0], e_tx_dstaddr[31:28], // B1
					 e_tx_dstaddr[27:4],  // B2, B3, B4
					 e_tx_dstaddr[3:0], e_tx_datamode[1:0], e_tx_write, e_tx_access // B5
				   };
               end 
	     else if( e_tx_ack ) 
	       begin
		  e_tx_ack  <= 1'b0;
		  tx_frame_par[7:0] <= 8'hFF;
		  tx_data_par[63:0]  <= { e_tx_data[31:0], e_tx_srcaddr[31:0]};   
               end 
	     else 
	       begin
		  e_tx_ack    <= 1'b0;
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
   reg     e_tx_rd_wait;
   reg     e_tx_wr_wait;
   
   always @ (posedge tx_lclk_par) 
     begin
	rd_wait_sync <= tx_rd_wait;
	e_tx_rd_wait <= rd_wait_sync;
	wr_wait_sync <= tx_wr_wait;
	e_tx_wr_wait <= wr_wait_sync;
     end

   assign ecfg_tx_datain[1:0] = {e_tx_wr_wait,
				 e_tx_rd_wait};
   
endmodule // e_tx_protocol


