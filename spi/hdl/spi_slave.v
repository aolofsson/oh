//#############################################################################
//# Purpose: SPI slave module                                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

module spi_slave(/*AUTOARG*/
   // Outputs
   spi_regs, miso, core_spi_access, core_spi_packet, core_spi_wait,
   // Inputs
   nreset, chipid, sclk, mosi, ss, core_clk, core_access, core_packet
   );

   //parameters
   parameter  REGS  = 16;                // total regs   
   parameter  AW    = 32;                // addresss width
   localparam PW    = (2*AW+40);         // packet width
 
   //clk,reset, cfg
   input 	        nreset;          // async active low reset
   input [7:0] 		chipid;          // chip id
   output [REGS*8-1:0]  spi_regs;        // all registers for control

   //IO interface
   input 		sclk;            // serial clock
   input 		mosi;            // slave input
   input 		ss;              // slave select
   output 		miso;            // slave output
   
   //core interface (cclk domain)
   input 		core_clk;        // core clock (for synchronization)
   output 		core_spi_access; // valid transaction
   output [PW-1:0] 	core_spi_packet; // data to core
   output 		core_spi_wait;   // pushback to core
   input 		core_access;     // read response from core
   input [PW-1:0] 	core_packet;     // read response packet from core

   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			core_spi_read;		// From spi_slave_io of spi_slave_io.v
   wire [6:0]		spi_addr;		// From spi_slave_io of spi_slave_io.v
   wire			spi_clk;		// From spi_slave_io of spi_slave_io.v
   wire [7:0]		spi_data;		// From spi_slave_io of spi_slave_io.v
   wire			spi_write;		// From spi_slave_io of spi_slave_io.v
   // End of automatics
   
   spi_slave_regs #(.AW(AW))
   spi_slave_regs (/*AUTOINST*/
		   // Outputs
		   .spi_regs		(spi_regs[REGS*8-1:0]),
		   // Inputs
		   .nreset		(nreset),
		   .chipid		(chipid[7:0]),
		   .spi_clk		(spi_clk),
		   .spi_data		(spi_data[7:0]),
		   .spi_write		(spi_write),
		   .spi_addr		(spi_addr[5:0]),
		   .core_clk		(core_clk),
		   .core_access		(core_access),
		   .core_packet		(core_packet[PW-1:0]),
		   .core_spi_read	(core_spi_read));
   

   spi_slave_io #(.AW(AW),
		  .REGS(REGS)
		  )
   spi_slave_io (/*AUTOINST*/
		 // Outputs
		 .miso			(miso),
		 .spi_clk		(spi_clk),
		 .spi_write		(spi_write),
		 .spi_addr		(spi_addr[6:0]),
		 .spi_data		(spi_data[7:0]),
		 .core_spi_access	(core_spi_access),
		 .core_spi_packet	(core_spi_packet[PW-1:0]),
		 .core_spi_read		(core_spi_read),
		 // Inputs
		 .sclk			(sclk),
		 .mosi			(mosi),
		 .ss			(ss),
		 .spi_regs		(spi_regs[REGS*8-1:0]),
		 .core_clk		(core_clk));
   
   
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
