/*
  File: axi_slave_wr.v
 
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
//######################################################################
//# According to the standard (IHI0022D_amba_axi_protocol_spec):
//# If the interconnect combines write transactions from
//# different masters to one slave, it must ensure that it
//# forwards the write data in address order.
//#
//# This block was implemented based on the above statement and won't 
//# work properly if the interconnect doesn't follow this rule.
//######################################################################
//# Currently not supported:
//# 1. non-valid data bytes in a given data size
//# 2. unaligned transfers
//# 3. WRAP burst type (is treated as FIXED)
//# 4. write data interleaving
//# 5. protection types
//# 6. atomic accesses
//# 7. memory types through AxCACHE encoding
//# !!! The block is implemented in a way it "ignores" any
//# !!! unsupported features, and produces uninterrupted 
//# !!! conversion of the transfers. As a result, the AXI bus
//# !!! should always operate without deadlocks.
//# !!! If the master issues unsupported transfer, the data written
//# !!! into the destination is unpredictable.   

module axi_slave_wr (/*AUTOARG*/
   // Outputs
   awready, wready, bid, bresp, bvalid, emesh_access_inb,
   emesh_write_inb, emesh_datamode_inb, emesh_ctrlmode_inb,
   emesh_dstaddr_inb, emesh_srcaddr_inb, emesh_data_inb,
   // Inputs
   aclk, eclk, reset, awid, awaddr, awlen, awsize, awburst, awlock,
   awcache, awprot, awvalid, wid, wdata, wstrb, wlast, wvalid, bready,
   emesh_wr_wait_outb
   );

   parameter SIDW = 12; //ID Width
   parameter SAW  = 32; //Address Bus Width
   parameter SDW  = 32; //Data Bus Width
   parameter STW = 8;  //Number of strobes
   parameter ACH = SAW+SIDW+5; //Width of all used Write Address Signals
   parameter AFW = 4;  //Address channel Fifo address width
   parameter DFW = 4;  //Data channel Fifo address width
   parameter BFW = 4;  //Response channel Fifo address width
   parameter DCH = SDW+1; //Width of all used Write Data Signals 
      
   //#########
   //# Inputs
   //#########

   // global signals
   input aclk;   //clock source of the axi bus
   input eclk;   //clock source of emesh interface
   input reset;  //reset 

   //########################
   //# Write address channel
   //########################
   input [SIDW-1:0] awid;   //write address ID
   input [SAW-1:0]  awaddr; //write address
   input [3:0]     awlen;   //burst lenght (the number of data transfers)
   input [2:0]     awsize;  //burst size (the size of each transfer)
   input [1:0]     awburst; //burst type
   input [1:0]     awlock;  //lock type (atomic characteristics)
   input [3:0]     awcache; //memory type
   input [2:0]     awprot;  //protection type
   input 	   awvalid; //write address valid

   //########################
   //# Write data channel
   //########################
   input [SIDW-1:0] wid;  //write ID tag (supported only in AXI3)
   input [SDW-1:0]  wdata;//write data
   input [3:0] 	    wstrb;//write strobes
   input 	   wlast; //write last. Indicates the last transfer in burst
   input 	   wvalid;//write valid

   //########################
   // Write response channel
   //########################
   input 	   bready;//response ready

   //##############################
   //# From the emesh interface
   //##############################
   input 	   emesh_wr_wait_outb; 

   //##########
   //# Outputs
   //##########

   //########################
   //# Write address channel
   //########################
   output 	   awready; //write address ready

   //########################
   //# Write data channel
   //########################
   output 	   wready; //write ready

   //########################
   // Write response channel
   //########################
   output [SIDW-1:0] bid;  //response ID tag
   output [1:0]     bresp; //write response
   output 	    bvalid;//write response valid
   
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

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#########
   //# Regs
   //#########
   reg 		    dch_wlast_reg;
   reg [DCH-1:0]    dch_fifo_in;
   reg 		    wvalid_wready_reg;
   reg [DCH-1:0]    dch_fifo_reg;
   reg 		    tran_go;
   reg 		    tran_go_reg;
   reg [SDW-1:0]     wdata_algn_reg;
   reg [SAW-1:0]     tran_addr_reg;
   reg [1:0] 	    tran_mode_reg;
   reg [SDW-1:0]     algn_byte;
   reg [SIDW-1:0]    bch_fifo_reg;
   reg 		    bch_fifo_empty_reg;
      
   //#########
   //# Wires
   //#########
   wire 	    awready;
   wire 	    ach_fifo_empty;
   wire [2:0] 	    dalgn_ctrl;
   wire 	    wready;
   wire 	    wvalid_wready;
   wire [DCH-1:0]   dch_data_in;
   wire [DCH-1:0]   dch_fifo_out;
   wire 	    dch_fifo_empty;
   wire 	    dch_fifo_full;
   wire 	    dch_fifo_wr;
   wire 	    dch_fifo_rd;
   wire 	    dch_wlast; //Indicates last data of burst (out of fifo_dch)
   
   wire [SIDW-1:0]  bch_data_in;
   wire [SIDW-1:0]  bch_fifo_out;
   wire 	    bch_fifo_empty;
   wire 	    bch_fifo_full;
   wire 	    bch_fifo_wr;
   wire 	    bch_fifo_rd;
   wire 	    bch_advance;
   wire 	    bvalid_bready;
      
   wire [SDW-1:0]   wdata_ec;
   wire [SDW-1:0]   algn_hword;
   wire [SDW-1:0]   wdata_algn;
   wire 	    tran_stall;
   wire 	    byte_tran;
   wire 	    hword_tran;
   wire [SAW-1:0]   tran_addr;
   wire [1:0] 	    tran_mode;
   wire [SIDW-1:0]  awid_ec;
      
   //#######################################
   //# Address channel synchronization FIFO
   //#######################################

   /*axi_slave_addrch AUTO_TEMPLATE(.aclk           (aclk),
                                    .addr           (awaddr[]),
                                    .ach_fifo_empty (ach_fifo_empty),
                                    .alen_ec	    (),
                                    .a\(.*\)        (aw\1[]),
                                    .tran_last      (dch_wlast),
                                    .new_addr_sel   (),
                                    .tran_go	    (dch_fifo_rd),
				    .byte_tran	    (),
				    .hword_tran	    (),
				    .word_tran	    (),
                                    .dalgn_ctrl	    (),
                                   );
    */                                    

   axi_slave_addrch axi_slave_addrch(/*AUTOINST*/
				     // Outputs
				     .aready		(awready),	 // Templated
				     .ach_fifo_empty	(ach_fifo_empty), // Templated
				     .tran_addr		(tran_addr[SAW-1:0]),
				     .tran_mode		(tran_mode[1:0]),
				     .dalgn_ctrl	(),		 // Templated
				     .byte_tran		(),		 // Templated
				     .hword_tran	(),		 // Templated
				     .word_tran		(),		 // Templated
				     .aid_ec		(awid_ec[SIDW-1:0]), // Templated
				     .alen_ec		(),		 // Templated
				     .new_addr_sel	(),		 // Templated
				     // Inputs
				     .aclk		(aclk),		 // Templated
				     .eclk		(eclk),
				     .reset		(reset),
				     .avalid		(awvalid),	 // Templated
				     .addr		(awaddr[SAW-1:0]), // Templated
				     .aid		(awid[SIDW-1:0]), // Templated
				     .alen		(awlen[3:0]),	 // Templated
				     .asize		(awsize[2:0]),	 // Templated
				     .aburst		(awburst[1:0]),	 // Templated
				     .tran_last		(dch_wlast),	 // Templated
				     .tran_stall	(tran_stall),
				     .tran_go		(dch_fifo_rd));	 // Templated
      
   
   //#######################################
   //# Data channel synchronization FIFO
   //#######################################

   assign wready = ~dch_fifo_full;
   
   assign wvalid_wready = wvalid & wready;
      
   assign dch_data_in[DCH-1:0] = {wdata[SDW-1:0],wlast};

   //# Since according to the standard it is possible that
   //# data will arive before the address, we are checking address
   //# availability prior to reading the data from the fifo.
   assign dch_fifo_rd = ~(dch_fifo_empty | ach_fifo_empty | tran_stall);
   
   //# The data is sampled before entering FIFO to prevent timing issues
   always @ (posedge aclk)
     if(~dch_fifo_full)
       dch_fifo_in[DCH-1:0] <= dch_data_in[DCH-1:0];

   always @ (posedge aclk or posedge reset)
     if(reset)
       wvalid_wready_reg <= 1'b0;
     else if(~dch_fifo_full)
       wvalid_wready_reg <= wvalid_wready;

   assign dch_fifo_wr = wvalid_wready_reg & ~dch_fifo_full;

   assign dch_wlast = dch_fifo_rd & dch_fifo_out[0];

   always @ (posedge eclk or posedge reset)
     if(reset)
       dch_wlast_reg <= 1'b0;
     else if(~tran_stall)
       dch_wlast_reg <= dch_wlast;
   
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
     if(~tran_stall)
       dch_fifo_reg[DCH-1:0] <= dch_fifo_out[DCH-1:0];

   always @ (posedge eclk or posedge reset)
     if(reset)
       begin
	  tran_go     <= 1'b0;
	  tran_go_reg <= 1'b0;
       end
     else if(~tran_stall)
       begin
	  tran_go     <= dch_fifo_rd;
	  tran_go_reg <= tran_go;
       end

   //########################
   //# AXI-EMESH conversion
   //########################

   //# Data Alignment for the EMESH protocol
   assign wdata_ec[SDW-1:0] = dch_fifo_reg[DCH-1:DCH-SDW];
   
   always @ (dalgn_ctrl[1:0] or wdata_ec[31:0])
     begin
	casez (dalgn_ctrl[1:0])
	  2'b00 : algn_byte[SDW-1:0] = {{(SDW-8){1'b0}},wdata_ec[7:0]};
	  2'b01 : algn_byte[SDW-1:0] = {{(SDW-8){1'b0}},wdata_ec[15:8]};
	  2'b10 : algn_byte[SDW-1:0] = {{(SDW-8){1'b0}},wdata_ec[23:16]};
	  2'b11 : algn_byte[SDW-1:0] = {{(SDW-8){1'b0}},wdata_ec[31:24]};
	  default: algn_byte[SDW-1:0] = {{(SDW-8){1'b0}},wdata_ec[7:0]};
	endcase // casez (dalgn_ctrl[1:0])
     end
   
   assign algn_hword[SDW-1:0] = dalgn_ctrl[1] ? {{(SDW/2){1'b0}},wdata_ec[31:16]} :
			                        {{(SDW/2){1'b0}},wdata_ec[15:0]};
   
   assign wdata_algn[SDW-1:0] = byte_tran  ? algn_byte[SDW-1:0] :
			       hword_tran ? algn_hword[SDW-1:0] :
			                    wdata_ec[SDW-1:0];

   assign byte_tran  = (tran_mode[1:0] == 2'b00);
   assign hword_tran = (tran_mode[1:0] == 2'b01);
   assign dalgn_ctrl[2:0] = tran_addr[2:0];
   
   always @ (posedge eclk)
     if(tran_go & ~tran_stall)
       begin
	  wdata_algn_reg[SDW-1:0] <= wdata_algn[SDW-1:0];
	  tran_addr_reg[SAW-1:0]  <= tran_addr[SAW-1:0];
	  tran_mode_reg[1:0]     <= tran_mode[1:0];
       end 
	  
   //#############################
   //# Emesh transaction creation
   //#############################

   assign emesh_dstaddr_inb[31:0] = tran_addr_reg[SAW-1:0];
   assign emesh_srcaddr_inb[31:0] = {(32){1'b0}};
   assign emesh_data_inb[31:0]    = wdata_algn_reg[31:0];
   assign emesh_datamode_inb[1:0] = tran_mode_reg[1:0];
   assign emesh_ctrlmode_inb[3:0] = 4'b0000;
   assign emesh_write_inb         = 1'b1;
   assign emesh_access_inb        = tran_go_reg & ~tran_stall;
   
   //#########################################
   //# Response channel synchronization FIFO
   //#########################################

   assign bid[SIDW-1:0]  = bch_fifo_reg[SIDW-1:0];
   assign bresp[1:0]    = 2'b00;
   assign bvalid        = ~bch_fifo_empty_reg;
   assign bvalid_bready = bvalid & bready;
      
   assign bch_data_in[SIDW-1:0] = awid_ec[SIDW-1:0];
   assign bch_fifo_wr          = dch_wlast_reg & ~tran_stall;
   assign bch_fifo_rd          = ~bch_fifo_empty & (~bvalid | bvalid_bready);
   assign bch_advance          = bvalid_bready | ~bvalid;
      
   /*fifo AUTO_TEMPLATE(.rd_clk        (aclk),
                        .wr_clk        (eclk),
                        .wr_data       (bch_data_in[SIDW-1:0]),
                        .rd_data       (bch_fifo_out[SIDW-1:0]), 
                        .rd_fifo_empty (bch_fifo_empty),
                        .wr_fifo_full  (bch_fifo_full),
                        .wr_write      (bch_fifo_wr),
                        .rd_read       (bch_fifo_rd),
                       );
    */

   fifo #(.DW(SIDW), .AW(BFW)) fifo_bch(/*AUTOINST*/
					// Outputs
					.rd_data	(bch_fifo_out[SIDW-1:0]), // Templated
					.rd_fifo_empty	(bch_fifo_empty), // Templated
					.wr_fifo_full	(bch_fifo_full), // Templated
					// Inputs
					.reset		(reset),
					.wr_clk		(eclk),		 // Templated
					.rd_clk		(aclk),		 // Templated
					.wr_write	(bch_fifo_wr),	 // Templated
					.wr_data	(bch_data_in[SIDW-1:0]), // Templated
					.rd_read	(bch_fifo_rd));	 // Templated

   //# The data is sampled after exiting FIFO to prevent timing issues
   always @ (posedge aclk or posedge reset)
     if(reset)
       bch_fifo_empty_reg <= 1'b1;
     else if(bch_advance)
       bch_fifo_empty_reg <= bch_fifo_empty;
   
   always @ (posedge aclk)
     if (bch_advance)
       bch_fifo_reg[SIDW-1:0] <= bch_fifo_out[SIDW-1:0];

   //##################################################
   //# Both Address and Data channels can be "stalled"
   //# as a result of emesh_wait or non-ready response 
   //# channel
   //##################################################

   assign tran_stall = emesh_wr_wait_outb | bch_fifo_full;
      
endmodule // axi_slave_wr
