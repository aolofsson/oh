/*
  File: earb.v
 
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
 EPIPHANY eMesh Arbiter
 ########################################################################
 
 This block takes three FIFO inputs (write, read request, read response),
 arbitrates between the active channels, and forwards the result on to
 the transmit channel.
 
 The arbitration order is (fixed, highest to lowest)
   1) read responses
   2) read requests
   3) writes
 
 */

module earb (/*AUTOARG*/
   // Outputs
   emwr_rd_en, emrq_rd_en, emrr_rd_en, emm_tx_access, emm_tx_write,
   emm_tx_datamode, emm_tx_ctrlmode, emm_tx_dstaddr, emm_tx_srcaddr,
   emm_tx_data,
   // Inputs
   clock, reset, emwr_rd_data, emwr_empty, emrq_rd_data, emrq_empty,
   emrr_rd_data, emrr_empty, emm_tx_rd_wait, emm_tx_wr_wait, emtx_ack
   );

   // TX clock
   input          clock;
   input          reset;
   
   // FIFO slave port, writes
   input [102:0]  emwr_rd_data;
   output         emwr_rd_en;
   input          emwr_empty;
   
   // FIFO slave port, read requests
   input [102:0]  emrq_rd_data;
   output         emrq_rd_en;
   input          emrq_empty;
   
   // FIFO slave port, read responses
   input [102:0]  emrr_rd_data;
   output         emrr_rd_en;
   input          emrr_empty;

   // eMesh master port, to TX
   output         emm_tx_access;
   output         emm_tx_write;
   output [1:0]   emm_tx_datamode;
   output [3:0]   emm_tx_ctrlmode;
   output [31:0]  emm_tx_dstaddr;
   output [31:0]  emm_tx_srcaddr;
   output [31:0]  emm_tx_data;
   input          emm_tx_rd_wait;
   input          emm_tx_wr_wait;

   // Ack from TX protocol module
   input          emtx_ack;

   // Control bits inputs (none)

   // output wires
   wire           emm_tx_access;
   wire           emm_tx_write;
   wire [1:0]     emm_tx_datamode;
   wire [3:0]     emm_tx_ctrlmode;
   wire [31:0]    emm_tx_dstaddr;
   wire [31:0]    emm_tx_srcaddr;
   wire [31:0]    emm_tx_data;
   
   //############
   //# Arbitrate & forward
   //############

   reg            ready;
   reg [102:0]    fifo_data;

   // priority-based ready signals
   wire           rr_ready = ~emrr_empty & ~emm_tx_wr_wait;
   wire           rq_ready = ~emrq_empty & ~emm_tx_rd_wait & ~rr_ready;
   wire           wr_ready = ~emwr_empty & ~emm_tx_wr_wait & ~rr_ready & ~rq_ready;

   // FIFO read enables, when we're idle or done with the current datum
   wire           emrr_rd_en = rr_ready & (~ready | emtx_ack);
   wire           emrq_rd_en = rq_ready & (~ready | emtx_ack);
   wire           emwr_rd_en = wr_ready & (~ready | emtx_ack);
   
   always @ (posedge clock) begin
      if( reset ) begin

         ready     <= 1'b0;
         fifo_data <= 'd0;

      end else begin

         if( emrr_rd_en ) begin

            ready <= 1'b1;
            fifo_data <= emrr_rd_data;

         end else if( emrq_rd_en ) begin

            ready <= 1'b1;
            fifo_data <= emrq_rd_data;

         end else if( emwr_rd_en ) begin

            ready <= 1'b1;
            fifo_data <= emwr_rd_data;

         end else if( emtx_ack ) begin

            ready <= 1'b0;

         end
      end // else: !if( reset )
   end // always @ (posedge clock)
      
   //#############################
   //# Break-out the emesh signals
   //#############################
   
   assign emm_tx_access   = ready;
   assign emm_tx_write    = fifo_data[102];
   assign emm_tx_datamode = fifo_data[101:100];
   assign emm_tx_ctrlmode = fifo_data[99:96];
   assign emm_tx_dstaddr  = fifo_data[95:64];
   assign emm_tx_srcaddr  = fifo_data[63:32];
   assign emm_tx_data     = fifo_data[31:0];

endmodule // earb
