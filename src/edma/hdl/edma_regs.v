//#############################################################################
//# Purpose: DMA registers                                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

`include "edma_regmap.vh"
module edma_regs (/*AUTOARG*/
   // Outputs
   reg_wait_out, reg_access_out, reg_packet_out, dma_en, mastermode,
   manualmode, datamode, ctrlmode, chainmode, irq, next_descr,
   curr_descr, stride_reg, count_reg, dstaddr_reg, srcaddr_reg,
   // Inputs
   clk, nreset, reg_access_in, reg_packet_in, reg_wait_in,
   fetch_access, fetch_packet, count, dstaddr, srcaddr, dma_state,
   update
   );

   // parameters 
   parameter  AW      = 8;         // address width
   parameter  PW      = 2*AW+40;   // emesh packet width
   parameter  DEF_CFG = 0;         // default config after reset   
   
   // clk, reset
   input           clk;           // main clock
   input 	   nreset;        // async active low reset   

   // config interface
   input 	   reg_access_in;     // config register access
   input [PW-1:0]  reg_packet_in;     // config register packet
   output          reg_wait_out;      // pushback by register read   
   output 	   reg_access_out;    // config readback
   output [PW-1:0] reg_packet_out;    // config reacback packet
   input 	   reg_wait_in;       // pushback for readback

   // descriptor fetch interface
   input 	   fetch_access;  // fetch descriptor
   input [PW-1:0]  fetch_packet;  // fetch packet (mux with readback)
   
   // config outputs
   output 	   dma_en;        // enable dma   
   output 	   mastermode;    // dma in master mode
   output 	   manualmode;    // 0=fetch descriptor, 1=assume config ready
   output [1:0]    datamode;      // transfer size (8,16,32,64 bits)
   output [4:0]    ctrlmode;      // ctrlmode
   output 	   chainmode;     // auto wrap around 
   output 	   irq;           // interrupt output
   output [15:0]   next_descr;    // pointer to next descriptor
   output [15:0]   curr_descr;    // pointer to current descriptor    
   
   // datapath regs
   output [31:0]   stride_reg;    // stride
   output [31:0]   count_reg;     // register transfer count
   output [63:0]   dstaddr_reg;   // register destination address
   output [63:0]   srcaddr_reg;   // register source address

   
   
   // datapath inputs
   input [31:0]    count;         // current count
   input [AW-1:0]  dstaddr;       // current destination address
   input [AW-1:0]  srcaddr;       // current source address
   
   // status
   input [3:0] 	   dma_state;     // dma sequencer state
   input 	   update;        // update registers
   
   //######################################################################
   //# BODY
   //######################################################################
   
   // regs
   reg [31:0] 	   config_reg;
   reg [31:0] 	   count_reg;
   reg [31:0] 	   stride_reg;   
   reg [63:0] 	   dstaddr_reg;   
   reg [63:0] 	   srcaddr_reg;
   reg [31:0] 	   status_reg;

   // wires
   wire 	   reg_write;
   wire 	   config_write;
   wire 	   stride_write;
   wire 	   count_write;
   wire 	   srcaddr0_write;
   wire 	   srcaddr1_write;
   wire 	   dstaddr0_write;
   wire 	   dstaddr1_write;
   wire 	   status_write;
   wire 	   irqmode;

   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	data_in;		// From p2e of packet2emesh.v
   wire [1:0]		datamode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From p2e of packet2emesh.v
   wire			write_in;		// From p2e of packet2emesh.v
   // End of automatics

   //################################
   //# DECODE
   //################################
   
   packet2emesh #(.AW(AW),
		  .PW(PW))
   p2e (.packet_in			(reg_packet_in[PW-1:0]),
	/*AUTOINST*/
	// Outputs
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[4:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]));

   assign reg_write      = write_in & reg_access_in;
   assign config_write   = reg_write & (dstaddr_in[6:2]==`EDMA_CONFIG);
   assign stride_write   = reg_write & (dstaddr_in[6:2]==`EDMA_STRIDE);
   assign count_write    = reg_write & (dstaddr_in[6:2]==`EDMA_COUNT);
   assign srcaddr0_write = reg_write & (dstaddr_in[6:2]==`EDMA_SRCADDR);
   assign srcaddr1_write = reg_write & (dstaddr_in[6:2]==`EDMA_SRCADDR64);
   assign dstaddr0_write = reg_write & (dstaddr_in[6:2]==`EDMA_DSTADDR);
   assign dstaddr1_write = reg_write & (dstaddr_in[6:2]==`EDMA_DSTADDR64);
   assign status_write   = reg_write & (dstaddr_in[6:2]==`EDMA_STATUS);

   //################################
   //# CONFIG
   //################################ 

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       config_reg[31:0] <= DEF_CFG;
     else if(config_write)
       config_reg[31:0] <= data_in[31:0];
   
   assign dma_en             = config_reg[0];    // dma enabled
   assign mastermode         = config_reg[1];    // dma in master mode
   assign chainmode          = config_reg[2];    // autostart when done
   assign manualmode         = ~config_reg[3];   // fetch descriptor if=1
   assign irqmode            = config_reg[4];    // enable irq at end of transfer
   assign datamode[1:0]      = config_reg[6:5];  // datamode (8/16/32/64 bits)   
   assign ctrlmode[4:0]      = 5'b0;             // bits 10-11 reserved
   assign next_descr[15:0]   = config_reg[31:16];// pointer to fetch descriptor
   
   //################################
   //# STRIDE
   //################################ 
   always @ (posedge clk)
     if(stride_write)
       stride_reg[31:0]  <= data_in[31:0];

   //################################
   //# COUNT
   //################################ 

   always @ (posedge clk)
     if(count_write)
       count_reg[31:0] <= data_in[31:0];
     else if (update)
       count_reg[31:0] <= count[31:0];

   //################################
   //# SRCADDR
   //################################ 

   always @ (posedge clk)
     if(srcaddr0_write)
       srcaddr_reg[31:0]  <= data_in[31:0];
     else if(srcaddr1_write)
       srcaddr_reg[63:32] <= data_in[31:0];
     else if (update)
       srcaddr_reg[AW-1:0] <= srcaddr[AW-1:0];

   //################################
   //# DSTADDR
   //################################ 

   always @ (posedge clk)
     if(dstaddr0_write)
       dstaddr_reg[31:0]  <= data_in[31:0];
     else if(dstaddr1_write)
       dstaddr_reg[63:32] <= data_in[31:0];
     else if (update)
       dstaddr_reg[AW-1:0] <= dstaddr[AW-1:0];

   //################################
   //# STATUS
   //################################ 

   always @ (posedge clk)
     if(status_write)
       status_reg[31:0]  <= data_in[31:0];
     else if (config_write)
       status_reg[31:0]  <= {next_descr[15:0],
                             12'b0,
			     dma_state[3:0]};

   assign curr_descr[15:0] = status_reg[31:16];

   //################################
   //# READBACK CIRCUIT
   //################################ 

   //TODO: no readback for now
   assign reg_wait_out   = 1'b0 ;

   assign reg_access_out = fetch_access;

   assign reg_packet_out[PW-1:0] = fetch_packet[PW-1:0];

   //################################
   //# READBACK CIRCUIT
   //################################ 
   assign irq = 1'b0;
   
endmodule // edma_regs


// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl") 
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


