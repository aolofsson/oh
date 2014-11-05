/*
  File: axi_slave_rd.v
 
  This file is part of the Parallella FPGA Reference Design.

  Copyright (C) 2013 Adapteva, Inc.
  Contributed by Roman Trogan <support@adapteva.com>

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
//# Limitations:
//# 1. Read burst cannot cross single core boundaries

module axi_slave_rd (/*AUTOARG*/
   // Outputs
   arready, rid, rdata, rresp, rlast, rvalid, emesh_access_inb,
   emesh_write_inb, emesh_datamode_inb, emesh_ctrlmode_inb,
   emesh_dstaddr_inb, emesh_srcaddr_inb, emesh_data_inb,
   emesh_wr_wait_inb,
   // Inputs
   aclk, eclk, reset, arid, araddr, arlen, arsize, arburst, arlock,
   arcache, arprot, arvalid, rready, emesh_access_outb,
   emesh_write_outb, emesh_datamode_outb, emesh_ctrlmode_outb,
   emesh_dstaddr_outb, emesh_srcaddr_outb, emesh_data_outb,
   emesh_rd_wait_outb
   );

   parameter SIDW = 12; //ID Width
   parameter SAW  = 32; //Address Bus Width
   parameter SDW  = 32; //Data Bus Width
   parameter ACH = SAW+SIDW+5; //Width of all used Read Address Signals
   parameter DFW = 4;  //Data channel Fifo address width
   parameter DCH = SDW+SIDW+1; //Width of all used Read Data Signals 

   //#########
   //# Inputs
   //#########

   // global signals
   input aclk;   // clock source of the axi bus
   input eclk;   // clock source of emesh interface
   input reset;  // reset 
   
   //########################
   //# Read address channel
   //########################
   input [SIDW-1:0] arid;   //read address ID
   input [SAW-1:0]  araddr; //read address
   input [3:0]     arlen;   //burst lenght (the number of data transfers)
   input [2:0]     arsize;  //burst size (the size of each transfer)
   input [1:0]     arburst; //burst type
   input [1:0]     arlock;  //lock type (atomic characteristics)
   input [3:0]     arcache; //memory type
   input [2:0]     arprot;  //protection type
   input 	   arvalid; //write address valid

   //########################
   //# Read data channel
   //########################
   input 	   rready; //read ready
   
   //##############################
   //# From the emesh interface
   //##############################
   input 	   emesh_access_outb;
   input 	   emesh_write_outb;
   input [1:0] 	   emesh_datamode_outb;
   input [3:0] 	   emesh_ctrlmode_outb;
   input [31:0]    emesh_dstaddr_outb;
   input [31:0]    emesh_srcaddr_outb;
   input [31:0]    emesh_data_outb;   
   input 	   emesh_rd_wait_outb; 

   //##########
   //# Outputs
   //##########

   //########################
   //# Read address channel
   //########################
   output 	   arready;//read address ready

   //########################
   //# Read data channel
   //########################
   output [SIDW-1:0] rid;  //read ID tag (must match arid of the transaction)
   output [SDW-1:0]  rdata;//read data
   output [1:0]     rresp; //read response
   output 	    rlast; //read last, indicates the last transfer in burst
   output 	    rvalid;//read valid

   //##############################
   //# To the emesh interface
   //##############################
   output 	    emesh_access_inb;
   output 	    emesh_write_inb;
   output [1:0]     emesh_datamode_inb;
   output [3:0]     emesh_ctrlmode_inb;
   output [31:0]    emesh_dstaddr_inb;
   output [31:0]    emesh_srcaddr_inb;
   output [31:0]    emesh_data_inb;  
   output 	    emesh_wr_wait_inb;  

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#########
   //# Regs
   //#########
   reg [3:0] 	    tran_len;
   reg 		    tran_go_reg;
   reg [SIDW+5:0]   tran_info_reg;
   reg 		    tran_last_reg;
         
   reg [31:0] 	    dstaddr_reg;
   reg [31:0] 	    data_reg;
   reg 		    emesh_wr_access_reg;
   reg [31:0] 	    realgn_byte;
   reg 		    dch_fifo_empty_reg;
   reg [DCH-1:0]    dch_fifo_reg;
      
   //#########
   //# Wires
   //#########
   wire 	    arready;

   wire 	    tran_go;
   wire 	    tran_stall;
   wire 	    tran_last_int;
   wire 	    tran_last;//Indicates last data of burst (out of fifo_dch)
   wire [SAW-1:0]    tran_addr;
   wire [1:0] 	    tran_mode;
   wire [SIDW-1:0]   arid_ec;
   wire [3:0] 	    arlen_ec;
   wire [3:0] 	    arlen_new;
   wire  	    arlen_dec;
   wire [3:0] 	    arlen_upd;
   wire 	    rd_last;
   wire [2:0] 	    dalgn_ctrl;
   wire 	    byte_tran;
   wire 	    hword_tran;
   wire 	    word_tran;
   wire [SIDW+5:0]   tran_info;
      
   wire 	    emesh_wr_access;
   wire 	    dch_fifo_full;
   wire [2:0] 	    realgn_ctrl;
   wire [31:0] 	    realgn_hword;
   wire 	    byte_realgn;
   wire 	    hword_realgn;
