/*
  File: axi_master_wr.v
 
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
module axi_master_wr (/*AUTOARG*/
   // Outputs
   awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot,
   awvalid, wid, wdata, wstrb, wlast, wvalid, bready,
   emesh_wr_wait_inb,
   // Inputs
   aclk, eclk, reset, awready, wready, bid, bresp, bvalid,
   emesh_access_outb, emesh_write_outb, emesh_datamode_outb,
   emesh_ctrlmode_outb, emesh_dstaddr_outb, emesh_srcaddr_outb,
   emesh_data_outb
   );

   parameter MIDW = 6; //ID Width
   parameter MAW  = 32; //Address Bus Width
   parameter MDW  = 64; //Data Bus Width
   parameter ACH = MAW+2; //Width of all used Write Address Signals
   parameter AFW = 4;  //Address channel Fifo address width
   parameter DFW = 4;  //Data channel Fifo address width
   parameter DCH = MDW+8; //Width of all used Write Data Signals 
   parameter STW = 8;  //Number of strobes

   //#########
   //# Inputs
   //#########

   // global signals
   input aclk;     // clock source of the axi bus
   input eclk;   // clock source of emesh interface
   input reset;  // reset 

   //########################
   //# Write address channel
   //########################
   input            awready; //write address ready
   
   //########################
   //# Write data channel
   //########################
   input 	    wready; //write ready

   //#########################
   //# Write response channel
   //#########################
   input [MIDW-1:0]  bid;   //response ID tag
   input [1:0] 	    bresp; //write response
   input 	    bvalid;//write response valid
      
   //##############################
   //# From the emesh interface
   //##############################
   input 	    emesh_access_outb;
   input 	    emesh_write_outb;
   input [1:0] 	    emesh_datamode_outb;
   input [3:0] 	    emesh_ctrlmode_outb;
   input [31:0]     emesh_dstaddr_outb;
   input [31:0]     emesh_srcaddr_outb;
   input [31:0]     emesh_data_outb;   
   
   //##########
   //# Outputs
   //##########

   //########################
   //# Write address channel
   //########################
   output [MIDW-1:0] awid;    //write address ID
   output [MAW-1:0]  awaddr;  //write address
   output [3:0]     awlen;   //burst lenght (the number of data transfers)
   output [2:0]     awsize;  //burst size (the size of each transfer)
   output [1:0]     awburst; //burst type
   output [1:0]     awlock;  //lock type (atomic characteristics)
   output [3:0]     awcache; //memory type
   output [2:0]     awprot;  //protection type
   output 	    awvalid; //write address valid
      
   //########################
   //# Write data channel
   //########################
   output [MIDW-1:0] wid;   //write ID tag (supported only in AXI3)
   output [MDW-1:0]  wdata; //write data
   output [STW-1:0] wstrb; //write strobes
   output 	    wlast; //write last, indicates the last transfer in burst
   output 	    wvalid;//write valid
   
   //########################
   // Write response channel
   //########################
   output 	    bready;//response ready
   
   //##############################
   //# To the emesh interface
   //##############################
   output 	    emesh_wr_wait_inb;  

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#########
   //# Regs
   //#########
   reg [33:0] 	    addr_reg;
   reg [63:0] 	    data_reg;
   reg 		    emesh_wr_access_reg;
   reg 		    ach_fifo_empty_reg;
   reg [ACH-1:0]    ach_fifo_reg;
   reg [63:0] 	    realgn_byte;
   reg [63:0] 	    realgn_hword;
   reg 		    dch_fifo_empty_reg;
   reg [DCH-1:0]    dch_fifo_reg;
   reg [7:0] 	    wstrb_hword;
   reg [7:0] 	    wstrb_byte;
      
   //#########
   //# Wires
   //#########
   wire 	    emesh_wr_access;
   wire [ACH-1:0]   ach_fifo_in;
   wire [ACH-1:0]   ach_fifo_out;
   wire 	    ach_fifo_wr;
   wire 	    ach_fifo_rd;
   wire 	    ach_fifo_full;
   wire 	    ach_fifo_empty;
   wire 	    ach_advance;
   wire 	    awvalid_awready;
   wire [2:0] 	    realgn_ctrl;
   wire 	    byte_realgn;
   wire 	    hword_realgn;
   wire 	    word_realgn;
   wire [63:0] 	    realgn_word;
   wire [63:0] 	    data_realgn;
   wire [DCH-1:0]   dch_fifo_in;
   wire [DCH-1:0]   dch_fifo_out;
   wire 	    dch_fifo_wr;
   wire 	    dch_fifo_rd;
   wire 	    dch_fifo_empty;
   wire 	    dch_advance;
   wire 	    wvalid_wready;
   wire [7:0] 	    wstrb_realgn;
   wire [7:0] 	    wstrb_word;
   wire 	    dch_fifo_full;
   
   
   //# Incoming transaction should be sampled to prevent timing issues
   assign emesh_wr_wait_inb = ach_fifo_full | dch_fifo_full;

   assign emesh_wr_access = emesh_access_outb & emesh_write_outb &
                                               ~emesh_wr_wait_inb;

   always @ (posedge eclk)
     if (emesh_wr_access)
       addr_reg[33:0] <= {emesh_dstaddr_outb[31:0],emesh_datamode_outb[1:0]};

   always @ (posedge eclk)
     if (emesh_wr_access)
       data_reg[63:0] <= {emesh_srcaddr_outb[31:0],emesh_data_outb[31:0]};
 
   always @ (posedge eclk or posedge reset)
     if(reset)
       emesh_wr_access_reg <= 1'b0;
     else if(~emesh_wr_wait_inb)
       emesh_wr_access_reg <= emesh_wr_access;
   
   //#######################################
   //# Address channel synchronization FIFO
   //#######################################

   assign ach_fifo_in[ACH-1:0] = addr_reg[33:0];
   assign ach_fifo_wr          = emesh_wr_access_reg & ~emesh_wr_wait_inb;
   assign ach_fifo_rd          = ~ach_fifo_empty & (~awvalid | awvalid_awready);
   assign ach_advance          = awvalid_awready | ~awvalid;
   
   
   /*fifo AUTO_TEMPLATE(.rd_clk        (aclk),
                        .wr_clk        (eclk),
                        .wr_data       (ach_fifo_in[ACH-1:0]),
                        .rd_data       (ach_fifo_out[ACH-1:0]), 
                        .rd_fifo_empty (ach_fifo_empty),
                        .wr_fifo_full  (ach_fifo_full),
                        .wr_write      (ach_fifo_wr),
                        .rd_read       (ach_fifo_rd),
                       );
    */

   fifo #(.DW(ACH), .AW(AFW)) fifo_ach(/*AUTOINST*/
				       // Outputs
				       .rd_data		(ach_fifo_out[ACH-1:0]), // Templated
				       .rd_fifo_empty	(ach_fifo_empty), // Templated
				       .wr_fifo_full	(ach_fifo_full), // Templated
				       // Inputs
				       .reset		(reset),
				       .wr_clk		(eclk),		 // Templated
				       .rd_clk		(aclk),		 // Templated
				       .wr_write	(ach_fifo_wr),	 // Templated
				       .wr_data		(ach_fifo_in[ACH-1:0]), // Templated
				       .rd_read		(ach_fifo_rd));	 // Templated
   
   //# The data is sampled after exiting FIFO to prevent timing issues
   always @ (posedge aclk or posedge reset)
     if(reset)
       ach_fifo_empty_reg <= 1'b1;
     else if(ach_advance)
       ach_fifo_empty_reg <= ach_fifo_empty;

   always @ (posedge aclk)
     if (ach_advance)
       ach_fifo_reg[ACH-1:0] <= ach_fifo_out[ACH-1:0];

   assign awid[MIDW-1:0]  = {(MIDW){1'b0}};
   assign awaddr[MAW-1:0] = ach_fifo_reg[ACH-1:2];
   assign awlen[3:0]     = 4'b0000;
   assign awsize[2:0]    = {1'b0,ach_fifo_reg[1:0]};
   assign awburst[1:0]   = 2'b01;
   assign awlock[1:0]    = 2'b00;
   assign awcache[3:0]   = 4'b0000;
   assign awprot[2:0]    = 3'b000;  //unprivileged, secured
   assign awvalid        = ~ach_fifo_empty_reg;

   assign awvalid_awready = awvalid & awready;
   
   //#######################################
   //# Data channel synchronization FIFO
   //#######################################

   assign realgn_ctrl[2:0]  = addr_reg[4:2];
   assign byte_realgn       = (addr_reg[1:0] == 2'b00);
   assign hword_realgn      = (addr_reg[1:0] == 2'b01);
   assign word_realgn       = (addr_reg[1:0] == 2'b10);

   always @ (realgn_ctrl[2:0] or data_reg[7:0])
     begin
       casez (realgn_ctrl[2:0])
	 3'b000 : realgn_byte[63:0] = {{(56){1'b0}},data_reg[7:0]             };
	 3'b001 : realgn_byte[63:0] = {{(48){1'b0}},data_reg[7:0],{( 8){1'b0}}};
	 3'b010 : realgn_byte[63:0] = {{(40){1'b0}},data_reg[7:0],{(16){1'b0}}};
	 3'b011 : realgn_byte[63:0] = {{(32){1'b0}},data_reg[7:0],{(24){1'b0}}};
	 3'b100 : realgn_byte[63:0] = {{(24){1'b0}},data_reg[7:0],{(32){1'b0}}};
	 3'b101 : realgn_byte[63:0] = {{(16){1'b0}},data_reg[7:0],{(40){1'b0}}};
	 3'b110 : realgn_byte[63:0] = {{(8){1'b0}},data_reg[7:0] ,{(48){1'b0}}};
	 3'b111 : realgn_byte[63:0] = {            data_reg[7:0] ,{(56){1'b0}}};
	 default: realgn_byte[63:0] = {{(56){1'b0}},data_reg[7:0]};
       endcase // casez (realgn_ctrl[2:0])
     end // always @ (realgn_ctrl[2:0])
   
   always @ (realgn_ctrl[2:1] or data_reg[15:0])
     begin
      casez (realgn_ctrl[2:1])
	2'b00 : realgn_hword[63:0] = {{(48){1'b0}},data_reg[15:0]};
	2'b01 : realgn_hword[63:0] = {{(32){1'b0}},data_reg[15:0],{(16){1'b0}}};
	2'b10 : realgn_hword[63:0] = {{(16){1'b0}},data_reg[15:0],{(32){1'b0}}};
	2'b11 : realgn_hword[63:0] = {             data_reg[15:0],{(48){1'b0}}};
	default: realgn_hword[63:0] = {{(48){1'b0}},data_reg[15:0]};
      endcase // casez (realgn_ctrl[2:1])
     end
   
   assign realgn_word[63:0] = realgn_ctrl[2] ? {data_reg[31:0],{(32){1'b0}}} :
			                       {{(32){1'b0}},data_reg[31:0]};

   assign data_realgn[63:0] = byte_realgn  ? realgn_byte[63:0] :
			      hword_realgn ? realgn_hword[63:0]:
			      word_realgn  ? realgn_word[63:0] :
			                     data_reg[63:0];

   //Write Strobes creation
   always @ (realgn_ctrl[2:0])
     begin
       casez (realgn_ctrl[2:0])
	 3'b000 : wstrb_byte[7:0] = 8'b00000001;
	 3'b001 : wstrb_byte[7:0] = 8'b00000010;
	 3'b010 : wstrb_byte[7:0] = 8'b00000100;
	 3'b011 : wstrb_byte[7:0] = 8'b00001000;
	 3'b100 : wstrb_byte[7:0] = 8'b00010000;
	 3'b101 : wstrb_byte[7:0] = 8'b00100000;
	 3'b110 : wstrb_byte[7:0] = 8'b01000000;
	 3'b111 : wstrb_byte[7:0] = 8'b10000000;
	 default: wstrb_byte[7:0] = 8'b00000001;
       endcase // casez (realgn_ctrl[2:0])
     end // always @ (realgn_ctrl[2:0])
   
   always @ (realgn_ctrl[2:1])
     begin
      casez (realgn_ctrl[2:1])
	2'b00 : wstrb_hword[7:0]  = 8'b00000011;
	2'b01 : wstrb_hword[7:0]  = 8'b00001100;
	2'b10 : wstrb_hword[7:0]  = 8'b00110000;
	2'b11 : wstrb_hword[7:0]  = 8'b11000000;
	default: wstrb_hword[7:0] = 8'b00000011;
      endcase // casez (realgn_ctrl[2:1])
     end
   
   assign wstrb_word[7:0] = realgn_ctrl[2] ? 8'b11110000 : 8'b00001111;
   
   assign wstrb_realgn[7:0] = byte_realgn  ? wstrb_byte[7:0] :
			      hword_realgn ? wstrb_hword[7:0]:
			      word_realgn  ? wstrb_word[7:0] : {(8){1'b1}};
   
   assign dch_fifo_in[DCH-1:0] = {data_realgn[63:0],wstrb_realgn[7:0]};
   assign dch_fifo_wr          = emesh_wr_access_reg & ~emesh_wr_wait_inb;
   assign dch_fifo_rd          = ~dch_fifo_empty & (~wvalid | wvalid_wready);
   assign dch_advance          = wvalid_wready | ~wvalid;
      
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
   
   assign wid[MIDW-1:0]   = {(MIDW){1'b0}};
   assign wdata[MDW-1:0]  = dch_fifo_reg[DCH-1:8];
   assign wstrb[STW-1:0] = dch_fifo_reg[7:0];
   assign wlast          = 1'b1;
   assign wvalid         = ~dch_fifo_empty_reg;

   assign wvalid_wready  = wvalid & wready;

   assign bready = 1'b1;
   
endmodule // axi_master_wr
