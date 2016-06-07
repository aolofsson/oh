//#############################################################################
//# Purpose: SPI slave IO state-machine                                       #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

`include "spi_regmap.vh"
module spi_slave_io #( parameter PW = 104  // packet width
		       )
   (
    //IO interface
    input 	    sclk, // slave clock
    input 	    mosi, // slave input
    input 	    ss, // slave select
    output 	    miso, // slave output
    //Control
    input 	    spi_en, // spi enable
    input 	    cpol, // cpol
    input 	    cpha, // cpha
    input 	    lsbfirst, // lsbfirst
    //register file interface
    output 	    spi_clk, // spi clock for regfile
    output 	    spi_write, // regfile write
    output [5:0]    spi_addr, // regfile addres
    output [7:0]    spi_wdata, // data for regfile
    output [7:0]    spi_rdata, // data for regfile
    //core interface (synced to core clk)
    input 	    clk, // core clock
    input 	    nreset, // async active low reset   
    output 	    access_out, // read or write core command   
    output [PW-1:0] packet_out, // packet
    input 	    wait_in // temporary pushback
    );

   //###############
   //# LOCAL WIRES
   //###############
   reg [1:0] 	    spi_state;   
   reg [7:0] 	    bit_count; 
   reg [7:0] 	    command_reg;   
   reg 		    access_out;
   reg 		    fetch_command;
   wire [7:0] 	    rx_data;
   wire [63:0] 	    tx_data;
   
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
	 default   :  spi_state[1:0] <= `SPI_CMD;
	 `SPI_CMD  :  spi_state[1:0] <= next_byte ? `SPI_DATA : `SPI_CMD;
	 `SPI_DATA :  spi_state[1:0] <= `SPI_DATA;
       endcase // case (spi_state[1:0])

   //bit counter
   always @ (posedge sclk or posedge ss)
     if(ss)
       bit_count[7:0] <= 'b0;
     else
       bit_count[7:0] <=  bit_count[7:0] + 1'b1;

   assign next_byte   = (spi_state[1:0]!=`SPI_IDLE) &
			(bit_count[2:0]==3'b000);

   assign byte_done   = (spi_state[1:0]!=`SPI_IDLE) &
		        (bit_count[2:0]==3'b111);

   // command/address register
   // auto increment for every byte
   always @ (posedge sclk or negedge nreset)
     if(!nreset)
       command_reg[7:0] <= 'b0;
     else if((spi_state[1:0]==`SPI_CMD) & byte_done)
       command_reg[7:0] <= spi_wdata[7:0];
     else if(byte_done)
       command_reg[7:0] <= {command_reg[7:6],
			    command_reg[5:0] + 1'b1};


   //#################################
   //# CPOL=0 CPHA=0 settings
   //#################################

   // RX
   assign rx_shift = ~ss & spi_en;
   assign rx_clk   = sclk;

   // TX
   assign tx_clk   = ~sclk;
   assign tx_shift = rx_shift;
   assign tx_load  = next_byte;

   //#################################
   //# SPI RX SHIFT REGISTER
   //#################################

   
   oh_ser2par #(.PW(8),
		.SW(1))
		//.EDGE("RISING")) // CPOL=0 CPHA=0
   rx_ser2par (// Outputs
	       .dout	 (rx_data[7:0]),
	       // Inputs
	       .clk	 (rx_clk),
	       .din	 (mosi),
	       .lsbfirst (lsbfirst), //msb first
	       .shift	 (rx_shift));
   
   //####################################
   //# REMOTE TRANSAXTION SHIFT REGISTER
   //####################################

   oh_ser2par #(.PW(PW),
		.SW(1))
   e_ser2par (// Outputs
	      .dout	(packet_out[PW-1:0]),
	      // Inputs
	      .clk	(rx_clk),
	      .din	(mosi),
	      .lsbfirst	(lsbfirst), //msb first
	      .shift	(rx_shift));//rx_shift
   
   //#################################
   //# TX SHIFT REGISTER
   //#################################

   oh_par2ser #(.PW(8),
		.SW(1))
   tx_par2ser (.dout	   (miso),
	       .access_out (),
	       .wait_out   (tx_wait),
	       .clk	   (tx_clk),
	       .nreset	   (~ss),
	       .din	   (spi_rdata[7:0]),
	       .shift      (tx_shift),
	       .lsbfirst   (lsbfirst),
	       .load       (tx_load),
	       .datasize   (8'd7),
	       .fill       (1'b0),
	       .wait_in    (1'b0));
   
   //#################################
   //# REGISTER FILE INTERFACE
   //#################################

   assign spi_clk       = sclk;

   assign spi_addr[5:0] = command_reg[5:0];   

   assign spi_write     = spi_en    &
			  byte_done &
			  ~ss       &
			  (command_reg[7:6]==`SPI_WR) &
			  (spi_state[1:0]==`SPI_DATA);

   // CPOL=0 CPHA=0:
   // Skip pipeline stage in rx_ser2par, and grab last bit directly from pin.
   // When first RX byte is received on 8th rising edge we need it immediately
   // because transmission of the second TX byte starts on the following
   // falling edge.

   assign spi_wdata[7:0] = lsbfirst ? {mosi, rx_data[6:0]}
				    : {rx_data[6:0], mosi};

   //###################################
   //# REMOTE FETCH LOGIC
   //###################################
   
   //sync the ss to free running clk
   //look for rising edge

   oh_dsync dsync (.dout  (ss_sync),
		   .clk   (clk),
		   .nreset(nreset),
		   .din   (ss));

   //create single cycle pulse
   oh_rise2pulse r2p (.nreset (nreset),
		      .out    (ss_pulse),
		      .clk    (clk),
		      .in     (ss_sync));

   assign spi_fetch = ss_pulse & (command_reg[7:6]==`SPI_FETCH);
   
   // pipeleining and holding pulse if there is wait
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       access_out <= 1'b0;   
     else if(~wait_in)
       access_out <= spi_fetch;

endmodule // spi_slave_io
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:
