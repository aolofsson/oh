/*
  File: e_rx_decoder
 
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
 EPIPHANY eMesh Filter / Distributor
 ########################################################################
 
 This block takes one eMesh input, selected from two available 
 (MMU or direct), and distributes the transactions based on type
 (write, read request, read response).
 
 */

module erx_disty (/*AUTOARG*/
   // Outputs
   emesh_rd_wait, emesh_wr_wait, emwr_wr_data, emwr_wr_en,
   emrq_wr_data, emrq_wr_en, emrr_wr_data, emrr_wr_en,
   // Inputs
   rxlclk_p, emesh_access, emesh_write, emesh_datamode,
   emesh_ctrlmode, emesh_dstaddr, emesh_srcaddr, emesh_data,
   emwr_full, emwr_prog_full, emrq_full, emrq_prog_full, emrr_full,
   emrr_prog_full, ecfg_rx_enable
   );

   parameter [11:0]  C_READ_TAG_ADDR = 12'h810;
   
   // RX clock
   input         rxlclk_p;
   
   //Inputs from MMU
   input          emesh_access;
   input          emesh_write;
   input [1:0]    emesh_datamode;
   input [3:0]    emesh_ctrlmode;
   input [31:0]   emesh_dstaddr;
   input [31:0]   emesh_srcaddr;
   input [31:0]   emesh_data;
   output         emesh_rd_wait;
   output         emesh_wr_wait;
 
   // Master FIFO port, writes
   output [102:0] emwr_wr_data;
   output         emwr_wr_en;
   input          emwr_full;       // full flags for debug only
   input          emwr_prog_full;
   
   // Master FIFO port, read requests
   output [102:0] emrq_wr_data;
   output         emrq_wr_en;
   input          emrq_full;
   input          emrq_prog_full;
   
   // Master FIFO port, read responses
   output [102:0] emrr_wr_data;
   output         emrr_wr_en;
   input          emrr_full;
   input          emrr_prog_full;

   // Control bits inputs
   input          ecfg_rx_enable;
   
   //############
   //# REGS
   //############
   
   reg            in_write;
   reg [1:0]      in_datamode;
   reg [3:0]      in_ctrlmode;
   reg [31:0]     in_dstaddr;
   reg [31:0]     in_srcaddr;
   reg [31:0]     in_data;

   reg            emwr_wr_en;
   reg            emrq_wr_en;
   reg            emrr_wr_en;

   //############
   //# WIRES
   //############

   wire [102:0]   fifo_din;
   wire [102:0]   emwr_wr_data;
   wire [102:0]   emrq_wr_data;
   wire [102:0]   emrr_wr_data;

   //############
   //# PIPELINE AND DISTRIBUTE
   //############   
   always @ (posedge rxlclk_p) 
     begin
	in_write          <= emesh_write;
        in_datamode[1:0]  <= emesh_datamode[1:0];
        in_ctrlmode[3:0]  <= emesh_ctrlmode[3:0];
        in_dstaddr[31:0]  <= emesh_dstaddr[31:0];
        in_srcaddr[31:0]  <= emesh_srcaddr[31:0];
        in_data[31:0]     <= emesh_data[31:0];
     end
	
   always @ (posedge rxlclk_p) 
     if(emesh_access) 
       begin
	  emrq_wr_en <= ~emesh_write;
          emrr_wr_en <= emesh_write & (emesh_dstaddr[31:20] == C_READ_TAG_ADDR);
          emwr_wr_en <= emesh_write & (emesh_dstaddr[31:20] != C_READ_TAG_ADDR);
       end
   
   // TODO: Why not keep the bit pattern the same as our "default" pattern??
   assign fifo_din[102:0] = {
			     in_write,
			     in_datamode[1:0],
			     in_ctrlmode[3:0],
			     in_dstaddr[31:0],
			     in_srcaddr[31:0],
			     in_data[31:0]
			     };
      
   assign emwr_wr_data[102:0] = fifo_din[102:0];
   assign emrq_wr_data[102:0] = fifo_din[102:0];
   assign emrr_wr_data[102:0] = fifo_din[102:0];
   
   //#############################
   //# Wait signal passthroughs
   //#############################
   
   assign        emesh_rd_wait = emrq_prog_full;
   assign        emesh_wr_wait = emwr_prog_full | emrr_prog_full;
   
endmodule // e_rx_decoder


