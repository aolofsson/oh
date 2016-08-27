//#############################################################################
//# Purpose: SPI slave IO state-machine                                       #
//#          NOTE: only cpol=0, cpha=0 supported for now!!                    #
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
    input [7:0]     spi_rdata, // data for regfile
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
   reg 		    access_reg;   
   reg [1:0] 	    spi_state;   
   reg [7:0] 	    bit_count; 
   reg [7:0] 	    command_reg;   
   reg 		    fetch_command;
   wire [7:0] 	    rx_data;
   wire [63:0] 	    tx_data;
   wire 	    rx_shift;
   wire 	    tx_load;
   wire 	    tx_wait;
   wire 	    ss_sync;
   wire 	    ss_pulse;
   wire 	    spi_fetch;
   wire 	    byte_done;
   wire 	    shift;
   wire 	    rx_clk;
   wire 	    tx_clk;
   wire 	    next_byte;
   
   //#################################
   //# MODES: TODO!
   //################################# 
   
   //cpol=0,cpha=0
   //(launch on negedge, capture on posedge)
   assign shift    = ~ss & spi_en;   
   assign rx_clk   = sclk;
   assign tx_clk   = ~sclk;
   assign tx_load  = next_byte;
      
   //#################################
   //# STATE MACHINE
   //################################# 

`define SPI_IDLE_STATE   2'b00  // when ss is high
`define SPI_CMD_STATE    2'b01  // 8 cycles for command/addr
`define SPI_DATA_STATE   2'b10  // stay in datamode until done

   //state machine
   always @ (posedge sclk or posedge ss)
     if(ss)
       spi_state[1:0] <=  `SPI_IDLE_STATE;
     else
       case (spi_state[1:0])
	 `SPI_IDLE_STATE :  spi_state[1:0] <= `SPI_CMD_STATE;
	 `SPI_CMD_STATE  :  spi_state[1:0] <= next_byte ? `SPI_DATA_STATE : `SPI_CMD_STATE;
	 `SPI_DATA_STATE :  spi_state[1:0] <= `SPI_DATA_STATE;
       endcase // case (spi_state[1:0])
   
   //bit counter
   always @ (posedge sclk or posedge ss)
     if(ss)
       bit_count[7:0] <= 'b0;
     else
       bit_count[7:0] <=  bit_count[7:0] + 1'b1;

   assign next_byte   = (spi_state[1:0]!=`SPI_IDLE_STATE) &
			(bit_count[2:0]==3'b000);
   
   assign byte_done  = (spi_state[1:0]!=`SPI_IDLE_STATE) &
		       (bit_count[2:0]==3'b111);
        
   // command/address register
   // auto increment for every byte
   always @ (posedge sclk or negedge nreset)
     if(!nreset)
       command_reg[7:0] <= 'b0;
     else if((spi_state[1:0]==`SPI_CMD_STATE) & byte_done)
       command_reg[7:0] <= spi_wdata[7:0];
     else if(byte_done)
       command_reg[7:0] <= {command_reg[7:6],
			    command_reg[5:0] + 1'b1};
   
   //#################################
   //# SPI RX SHIFT REGISTER
   //#################################
   
   oh_ser2par #(.PW(8),
		.SW(1))
   rx_ser2par (// Outputs
	       .dout	 (rx_data[7:0]),
	       // Inputs
	       .clk	 (rx_clk),
	       .din	 (mosi),
	       .lsbfirst (lsbfirst), //msb first
	       .shift	 (shift));
  
   
   //#################################
   //# TX SHIFT REGISTER
   //#################################

   oh_par2ser #(.PW(8),
		.SW(1))
   tx_par2ser (.dout	   (miso),
	       .access_out (),
	       .wait_out   (tx_wait),
	       .clk	   (tx_clk), // shift out on positive edge
	       .nreset	   (~ss),
	       .din	   (spi_rdata[7:0]),
	       .shift      (shift),
	       .lsbfirst   (lsbfirst),
	       .load       (tx_load),
	       .datasize   (8'd7),
	       .fill       (1'b0),
	       .wait_in    (1'b0));
   
   //#################################
   //# REGISTER FILE INTERFACE
   //#################################

   assign spi_clk       = rx_clk;

   assign spi_addr[5:0] = command_reg[5:0];   

   assign spi_write     = spi_en    &
			  byte_done &
			  ~ss       &
			  (command_reg[7:6]==`SPI_WR) & 
			  (spi_state[1:0]==`SPI_DATA_STATE);
    
   assign spi_wdata[7:0] = lsbfirst ? {mosi, rx_data[7:1]}
				    : {rx_data[6:0], mosi};


   //####################################
   //# REMOTE TRANSACTION LOGIC
   //####################################
`ifdef DV_SPI_BYPASS
   // Bypass spi for DV (B/C SPI IS SLOOOOOOOW!)
   // Drive wires "packet_out" and "access_out" from testbench
`else

   //Create a complete packet (104/136 bits)
   oh_ser2par #(.PW(PW),
		.SW(1))
   e_ser2par (// Outputs
	      .dout	(packet_out[PW-1:0]),
	      // Inputs
	      .clk	(rx_clk),
	      .din	(mosi),
	      .lsbfirst	(lsbfirst), //msb first
	      .shift	(shift));//rx_shift
   
   //sync the ss to free running clk
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
       access_reg <= 1'b0;   
     else if(~wait_in)
       access_reg <= spi_fetch;

   assign access_out = access_reg;
   
`endif
   
endmodule // spi_slave_io
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:
