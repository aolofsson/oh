//#############################################################################
//# Purpose: SPI slave IO and statemachine                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

module spi_master_io(/*AUTOARG*/
   // Outputs
   spi_state, rx_data, rx_access, sclk, mosi, ss,
   // Inputs
   clk, nreset, spi_en, cpol, cpha, clkdiv_reg, psize_reg, cmd_reg,
   tx_data, tx_access, miso
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
   input [7:0] 	   clkdiv_reg; // baudrate	 
   input [7:0] 	   psize_reg;  // packetsize   
   output [2:0]    spi_state;  // current spi tx state
     
   //data to transmit
   input [7:0]     cmd_reg;    // 8 bit command
   input [PW-1:0]  tx_data;    // data payload
   input 	   tx_access;  // start transfer 
   
   //receive data
   output [7:0]    rx_data;    // rx data
   output 	   rx_access;  // rx ready pulse
   
   //IO interface
   output 	   sclk;       // spi clock
   output 	   mosi;       // slave input
   output 	   ss;         // slave select
   input 	   miso;       // slave output

   reg [7:0] 	   baud_counter = 'b0; //works b/c of free running counter!
   reg [2:0] 	   spi_state;
   reg [PW-1:0]    tx_shiftreg;
   reg [7:0] 	   bit_count;
   
   //#################################
   //# STATE MACHINE
   //#################################
   
`define SPI_IDLE    3'b000  // clear ss
`define SPI_SETUP   3'b001  // load tx
`define SPI_CMD     3'b010  // send command
`define SPI_DATA    3'b011  // send packet
`define SPI_FINISH  3'b100  // raise
   
   //state machine
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       spi_state[1:0] <=  `SPI_IDLE;
     else if(baud_match)
       case (spi_state[1:0])
	 `SPI_IDLE : 
	   spi_state[2:0] <= tx_access ? `SPI_CMD : `SPI_IDLE;
	 `SPI_SETUP :
	   spi_state[2:0] <=`SPI_CMD;
	 `SPI_CMD  : 
	   spi_state[2:0] <= byte_done ? `SPI_DATA : `SPI_CMD;
	 `SPI_DATA : 
	   spi_state[2:0] <= packet_done ? `SPI_FINISH : `SPI_DATA;
	 `SPI_FINISH : 
	   spi_state[2:0] <= `SPI_IDLE;
       endcase // case (spi_state[1:0])
      
  
   always @ (posedge sclk)
     if(spi_state[2:0]==`SPI_IDLE)
       bit_count[7:0] <= 'b0;
     else if(baud_match)
       bit_count[7:0] <=  bit_count[7:0] + 1'b1;

   assign byte_done     = &bit_count[2:0];

   assign packet_done   = (bit_count[7:0]==psize_reg[7:0]);
   
   //#################################
   //# BAUD COUNTER
   //#################################

   always @ (posedge clk)
     if(baud_match)
       baud_counter[7:0] <= 'b0;
     else
       baud_counter[7:0] <= baud_counter[7:0] + 1'b1;

   assign baud_match  = (baud_counter[7:0]==clkdiv_reg[7:0]);
   assign phase_match = (baud_counter[7:0]==(clkdiv_reg[7:0]>>1));
   
   //#################################
   //# CHIP SELECT
   //#################################
   assign ss = (spi_state==`SPI_IDLE);
   
   //#################################
   //# SCLK GENERATOR
   //#################################

   //TODO!!
   
   //#################################
   //# RX/TX SHIFT REGISTER
   //#################################
   
   always @ (posedge clk)     
     if (tx_access)
       tx_shiftreg[PW-1:0] <= tx_data[PW-1:0];
     else if(baud_match)       
       tx_shiftreg[PW-1:0] <= {tx_shiftreg[PW-2:0],miso};

   assign mosi = tx_shiftreg[PW-1];

   assign rx_data[7:0] = tx_shiftreg[7:0];
   
   
endmodule // spi_slave_io

// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emesh/hdl") 
// End:
