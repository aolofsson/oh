/*
  File: eproto_tx.v
 
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

module eproto_tx (/*AUTOARG*/
   // Outputs
   emtx_rd_wait, emtx_wr_wait, emtx_ack, txframe_p, txdata_p,
   // Inputs
   reset, emtx_access, emtx_write, emtx_datamode, emtx_ctrlmode,
   emtx_dstaddr, emtx_srcaddr, emtx_data, txlclk_p, tx_rd_wait,
   tx_wr_wait
   );

   // System reset input
   input         reset;

   // Input from TX Arbiter
   input         emtx_access;
   input         emtx_write;
   input [1:0]   emtx_datamode;
   input [3:0]   emtx_ctrlmode;
   input [31:0]  emtx_dstaddr;
   input [31:0]  emtx_srcaddr;
   input [31:0]  emtx_data;
   output        emtx_rd_wait;
   output        emtx_wr_wait;
   output        emtx_ack;
   
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
   reg           emtx_ack;  // Acknowledge transaction
   reg [7:0]     txframe_p;
   reg [63:0]    txdata_p;
   
   //############
   //# Logic
   //############

   // TODO: Bursts

   always @( posedge txlclk_p or reset ) begin

      if( reset ) begin

         emtx_ack    <= 1'b0;
         txframe_p   <= 'd0;
         txdata_p    <= 'd0;

      end else begin

         if( emtx_access & ~emtx_ack ) begin

            emtx_ack  <= 1'b1;
            txframe_p <= 8'h3F;
            txdata_p  <=
               { 8'd0,  // Not used
                 8'd0,
                 ~emtx_write, 7'd0,   // B0- TODO: For bursts, add the inc bit
                 emtx_ctrlmode, emtx_dstaddr[31:28], // B1
                 emtx_dstaddr[27:4],  // B2, B3, B4
                 emtx_dstaddr[3:0], emtx_datamode, emtx_write, emtx_access // B5
                 };
         end else if( emtx_ack ) begin // if ( emtx_access & ~emtx_ack )

            emtx_ack  <= 1'b0;
            txframe_p <= 8'hFF;
            txdata_p  <= { emtx_data, emtx_srcaddr };
            
         end else begin

            emtx_ack    <= 1'b0;
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
   reg     emtx_rd_wait;
   reg     emtx_wr_wait;
   
   always @( posedge txlclk_p ) begin
      rd_wait_sync <= tx_rd_wait;
      emtx_rd_wait <= rd_wait_sync;
      wr_wait_sync <= tx_wr_wait;
      emtx_wr_wait <= wr_wait_sync;
   end
            
endmodule // eproto_tx

