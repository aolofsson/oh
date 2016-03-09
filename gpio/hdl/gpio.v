//#############################################################################
//# Function: General Purpose Software Programmable IO                        #
//# (See README.md for complete documentation)                                #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################
`include "gpio_regmap.vh"
module gpio(/*AUTOARG*/
   // Outputs
   reg_rdata, gpio_out, gpio_oen, gpio_irq, gpio_data,
   // Inputs
   nreset, clk, reg_access, reg_packet, gpio_in
   );
  
   //##########################################
   //# INTERFACE
   //##########################################

   parameter  N      = 24;      // number of gpio pins
   parameter  AW     = 32;      // address width
   parameter  PW     = 2*AW+40; // packet width   
   parameter  ID     = 0;       // block id to match to, bits [10:8]
      
   //clk, reset
   input           nreset;      // asynchronous active low reset
   input 	   clk;         // clock

   //register access interface
   input 	   reg_access;  // register access
   input [PW-1:0]  reg_packet;  // data/address
   output [31:0]   reg_rdata;   // readback data

   //IO signals
   output [N-1:0]  gpio_out;    // data to drive to IO pins
   output [N-1:0]  gpio_oen;    // tristate enables for IO pins
   input [N-1:0]   gpio_in;     // data from IO pins
   
   //global interrupt   
   output 	   gpio_irq;    // toggle detect edge interrupt
   output [N-1:0]  gpio_data;   // individual interrupt outputs
   
   //##################################################################
   //# BODY
   //##################################################################
   
   //registers
   reg [63:0] 	   oen_reg;
   reg [63:0] 	   out_reg;
   reg [63:0] 	   ien_reg;
   reg [63:0] 	   in_reg;
   reg [63:0] 	   imask_reg;
   reg [31:0] 	   reg_rdata;

   //nets
   wire [N-1:0]    gpio_sync;
   wire [N-1:0]    gpio_edge;  
   wire [N-1:0]    edge_data;   
   wire [63:0] 	   reg_wdata;
   wire [63:0] 	   out_dmux;   
   integer 	   i,j;

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
   //# SYNCHRONIZE INPUT DATA
   //################################  

   oh_dsync #(.DW(N))
   dsync (.dout	(gpio_sync[N-1:0]),
          .clk	(clk),
          .din	(gpio_in[N-1:0]));
   
   //################################
   //# REGISTER ACCESS DECODE
   //################################  
   
   packet2emesh p2e(.packet_in		(reg_packet[PW-1:0]),
		    /*AUTOINST*/
		    // Outputs
		    .write_in		(write_in),
		    .datamode_in	(datamode_in[1:0]),
		    .ctrlmode_in	(ctrlmode_in[4:0]),
		    .dstaddr_in		(dstaddr_in[AW-1:0]),
		    .srcaddr_in		(srcaddr_in[AW-1:0]),
		    .data_in		(data_in[AW-1:0]));

   assign reg_write        = reg_access & write_in;
   assign reg_read         = reg_access & ~write_in;
   assign reg_double       = datamode_in[1:0]==2'b11;
   assign reg_wdata[63:0]  = {srcaddr_in[31:0],data_in[31:0]};
   
   assign oen_write     = reg_write & (dstaddr_in[7:3]==`GPIO_OEN);
   assign out_write     = reg_write & (dstaddr_in[7:3]==`GPIO_OUT);
   assign ien_write     = reg_write & (dstaddr_in[7:3]==`GPIO_IEN);
   assign in_write      = reg_write & (dstaddr_in[7:3]==`GPIO_IN);
   assign outand_write  = reg_write & (dstaddr_in[7:3]==`GPIO_OUTAND);
   assign outorr_write  = reg_write & (dstaddr_in[7:3]==`GPIO_OUTORR);
   assign outxor_write  = reg_write & (dstaddr_in[7:3]==`GPIO_OUTXOR);
   assign imask_write   = reg_write & (dstaddr_in[7:3]==`GPIO_IMASK);

   assign out_reg_write = out_write |
	                  outand_write |
			  outorr_write |
			  outxor_write;
      
   //################################
   //# OUTPUT
   //################################ 
   //oen (active low, tristate by default)
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       oen_reg[63:0] <= 'b0;   
     else if(oen_write & reg_double)
       oen_reg[63:0] <= reg_wdata[63:0];
     else if(oen_write)
       oen_reg[31:0] <= reg_wdata[31:0];
   
   assign gpio_oen[N-1:0] = oen_reg[N-1:0];
   
   //odata
   oh_mux4 #(.DW(64))
   oh_mux4 (.out (out_dmux[63:0]),
	    // Inputs
	    .in0 (reg_wdata[63:0]                ),.sel0 (out_write),
	    .in1 (out_reg[63:0] & reg_wdata[63:0]),.sel1 (outand_write),
	    .in2 (out_reg[63:0] | reg_wdata[63:0]),.sel2 (outorr_write),
	    .in3 (out_reg[63:0] ^ reg_wdata[63:0]),.sel3 (outxor_write));
   
   always @ (posedge clk)
     if(out_reg_write & reg_double)
       out_reg[63:0] <= out_dmux[63:0];
     else if(out_reg_write)
       out_reg[31:0] <= out_dmux[31:0];
 
   assign gpio_out[N-1:0] = out_reg[N-1:0];

   //################################
   //# INPUT
   //################################ 

   //ien
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       ien_reg[63:0] <= {(64){1'b1}}; 
     else if(ien_write & reg_double)
       ien_reg[63:0] <= reg_wdata[63:0];
     else if(ien_write)
       ien_reg[31:0] <= reg_wdata[31:0];

   //idata
   always @ (posedge clk)
     in_reg[63:0] <= gpio_sync[N-1:0] & ien_reg[63:0];

   assign gpio_data[N-1:0] = in_reg[63:0];

   //################################
   //# EDGE DETECTOR
   //################################ 

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       imask_reg[63:0] <= 'b0;   
     else if(imask_write & reg_double)
       imask_reg[63:0] <= reg_wdata[63:0];
     else if(imask_write)
       imask_reg[31:0] <= reg_wdata[31:0];

   assign edge_data[N-1:0] = ~imask_reg[N-1:0] & in_reg[N-1:0];
   
   //detect any edge on input data
   oh_edgedetect #(.DW(N))
   oh_edgedetect (.out	(gpio_edge[N-1:0]),
		  .clk	(clk),
		  .cfg	(2'b11), //toggle detect
		  .in	(edge_data[N-1:0])
		  );

   assign gpio_irq = |gpio_edge[N-1:0];
			    
   //################################
   //# READBACK
   //################################ 
   
   assign odd = (N>32) & dstaddr_in[2];
         
   always @ (posedge clk)
     if(reg_read)
       case(dstaddr_in[7:3])		 
	 `GPIO_OEN     :  reg_rdata[31:0] <= odd ? oen_reg[63:32]     : 
					           oen_reg[31:0];
	 `GPIO_OUT     :  reg_rdata[31:0] <= odd ? out_reg[63:32]     : 
					           out_reg[31:0];
	 `GPIO_IEN     :  reg_rdata[31:0] <= odd ? ien_reg[63:32]     : 
					           ien_reg[31:0]; 
	 `GPIO_IN      :  reg_rdata[31:0] <= odd ? in_reg[63:32]      : 
					           in_reg[31:0];	 
	 `GPIO_IMASK   :  reg_rdata[31:0] <= odd ? imask_reg[63:32]   : 
					           imask_reg[31:0];	 
	 default       :  reg_rdata[31:0] <='b0;
       endcase // case (dstaddr_in[7:3])

endmodule // gpio
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:

//////////////////////////////////////////////////////////////////////////////
// The MIT License (MIT)                                                    //
//                                                                          //
// Copyright (c) 2015-2016, Adapteva, Inc.                                  //
//                                                                          //
// Permission is hereby granted, free of charge, to any person obtaining a  //
// copy of this software and associated documentation files (the "Software")//
// to deal in the Software without restriction, including without limitation// 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, //
// and/or sell copies of the Software, and to permit persons to whom the    //
// Software is furnished to do so, subject to the following conditions:     //
//                                                                          //
// The above copyright notice and this permission notice shall be included  // 
// in all copies or substantial portions of the Software.                   //
//                                                                          //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS  //
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF               //
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.   //
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY     //
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT//
// OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR //
// THE USE OR OTHER DEALINGS IN THE SOFTWARE.                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
