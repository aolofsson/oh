/*
  File: axi_slave.v
 
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
module axi_slave (/*AUTOARG*/
   // Outputs
   csysack, cactive, awready, wready, bid, bresp, bvalid, arready,
   rid, rdata, rresp, rlast, rvalid, emesh_access_inb,
   emesh_write_inb, emesh_datamode_inb, emesh_ctrlmode_inb,
   emesh_dstaddr_inb, emesh_srcaddr_inb, emesh_data_inb,
   emesh_wr_wait_inb, emesh_rd_wait_inb,
   // Inputs
   aclk, eclk, reset, csysreq, awid, awaddr, awlen, awsize, awburst,
   awlock, awcache, awprot, awvalid, wid, wdata, wstrb, wlast, wvalid,
   bready, arid, araddr, arlen, arsize, arburst, arlock, arcache,
   arprot, arvalid, rready, emesh_access_outb, emesh_write_outb,
   emesh_datamode_outb, emesh_ctrlmode_outb, emesh_dstaddr_outb,
   emesh_srcaddr_outb, emesh_data_outb, emesh_wr_wait_outb,
   emesh_rd_wait_outb, awqos, arqos
   );

   parameter SIDW = 12; //ID Width
   parameter SAW  = 32; //Address Bus Width
   parameter SDW  = 32; //Data Bus Width
   
   //#########
   //# Inputs
   //#########

   // global signals
   input aclk;     // clock source of the axi bus
   input eclk;   // clock source of emesh interface
   input reset;  // reset 
   input csysreq;// system exit low-power state request 

   //########################
   //# Write address channel
   //########################
   input [SIDW-1:0] awid;    //write address ID
   input [SAW-1:0]  awaddr;  //write address
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
   input [SIDW-1:0] wid;   //write ID tag (supported only in AXI3)
   input [SDW-1:0]  wdata; //write data
   input [3:0] 	    wstrb; //write strobes
   input 	   wlast; //write last. Indicates the last transfer in burst
   input 	   wvalid;//write valid
      
   //########################
   // Write response channel
   //########################
   input 	   bready;//response ready

   //########################
   //# Read address channel
   //########################
   input [SIDW-1:0] arid;    //read address ID
   input [SAW-1:0]  araddr;  //read address
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
   input 	    emesh_access_outb;
   input 	    emesh_write_outb;
   input [1:0] 	    emesh_datamode_outb;
   input [3:0] 	    emesh_ctrlmode_outb;
   input [31:0]     emesh_dstaddr_outb;
   input [31:0]     emesh_srcaddr_outb;
   input [31:0]     emesh_data_outb;   
   input 	    emesh_wr_wait_outb; 
   input 	    emesh_rd_wait_outb; 

   //##########
   //# Outputs
   //##########

   // global signals
   output          csysack;//exit low-power state acknowledgement
   output          cactive;//clock active

   //########################
   //# Write address channel
   //########################
   output 	   awready; //write address ready

   //########################
   //# Write data channel
   //########################
   output 	    wready; //write ready

   //########################
   // Write response channel
   //########################
   output [SIDW-1:0] bid;   //response ID tag
   output [1:0]     bresp; //write response
   output 	    bvalid;//write response valid

   //########################
   //# Read address channel
   //########################
   output 	    arready;//read address ready

   //########################
   //# Read data channel
   //########################
   output [SIDW-1:0] rid;   //read ID tag (must match arid of the transaction)
   output [SDW-1:0]  rdata; //read data
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
   output 	    emesh_rd_wait_inb; 
  
   //#######################################################################
   //# The following feature are not supported (AXI4 only)
   //# If un-commented, those signals have to be driven with default values
   //#######################################################################
   input [3:0]     awqos;   //Quality of Service (AXI4 only) default 4'b0000
   // input [3:0]  awregion;//region identifier  (AXI4 only)
   // input   	   awuser;  //user signal (AXI4 only)
   // input        wuser;   //user signal (AXI4 only)  
   input [3:0] 	   arqos;   //quality of service (AXI4 only) default 4'b0000
   // input [3:0]  arregion;//region identifier (AXI4 only)
   // input 	   aruser;  //user signal (AXI4 only)
   // output       buser;   //user signal (AXI4 only)
   // output       ruser;   //user signal (AXI4 only)


   //#########
   //# Regs
   //#########
   reg 		   csysack;
      
   //#########
   //# Wires
   //#########
   wire 	   emesh_wr_access_inb;
   wire 	   emesh_wr_write_inb;
   wire [1:0] 	   emesh_wr_datamode_inb;
   wire [3:0] 	   emesh_wr_ctrlmode_inb;
   wire [31:0] 	   emesh_wr_dstaddr_inb;
   wire [31:0] 	   emesh_wr_srcaddr_inb;
   wire [31:0] 	   emesh_wr_data_inb;  

   wire 	   emesh_rd_access_inb;
   wire 	   emesh_rd_write_inb;
   wire [1:0] 	   emesh_rd_datamode_inb;
   wire [3:0] 	   emesh_rd_ctrlmode_inb;
   wire [31:0] 	   emesh_rd_dstaddr_inb;
   wire [31:0] 	   emesh_rd_srcaddr_inb;
   wire [31:0] 	   emesh_rd_data_inb;  

   wire 	   emesh_rd_wait;
   
   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //##################################################
   //# This block doesn't accept read transactions
   //# from emesh.
   //##################################################

   assign emesh_rd_wait_inb = 1'b0;
   
   //##################################################
   //#              Low Power State
   //# We don't support low power state
   //##################################################

   assign cactive = 1'b1;

   always @ (posedge eclk or posedge reset)
     if(reset)
       csysack <= 1'b1;
     else
       csysack <= csysreq;
   
   //##################################################
   //#        RD/WR transaction selection
   //# *Write transactions are of the higher priority
   //##################################################
   assign emesh_rd_wait = emesh_rd_wait_outb | emesh_wr_access_inb;

   assign emesh_access_inb = emesh_wr_access_inb | emesh_rd_access_inb;

   assign emesh_write_inb  = emesh_wr_access_inb ? emesh_wr_write_inb :
			                           emesh_rd_write_inb;
   assign emesh_datamode_inb[1:0] = emesh_wr_access_inb ? 
                                                  emesh_wr_datamode_inb[1:0] :
				                  emesh_rd_datamode_inb[1:0];
   assign emesh_ctrlmode_inb[3:0] = emesh_wr_access_inb ? 
                                                  emesh_wr_ctrlmode_inb[3:0] :
				                  emesh_rd_ctrlmode_inb[3:0];
   assign emesh_dstaddr_inb[31:0] = emesh_wr_access_inb ? 
                                                  emesh_wr_dstaddr_inb[31:0] :
				                  emesh_rd_dstaddr_inb[31:0];
   assign emesh_srcaddr_inb[31:0] = emesh_wr_access_inb ? 
                                                  emesh_wr_srcaddr_inb[31:0] :
				                  emesh_rd_srcaddr_inb[31:0];
   assign emesh_data_inb[31:0] = emesh_wr_access_inb ? 
                                                  emesh_wr_data_inb[31:0] :
				                  emesh_rd_data_inb[31:0];
   
   //##################################
   //# Slave Write Port Instantiation
   //##################################
   
   /*axi_slave_wr AUTO_TEMPLATE(.emesh_wr_wait_outb (emesh_wr_wait_outb),
                                .emesh_\(.*\)_inb   (emesh_wr_\1_inb[]),
                               );
    */                                    

   axi_slave_wr axi_slave_wr(/*AUTOINST*/
			     // Outputs
			     .awready		(awready),
			     .wready		(wready),
			     .bid		(bid[SIDW-1:0]),
			     .bresp		(bresp[1:0]),
			     .bvalid		(bvalid),
			     .emesh_access_inb	(emesh_wr_access_inb), // Templated
			     .emesh_write_inb	(emesh_wr_write_inb), // Templated
			     .emesh_datamode_inb(emesh_wr_datamode_inb[1:0]), // Templated
			     .emesh_ctrlmode_inb(emesh_wr_ctrlmode_inb[3:0]), // Templated
			     .emesh_dstaddr_inb	(emesh_wr_dstaddr_inb[31:0]), // Templated
			     .emesh_srcaddr_inb	(emesh_wr_srcaddr_inb[31:0]), // Templated
			     .emesh_data_inb	(emesh_wr_data_inb[31:0]), // Templated
			     // Inputs
			     .aclk		(aclk),
			     .eclk		(eclk),
			     .reset		(reset),
			     .awid		(awid[SIDW-1:0]),
			     .awaddr		(awaddr[SAW-1:0]),
			     .awlen		(awlen[3:0]),
			     .awsize		(awsize[2:0]),
			     .awburst		(awburst[1:0]),
			     .awlock		(awlock[1:0]),
			     .awcache		(awcache[3:0]),
			     .awprot		(awprot[2:0]),
			     .awvalid		(awvalid),
			     .wid		(wid[SIDW-1:0]),
			     .wdata		(wdata[SDW-1:0]),
			     .wstrb		(wstrb[3:0]),
			     .wlast		(wlast),
			     .wvalid		(wvalid),
			     .bready		(bready),
			     .emesh_wr_wait_outb(emesh_wr_wait_outb)); // Templated
   
   //##################################
   //# Slave Read Port Instantiation
   //##################################
   
   /*axi_slave_rd AUTO_TEMPLATE(.emesh_rd_wait_outb (emesh_rd_wait),
                                .emesh_wr_wait_inb  (emesh_wr_wait_inb),
                                .emesh_\(.*\)_inb   (emesh_rd_\1_inb[]),
                               );
    */                                    

   axi_slave_rd axi_slave_rd(/*AUTOINST*/
			     // Outputs
			     .arready		(arready),
			     .rid		(rid[SIDW-1:0]),
			     .rdata		(rdata[SDW-1:0]),
			     .rresp		(rresp[1:0]),
			     .rlast		(rlast),
			     .rvalid		(rvalid),
			     .emesh_access_inb	(emesh_rd_access_inb), // Templated
			     .emesh_write_inb	(emesh_rd_write_inb), // Templated
			     .emesh_datamode_inb(emesh_rd_datamode_inb[1:0]), // Templated
			     .emesh_ctrlmode_inb(emesh_rd_ctrlmode_inb[3:0]), // Templated
			     .emesh_dstaddr_inb	(emesh_rd_dstaddr_inb[31:0]), // Templated
			     .emesh_srcaddr_inb	(emesh_rd_srcaddr_inb[31:0]), // Templated
			     .emesh_data_inb	(emesh_rd_data_inb[31:0]), // Templated
			     .emesh_wr_wait_inb	(emesh_wr_wait_inb), // Templated
			     // Inputs
			     .aclk		(aclk),
			     .eclk		(eclk),
			     .reset		(reset),
			     .arid		(arid[SIDW-1:0]),
			     .araddr		(araddr[SAW-1:0]),
			     .arlen		(arlen[3:0]),
			     .arsize		(arsize[2:0]),
			     .arburst		(arburst[1:0]),
			     .arlock		(arlock[1:0]),
			     .arcache		(arcache[3:0]),
			     .arprot		(arprot[2:0]),
			     .arvalid		(arvalid),
			     .rready		(rready),
			     .emesh_access_outb	(emesh_access_outb),
			     .emesh_write_outb	(emesh_write_outb),
			     .emesh_datamode_outb(emesh_datamode_outb[1:0]),
			     .emesh_ctrlmode_outb(emesh_ctrlmode_outb[3:0]),
			     .emesh_dstaddr_outb(emesh_dstaddr_outb[31:0]),
			     .emesh_srcaddr_outb(emesh_srcaddr_outb[31:0]),
			     .emesh_data_outb	(emesh_data_outb[31:0]),
			     .emesh_rd_wait_outb(emesh_rd_wait)); // Templated
   
   
endmodule // axi_slave
