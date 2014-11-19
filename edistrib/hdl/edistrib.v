/*
  File: edistrib.v
 
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

module edistrib (/*AUTOARG*/
   // Outputs
   ems_dir_rd_wait, ems_dir_wr_wait, emwr_wr_data, emwr_wr_en,
   emrq_wr_data, emrq_wr_en, emrr_wr_data, emrr_wr_en,
   // Inputs
   rxlclk, ems_dir_access, ems_dir_write, ems_dir_datamode,
   ems_dir_ctrlmode, ems_dir_dstaddr, ems_dir_srcaddr, ems_dir_data,
   ems_mmu_access, ems_mmu_write, ems_mmu_datamode, ems_mmu_ctrlmode,
   ems_mmu_dstaddr, ems_mmu_srcaddr, ems_mmu_data, emwr_full,
   emwr_prog_full, emrq_full, emrq_prog_full, emrr_full,
   emrr_prog_full, ecfg_rx_enable, ecfg_rx_mmu_mode
   );

   parameter [11:0]  C_READ_TAG_ADDR = 12'h810;
   
   // RX clock
   input         rxlclk;
   
   // Direct slave port (with wait signals)
   input         ems_dir_access;
   input         ems_dir_write;
   input [1:0]   ems_dir_datamode;
   input [3:0]   ems_dir_ctrlmode;
   input [31:0]  ems_dir_dstaddr;
   input [31:0]  ems_dir_srcaddr;
   input [31:0]  ems_dir_data;
   output        ems_dir_rd_wait;
   output        ems_dir_wr_wait;

   // MMU slave port (no wait signals)
   input         ems_mmu_access;
   input         ems_mmu_write;
   input [1:0]   ems_mmu_datamode;
   input [3:0]   ems_mmu_ctrlmode;
   input [31:0]  ems_mmu_dstaddr;
   input [31:0]  ems_mmu_srcaddr;
   input [31:0]  ems_mmu_data;

   // Master FIFO port, writes
   output [102:0] emwr_wr_data;
   output         emwr_wr_en;
   input          emwr_full;       // full flags for error checking
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
   input          ecfg_rx_mmu_mode;
   
   //############
   //# Distribute based on type & read-response tag
   //############

   reg [1:0]      rxmmu_sync;
   wire           rxmmu = rxmmu_sync[0];
   
   reg            in_write;
   reg [1:0]      in_datamode;
   reg [3:0]      in_ctrlmode;
   reg [31:0]     in_dstaddr;
   reg [31:0]     in_srcaddr;
   reg [31:0]     in_data;

   reg            emwr_wr_en;
   reg            emrq_wr_en;
   reg            emrr_wr_en;

   wire [102:0]   fifo_din;
   wire [102:0]   emwr_wr_data;
   wire [102:0]   emrq_wr_data;
   wire [102:0]   emrr_wr_data;
   
   always @ (posedge rxlclk) begin

      rxmmu_sync <= {ecfg_rx_mmu_mode, rxmmu_sync[1]};

      if(rxmmu) begin

         in_write    <= ems_mmu_write;
         in_datamode <= ems_mmu_datamode;
         in_ctrlmode <= ems_mmu_ctrlmode;
         in_dstaddr  <= ems_mmu_dstaddr;
         in_srcaddr  <= ems_mmu_srcaddr;
         in_data     <= ems_mmu_data;

         if(ems_mmu_access) begin
            emrq_wr_en <= ~ems_mmu_write;
            emrr_wr_en <= ems_mmu_write & (ems_mmu_dstaddr[31:20] == C_READ_TAG_ADDR);
            emwr_wr_en <= ems_mmu_write & (ems_mmu_dstaddr[31:20] != C_READ_TAG_ADDR);
         end else begin
            emrq_wr_en <= 1'b0;
            emrr_wr_en <= 1'b0;
            emwr_wr_en <= 1'b0;
         end
         
      end else begin

         in_write    <= ems_dir_write;
         in_datamode <= ems_dir_datamode;
         in_ctrlmode <= ems_dir_ctrlmode;
         in_dstaddr  <= ems_dir_dstaddr;
         in_srcaddr  <= ems_dir_srcaddr;
         in_data     <= ems_dir_data;

         if(ems_dir_access) begin
            emrq_wr_en <= ~ems_dir_write;
            emrr_wr_en <= ems_dir_write & (ems_dir_dstaddr[31:20] == C_READ_TAG_ADDR);
            emwr_wr_en <= ems_dir_write & (ems_dir_dstaddr[31:20] != C_READ_TAG_ADDR);
         end else begin
            emrq_wr_en <= 1'b0;
            emrr_wr_en <= 1'b0;
            emwr_wr_en <= 1'b0;
         end
         
      end // else: !if(rxmmu)

   end // always @ (posedge rxlclk)

      // Data is the same for all.
   assign fifo_din = 
         {in_write,
          in_datamode,
          in_ctrlmode,
          in_dstaddr,
          in_srcaddr,
          in_data};
      
   assign emwr_wr_data = fifo_din;
   assign emrq_wr_data = fifo_din;
   assign emrr_wr_data = fifo_din;
   
   //#############################
   //# Wait signal passthroughs
   //#############################
   assign        ems_dir_rd_wait = emrq_prog_full;
   assign        ems_dir_wr_wait = emwr_prog_full | emrr_prog_full;
   
endmodule // edistrib
