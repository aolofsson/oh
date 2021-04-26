//#############################################################################
//# Purpose: DMA datapath                                                     #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################
module edma_dp (/*AUTOARG*/
   // Outputs
   count, srcaddr, dstaddr, wait_out, access_out, packet_out,
   // Inputs
   clk, nreset, master_active, update2d, datamode, ctrlmode,
   stride_reg, count_reg, srcaddr_reg, dstaddr_reg, access_in,
   packet_in, wait_in
   );

   parameter  AW   = 8;            // divider counter width
   parameter  PW  = 2*AW+40;      // emesh packet width
   
   // clk, reset, config
   input           clk;           // main clock
   input 	   nreset;        // async active low reset
   input 	   master_active; // master mode active
   input 	   update2d;      // outer loop transfer
   input [1:0] 	   datamode;      // datamode for master mode
   input [4:0] 	   ctrlmode;      // ctrlmode for master mode    

   // data registers
   input [31:0]    stride_reg;    // transfer stride
   input [31:0]    count_reg;     // starting count
   input [AW-1:0]  srcaddr_reg;   // starting source address
   input [AW-1:0]  dstaddr_reg;   // starting destination address

   // output to register file
   output [31:0]   count;         // current count
   output [AW-1:0] srcaddr;       // current source address
   output [AW-1:0] dstaddr;       // current source address

   // datapath interface
   input 	   access_in;   
   input [PW-1:0]  packet_in;     // streaming input data 
   output 	   wait_out;
   
   output 	   access_out;        
   output [PW-1:0] packet_out;    // output packet (with address)
   input 	   wait_in;       // pushback
   
   //######################################################################
   //# BODY
   //######################################################################

   // regs
   reg [PW-1:0]    packet_out;
   reg 		   access_out;
   
   // wires
   wire [4:0] 	   ctrlmode_out;
   wire [AW-1:0]   data_out;	
   wire [1:0] 	   datamode_out;
   wire [AW-1:0]   dstaddr_out;	
   wire [AW-1:0]   srcaddr_out;	
   wire 	   write_out;	
   wire [PW-1:0]   packet;

   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	data_in;		// From p2e of packet2emesh.v
   wire [1:0]		datamode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From p2e of packet2emesh.v
   wire			write_in;		// From p2e of packet2emesh.v
   // End of automatics
   /*AUTOINPUT*/
   
   //################################
   //# COUNT
   //################################ 
   
   assign count[31:0] = update2d ? {(count_reg[31:16] - 1'b1),count_reg[15:0]} :
		                     count_reg[31:0] - 1'b1;
   
   //################################
   //# SRCADDR
   //################################ 

   assign srcaddr[AW-1:0] = srcaddr_reg[AW-1:0] + 
			    {{(AW-16){stride_reg[15]}},stride_reg[15:0]};

   //################################
   //# DSTADDR
   //################################ 

   assign dstaddr[AW-1:0] = dstaddr_reg[AW-1:0] + 
			    {{(AW-16){stride_reg[31]}},stride_reg[31:16]};
   
   //################################
   //# MASTER/SLAVE MUX
   //################################ 
   
   // parsing input packet
   packet2emesh #(.AW(AW),
		  .PW(PW))
   p2e (/*AUTOINST*/
	// Outputs
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[4:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]),
	// Inputs
	.packet_in			(packet_in[PW-1:0]));

   //master/slave mux
   
   assign write_out           = master_active ? 1'b0          : 1'b1;
   assign datamode_out[1:0]   = master_active ? datamode[1:0] : datamode_in[1:0];
   assign ctrlmode_out[4:0]   = master_active ? ctrlmode[4:0] : ctrlmode_in[4:0];
   assign dstaddr_out[AW-1:0] = dstaddr[AW-1:0];
   assign data_out[AW-1:0]    = master_active ? {(AW){1'b0}}  : data_in[31:0];
   assign srcaddr_out[AW-1:0] = master_active ? {(AW){1'b0}}  : srcaddr_in[31:0];
   
   // constructing output packet
   emesh2packet #(.AW(AW),
		  .PW(PW))
   e2p (.packet_out			(packet[PW-1:0]),
     /*AUTOINST*/
	// Inputs
	.write_out			(write_out),
	.datamode_out			(datamode_out[1:0]),
	.ctrlmode_out			(ctrlmode_out[4:0]),
	.dstaddr_out			(dstaddr_out[AW-1:0]),
	.data_out			(data_out[AW-1:0]),
	.srcaddr_out			(srcaddr_out[AW-1:0]));

   //################################
   //# REGISTER (FOR TIMING PURPOSES)
   //################################ 

   //pipelining the packet
   always @ (posedge clk)
     if(~wait_in)
       packet_out[PW-1:0] <= packet[PW-1:0];
   
   // access signal
   always @ (posedge clk)
     if(~wait_in)
       access_out <= access_in | master_active;

   //wait pass through (for slave access)
   assign wait_out = wait_in;
   
endmodule // edma_dp
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



