//#############################################################################
//# Purpose: SPI master (configurable)                                        #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

module spi_master(/*AUTOARG*/
   // Outputs
   sclk, mosi, ss, wait_out, access_out, packet_out,
   // Inputs
   clk, nreset, hw_en, miso, access_in, packet_in, wait_in
   );

   //parameters
   parameter  DEPTH = 32;                // fifo depth   
   parameter  REGS  = 16;                // total regs   
   parameter  AW    = 32;                // addresss width
   localparam PW    = (2*AW+40);         // packet width
 
   //clk,reset, cfg
   input 		clk;             // core clock
   input 	        nreset;          // async active low reset
   input 		hw_en;           // hardware enable pin
   
   //IO interface
   output 		sclk;            // spi clock
   output 		mosi;            // slave input
   output 		ss;              // slave select
   input 		miso;            // slave output
   
   //packet to transmit
   input 		access_in;       // access from core
   input [PW-1:0] 	packet_in;       // data to core
   output 		wait_out;        // pushback from spi register

   //return packet
   output 		access_out;      // readback access 
   output [PW-1:0] 	packet_out;      // packet from spi register
   input 		wait_in;         // pushback by core
 
   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [7:0]		clkdiv_reg;		// From spi_master_regs of spi_master_regs.v
   wire			cpha;			// From spi_master_regs of spi_master_regs.v
   wire			cpol;			// From spi_master_regs of spi_master_regs.v
   wire [7:0]		fifo_dout;		// From spi_master_fifo of spi_master_fifo.v
   wire			fifo_empty;		// From spi_master_fifo of spi_master_fifo.v
   wire			fifo_prog_full;		// From spi_master_fifo of spi_master_fifo.v
   wire			fifo_read;		// From spi_master_io of spi_master_io.v
   wire			fifo_wait;		// From spi_master_fifo of spi_master_fifo.v
   wire			lsbfirst;		// From spi_master_regs of spi_master_regs.v
   wire			rx_access;		// From spi_master_io of spi_master_io.v
   wire [63:0]		rx_data;		// From spi_master_io of spi_master_io.v
   wire			spi_en;			// From spi_master_regs of spi_master_regs.v
   wire [1:0]		spi_state;		// From spi_master_io of spi_master_io.v
   // End of automatics

   //#####################################################
   //# Master control registers
   //#####################################################
   
   spi_master_regs #(.AW(AW))
   spi_master_regs (/*AUTOINST*/
		    // Outputs
		    .cpol		(cpol),
		    .cpha		(cpha),
		    .lsbfirst		(lsbfirst),
		    .spi_en		(spi_en),
		    .clkdiv_reg		(clkdiv_reg[7:0]),
		    .wait_out		(wait_out),
		    .access_out		(access_out),
		    .packet_out		(packet_out[PW-1:0]),
		    // Inputs
		    .clk		(clk),
		    .nreset		(nreset),
		    .hw_en		(hw_en),
		    .rx_data		(rx_data[63:0]),
		    .rx_access		(rx_access),
		    .spi_state		(spi_state[1:0]),
		    .fifo_prog_full	(fifo_prog_full),
		    .fifo_wait		(fifo_wait),
		    .access_in		(access_in),
		    .packet_in		(packet_in[PW-1:0]),
		    .wait_in		(wait_in));
   
   //#####################################################
   //# Transmit FIFO (SPI_TX)
   //#####################################################

   /* spi_master_fifo AUTO_TEMPLATE (.wait_out		(fifo_wait), 
                                    .fifo_dout		(fifo_dout[7:0]),
    );
        */
   
   spi_master_fifo #(.AW(AW),
		     .DEPTH(DEPTH))
   spi_master_fifo(
		   /*AUTOINST*/
		   // Outputs
		   .fifo_prog_full	(fifo_prog_full),
		   .wait_out		(fifo_wait),		 // Templated
		   .fifo_empty		(fifo_empty),
		   .fifo_dout		(fifo_dout[7:0]),	 // Templated
		   // Inputs
		   .clk			(clk),
		   .nreset		(nreset),
		   .spi_en		(spi_en),
		   .access_in		(access_in),
		   .packet_in		(packet_in[PW-1:0]),
		   .fifo_read		(fifo_read));
   
   //#####################################################
   //# SPI IO (8 bit)
   //#####################################################
     
   spi_master_io #(.AW(AW))
   spi_master_io (/*AUTOINST*/
		  // Outputs
		  .spi_state		(spi_state[1:0]),
		  .fifo_read		(fifo_read),
		  .rx_data		(rx_data[63:0]),
		  .rx_access		(rx_access),
		  .sclk			(sclk),
		  .mosi			(mosi),
		  .ss			(ss),
		  // Inputs
		  .clk			(clk),
		  .nreset		(nreset),
		  .cpol			(cpol),
		  .cpha			(cpha),
		  .lsbfirst		(lsbfirst),
		  .clkdiv_reg		(clkdiv_reg[7:0]),
		  .fifo_dout		(fifo_dout[7:0]),
		  .fifo_empty		(fifo_empty),
		  .miso			(miso));
   
   
endmodule // spi_master

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
