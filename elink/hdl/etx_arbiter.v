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
   emwr_rd_en, emrq_rd_en, emrr_rd_en, etx_access, etx_write,
   etx_datamode, etx_ctrlmode, etx_dstaddr, etx_srcaddr, etx_data,
   // Inputs
   tx_lclk_par, reset, emwr_fifo_access, emwr_fifo_write,
   emwr_fifo_datamode, emwr_fifo_ctrlmode, emwr_fifo_dstaddr,
   emwr_fifo_data, emwr_fifo_srcaddr, emrq_fifo_access,
   emrq_fifo_write, emrq_fifo_datamode, emrq_fifo_ctrlmode,
   emrq_fifo_dstaddr, emrq_fifo_data, emrq_fifo_srcaddr,
   emrr_fifo_access, emrr_fifo_write, emrr_fifo_datamode,
   emrr_fifo_ctrlmode, emrr_fifo_dstaddr, emrr_fifo_data,
   emrr_fifo_srcaddr, etx_rd_wait, etx_wr_wait, etx_ack
   );

   // tx clock
   input          tx_lclk_par;
   input          reset;
   
   //Write Request (from slave)
   input 	  emwr_fifo_access;
   input 	  emwr_fifo_write;
   input [1:0] 	  emwr_fifo_datamode;
   input [3:0] 	  emwr_fifo_ctrlmode;
   input [31:0]   emwr_fifo_dstaddr;
   input [31:0]   emwr_fifo_data;
   input [31:0]   emwr_fifo_srcaddr;
   output         emwr_rd_en;
   
   //Read Request (from slave)
   input 	  emrq_fifo_access;
   input 	  emrq_fifo_write;
   input [1:0] 	  emrq_fifo_datamode;
   input [3:0] 	  emrq_fifo_ctrlmode;
   input [31:0]   emrq_fifo_dstaddr;
   input [31:0]   emrq_fifo_data;
   input [31:0]   emrq_fifo_srcaddr;
   output         emrq_rd_en;
   
   //Read Response (from master)
   input 	  emrr_fifo_access;
   input 	  emrr_fifo_write;
   input [1:0] 	  emrr_fifo_datamode;
   input [3:0] 	  emrr_fifo_ctrlmode;
   input [31:0]   emrr_fifo_dstaddr;
   input [31:0]   emrr_fifo_data;
   input [31:0]   emrr_fifo_srcaddr;
   output         emrr_rd_en;

   // eMesh master port, to TX
   output         etx_access;
   output         etx_write;
   output [1:0]   etx_datamode;
   output [3:0]   etx_ctrlmode;
   output [31:0]  etx_dstaddr;
   output [31:0]  etx_srcaddr;
   output [31:0]  etx_data;
   input          etx_rd_wait;
   input          etx_wr_wait;

   // Ack from TX protocol module
   input          etx_ack;

   //regs
   reg            ready;
   reg 		  etx_write;
   reg [1:0] 	  etx_datamode;
   reg [3:0] 	  etx_ctrlmode;
   reg [31:0] 	  etx_dstaddr;
   reg [31:0] 	  etx_srcaddr;
   reg [31:0] 	  etx_data;

   //wires
   wire 	  rr_ready;
   wire 	  rq_ready;
   wire 	  wr_ready;
   wire           emrr_rd_en;
   wire 	  emrq_rd_en;
   wire 	  emwr_rd_en;


   //############
   //# Arbitrate & forward
   //############

   // priority-based ready signals
   assign     wr_ready = emwr_fifo_access & ~etx_wr_wait;                        //highest
   assign     rq_ready = emrq_fifo_access & ~etx_rd_wait & ~wr_ready;
   assign     rr_ready = emrr_fifo_access & ~etx_wr_wait & ~wr_ready & ~rq_ready;//lowest
   
   // FIFO read enables, when we're idle or done with the current datum
   assign     emrr_rd_en = rr_ready & (~ready | etx_ack);
   assign     emrq_rd_en = rq_ready & (~ready | etx_ack);
   assign     emwr_rd_en = wr_ready & (~ready | etx_ack);
   
   always @ (posedge tx_lclk_par)
      if( reset ) 
	begin
           ready             <= 1'b0;
	   etx_write         <= 1'b0;
	   etx_datamode[1:0] <= 2'b0;
	   etx_ctrlmode[3:0] <= 4'b0;
	   etx_dstaddr[31:0] <= 32'b0;
	   etx_data[31:0]    <= 32'b0;
	   etx_srcaddr[31:0] <= 32'b0;
	end 
      else 
	begin
	   etx_write  <= emrr_rd_en ? emrr_fifo_write :
			 emrq_rd_en ? emrq_fifo_write :
			              emwr_fifo_write;

	   etx_datamode[1:0] <= emrr_rd_en ? emrr_fifo_datamode[1:0] :
				emrq_rd_en ? emrq_fifo_datamode[1:0] :
			        emwr_fifo_datamode[1:0];
	   
	   
	   etx_ctrlmode[3:0] <= emrr_rd_en ? emrr_fifo_ctrlmode[3:0] :
				emrq_rd_en ? emrq_fifo_ctrlmode[3:0] :
			        emwr_fifo_ctrlmode[3:0];


	   etx_dstaddr[31:0] <= emrr_rd_en ? emrr_fifo_dstaddr[31:0] :
				emrq_rd_en ? emrq_fifo_dstaddr[31:0] :
			        emwr_fifo_dstaddr[31:0];


	   etx_data[31:0] <= emrr_rd_en ? emrr_fifo_data[31:0] :
			     emrq_rd_en ? emrq_fifo_data[31:0] :
			     emwr_fifo_data[31:0];
	   
	   
	   etx_srcaddr[31:0] <= emrr_rd_en ? emrr_fifo_srcaddr[31:0] :
				emrq_rd_en ? emrq_fifo_srcaddr[31:0] :
				emwr_fifo_srcaddr[31:0];
	   
	   ready <= emrr_rd_en | emrq_rd_en | emwr_rd_en | ~etx_ack;//TODO: check last term
	end // else: !if( reset )

   assign etx_access = ready;
   
      
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
