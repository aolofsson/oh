//#############################################################################
//# Purpose: SPI master IO state-machine                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################
module spi_master_io
  (
   //clk, reset, cfg
   input 	    clk, // core clock
   input 	    nreset, // async active low reset
   input 	    cpol, // cpol
   input 	    cpha, // cpha
   input 	    lsbfirst, // send lsbfirst   
   input 	    manual_mode,// sets automatic ss mode
   input 	    send_data, // controls ss in manual ss mode
   input [7:0] 	    clkdiv_reg, // baudrate	    
   output reg [2:0] spi_state, // current spi tx state
   // data to transmit
   input [7:0] 	    fifo_dout, // data payload
   input 	    fifo_empty, // 
   output 	    fifo_read, // read new byte
   // receive data (for sregs)
   output [63:0]    rx_data, // rx data
   output 	    rx_access, // transfer done
   // IO interface
   output reg 	    sclk, // spi clock
   output 	    mosi, // slave input
   output 	    ss, // slave select
   input 	    miso       // slave output
   );

   //###############
   //# LOCAL WIRES
   //###############
   reg 		   fifo_empty_reg;
   reg 		   load_byte;
   reg 		   ss_reg;   
   wire [7:0] 	   data_out;
   wire [15:0] 	   clkphase0;
   wire 	   period_match;
   wire 	   phase_match;
   wire 	   clkout;
   wire 	   clkchange;
   wire 	   data_done;
   wire 	   spi_wait;
   wire 	   shift;
   wire 	   spi_active;
   wire 	   tx_shift;
   wire 	   rx_shift;
   
   /*AUTOWIRE*/
   
   //#################################
   //# CLOCK GENERATOR
   //#################################
   assign clkphase0[7:0]  = 'b0;
   assign clkphase0[15:8] = (clkdiv_reg[7:0]+1'b1)>>1;
   
   oh_clockdiv 
   oh_clockdiv (.clkdiv		(clkdiv_reg[7:0]),
		.clken		(1'b1),	
		.clkrise0	(period_match),
		.clkfall0	(phase_match),	
		.clkphase1	(16'b0),
		.clkout0	(clkout),
		//clocks not used ("single clock")
		.clkout1	(),
		.clkrise1	(),
		.clkfall1	(),
		.clkstable	(),
		//ignore for now, assume no writes while spi active
		.clkchange	(1'b0),
		/*AUTOINST*/
		// Inputs
		.clk			(clk),
		.nreset			(nreset),
		.clkphase0		(clkphase0[15:0]));
    
   //#################################
   //# STATE MACHINE
   //#################################

`define SPI_IDLE    3'b000  // set ss to 1
`define SPI_SETUP   3'b001  // setup time
`define SPI_DATA    3'b010  // send data
`define SPI_HOLD    3'b011  // hold time
`define SPI_MARGIN  3'b100  // pause

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       spi_state[2:0] <=  `SPI_IDLE;
   else
     case (spi_state[2:0])
       `SPI_IDLE : 
	 spi_state[2:0] <= fifo_read   ? `SPI_SETUP :  `SPI_IDLE;
       `SPI_SETUP :
	 spi_state[2:0] <= phase_match ? `SPI_DATA   : `SPI_SETUP;       
       `SPI_DATA : 
	 spi_state[2:0] <= data_done   ? `SPI_HOLD   : `SPI_DATA;
       `SPI_HOLD : 
	 spi_state[2:0] <= phase_match ? `SPI_MARGIN : `SPI_HOLD;
       `SPI_MARGIN : 
	 spi_state[2:0] <= phase_match ? `SPI_IDLE   : `SPI_MARGIN;
     endcase // case (spi_state[1:0])
   
   //read fifo on phase match (due to one cycle pipeline latency
   assign fifo_read = ~fifo_empty & ~spi_wait & phase_match;

   //data done whne
   assign data_done = fifo_empty & ~spi_wait & phase_match;
    
   //load is the result of the fifo_read
   always @ (posedge clk)
     load_byte <= fifo_read;
   
   //#################################
   //# CHIP SELECT
   //#################################

   assign spi_active = ~(spi_state[2:0]==`SPI_IDLE | spi_state[2:0]==`SPI_MARGIN);      

   assign ss    = ~((spi_active & ~manual_mode) | (send_data & manual_mode));

   //#################################
   //# DRIVE OUTPUT CLOCK
   //#################################
   always @ (posedge clk or negedge nreset)
     if(~nreset)
       sclk <= 1'b0;
     else if (period_match & (spi_state[2:0]==`SPI_DATA))
       sclk <= 1'b1;   
     else if (phase_match & (spi_state[2:0]==`SPI_DATA))	       
       sclk <= 1'b0;
   
   //#################################
   //# TX SHIFT REGISTER
   //#################################

   //shift on falling edge
   assign tx_shift     = phase_match & (spi_state[2:0]==`SPI_DATA);
   
   oh_par2ser  #(.PW(8),
		 .SW(1))
   par2ser (// Outputs
	    .dout	(mosi),           // serial output
	    .access_out	(),
	    .wait_out	(spi_wait),
	    // Inputs
	    .clk	(clk),
	    .nreset	(nreset),         // async active low reset
	    .din	(fifo_dout[7:0]), // 8 bit data from fifo
	    .shift	(tx_shift),          // shift on neg edge
	    .datasize	(8'd7),           // 8 bits at a time (0..7-->8)
	    .load	(load_byte),      // load data from fifo
	    .lsbfirst	(lsbfirst),       // serializer direction
	    .fill	(1'b0),           // fill with slave data
	    .wait_in	(1'b0));          // no wait

   //#################################
   //# RX SHIFT REGISTER
   //#################################

   //shift in rising edge
   assign rx_shift = (spi_state[2:0] == `SPI_DATA) & period_match;

   oh_ser2par #(.PW(64),
		.SW(1))
   ser2par (//output
	    .dout	(rx_data[63:0]),  // parallel data out
	    //inputs
	    .din	(miso),           // serial data in
	    .clk	(clk),            // shift clk
	    .lsbfirst	(lsbfirst),       // shift direction
	    .shift	(rx_shift));         // shift data

   //generate access pulse at rise of ss
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       ss_reg <= 1'b1;
     else
       ss_reg <= ss;
   
   assign rx_access = ss & ~ss_reg;
   
         
endmodule // spi_master_io
// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emesh/hdl") 
// End:


