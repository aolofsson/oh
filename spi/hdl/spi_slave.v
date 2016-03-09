//#############################################################################
//# Purpose: SPI slave module                                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

module spi_slave(/*AUTOARG*/
   // Outputs
   spi_regs, spi_irq, miso, access_out, packet_out, wait_out,
   // Inputs
   clk, nreset, sclk, mosi, ss, wait_in, access_in, packet_in
   );

   //parameters
   parameter  SREGS = 16;                // total spi slave regs   
   parameter  AW    = 32;                // addresss width
   localparam PW    = (2*AW+40);         // packet width
 
   //clk,reset, cfg
   input 		clk;             // core clock
   input 	        nreset;          // async active low reset
   output [SREGS*8-1:0] spi_regs;        // all registers for control
   output 		spi_irq;         // interrupt
   
   //IO interface
   input 		sclk;            // spi clock
   input 		mosi;            // slave input
   input 		ss;              // slave select
   output 		miso;            // slave output
   
 
   // read request to core
   output 		access_out;      // valid transaction
   output [PW-1:0] 	packet_out;      // data to core
   input 		wait_in;         // pushback from core

   // return from core
   input 		access_in;       // read response from core
   input [PW-1:0] 	packet_in;       // read response packet from core
   output 		wait_out;        // pushback (not used)
      
   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [6:0]		spi_addr;		// From spi_slave_io of spi_slave_io.v
   wire			spi_clk;		// From spi_slave_io of spi_slave_io.v
   wire [7:0]		spi_data;		// From spi_slave_io of spi_slave_io.v
   wire			spi_request;		// From spi_slave_io of spi_slave_io.v
   wire			spi_write;		// From spi_slave_io of spi_slave_io.v
   // End of automatics
   
   spi_slave_regs #(.AW(AW),
		    .SREGS(SREGS)
		    )
   spi_slave_regs (/*AUTOINST*/
		   // Outputs
		   .spi_regs		(spi_regs[SREGS*8-1:0]),
		   .wait_out		(wait_out),
		   // Inputs
		   .clk			(clk),
		   .nreset		(nreset),
		   .spi_clk		(spi_clk),
		   .spi_data		(spi_data[7:0]),
		   .spi_write		(spi_write),
		   .spi_addr		(spi_addr[5:0]),
		   .access_in		(access_in),
		   .packet_in		(packet_in[PW-1:0]),
		   .spi_request		(spi_request));
   

   spi_slave_io #(.AW(AW),
		  .SREGS(SREGS)
		  )
   spi_slave_io (/*AUTOINST*/
		 // Outputs
		 .miso			(miso),
		 .spi_clk		(spi_clk),
		 .spi_write		(spi_write),
		 .spi_addr		(spi_addr[6:0]),
		 .spi_data		(spi_data[7:0]),
		 .access_out		(access_out),
		 .packet_out		(packet_out[PW-1:0]),
		 .spi_request		(spi_request),
		 // Inputs
		 .sclk			(sclk),
		 .mosi			(mosi),
		 .ss			(ss),
		 .spi_regs		(spi_regs[SREGS*8-1:0]),
		 .clk			(clk));
   
   
endmodule // spi_slave

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