//   wire 	    word_realgn;
   wire [31:0] 	    data_realgn;
   wire [SIDW-1:0]   tran_id;
   wire 	    last_tran;
   wire [DCH-1:0]   dch_fifo_in;
   wire 	    dch_fifo_wr;
   wire 	    dch_fifo_rd;
   wire 	    dch_fifo_empty;
   wire [DCH-1:0]   dch_fifo_out;
   wire 	    rvalid_rready;
   wire 	    dch_advance;
   wire 	    new_burst;
      
   //#######################################
   //# Address channel synchronization FIFO
   //#######################################

   /*axi_slave_addrch AUTO_TEMPLATE(.aclk           (aclk),
                                    .addr           (araddr[]),
                                    .ach_fifo_empty (),
                                    .a\(.*\)        (ar\1[]),
                                    .new_addr_sel   (new_burst),
                                   );
    */                                    

   axi_slave_addrch axi_slave_addrch(/*AUTOINST*/
				     // Outputs
				     .aready		(arready),	 // Templated
				     .ach_fifo_empty	(),		 // Templated
				     .tran_addr		(tran_addr[SAW-1:0]),
				     .tran_mode		(tran_mode[1:0]),
				     .dalgn_ctrl	(dalgn_ctrl[2:0]),
				     .byte_tran		(byte_tran),
				     .hword_tran	(hword_tran),
				     .word_tran		(word_tran),
				     .aid_ec		(arid_ec[SIDW-1:0]), // Templated
				     .alen_ec		(arlen_ec[3:0]), // Templated
				     .new_addr_sel	(new_burst),	 // Templated
				     // Inputs
				     .aclk		(aclk),		 // Templated
				     .eclk		(eclk),
				     .reset		(reset),
				     .avalid		(arvalid),	 // Templated
				     .addr		(araddr[SAW-1:0]), // Templated
				     .aid		(arid[SIDW-1:0]), // Templated
				     .alen		(arlen[3:0]),	 // Templated
				     .asize		(arsize[2:0]),	 // Templated
				     .aburst		(arburst[1:0]),	 // Templated
				     .tran_last		(tran_last),
				     .tran_stall	(tran_stall),
				     .tran_go		(tran_go));
   
   //########################
   //# AXI-EMESH conversion
   //########################

   assign tran_go        = |(arlen_new[3:0]);
   assign tran_last_int  = dch_fifo_wr & last_tran;
   assign tran_last      = tran_last_reg & ~tran_stall;
      
   always @ (posedge eclk or posedge reset)
     if(reset)
       tran_last_reg <= 1'b0;
     else if(tran_last_int | ~tran_stall)
       tran_last_reg <= tran_last_int;

   always @ (posedge eclk or posedge reset)
     if(reset)
       tran_len[3:0] <= 4'b0000;
     else if(tran_go & ~tran_stall)
       tran_len[3:0] <= arlen_new[3:0];

   always @ (posedge eclk or posedge reset)
     if(reset)
       tran_go_reg <= 1'b0;
     else if(~tran_stall)
       tran_go_reg <= tran_go;

   assign arlen_dec = |(tran_len[3:0]);
   
   assign arlen_upd[3:0] = {(4){arlen_dec}} & (tran_len[3:0] - 4'b0001);
   
   assign arlen_new[3:0] = new_burst ? arlen_ec[3:0] : arlen_upd[3:0];

   assign rd_last  = (tran_len[3:0] == 4'b0001);

   assign tran_info[SIDW+5:0] = {arid_ec[SIDW-1:0],dalgn_ctrl[2:0],byte_tran,
				hword_tran,word_tran};

   always @ (posedge eclk)
     if(tran_go & ~tran_stall)
       tran_info_reg[SIDW+5:0] <= tran_info[SIDW+5:0];
   
   //#############################
   //# Emesh transaction creation
   //#############################

   assign emesh_dstaddr_inb[31:0] = tran_addr[SAW-1:0];

   assign emesh_srcaddr_inb[31:0] = {`AXI_COORD,{(13-SIDW){1'b0}},
				     tran_info_reg[SIDW+5:0], rd_last};
   assign emesh_data_inb[31:0]    = 32'h00000000;
   assign emesh_datamode_inb[1:0] = tran_mode[1:0];
   assign emesh_ctrlmode_inb[3:0] = 4'b0000;
   assign emesh_write_inb         = 1'b0;
   assign emesh_access_inb        = tran_go_reg & ~tran_stall;

   //#######################################
   //# Data channel synchronization FIFO
   //#######################################

   assign emesh_wr_wait_inb = dch_fifo_full;

   //# Incoming transaction should be sampled to prevent timing issues
   assign emesh_wr_access = emesh_access_outb & emesh_write_outb &
                                               ~emesh_wr_wait_inb;

   always @ (posedge eclk)
     if (emesh_wr_access)
       dstaddr_reg[31:0] <= emesh_dstaddr_outb[31:0];

   always @ (posedge eclk)
     if (emesh_wr_access)
       data_reg[31:0] <= emesh_data_outb[31:0];
 
   always @ (posedge eclk or posedge reset)
     if(reset)
       emesh_wr_access_reg <= 1'b0;
     else if(~emesh_wr_wait_inb)
       emesh_wr_access_reg <= emesh_wr_access;

   //# RID
   assign tran_id[SIDW-1:0]  = dstaddr_reg[SIDW+6:7];
   
   //# Data Re-alignment from the EMESH protocol
   assign realgn_ctrl[2:0]  = dstaddr_reg[6:4];
   assign byte_realgn       = dstaddr_reg[3];
   assign hword_realgn      = dstaddr_reg[2];
//   assign word_realgn       = dstaddr_reg[1];

   //# Last transfer
   assign last_tran         = dstaddr_reg[0];
   
   always @ (realgn_ctrl[1:0] or data_reg[7:0])
     begin
       casez (realgn_ctrl[1:0])
	 2'b00 : realgn_byte[31:0] = {{(24){1'b0}},data_reg[7:0]             };
	 2'b01 : realgn_byte[31:0] = {{(16){1'b0}},data_reg[7:0],{( 8){1'b0}}};
	 2'b10 : realgn_byte[31:0] = {{(8){1'b0}},data_reg[7:0],{(16){1'b0}}};
	 2'b11 : realgn_byte[31:0] = {data_reg[7:0],{(24){1'b0}}};
	 default: realgn_byte[31:0] = {{(24){1'b0}},data_reg[7:0]};
       endcase // casez (realgn_ctrl[1:0])
     end
   
   assign realgn_hword[31:0] = realgn_ctrl[1] ? {data_reg[15:0],{(16){1'b0}}} :
			                       {{(16){1'b0}},data_reg[15:0]};
   
   assign data_realgn[31:0] = byte_realgn  ? realgn_byte[31:0] :
			      hword_realgn ? realgn_hword[31:0]:
			                     data_reg[31:0];

   
   assign dch_fifo_in[DCH-1:0] = {data_realgn[31:0],tran_id[SIDW-1:0],last_tran};
   assign dch_fifo_wr          = emesh_wr_access_reg & ~dch_fifo_full;
   assign dch_fifo_rd          = ~dch_fifo_empty & (~rvalid | rvalid_rready);
   assign dch_advance          = rvalid_rready | ~rvalid;
      
   /*fifo AUTO_TEMPLATE(.rd_clk        (aclk),
                        .wr_clk        (eclk),
                        .wr_data       (dch_fifo_in[DCH-1:0]),
                        .rd_data       (dch_fifo_out[DCH-1:0]), 
                        .rd_fifo_empty (dch_fifo_empty),
                        .wr_fifo_full  (dch_fifo_full),
                        .wr_write      (dch_fifo_wr),
                        .rd_read       (dch_fifo_rd),
                       );
    */

   fifo #(.DW(DCH), .AW(DFW)) fifo_dch(/*AUTOINST*/
				       // Outputs
				       .rd_data		(dch_fifo_out[DCH-1:0]), // Templated
				       .rd_fifo_empty	(dch_fifo_empty), // Templated
				       .wr_fifo_full	(dch_fifo_full), // Templated
				       // Inputs
				       .reset		(reset),
				       .wr_clk		(eclk),		 // Templated
				       .rd_clk		(aclk),		 // Templated
				       .wr_write	(dch_fifo_wr),	 // Templated
				       .wr_data		(dch_fifo_in[DCH-1:0]), // Templated
				       .rd_read		(dch_fifo_rd));	 // Templated
   
   
   //# The data is sampled after exiting FIFO to prevent timing issues
   always @ (posedge aclk or posedge reset)
     if(reset)
       dch_fifo_empty_reg <= 1'b1;
     else if(dch_advance)
       dch_fifo_empty_reg <= dch_fifo_empty;
   
   always @ (posedge aclk)
     if (dch_advance)
       dch_fifo_reg[DCH-1:0] <= dch_fifo_out[DCH-1:0];
   
   assign rid[SIDW-1:0]  = dch_fifo_reg[SIDW:1];
   assign rresp[1:0]    = 2'b00;
   assign rvalid        = ~dch_fifo_empty_reg;
   assign rvalid_rready = rvalid & rready;
   assign rdata[SDW-1:0] = dch_fifo_reg[DCH-1:SIDW+1];
   assign rlast         = dch_fifo_reg[0];

   //# Transaction Stall
   assign tran_stall = emesh_rd_wait_outb;
   
   
endmodule // axi_slave_rd
