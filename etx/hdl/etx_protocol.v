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
   e_tx_rd_wait, e_tx_wr_wait, e_tx_ack, txframe_p, txdata_p,
   // Inputs
   reset, e_tx_access, e_tx_write, e_tx_datamode, e_tx_ctrlmode,
   e_tx_dstaddr, e_tx_srcaddr, e_tx_data, txlclk_p, tx_rd_wait,
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
   input         txlclk_p; // Parallel-rate clock from eClock block
   output [7:0]  txframe_p;
   output [63:0] txdata_p;
   input         tx_rd_wait;  // The wait signals are passed through
   input         tx_wr_wait;  // to the emesh interfaces
   
   //#############
   //# Configuration bits
   //#############

   //############
   //# Local regs & wires
   //############
   reg           e_tx_ack;  // Acknowledge transaction
   reg [7:0]     txframe_p;
   reg [63:0]    txdata_p;
   
   //############
   //# Logic
   //############

   // TODO: Bursts

   always @( posedge txlclk_p or posedge reset ) begin

      if( reset ) begin

         e_tx_ack    <= 1'b0;
         txframe_p   <= 'd0;
         txdata_p    <= 'd0;

      end else begin

         if( e_tx_access & ~e_tx_ack ) begin

            e_tx_ack  <= 1'b1;
            txframe_p <= 8'h3F;
            txdata_p  <=
               { 8'd0,  // Not used
                 8'd0,
                 ~e_tx_write, 7'd0,   // B0- TODO: For bursts, add the inc bit
                 e_tx_ctrlmode, e_tx_dstaddr[31:28], // B1
                 e_tx_dstaddr[27:4],  // B2, B3, B4
                 e_tx_dstaddr[3:0], e_tx_datamode, e_tx_write, e_tx_access // B5
                 };
         end else if( e_tx_ack ) begin // if ( e_tx_access & ~e_tx_ack )

            e_tx_ack  <= 1'b0;
            txframe_p <= 8'hFF;
            txdata_p  <= { e_tx_data, e_tx_srcaddr };
            
         end else begin

            e_tx_ack    <= 1'b0;
            txframe_p <= 8'h00;
            txdata_p  <= 64'd0;

         end

      end // else: !if( reset )
   end // always @ ( posedge txlclk_p or reset )
   
   //#############################
   //# Wait signals
   //#############################

   reg     rd_wait_sync;
   reg     wr_wait_sync;
   reg     e_tx_rd_wait;
   reg     e_tx_wr_wait;
   
   always @( posedge txlclk_p ) begin
      rd_wait_sync <= tx_rd_wait;
      e_tx_rd_wait <= rd_wait_sync;
      wr_wait_sync <= tx_wr_wait;
      e_tx_wr_wait <= wr_wait_sync;
   end
            
endmodule // e_tx_protocol


