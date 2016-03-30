//#############################################################################
//# Purpose: SPI slave IO and statemachine                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

module spi_slave_io(/*AUTOARG*/
   // Outputs
   miso, spi_clk, spi_write, spi_addr, spi_wdata, spi_rdata,
   access_out, packet_out,
   // Inputs
   sclk, mosi, ss, spi_en, cpol, cpha, lsbfirst, clk
   );

   //#################################
   //# INTERFACE
   //#################################

   //parameters
   parameter  SREGS  = 16;         // total regs  (16/32/64) 
   parameter  AW    = 32;         // address width
   localparam PW    = (2*AW+40);  // packet width
   
   //IO interface
   input 	       sclk;           // slave clock
   input 	       mosi;           // slave input
   input 	       ss;             // slave select
   output 	       miso;           // slave output

   //Control
   input 	       spi_en;         // spi enable
   input 	       cpol;           // cpol
   input 	       cpha;           // cpha
   input 	       lsbfirst;       // lsbfirst
   
   //register file interface
   output 	       spi_clk;         // spi clock for regfile
   output 	       spi_write;       // regfile write
   output [5:0]        spi_addr;        // regfile addres
   output [7:0]        spi_wdata;       // data for regfile
   output [7:0]        spi_rdata;       // data for regfile
   
   //core interface (synced to core clk)
   input 	       clk;             // core clock
   output 	       access_out;      // read or write core command   
   output [PW-1:0]     packet_out;      // packet
   
   //#################################
   //# BODY
   //#################################

   reg [1:0] 	       spi_state;   
   reg [7:0] 	       bit_count; 
   reg [7:0] 	       command_reg;   
   reg 		       packet_done_reg;
   reg [PW-1:0]        packet_out;   

   wire [7:0] 	       rx_data;
   wire [63:0] 	       tx_data;
   //#################################
   //# STATE MACHINE
   //#################################

`define SPI_IDLE   2'b00  // when ss is high
`define SPI_CMD    2'b01  // 8 cycles for command/addr
`define SPI_DATA   2'b10  // stay in datamode until done

   //state machine
   always @ (posedge sclk or posedge ss)
     if(ss)
       spi_state[1:0] <=  `SPI_IDLE;
     else
       case (spi_state[1:0])
	 `SPI_IDLE :  spi_state[1:0] <= `SPI_CMD;
	 `SPI_CMD  :  spi_state[1:0] <= byte_done ? `SPI_DATA : `SPI_CMD;
	 `SPI_DATA :  spi_state[1:0] <= `SPI_DATA;
       endcase // case (spi_state[1:0])
   
   //bit counter
   always @ (posedge sclk or posedge ss)
     if(ss)
       bit_count[7:0] <= 'b0;
     else
       bit_count[7:0] <=  bit_count[7:0] + 1'b1;
   
   assign byte_done  = (spi_state[1:0]!=`SPI_IDLE) &
		       (bit_count[2:0]==3'b000);
        
   // command/address register
   // auto increment for every byte
   always @ (negedge sclk or posedge ss)
     if(ss)
       command_reg[7:0] <= 'b0;   
     else if((spi_state[1:0]==`SPI_CMD) & byte_done)
       command_reg[7:0] <= rx_data[7:0];
     else if(byte_done)
       command_reg[7:0] <= {command_reg[7:6],
			    command_reg[5:0] + 1'b1};
              
   //#################################
   //# RX SHIFT REGISTER
   //#################################

   assign rx_shift = ~ss & spi_en;
   
   oh_ser2par #(.PW(8),
		.SW(1))
   ser2par (// Outputs
	    .dout	(rx_data[7:0]),
	    // Inputs
	    .clk	(sclk),
	    .din	(mosi),
	    .lsbfirst	(lsbfirst), //msb first
	    .shift	(rx_shift)
	    );

   //#################################
   //# TX SHIFT REGISTER
   //#################################

   assign tx_load   = byte_done & (spi_state[1:0]==`SPI_CMD);
   assign tx_shift  = ~ss & spi_en;
   
   oh_par2ser #(.PW(8),
		.SW(1))
   par2ser (.dout	(miso),
	    .access_out (),
	    .wait_out	(tx_wait),
	    .clk	(sclk), // shift out on positive edge
	    .nreset	(~ss),
	    .din	(spi_rdata[7:0]),
	    .shift      (tx_shift),
	    .lsbfirst	(lsbfirst),
	    .load       (tx_load),
	    .datasize   (8'd7),
	    .fill       (1'b0),
	    .wait_in    (1'b0)
	    );
   
   //#################################
   //# REGISTER FILE INTERFACE
   //#################################

   assign spi_clk       = sclk;

   assign spi_addr[5:0] = command_reg[5:0];   

   assign spi_write     = spi_en &
			  byte_done &
			  (command_reg[7:6]==2'b00) &
			  (spi_state[1:0]==`SPI_DATA);
  
   assign spi_remote    = spi_en &
			  ss     &                 // wait until signal goes high
			  command_reg[7:6]==2'b11; // send remote request

   assign spi_wdata[7:0] = rx_data[7:0];
 
   //###################################
   //# SYNCHRONIZATION TO CORE
   //###################################
   
   //sync the ss to free running clk
   //look for rising edge
   oh_dsync dsync (.dout (ss_sync),
		   .clk  (clk),
		   .din  (spi_remote)
		   );

   //create single cycle pulse
   oh_rise2pulse r2p (.out  (access_out),
		      .clk  (clk),
		      .in   (ss_sync)
		      );

endmodule // spi_slave_io
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
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
