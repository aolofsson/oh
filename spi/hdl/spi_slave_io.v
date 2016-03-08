//#############################################################################
//# Purpose: SPI slave IO and statemachine                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

module spi_slave_io(/*AUTOARG*/
   // Outputs
   miso, spi_clk, spi_write, spi_addr, spi_data, core_spi_access,
   core_spi_packet, core_spi_read,
   // Inputs
   sclk, mosi, ss, spi_regs, core_clk
   );

   //#################################
   //# INTERFACE
   //#################################

   //parameters
   parameter  REGS  = 16;         // total regs  (16/32/64) 
   parameter  AW    = 32;         // address width
   localparam PW    = (2*AW+40);  // packet width
   
   //IO interface
   input 	       sclk;           // slave clock
   input 	       mosi;           // slave input
   input 	       ss;             // slave select
   output 	       miso;           // slave output
   
   //register file interface
   output 	       spi_clk;         // spi clock for regfile
   output 	       spi_write;       // regfile write
   output [6:0]        spi_addr;        // regfile addre
   output [7:0]        spi_data;        // data for regfile
   input [REGS*8-1:0]  spi_regs;        // all registers
   
   //core interface (synced to core clk)
   input 	       core_clk;        // core clock
   output 	       core_spi_access; // read or write core command   
   output [PW-1:0]     core_spi_packet; // packet
   output 	       core_spi_read;   // read core command (for regfile)
   
   //#################################
   //# BODY
   //#################################

   reg [2:0] 	       spi_state;   
   reg [7:0] 	       bit_count;
   reg [PW-1:0]        spi_rx;
   reg [PW-1:0]        spi_tx;
   reg 		       spi_access;
   reg 		       packet_done_reg;
   reg 		       core_spi_read;
   reg [PW-1:0]        core_spi_packet;   
   wire [7:0] 	       packetsize;
      
   //#################################
   //# RX SHIFT REGISTER
   //#################################
 
   always @ (posedge sclk)
     if(~ss)
       spi_rx[PW-1:0] <= {spi_rx[PW-2:0],mosi};
   
   //#################################
   //# STATE MACHINE
   //#################################

   assign packetsize[7:0] = spi_regs[15:8];
   
`define SPI_IDLE   3'b000  // when ss is high
`define SPI_CMD    3'b001  // 8 cycles for command/addr
`define SPI_READ   3'b010  // 8 cycles to shift out data
`define SPI_WRITE  3'b011  // 8 cycles for data to write
`define SPI_REMOTE 3'b100  // PW cycles (split transaction)
      
   //state machine
   always @ (posedge sclk or posedge ss)
     if(ss)
       spi_state[1:0] <=  `SPI_IDLE;
     else
       case (spi_state[1:0])
	 `SPI_IDLE     : 
	   spi_state[2:0] <= `SPI_CMD;
	 `SPI_CMD      : 
	   spi_state[2:0] <= read_cmd   ? `SPI_READ  :
			     write_cmd  ? `SPI_WRITE :
			     remote_cmd ? `SPI_REMOTE :
			                  `SPI_CMD;
	 `SPI_READ     : 
	   spi_state[2:0] <= byte_done   ? `SPI_IDLE : 
			                   `SPI_READ;
	 `SPI_WRITE    : 
	   spi_state[2:0] <= byte_done   ? `SPI_IDLE : 
					   `SPI_WRITE;
	 `SPI_REMOTE   : 
	   spi_state[2:0] <= packet_done ? `SPI_IDLE : 
					   `SPI_REMOTE;
       endcase // case (spi_state[1:0])
   
   //bit counter
   always @ (posedge sclk or posedge ss)
     if(ss)
       bit_count[7:0] <= 'b0;
     else
       bit_count[7:0] <=  bit_count[7:0] + 1'b1;

   assign read_cmd      = (spi_rx[7:6]==2'b10) &
			  (spi_state[2:0]==`SPI_CMD);

   assign write_cmd     = (spi_rx[7:6]==2'b00) &
			  (spi_state[2:0]==`SPI_CMD);
   
   assign remote_cmd    = (spi_rx[7:6]==2'b11) &
			  (spi_state[2:0]==`SPI_CMD);
      
   assign byte_done     = &bit_count[2:0];

   assign packet_done   = (bit_count[7:0]==packetsize[7:0]);

   //#################################
   //# TX SHIFT REGISTER
   //#################################

   assign load_tx  = byte_done & (spi_state[1:0]==`SPI_CMD);
    
   always @ (posedge sclk)
     if(load_tx)
       spi_tx[7:0] <= spi_regs[spi_rx[6:0]]; // 
     else if(~ss)
       spi_tx[7:0] <= {spi_tx[6:0],1'b0};   

   assign miso = spi_tx[7];
     
   //#################################
   //# REGISTER FILE INTERFACE
   //#################################
   assign spi_clk       = sclk;
   assign spi_addr[5:0] = spi_rx[5:0];
   assign spi_write     = byte_done & (spi_state[2:0]==`SPI_WRITE);
   assign spi_read      = byte_done & (spi_state[2:0]==`SPI_READ);
   assign spi_data[7:0] = spi_rx[7:0];
 
   //#################################
   //# CLOCK SYNCHRONIZATION
   //#################################

   //!!! CLK_CORE FRE MUST BE > 2 * SCLK FREQ !!!
   
   //synchronizer
   oh_dsync dsync (.dout (packet_done_sync),
		   .clk  (core_clk),
		   .din  (packet_done)
		   );

   //posedge detect and pipeline to line up with data
   always @ (posedge core_clk)
     begin
	packet_done_reg <= packet_done_sync;	
	spi_access      <= spi_access_pulse;	
     end

   assign spi_access_pulse = packet_done_sync & ~packet_done_reg;	
   
   //spi read
   always @ (posedge core_clk)
     if(spi_access_pulse)
       core_spi_read <= spi_read;
     else
       core_spi_read <= 1'b0;
         
   //sample rx data
   always @ (posedge core_clk)
     if(spi_access_pulse)
       core_spi_packet[PW-1:0] <= spi_rx[PW-1:0];
   
endmodule // spi_slave_io
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// 
