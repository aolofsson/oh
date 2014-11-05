/*
  File: axi_slave_addrch.v
 
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
module axi_slave_addrch (/*AUTOARG*/
   // Outputs
   aready, ach_fifo_empty, tran_addr, tran_mode, dalgn_ctrl,
   byte_tran, hword_tran, word_tran, aid_ec, alen_ec, new_addr_sel,
   // Inputs
   aclk, eclk, reset, avalid, addr, aid, alen, asize, aburst,
   tran_last, tran_stall, tran_go
   );

   parameter SAW  = 32; //Address Bus Width
   parameter SIDW = 12; //ID Width
   parameter ACH = SAW+SIDW+9; //Width of all used Address Signals
   parameter AFW = 4;  //Address channel FIFO address width

   //#########
   //# Inputs
   //#########

   // global signals
   input aclk;   //clock source of the axi bus
   input eclk;   //clock source of emesh interface
   input reset;  //reset 

   input 	    avalid; //address valid
   input [SAW-1:0]   addr;  //address
   input [SIDW-1:0]  aid;   //address ID
   input [3:0]      alen;   //burst lenght (the number of data transfers)
   input [2:0] 	    asize;  //burst size (the size of each transfer)
   input [1:0] 	    aburst; //burst type
   
   input 	    tran_last;  //Last data of burst 
   input 	    tran_stall; //Transaction stall
   input 	    tran_go;    //Transaction is "dispatching"
   
   //##########
   //# Outputs
   //##########

   output 	    aready; //address ready

   output 	    ach_fifo_empty;
   output [SAW-1:0]  tran_addr;
   output [1:0]     tran_mode;
   output [2:0]     dalgn_ctrl;
   output 	    byte_tran;
   output 	    hword_tran;
   output 	    word_tran;
   output [SIDW-1:0] aid_ec;
   output [3:0]     alen_ec;
   output 	    new_addr_sel;

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#########
   //# Regs
   //#########
   reg [ACH-1:0]    ach_fifo_in;
   reg 		    avalid_aready_reg;
   reg [ACH-1:0]    ach_fifo_reg;
   reg 		    ach_fifo_rd_reg;
   reg [SAW-1:0]     tran_addr;
   reg [1:0] 	    tran_mode;
   reg 		    ach_fifo_empty_reg;

   //#########
   //# Wires
   //#########
   wire [ACH-1:0]   ach_data_in;
   wire [ACH-1:0]   ach_fifo_out;
   wire 	    aready;
   wire 	    avalid_aready;
   wire 	    ach_fifo_full;
   wire 	    ach_fifo_rd;
   wire 	    ach_fifo_wr;
   wire 	    ach_fifo_empty;

   wire [SAW-1:0]    addr_ec; // "_ec" indicates an eclk domain signal
   wire [SIDW-1:0]   aid_ec;
   wire [3:0] 	    alen_ec;
   wire [2:0] 	    asize_ec;
   wire [1:0] 	    aburst_ec;
   wire 	    incr_burst;
   wire 	    byte_tran;
   wire 	    hword_tran;
   wire 	    word_tran;
   wire [3:0] 	    addr_incr;
   wire [SAW-1:0]    addr_upd;
   wire [SAW-1:0]    addr_mask;
   wire [SAW-1:0]    addr_algn;
   wire [SAW-1:0]    addr_new;
   wire [2:0] 	    dalgn_ctrl;
   wire 	    new_addr_sel;
      
   //# The data is sampled before entering FIFO to prevent timing issues
   assign ach_data_in[ACH-1:0] = {addr[SAW-1:0],aid[SIDW-1:0],alen[3:0],
				  asize[2:0],aburst[1:0]};
   always @ (posedge aclk)
     if(~ach_fifo_full)
       ach_fifo_in[ACH-1:0] <= ach_data_in[ACH-1:0];
   
   always @ (posedge aclk or posedge reset)
     if(reset)
       avalid_aready_reg <= 1'b0;
     else if(~ach_fifo_full)
       avalid_aready_reg <= avalid_aready;

   assign aready        = ~ach_fifo_full;
   assign avalid_aready = avalid & aready;

   assign ach_fifo_rd = ~(ach_fifo_empty | ~tran_last | tran_stall);
   assign ach_fifo_wr = avalid_aready_reg & ~ach_fifo_full;

   /*fifo AUTO_TEMPLATE(.rd_clk        (eclk),
                        .wr_clk        (aclk),
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
				       .wr_clk		(aclk),		 // Templated
				       .rd_clk		(eclk),		 // Templated
				       .wr_write	(ach_fifo_wr),	 // Templated
				       .wr_data		(ach_fifo_in[ACH-1:0]), // Templated
				       .rd_read		(ach_fifo_rd));	 // Templated
   
   //# The data is sampled after exiting FIFO to prevent timing issues
   always @ (posedge eclk)
     if(~tran_stall)
       ach_fifo_reg[ACH-1:0] <= ach_fifo_out[ACH-1:0];

   always @ (posedge eclk or posedge reset)
     if(reset)
       ach_fifo_rd_reg <= 1'b0;
     else if(~tran_stall)
       ach_fifo_rd_reg <= ach_fifo_rd;
   
   //# Address info decode
   assign addr_ec[SAW-1:0] = ach_fifo_reg[ACH-1:ACH-SAW];
   assign aid_ec[SIDW-1:0] = ach_fifo_reg[ACH-SAW-1:9];
   assign alen_ec[3:0]    = ach_fifo_reg[8:5] + 4'b0001;
   assign asize_ec[2:0]   = ach_fifo_reg[4:2];
   assign aburst_ec[1:0]  = ach_fifo_reg[1:0];

   //# currently only INCR and FIXED bursts are supported
   //# WRAP type burst will be treated as FIXED type 
   assign incr_burst = (aburst_ec[1:0] == 2'b01);

   //# size decode
   assign byte_tran  = (asize_ec[2:0] == 3'b000);
   assign hword_tran = (asize_ec[2:0] == 3'b001);
   assign word_tran  = (asize_ec[2:0] == 3'b010);
   
   //# new address calculation
   assign addr_incr[3:0] = byte_tran  ? {3'b000,incr_burst}:
			   hword_tran ? {2'b00, incr_burst,1'b0}:
			   word_tran  ? {1'b0,  incr_burst,2'b00} :
			                {       incr_burst,3'b000};

   assign addr_upd[SAW-1:0] = tran_addr[SAW-1:0] +{{(SAW-4){1'b0}},addr_incr[3:0]};

   //# Since we don't support unaligned transfers, a special masking
   //# mechanism is implemented to "turn" an illegal transfer into legal.
   assign addr_mask[SAW-1:0] = byte_tran  ? {{(SAW-3){1'b1}},3'b111}:
			      hword_tran ? {{(SAW-3){1'b1}},3'b110}:
			      word_tran  ? {{(SAW-3){1'b1}},3'b100}:
			                   {{(SAW-3){1'b1}},3'b000};

   assign addr_algn[SAW-1:0] = addr_ec[SAW-1:0] & addr_mask[SAW-1:0];

   assign addr_new[SAW-1:0] = new_addr_sel ? addr_algn[SAW-1:0] :
		                            addr_upd[SAW-1:0];

   always @ (posedge eclk)
     if(tran_go & ~tran_stall)
       begin
	  tran_addr[SAW-1:0] <= addr_new[SAW-1:0];
	  tran_mode[1:0]    <= asize_ec[1:0];
       end

   assign dalgn_ctrl[2:0] = addr_new[2:0];

   always @ (posedge eclk or posedge reset)
     if (reset)
       ach_fifo_empty_reg <= 1'b1;
     else if((ach_fifo_empty | tran_go) & ~tran_stall)
       ach_fifo_empty_reg <= ach_fifo_empty;
   
   assign new_addr_sel        = (ach_fifo_empty_reg | ach_fifo_rd_reg) & 
				~ach_fifo_empty;
      
endmodule // axi_slave_addrch
