//#############################################################################
//# Purpose: SPI master IO state-machine                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################
module spi_master_io
  (
   //clk, reset, cfg
   input 	 clk, // core clock
   input 	 nreset, // async active low reset
   input 	 cpol, // cpol
   input 	 cpha, // cpha
   input 	 lsbfirst, // send lsbfirst   
   input [7:0] 	 clkdiv_reg, // baudrate	 
   output [2:0]  spi_state, // current spi tx state
   // data to transmit
   input [7:0] 	 fifo_dout, // data payload
   input 	 fifo_empty, // 
   output 	 fifo_read, // read new byte
   // receive data (for sregs)
   output [63:0] rx_data, // rx data
   output 	 rx_access, // transfer done
   // IO interface
   output 	 sclk, // spi clock
   output 	 mosi, // slave input
   output 	 ss, // slave select
   input 	 miso       // slave output
   );

   //###############
   //# LOCAL WIRES
   //###############
   reg [2:0] 	   spi_state;
   reg 		   fifo_empty_reg;
   reg 		   load_byte;   
   wire [7:0] 	   data_out;
   wire [15:0] 	   clkphase0;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			clkfall1;		// From oh_clockdiv of oh_clockdiv.v
   wire			clkout1;		// From oh_clockdiv of oh_clockdiv.v
   wire			clkrise1;		// From oh_clockdiv of oh_clockdiv.v
   wire			clkstable;		// From oh_clockdiv of oh_clockdiv.v
   // End of automatics
   
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
		/*AUTOINST*/
		// Outputs
		.clkout1		(clkout1),
		.clkrise1		(clkrise1),
		.clkfall1		(clkfall1),
		.clkstable		(clkstable),
		// Inputs
		.clk			(clk),
		.nreset			(nreset),
		.clkchange		(clkchange),
		.clkphase0		(clkphase0[15:0]));
    
   //#################################
   //# STATE MACHINE
   //#################################

`define SPI_IDLE    3'b000  // set ss to 1
`define SPI_SETUP   3'b001  // setup time
`define SPI_DATA    3'b010  // send data
`define SPI_HOLD    3'b011  // hold time
`define SPI_GRACE   3'b100  // grace period

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       spi_state[2:0] <=  `SPI_IDLE;
   else
     case (spi_state[2:0])
       default : /* SPI_IDLE */
	 spi_state[2:0] <= fifo_read   ? `SPI_SETUP : `SPI_IDLE;
       `SPI_SETUP :
	 spi_state[2:0] <= phase_match ? `SPI_DATA  : `SPI_SETUP;
       `SPI_DATA :
	 spi_state[2:0] <= data_done   ? `SPI_HOLD  : `SPI_DATA;
       `SPI_HOLD :
	 spi_state[2:0] <= phase_match ? `SPI_GRACE : `SPI_HOLD;
       `SPI_GRACE :
	 spi_state[2:0] <= phase_match ? `SPI_IDLE  : `SPI_GRACE;
     endcase // case (spi_state[2:0])
   
   //read fifo on phase match (due to one cycle pipeline latency
   assign fifo_read = ~fifo_empty & ~spi_wait & phase_match;

   //data done whne
   assign data_done = fifo_empty & ~spi_wait & phase_match;

   // In CPOL=0 CPHA=0 (MODE=0) MOSI is output on negative egde.
   //shift on every clock cycle while in datamode
   wire tx_shift;
   assign tx_shift     = phase_match & (spi_state[2:0]==`SPI_DATA);
   
   //load is the result of the fifo_read
   always @ (posedge clk)
     load_byte <= fifo_read;
   
   //#################################
   //# CHIP SELECT
   //#################################
   
   assign ss = (spi_state[2:0]==`SPI_IDLE) | (spi_state[2:0]==`SPI_GRACE);

   //#################################
   //# DRIVE OUTPUT CLOCK
   //#################################
   
   assign sclk = clkout & (spi_state[2:0]==`SPI_DATA);

   //#################################
   //# TX SHIFT REGISTER
   //#################################
      
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
	    .shift	(tx_shift),       // shift data
	    .datasize	(8'd7),           // 8 bits at a time (0..7-->8)
	    .load	(load_byte),      // load data from fifo
	    .lsbfirst	(lsbfirst),       // serializer direction
	    .fill	(1'b0),           // fill with slave data
	    .wait_in	(1'b0));          // no wait

   //#################################
   //# RX SHIFT REGISTER
   //#################################

   //generate access pulse at rise of ss
   oh_rise2pulse 
     pulse (.nreset(nreset),
	    .out (rx_access),
	    .clk (clk),
	    .in	 (ss));

   // In CPOL=0 CPHA=0 (MODE=0) MISO is sampled on positive egde.
   wire rx_shift;
   assign rx_shift = (spi_state[2:0] == `SPI_DATA) & period_match;
   oh_ser2par #(.PW(64),
		.SW(1))
   ser2par (//output
	    .dout	(rx_data[63:0]),  // parallel data out
	    //inputs
	    .din	(miso),           // serial data in
	    .clk	(clk),            // shift clk
	    .lsbfirst	(lsbfirst),       // shift direction
	    .shift	(rx_shift));      // shift data
         
endmodule // spi_master_io
// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emesh/hdl") 
// End:


