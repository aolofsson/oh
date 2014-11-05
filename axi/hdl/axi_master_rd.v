/*
  File: axi_master_rd.v
 
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
module axi_master_rd (/*AUTOARG*/
   // Outputs
   arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot,
   arvalid, rready, emesh_access_inb, emesh_write_inb,
   emesh_datamode_inb, emesh_ctrlmode_inb, emesh_dstaddr_inb,
   emesh_srcaddr_inb, emesh_data_inb, emesh_rd_wait_inb,
   // Inputs
   aclk, eclk, reset, arready, rid, rdata, rresp, rlast, rvalid,
   emesh_access_outb, emesh_write_outb, emesh_datamode_outb,
   emesh_ctrlmode_outb, emesh_dstaddr_outb, emesh_srcaddr_outb,
   emesh_data_outb, emesh_wr_wait_outb
   );

   parameter MIDW = 6; //ID Width
   parameter MAW  = 32; //Address Bus Width
   parameter MDW  = 64; //Data Bus Width
   parameter ACH = MAW+2; //Width of all used Read Address Signals
   parameter AFW = 4;  //Address channel FIFO address width
   parameter DFW = 4;  //Data channel FIFO address width
   parameter DCH = MDW; //Width of all used Read Data Signals 
   parameter WB  = MAW+9; //Width of all used Write Back Address Signals
   parameter BFW = 4;  //Write Backl FIFO address width
   
   
   //#########
   //# Inputs
   //#########

   // global signals
   input aclk;     // clock source of the axi bus
   input eclk;   // clock source of emesh interface
   input reset;  // reset 

   //########################
   //# Read address channel
   //########################
   input 	    arready;//read address ready
   
   //########################
   //# Read data channel
   //########################
   input [MIDW-1:0]  rid;   //read ID tag 
   input [MDW-1:0]   rdata; //read data
   input [1:0] 	    rresp; //read response
   input 	    rlast; //read last, indicates the last transfer in burst
   input 	    rvalid;//read valid

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
   input 	    emesh_wr_wait_outb; 

   //##########
   //# Outputs
   //##########

   //########################
   //# Read address channel
   //########################
   output [MIDW-1:0] arid;    //read address ID
   output [MAW-1:0]  araddr;  //read address
   output [3:0]     arlen;   //burst lenght (the number of data transfers)
   output [2:0]     arsize;  //burst size (the size of each transfer)
   output [1:0]     arburst; //burst type
   output [1:0]     arlock;  //lock type (atomic characteristics)
   output [3:0]     arcache; //memory type
   output [2:0]     arprot;  //protection type
   output 	    arvalid; //write address valid
      
   //########################
   //# Read data channel
   //########################
   output 	    rready; //read ready

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
   output 	    emesh_rd_wait_inb; 
   
   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#########
   //# Regs
   //#########
   reg [33:0] 	    dstaddr_reg;
   reg [31:0] 	    srcaddr_reg;
   reg [3:0] 	    ctrlmode_reg;
   reg 		    emesh_rd_access_reg;
   reg 		    ach_fifo_empty_reg;
   reg [ACH-1:0]    ach_fifo_reg;
   reg [WB-1:0]     wb_fifo_reg;
   reg [WB-1:0]     tran_addr_mode;
   reg [DCH-1:0]    dch_fifo_in;
   reg 		    rvalid_rready_reg;
   reg [DCH-1:0]    dch_fifo_reg;
   reg [MDW-1:0]     algn_byte;
   reg [MDW-1:0]     algn_hword;
   reg [MDW-1:0]     wdata_algn_reg;
   reg 		    tran_go;
   reg 		    tran_go_reg;
      
   //#########
   //# Wires
   //#########
   wire 	    emesh_rd_access;
   wire [ACH-1:0]   ach_fifo_in;
   wire 	    ach_fifo_wr;
   wire 	    ach_fifo_rd;
   wire 	    ach_fifo_empty;
   wire 	    ach_fifo_full;
   wire 	    arvalid_arready;
   wire 	    ach_advance;
   wire [ACH-1:0]   ach_fifo_out;
   wire [WB-1:0]    wb_fifo_in;
   wire [WB-1:0]    wb_fifo_out;
   wire 	    wb_fifo_wr;
   wire 	    wb_fifo_rd;
   wire 	    wb_fifo_empty;
   wire 	    wb_fifo_full;
   wire [DCH-1:0]   dch_data_in;
   wire 	    dch_fifo_wr;
   wire 	    dch_fifo_rd;
   wire [DCH-1:0]   dch_fifo_out;
   wire 	    dch_fifo_empty;
   wire 	    dch_fifo_full;
   wire 	    rvalid_rready;
   wire [2:0] 	    dalgn_ctrl;
   wire [MDW-1:0]    algn_word;
   wire [1:0] 	    tran_mode;
   wire 	    byte_tran;
   wire 	    hword_tran;
   wire 	    word_tran;
   wire [MDW-1:0]    wdata_algn;
   
   
   //# Incoming transaction should be sampled to prevent timing issues
   assign emesh_rd_wait_inb = ach_fifo_full | wb_fifo_full;

   assign emesh_rd_access = emesh_access_outb & ~emesh_write_outb &
                                                ~emesh_rd_wait_inb;

   always @ (posedge eclk)
     if (emesh_rd_access)
       dstaddr_reg[33:0] <= {emesh_dstaddr_outb[31:0],emesh_datamode_outb[1:0]};

   always @ (posedge eclk)
     if (emesh_rd_access)
       srcaddr_reg[31:0] <= emesh_srcaddr_outb[31:0];

   always @ (posedge eclk)
     if (emesh_rd_access)
       ctrlmode_reg[3:0] <= emesh_ctrlmode_outb[3:0];
   
   always @ (posedge eclk or posedge reset)
     if(reset)
       emesh_rd_access_reg <= 1'b0;
     else if(~emesh_rd_wait_inb)
       emesh_rd_access_reg <= emesh_rd_access;

   //############################################
   //# AXI Address channel synchronization FIFO
   //############################################

   assign ach_fifo_in[ACH-1:0] = dstaddr_reg[33:0];
   assign ach_fifo_wr          = emesh_rd_access_reg & ~emesh_rd_wait_inb;
   assign ach_fifo_rd          = ~ach_fifo_empty & (~arvalid | arvalid_arready);
   assign ach_advance          = arvalid_arready | ~arvalid;
   
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

   assign arid[MIDW-1:0]  = {(MIDW){1'b0}};
   assign araddr[MAW-1:0] = ach_fifo_reg[ACH-1:2];
   assign arlen[3:0]     = 4'b0000;
   assign arsize[2:0]    = {1'b0,ach_fifo_reg[1:0]};
   assign arburst[1:0]   = 2'b01;
   assign arlock[1:0]    = 2'b00;
   assign arcache[3:0]   = 4'b0000;
   assign arprot[2:0]    = 3'b000;  //unprivileged, secured
   assign arvalid        = ~ach_fifo_empty_reg;

   assign arvalid_arready = arvalid & arready;
   
   //############################################
   //# Address FIFO of the returning transaction
   //############################################

   assign wb_fifo_in[WB-1:0] = {ctrlmode_reg[3:0],srcaddr_reg[31:0],dstaddr_reg[4:0]};
   assign wb_fifo_wr   = emesh_rd_access_reg & ~emesh_rd_wait_inb;
   assign wb_fifo_rd   = dch_fifo_rd;

   /*fifo AUTO_TEMPLATE(.rd_clk        (eclk),
                        .wr_clk        (eclk),
                        .wr_data       (wb_fifo_in[WB-1:0]),
                        .rd_data       (wb_fifo_out[WB-1:0]), 
                        .rd_fifo_empty (wb_fifo_empty),
                        .wr_fifo_full  (wb_fifo_full),
                        .wr_write      (wb_fifo_wr),
                        .rd_read       (wb_fifo_rd),
                       );
    */

   fifo #(.DW(WB), .AW(BFW)) fifo_wb(/*AUTOINST*/
				     // Outputs
				     .rd_data		(wb_fifo_out[WB-1:0]), // Templated
				     .rd_fifo_empty	(wb_fifo_empty), // Templated
				     .wr_fifo_full	(wb_fifo_full),	 // Templated
				     // Inputs
				     .reset		(reset),
				     .wr_clk		(eclk),		 // Templated
				     .rd_clk		(eclk),		 // Templated
				     .wr_write		(wb_fifo_wr),	 // Templated
				     .wr_data		(wb_fifo_in[WB-1:0]), // Templated
				     .rd_read		(wb_fifo_rd));	 // Templated
   
   //# The data is sampled after exiting FIFO to prevent timing issues
   always @ (posedge eclk)
     if(~emesh_wr_wait_outb)
       wb_fifo_reg[WB-1:0] <= wb_fifo_out[WB-1:0];

   //# To synchronize the address with the data
   always @ (posedge eclk)
     if(tran_go & ~emesh_wr_wait_outb)
       tran_addr_mode[WB-1:0] <= wb_fifo_reg[WB-1:0];

   //#######################################
   //# AXI Data channel synchronization FIFO
   //#######################################

   assign rready        = ~dch_fifo_full;
   assign rvalid_rready = rvalid & rready;
      
   assign dch_data_in[DCH-1:0] = rdata[MDW-1:0];
   assign dch_fifo_wr          = rvalid_rready_reg & ~dch_fifo_full;
   assign dch_fifo_rd          = ~(dch_fifo_empty | emesh_wr_wait_outb);

   //# The data is sampled before entering FIFO to prevent timing issues
   always @ (posedge aclk)
     if(~dch_fifo_full)
       dch_fifo_in[DCH-1:0] <= dch_data_in[DCH-1:0];

   always @ (posedge aclk or posedge reset)
     if(reset)
       rvalid_rready_reg <= 1'b0;
     else if(~dch_fifo_full)
       rvalid_rready_reg <= rvalid_rready;

   /*fifo AUTO_TEMPLATE(.rd_clk        (eclk),
                        .wr_clk        (aclk),
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
				       .wr_clk		(aclk),		 // Templated
				       .rd_clk		(eclk),		 // Templated
				       .wr_write	(dch_fifo_wr),	 // Templated
				       .wr_data		(dch_fifo_in[DCH-1:0]), // Templated
				       .rd_read		(dch_fifo_rd));	 // Templated
   
   //# The data is sampled after exiting FIFO to prevent timing issues
   always @ (posedge eclk)
     if(~emesh_wr_wait_outb)
       dch_fifo_reg[DCH-1:0] <= dch_fifo_out[DCH-1:0];

   //########################
   //# AXI-EMESH conversion
   //########################

   assign dalgn_ctrl[2:0] = wb_fifo_reg[4:2];
   assign tran_mode[1:0]  = wb_fifo_reg[1:0];
   
   //# Data Alignment for the EMESH protocol
   always @ (dalgn_ctrl[2:0] or dch_fifo_reg[63:0])
     begin
	casez (dalgn_ctrl[2:0])
	  3'b000 : algn_byte[MDW-1:0] = {{(MDW-8){1'b0}},dch_fifo_reg[7:0]};
	  3'b001 : algn_byte[MDW-1:0] = {{(MDW-8){1'b0}},dch_fifo_reg[15:8]};
	  3'b010 : algn_byte[MDW-1:0] = {{(MDW-8){1'b0}},dch_fifo_reg[23:16]};
	  3'b011 : algn_byte[MDW-1:0] = {{(MDW-8){1'b0}},dch_fifo_reg[31:24]};
	  3'b100 : algn_byte[MDW-1:0] = {{(MDW-8){1'b0}},dch_fifo_reg[39:32]};
	  3'b101 : algn_byte[MDW-1:0] = {{(MDW-8){1'b0}},dch_fifo_reg[47:40]};
	  3'b110 : algn_byte[MDW-1:0] = {{(MDW-8){1'b0}},dch_fifo_reg[55:48]};
	  3'b111 : algn_byte[MDW-1:0] = {{(MDW-8){1'b0}},dch_fifo_reg[63:56]};
	  default: algn_byte[MDW-1:0] = {{(MDW-8){1'b0}},dch_fifo_reg[7:0]};
	endcase // casez (dalgn_ctrl[2:0])
     end // always @ (dalgn_ctrl[2:0])
   
   always @ (dalgn_ctrl[2:1] or dch_fifo_reg[63:0])
     begin
	casez (dalgn_ctrl[2:1])
	  2'b00 : algn_hword[MDW-1:0] = {{(MDW-16){1'b0}},dch_fifo_reg[15:0]};
	  2'b01 : algn_hword[MDW-1:0] = {{(MDW-16){1'b0}},dch_fifo_reg[31:16]};
	  2'b10 : algn_hword[MDW-1:0] = {{(MDW-16){1'b0}},dch_fifo_reg[47:32]};
	  2'b11 : algn_hword[MDW-1:0] = {{(MDW-16){1'b0}},dch_fifo_reg[63:48]};
	  default: algn_hword[MDW-1:0] = {{(MDW-16){1'b0}},dch_fifo_reg[15:0]};
	endcase // casez (dalgn_ctrl[2:1])
     end
   
   assign algn_word[MDW-1:0] = dalgn_ctrl[2] ? 
                                    {{(MDW/2){1'b0}},dch_fifo_reg[63:32]}:
			            {{(MDW/2){1'b0}},dch_fifo_reg[31:0]};

   assign byte_tran  = (tran_mode[1:0] == 2'b00);
   assign hword_tran = (tran_mode[1:0] == 2'b01);
   assign word_tran  = (tran_mode[1:0] == 2'b10);
   
   assign wdata_algn[MDW-1:0] = byte_tran  ? algn_byte[MDW-1:0] :
			       hword_tran ? algn_hword[MDW-1:0]:
			       word_tran  ? algn_word[MDW-1:0] :
			                    dch_fifo_reg[MDW-1:0];

   always @ (posedge eclk)
     if(tran_go & ~emesh_wr_wait_outb)
       wdata_algn_reg[MDW-1:0] <= wdata_algn[MDW-1:0];
   
   always @ (posedge eclk or posedge reset)
     if(reset)
       begin
	  tran_go     <= 1'b0;
	  tran_go_reg <= 1'b0;
       end
     else if(~emesh_wr_wait_outb)
       begin
	  tran_go     <= dch_fifo_rd;
	  tran_go_reg <= tran_go;
       end

   //#############################
   //# Emesh transaction creation
   //#############################

   assign emesh_dstaddr_inb[31:0] = tran_addr_mode[WB-5:5];
   assign emesh_srcaddr_inb[31:0] = wdata_algn_reg[MDW-1:32];
   assign emesh_data_inb[31:0]    = wdata_algn_reg[31:0];
   assign emesh_datamode_inb[1:0] = tran_addr_mode[1:0];
   assign emesh_ctrlmode_inb[3:0] = tran_addr_mode[WB-1:WB-4];
   assign emesh_write_inb         = 1'b1;
   assign emesh_access_inb        = tran_go_reg & ~emesh_wr_wait_outb;

   
endmodule // axi_master_rd
