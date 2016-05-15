//#############################################################################
//# Purpose: A DMA ENGINE                                                     #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################
module edma #( parameter AW  = 32,  // address width
	       parameter PW  = 104 // packet width
	       ) 
   (
    // power
    input 	    vdd, // supply
    input 	    vss, // common ground
    // reset, clk, config
    input 	    clk, // main core clock   
    input 	    nreset, // async active low reset
    output 	    irq, // interrupt output
    // datapath interface
    input 	    access_in, // streaming input access
    input [PW-1:0]  packet_in, // streaming input data 
    output 	    wait_out, // pushback
    output 	    access_out, // output access (master/slave)
    output [PW-1:0] packet_out, // output packet (with address)
    input 	    wait_in, // pushback
    // config/fetch interface
    input 	    reg_access_in, // config register access
    input [PW-1:0]  reg_packet_in, // config register packet
    output 	    reg_wait_out, // pushback by register read
    output 	    reg_access_out,// config readback
    output [PW-1:0] reg_packet_out,// config reacback packet
    input 	    reg_wait_in    // pushback for readback
    );
   
   //###############
   //# LOCAL WIRES
   //###############
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			chainmode;		// From edma_regs of edma_regs.v
   wire [31:0]		count;			// From edma_dp of edma_dp.v
   wire [31:0]		count_reg;		// From edma_regs of edma_regs.v
   wire [4:0]		ctrlmode;		// From edma_regs of edma_regs.v
   wire [15:0]		curr_descr;		// From edma_regs of edma_regs.v
   wire [1:0]		datamode;		// From edma_regs of edma_regs.v
   wire			dma_en;			// From edma_regs of edma_regs.v
   wire [3:0]		dma_state;		// From edma_ctrl of edma_ctrl.v
   wire [AW-1:0]	dstaddr;		// From edma_dp of edma_dp.v
   wire [63:0]		dstaddr_reg;		// From edma_regs of edma_regs.v
   wire			fetch_access;		// From edma_ctrl of edma_ctrl.v
   wire [PW-1:0]	fetch_packet;		// From edma_ctrl of edma_ctrl.v
   wire			manualmode;		// From edma_regs of edma_regs.v
   wire			master_active;		// From edma_ctrl of edma_ctrl.v
   wire			mastermode;		// From edma_regs of edma_regs.v
   wire [15:0]		next_descr;		// From edma_regs of edma_regs.v
   wire [AW-1:0]	srcaddr;		// From edma_dp of edma_dp.v
   wire [63:0]		srcaddr_reg;		// From edma_regs of edma_regs.v
   wire [31:0]		stride_reg;		// From edma_regs of edma_regs.v
   wire			update;			// From edma_ctrl of edma_ctrl.v
   wire			update2d;		// From edma_ctrl of edma_ctrl.v
   // End of automatics

   //##########################
   //# DATAPATH
   //##########################

   edma_dp #(.AW(AW),
	     .PW(PW))
   edma_dp(/*AUTOINST*/
	   // Outputs
	   .count			(count[31:0]),
	   .srcaddr			(srcaddr[AW-1:0]),
	   .dstaddr			(dstaddr[AW-1:0]),
	   .wait_out			(wait_out),
	   .access_out			(access_out),
	   .packet_out			(packet_out[PW-1:0]),
	   // Inputs
	   .clk				(clk),
	   .nreset			(nreset),
	   .master_active		(master_active),
	   .update2d			(update2d),
	   .datamode			(datamode[1:0]),
	   .ctrlmode			(ctrlmode[4:0]),
	   .stride_reg			(stride_reg[31:0]),
	   .count_reg			(count_reg[31:0]),
	   .srcaddr_reg			(srcaddr_reg[AW-1:0]),
	   .dstaddr_reg			(dstaddr_reg[AW-1:0]),
	   .access_in			(access_in),
	   .packet_in			(packet_in[PW-1:0]),
	   .wait_in			(wait_in));
   
   //##########################
   //# CONFIG REGISTERS
   //##########################

   edma_regs #(.AW(AW),
	       .PW(PW))
   edma_regs (/*AUTOINST*/
	      // Outputs
	      .reg_wait_out		(reg_wait_out),
	      .reg_access_out		(reg_access_out),
	      .reg_packet_out		(reg_packet_out[PW-1:0]),
	      .dma_en			(dma_en),
	      .mastermode		(mastermode),
	      .manualmode		(manualmode),
	      .datamode			(datamode[1:0]),
	      .ctrlmode			(ctrlmode[4:0]),
	      .chainmode		(chainmode),
	      .irq			(irq),
	      .next_descr		(next_descr[15:0]),
	      .curr_descr		(curr_descr[15:0]),
	      .stride_reg		(stride_reg[31:0]),
	      .count_reg		(count_reg[31:0]),
	      .dstaddr_reg		(dstaddr_reg[63:0]),
	      .srcaddr_reg		(srcaddr_reg[63:0]),
	      // Inputs
	      .clk			(clk),
	      .nreset			(nreset),
	      .reg_access_in		(reg_access_in),
	      .reg_packet_in		(reg_packet_in[PW-1:0]),
	      .reg_wait_in		(reg_wait_in),
	      .fetch_access		(fetch_access),
	      .fetch_packet		(fetch_packet[PW-1:0]),
	      .count			(count[31:0]),
	      .dstaddr			(dstaddr[AW-1:0]),
	      .srcaddr			(srcaddr[AW-1:0]),
	      .dma_state		(dma_state[3:0]),
	      .update			(update));

   //##########################
   //# STATE MACHINE
   //##########################

   edma_ctrl #(.AW(AW),
	       .PW(PW))
   edma_ctrl (/*AUTOINST*/
	      // Outputs
	      .fetch_access		(fetch_access),
	      .fetch_packet		(fetch_packet[PW-1:0]),
	      .dma_state		(dma_state[3:0]),
	      .update			(update),
	      .update2d			(update2d),
	      .master_active		(master_active),
	      // Inputs
	      .clk			(clk),
	      .nreset			(nreset),
	      .dma_en			(dma_en),
	      .chainmode		(chainmode),
	      .manualmode		(manualmode),
	      .mastermode		(mastermode),
	      .count			(count[31:0]),
	      .curr_descr		(curr_descr[15:0]),
	      .next_descr		(next_descr[15:0]),
	      .reg_wait_in		(reg_wait_in),
	      .access_in		(access_in),
	      .wait_in			(wait_in));
   
endmodule // edma

// Local Variables:
// verilog-library-directories:("." "../hdl" "../../common/hdl")
// End:

///////////////////////////////////////////////////////////////////////////////
// The MIT License (MIT)                                                     //
//                                                                           //
// Copyright (c) 2015-2016, Adapteva, Inc.                                   //
//                                                                           //
// Permission is hereby granted, free of charge, to any person obtaining a   //
// copy of this software and associated documentation files (the "Software") //
// to deal in the Software without restriction, including without limitation // 
// the rights to use, copy, modify, merge, publish, distribute, sublicense,  //
// and/or sell copies of the Software, and to permit persons to whom the     //
// Software is furnished to do so, subject to the following conditions:      //
//                                                                           //
// The above copyright notice and this permission notice shall be included   // 
// in all copies or substantial portions of the Software.                    //
//                                                                           //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS   //
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF                //
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.    //
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY      //
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT //
// OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR  //
// THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                //
//                                                                           // 
///////////////////////////////////////////////////////////////////////////////


