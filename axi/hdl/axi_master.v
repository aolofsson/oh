/*
  File: axi_master.v
 
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
module axi_master (/*AUTOARG*/
   // Outputs
   awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot,
   awvalid, wid, wdata, wstrb, wlast, wvalid, bready, arid, araddr,
   arlen, arsize, arburst, arlock, arcache, arprot, arvalid, rready,
   emesh_access_inb, emesh_write_inb, emesh_datamode_inb,
   emesh_ctrlmode_inb, emesh_dstaddr_inb, emesh_srcaddr_inb,
   emesh_data_inb, emesh_wr_wait_inb, emesh_rd_wait_inb, awqos, arqos,
   // Inputs
   aclk, eclk, reset, awready, wready, bid, bresp, bvalid, arready,
   rid, rdata, rresp, rlast, rvalid, emesh_access_outb,
   emesh_write_outb, emesh_datamode_outb, emesh_ctrlmode_outb,
   emesh_dstaddr_outb, emesh_srcaddr_outb, emesh_data_outb,
   emesh_wr_wait_outb
   );

   parameter MIDW = 6;  //ID Width
   parameter MAW  = 32; //Address Bus Width
   parameter MDW  = 64; //Data Bus Width
   parameter STW = 8;  //Number of strobes
      
   //#########
   //# Inputs
   //#########

   // global signals
   input aclk;   // clock source of the axi bus
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
   output 	    emesh_wr_wait_inb;  
   output 	    emesh_rd_wait_inb; 
   
   //#######################################################################
   //# The following features are not supported (AXI4 only)
   //# If un-commented, those signals have to be driven with default values
   //#######################################################################
   // input 	    buser;   //user signal (AXI4 only)
   // input         ruser;   //user signal (AXI4 only)
   output [3:0]     awqos;   //quality of service (AXI4 only) default 4'b0000
   // output [3:0]  awregion;//region identifier (AXI4 only)
   // output 	    awuser;  //user signal (AXI4 only)
   // output        wuser;   //user signal (AXI4 only)  
   output [3:0]     arqos;   //quality of service (AXI4 only) default 4'b0000
   // output [3:0]  arregion;//region identifier (AXI4 only)
   // output 	    aruser;  //user signal (AXI4 only)

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //############
   //# Wires
   //############
   wire [MIDW-1:0]  awid;    //write address ID
   wire [MAW-1:0]   awaddr;  //write address
   wire [3:0] 	    awlen;   //burst lenght (the number of data transfers)
   wire [2:0] 	    awsize;  //burst size (the size of each transfer)
   wire [1:0] 	    awburst; //burst type
   wire [1:0] 	    awlock;  //lock type (atomic characteristics)
   wire [3:0] 	    awcache; //memory type
   wire [2:0] 	    awprot;  //protection type
   wire 	    awvalid; //write address valid
   wire [MIDW-1:0]  wid;     //write ID tag (supported only in AXI3)
   wire [MDW-1:0]   wdata;   //write data
   wire [STW-1:0]   wstrb;   //write strobes
   wire 	    wlast;   //write last, indicates the last transfer in burst
   wire 	    wvalid;  //write valid
   wire 	    bready;  //response ready
   wire [MIDW-1:0]  arid;    //read address ID
   wire [MAW-1:0]   araddr;  //read address
   wire [3:0] 	    arlen;   //burst lenght (the number of data transfers)
   wire [2:0] 	    arsize;  //burst size (the size of each transfer)
   wire [1:0] 	    arburst; //burst type
   wire [1:0] 	    arlock;  //lock type (atomic characteristics)
   wire [3:0] 	    arcache; //memory type
   wire [2:0] 	    arprot;  //protection type
   wire 	    arvalid; //write address valid
   wire 	    rready;  //read ready
   wire 	    emesh_access_inb;
   wire 	    emesh_write_inb;
   wire [1:0] 	    emesh_datamode_inb;
   wire [3:0] 	    emesh_ctrlmode_inb;
   wire [31:0] 	    emesh_dstaddr_inb;
   wire [31:0] 	    emesh_srcaddr_inb;
   wire [31:0] 	    emesh_data_inb;  
   wire 	    emesh_wr_wait_inb;  
   wire 	    emesh_rd_wait_inb; 
   
   //#######################
   //# Defaults
   //#######################
   assign awqos[3:0] = 4'b0000;
   assign arqos[3:0] = 4'b0000;
   
   //##################################
   //# Master Write Port Instantiation
   //##################################
   
   axi_master_wr axi_master_wr(/*AUTOINST*/
			       // Outputs
			       .awid		(awid[MIDW-1:0]),
			       .awaddr		(awaddr[MAW-1:0]),
			       .awlen		(awlen[3:0]),
			       .awsize		(awsize[2:0]),
			       .awburst		(awburst[1:0]),
			       .awlock		(awlock[1:0]),
			       .awcache		(awcache[3:0]),
			       .awprot		(awprot[2:0]),
			       .awvalid		(awvalid),
			       .wid		(wid[MIDW-1:0]),
			       .wdata		(wdata[MDW-1:0]),
			       .wstrb		(wstrb[STW-1:0]),
			       .wlast		(wlast),
			       .wvalid		(wvalid),
			       .bready		(bready),
			       .emesh_wr_wait_inb(emesh_wr_wait_inb),
			       // Inputs
			       .aclk		(aclk),
			       .eclk		(eclk),
			       .reset		(reset),
			       .awready		(awready),
			       .wready		(wready),
			       .bid		(bid[MIDW-1:0]),
			       .bresp		(bresp[1:0]),
			       .bvalid		(bvalid),
			       .emesh_access_outb(emesh_access_outb),
			       .emesh_write_outb(emesh_write_outb),
			       .emesh_datamode_outb(emesh_datamode_outb[1:0]),
			       .emesh_ctrlmode_outb(emesh_ctrlmode_outb[3:0]),
			       .emesh_dstaddr_outb(emesh_dstaddr_outb[31:0]),
			       .emesh_srcaddr_outb(emesh_srcaddr_outb[31:0]),
			       .emesh_data_outb	(emesh_data_outb[31:0]));
   
   //##################################
   //# Master Read Port Instantiation
   //##################################
   
   axi_master_rd axi_master_rd(/*AUTOINST*/
			       // Outputs
			       .arid		(arid[MIDW-1:0]),
			       .araddr		(araddr[MAW-1:0]),
			       .arlen		(arlen[3:0]),
			       .arsize		(arsize[2:0]),
			       .arburst		(arburst[1:0]),
			       .arlock		(arlock[1:0]),
			       .arcache		(arcache[3:0]),
			       .arprot		(arprot[2:0]),
			       .arvalid		(arvalid),
			       .rready		(rready),
			       .emesh_access_inb(emesh_access_inb),
			       .emesh_write_inb	(emesh_write_inb),
			       .emesh_datamode_inb(emesh_datamode_inb[1:0]),
			       .emesh_ctrlmode_inb(emesh_ctrlmode_inb[3:0]),
			       .emesh_dstaddr_inb(emesh_dstaddr_inb[31:0]),
			       .emesh_srcaddr_inb(emesh_srcaddr_inb[31:0]),
			       .emesh_data_inb	(emesh_data_inb[31:0]),
			       .emesh_rd_wait_inb(emesh_rd_wait_inb),
			       // Inputs
			       .aclk		(aclk),
			       .eclk		(eclk),
			       .reset		(reset),
			       .arready		(arready),
			       .rid		(rid[MIDW-1:0]),
			       .rdata		(rdata[MDW-1:0]),
			       .rresp		(rresp[1:0]),
			       .rlast		(rlast),
			       .rvalid		(rvalid),
			       .emesh_access_outb(emesh_access_outb),
			       .emesh_write_outb(emesh_write_outb),
			       .emesh_datamode_outb(emesh_datamode_outb[1:0]),
			       .emesh_ctrlmode_outb(emesh_ctrlmode_outb[3:0]),
			       .emesh_dstaddr_outb(emesh_dstaddr_outb[31:0]),
			       .emesh_srcaddr_outb(emesh_srcaddr_outb[31:0]),
			       .emesh_data_outb	(emesh_data_outb[31:0]),
			       .emesh_wr_wait_outb(emesh_wr_wait_outb));
   

endmodule // axi_master
