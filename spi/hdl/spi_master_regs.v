//#############################################################################
//# Purpose: SPI master (configurable)                                        #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

`include "spi_regmap.vh"
module spi_master_regs (/*AUTOARG*/
   // Outputs
   cpol, cpha, lsbfirst, emode, spi_en, clkdiv_reg, cmd_reg, wait_out,
   access_out, packet_out,
   // Inputs
   clk, nreset, rx_data, rx_access, spi_state, fifo_prog_full,
   fifo_wait, access_in, packet_in, wait_in
   );

   //parameters
   parameter  CLKDIV = 1;             // default clkdiv     
   parameter  PSIZE  = 0;             // default is 32 bits
   parameter  AW     = 32;            // addresss width
   localparam PW     = (2*AW+40);     // packet width
 
   //clk,reset, cfg
   input 	     clk;             // core clock
   input 	     nreset;          // async active low reset

   //io interface
   input [63:0]      rx_data;         // rx data
   input 	     rx_access;       // rx access pulse

   //control
   output 	     cpol;            // clk polarity (default is 0)
   output 	     cpha;            // clk phase shift (default is 0)
   output            lsbfirst;        // send lsbfirst
   output 	     emode;           // send emesh transaction
   output 	     spi_en;          // enable transmitter   
   output [7:0]      clkdiv_reg;      // baud rate setting
   output [7:0]      cmd_reg;         // command register for emode   
   input [1:0] 	     spi_state;       // transmit state
   input 	     fifo_prog_full;  // fifo reached half/full
   input 	     fifo_wait;       // tx transfer wait
   
   //packet to transmit
   input 	     access_in;       // access from core
   input [PW-1:0]    packet_in;       // data to core
   output 	     wait_out;        // pushback from spi master
   
   //return packet
   output 	     access_out;      // writeback from spi 
   output [PW-1:0]   packet_out;      // writeback data from spi
   input 	     wait_in;         // pushback by core
   
   //########################################################
   //# BODY
   //########################################################

   reg [7:0] 	     config_reg;
   reg [7:0] 	     status_reg;
   reg [7:0] 	     clkdiv_reg;
   reg [7:0] 	     cmd_reg;
   reg [7:0] 	     rx_reg[7:0];
   
   reg 		     autotran;
   reg [31:0] 	     read_data;
   reg 		     access_out;
   
   integer 	     i;

   wire [31:0] 	     reg_wdata;
   wire [1:0] 	     datamode_out;
   wire [AW-1:0]     dstaddr_out;
   wire [AW-1:0]     data_out;
   wire [AW-1:0]     srcaddr_out;
   wire [4:0] 	     ctrlmode_out;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From pe2 of packet2emesh.v
   wire [AW-1:0]	data_in;		// From pe2 of packet2emesh.v
   wire [1:0]		datamode_in;		// From pe2 of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From pe2 of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From pe2 of packet2emesh.v
   wire			write_in;		// From pe2 of packet2emesh.v
   // End of automatics
   
   //####################################
   //# DECODE
   //####################################

   packet2emesh #(.AW(AW))
   pe2 (/*AUTOINST*/
	// Outputs
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[4:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]),
	// Inputs
	.packet_in			(packet_in[PW-1:0]));

   assign reg_write       = access_in & write_in;
   assign reg_read        = access_in & ~write_in;
   assign reg_wdata[31:0] = data_in[AW-1:0];
   
   assign config_write    = reg_write & (dstaddr_in[7:0]==`SPI_CONFIG);
   assign status_write    = reg_write & (dstaddr_in[7:0]==`SPI_STATUS);
   assign clkdiv_write    = reg_write & (dstaddr_in[7:0]==`SPI_CLKDIV);
   assign cmd_write       = reg_write & (dstaddr_in[7:0]==`SPI_CMD);
   assign tx_write        = reg_write & (dstaddr_in[7:0]==`SPI_TX);

   //####################################
   //# CONFIG
   //####################################
   
   always @ (posedge clk or negedge nreset)
     if (~nreset)
       config_reg[7:0] <= 'b0;   
     else if(config_write)
       config_reg[7:0] <= data_in[7:0];
   
   assign spi_en       = ~config_reg[0]; // disable spi (on by default)
   assign irq_en       = config_reg[1];  // enable interrupt
   assign cpol         = config_reg[2];  // cpol
   assign cpha         = config_reg[3];  // cpha
   assign lsbfirst     = config_reg[4];  // send lsb first
   assign manual_ss    = config_reg[5];  // manually control ss pin
   assign emode        = config_reg[6];  // epiphany transfer mode
    
   //####################################
   //# STATUS
   //####################################

   always @ (posedge clk or negedge nreset)
     if (~nreset)
       status_reg[7:0] <= 'b0;   
     else if(status_write)
       status_reg[7:0] <= reg_wdata[7:0];
     else
       status_reg[7:0] <= {5'b0,                        //7:3
			   fifo_prog_full,              //2
			   |spi_state[1:0],             //1
			   (rx_access | status_reg[0])};//0
   			       
   //####################################
   //# CLKDIV 
   //####################################

   always @ (posedge clk or negedge nreset)
     if (~nreset)
       clkdiv_reg[7:0] <= CLKDIV;   
     else if(clkdiv_write)
       clkdiv_reg[7:0] <= reg_wdata[7:0];

   //####################################
   //# COMMAND (for emode) 
   //####################################

   always @ (posedge clk)
     if(cmd_write)
       cmd_reg[7:0] <= reg_wdata[7:0];
     
   //####################################
   //# RX REG
   //####################################
   always @ (posedge clk)
     if(rx_access)
       for(i=0;i<8;i=i+1)
	 rx_reg[i] <= rx_data[i*8+:8];

   //####################################
   //# AUTOTRANSFER
   //####################################

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       autotran <= 1'b0;   
     else if(rx_access & emode)
       autotran <= 1'b1;   
     else if(~wait_in)
       autotran <= 1'b0;   

   //####################################
   //# READBACK
   //####################################

   always @ (posedge clk)
     access_out <= access_in;
      
   always @ (posedge clk)
     read_data[31:0] <= 64'b0;
   
   //create a pulse on register reads
   oh_edge2pulse 
     e2pulse (.out (wait_pulse),
   	      .clk (clk),
	      .in  (reg_read));
   
   assign wait_out = fifo_wait;
   

/*wait_in   | 
		     fifo_wait |
		     autotran  |
		     wait_pulse;
*/
   assign dstaddr_out[AW-1:0] = srcaddr_in[AW-1:0];
   assign data_out[31:0]      = read_data[31:0];
   assign srcaddr_out[31:0]   = 32'b0;   
   assign ctrlmode_out[4:0]   = ctrlmode_in[4:0];
   assign ctrlmode_out[4:0]   = datamode_in[4:0];

			      
   emesh2packet e2p (.write_out		(1'b1),
		     /*AUTOINST*/
		     // Outputs
		     .packet_out	(packet_out[PW-1:0]),
		     // Inputs
		     .datamode_out	(datamode_out[1:0]),
		     .ctrlmode_out	(ctrlmode_out[4:0]),
		     .dstaddr_out	(dstaddr_out[AW-1:0]),
		     .data_out		(data_out[AW-1:0]),
		     .srcaddr_out	(srcaddr_out[AW-1:0]));
   
endmodule // spi_master_regs

// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:
