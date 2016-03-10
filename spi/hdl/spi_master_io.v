//#############################################################################
//# Purpose: SPI slave IO and statemachine                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

module spi_master_io(/*AUTOARG*/
   // Outputs
   spi_state, fifo_read, rx_data, rx_access, sclk, mosi, ss,
   // Inputs
   clk, nreset, spi_en, cpol, cpha, lsbfirst, clkdiv_reg, fifo_dout,
   fifo_empty, miso
   );

   //#################################
   //# INTERFACE
   //#################################

   //parameters
   parameter  REGS  = 16;         // total regs  (16/32/64) 
   parameter  AW    = 32;         // address width
   localparam PW    = (2*AW+40);  // packet width
   
   //clk, reset, cfg
   input 	   clk;        // core clock
   input 	   nreset;     // async active low reset
   
   //cfg
   input 	   spi_en;     // spi enable
   input 	   cpol;       // cpol
   input 	   cpha;       // cpha
   input 	   lsbfirst;   // send lsbfirst   
   input [7:0] 	   clkdiv_reg; // baudrate	 
   output [1:0]    spi_state;  // current spi tx state
     
   //data to transmit
   input [7:0] 	   fifo_dout;  // data payload
   input 	   fifo_empty; // 
   output 	   fifo_read;  // read new byte
   
   //receive data (for sregs)
   output [63:0]   rx_data;    // rx data
   output 	   rx_access;  // transfer done
   
   //IO interface
   output 	   sclk;       // spi clock
   output 	   mosi;       // slave input
   output 	   ss;         // slave select
   input 	   miso;       // slave output

   reg [7:0] 	   baud_counter = 'b0; //works b/c of free running counter!
   reg [1:0] 	   spi_state;
   reg [2:0] 	   bit_count;
   reg 		   fifo_empty_reg;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			clkout;			// From oh_clockdiv of oh_clockdiv.v
   wire			period_match;		// From oh_clockdiv of oh_clockdiv.v
   wire			phase_match;		// From oh_clockdiv of oh_clockdiv.v
   // End of automatics
   
//states
`define SPI_IDLE    2'b00  // set ss to 1
`define SPI_SETUP   2'b01  // setup time
`define SPI_DATA    2'b10  // send data
`define SPI_HOLD    2'b11  // hold time
   
   //#################################
   //# CLOCK GENERATOR
   //#################################
   
   oh_clockdiv #(.DW(8))
   oh_clockdiv (.clkdiv		(clkdiv_reg[2:0]),
		.en			(1'b1),
		/*AUTOINST*/
		// Outputs
		.period_match		(period_match),
		.phase_match		(phase_match),
		.clkout			(clkout),
		// Inputs
		.clk			(clk),
		.nreset			(nreset));
    
   assign sclk = clkout & (spi_state[1:0]==`SPI_DATA);
    
   //#################################
   //# STATE MACHINE
   //#################################
      
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       spi_state[1:0] <=  `SPI_IDLE;
     else if(period_match)
       case (spi_state[1:0])
	 `SPI_IDLE : 
	   spi_state[1:0] <= ~fifo_empty ? `SPI_SETUP : `SPI_IDLE;
	 `SPI_SETUP :
	   spi_state[1:0] <=`SPI_DATA;
	 `SPI_DATA : 
	   begin
	      spi_state[1:0] <= fifo_empty_reg & byte_done ? `SPI_HOLD : `SPI_DATA;
	      fifo_empty_reg <= fifo_empty;
	   end
	 `SPI_HOLD : 
	   spi_state[1:0] <= `SPI_IDLE;
     endcase // case (spi_state[1:0])
   
   //Bit counter
   always @ (posedge clk)
     if(spi_state[1:0]==`SPI_IDLE)
       bit_count[2:0] <= 'b0;
     else if(period_match)
       bit_count[2:0] <=  bit_count[2:0] + 1'b1;

   //byte done indicator
   assign byte_done  = (bit_count[2:0]==3'b000);

   //read fifo on phase match (due to one cycle pipeline latency
   assign fifo_read = ((spi_state[1:0]==`SPI_IDLE) & phase_match ) |
		      ((spi_state[1:0]==`SPI_DATA) & phase_match & byte_done);

   //load once per byte
   assign load_byte = period_match & byte_done & (spi_state[1:0]!=`SPI_IDLE);
   
   //shift on every clock cycle while in datamode
   assign shift     = period_match & (spi_state[1:0]==`SPI_DATA);

   //#################################
   //# CHIP SELECT
   //#################################
   
   assign ss = (spi_state[1:0]==`SPI_IDLE);
         
   //#################################
   //# TX SHIFT REGISTER
   //#################################

   oh_par2ser  #(.PW(8),
		 .SW(1))
   par2ser (// Outputs
	    .dout	(mosi),           // serial output
	    .access_out	(),
	    .wait_out	(),
	    // Inputs
	    .clk	(clk),
	    .nreset	(nreset),         // async active low reset
	    .din	(fifo_dout[7:0]), // 8 bit data from fifo
	    .shift	(shift),          // shift on neg edge
	    .datasize	(3'b111),         // 8 bits
	    .load	(load_byte),      // load data from fifo
	    .lsbfirst	(lsbfirst),       // serializer direction
	    .fill	(1'b0),           // fill with slave data
	    .wait_in	(1'b0)            // no wait
	    );

   //#################################
   //# RX SHIFT REGISTER
   //#################################

   //generate access pulse at rise of ss
   oh_rise2pulse 
     pulse (.out (rx_access),
	    .clk (clk),
	    .in	 (ss));
   
   oh_ser2par #(.PW(64))
   ser2par (//output
	    .dout	(rx_data[63:0]),  // parallel data out
	    //inputs
	    .din	(miso),           // serial data in
	    .clk	(clk),            // shift clk
	    .lsbfirst	(lsbfirst),       // shift direction
	    .shift	(shift));         // shift data
         
endmodule // spi_slave_io

// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emesh/hdl") 
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


