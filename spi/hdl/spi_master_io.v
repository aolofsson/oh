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
   output [7:0]    rx_data;    // rx data
   output 	   rx_access;  // rx ready pulse
   
   //IO interface
   output 	   sclk;       // spi clock
   output 	   mosi;       // slave input
   output 	   ss;         // slave select
   input 	   miso;       // slave output

   reg [7:0] 	   baud_counter = 'b0; //works b/c of free running counter!
   reg [1:0] 	   spi_state;
   reg [2:0] 	   bit_count;
   reg 		   sclk;

   //#################################
   //# STATE MACHINE
   //#################################
   
`define SPI_IDLE    2'b00  // set ss to 1
`define SPI_SETUP   2'b01  // setup time
`define SPI_DATA    2'b10  // send data
`define SPI_HOLD    2'b11  // hold time
   
   //state machine
   //NOTE: tx access pulse is lost if there is ongoing transactio (makes sense..)
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       spi_state[1:0] <=  `SPI_IDLE;
     else if(baud_match)
       case (spi_state[1:0])
	 `SPI_IDLE : 
	   spi_state[1:0] <= ~fifo_empty ? `SPI_SETUP : `SPI_IDLE;
	 `SPI_SETUP :
	   spi_state[1:0] <=`SPI_DATA;
	 `SPI_DATA : 
	   spi_state[1:0] <= fifo_empty_reg & byte_done ? `SPI_HOLD : `SPI_DATA;
	 `SPI_HOLD : 
	   spi_state[1:0] <= `SPI_IDLE;
     endcase // case (spi_state[1:0])
   
   //Bit counter
   always @ (posedge clk)
     if(spi_state[1:0]==`SPI_IDLE)
       bit_count[2:0] <= 'b0;
     else if(baud_match)
       bit_count[2:0] <=  bit_count[2:0] + 1'b1;

   assign byte_done  = (bit_count[2:0]==3'b000);

   assign fifo_read = ((spi_state[1:0]==`SPI_IDLE) & phase_match ) |
		      ((spi_state[1:0]==`SPI_DATA) & phase_match & byte_done);

   assign load_byte = baud_match & byte_done & (spi_state[1:0]!=`SPI_IDLE);
   
   assign shift = baud_match & (spi_state[1:0]==`SPI_DATA);

   //TODO: Ugly Fifo goes empty on one clk cycle, need to add hold time using baud match
   //better solution?

   reg 		   fifo_empty_reg;
   
   always @ (posedge clk)
     if(baud_match)
       fifo_empty_reg <= fifo_empty;
   
   //#################################
   //# BAUD COUNTER
   //#################################

   always @ (posedge clk)
     if(baud_match)
       baud_counter[7:0] <= 'b0;
     else
       baud_counter[7:0] <= baud_counter[7:0] + 1'b1;

   assign baud_match  = (baud_counter[7:0]==((1 << clkdiv_reg[7:0]) - 1'b1));
   assign phase_match = (baud_counter[7:0]==((1 << (clkdiv_reg[7:0]) >> 1) - 1'b1));
   
   //#################################
   //# CHIP SELECT
   //#################################
   assign ss = (spi_state[1:0]==`SPI_IDLE);
   
   //#################################
   //# SCLK GENERATOR
   //#################################

   //TODO: implement cpol/cpha (cpha=0 for now)
   
   always @ (posedge clk)
     if(spi_state[1:0]!=`SPI_DATA)
       sclk <= 1'b0;
     else if(phase_match)
       sclk <= 1'b1;
     else if(baud_match)
       sclk <= 1'b0;
      
   //#################################
   //# RX/TX SHIFT REGISTER
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
	    .fill	(miso),           // fill with slave data
	    .wait_in	(1'b0)            // no wait
	    );
         
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


