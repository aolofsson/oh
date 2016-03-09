//#############################################################################
//# Purpose: SPI master (configurable)                                        #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################
`include "spi_regmap.vh"
module spi_master_regs (/*AUTOARG*/
   // Outputs
   tx_access, cmd_reg, tx_data, cpol, cpha, spi_en, psize_reg,
   clkdiv_reg, wait_out, access_out, packet_out,
   // Inputs
   clk, nreset, rx_data, rx_access, spi_state, access_in, packet_in,
   wait_in
   );

   //parameters
   parameter  CLKDIV = 16;            // default clkdiv     
   parameter  PSIZE  = 4;             // default 4 byte read  
   parameter  AW     = 32;            // addresss width
   localparam PW     = (2*AW+40);     // packet width
 
   //clk,reset, cfg
   input 	     clk;             // core clock
   input 	     nreset;          // async active low reset

   //io interface
   output 	     tx_access;       // start the transfer
   output [7:0]      cmd_reg;         // first 8 bites to send
   output [PW-1:0]   tx_data;         // data payload
   
   input [PW-1:0]    rx_data;         // rx data
   input 	     rx_access;       // rx access pulse

   //control
   output 	     cpol;
   output 	     cpha;   
   output 	     spi_en;          // enable transmitter   
   output [7:0]      psize_reg;       // packet size   
   output [7:0]      clkdiv_reg;      // baud rate setting
   input [2:0] 	     spi_state;       // transmit state
   
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
   reg [7:0] 	     cmd_reg;   
   reg [7:0] 	     psize_reg;   
   reg [7:0] 	     clkdiv_reg;
   reg [63:0] 	     tx_reg[3:0];
   reg [7:0] 	     rx_reg;
   
   wire [63:0] 	     reg_wdata;
   wire [255:0]      tx_vector;   
   wire [63:0] 	     write_mask;
   
   integer 	     i;

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
   assign reg_wdata[63:0] = {srcaddr_in[AW-1:0],data_in[AW-1:0]};
  
   assign config_write    = reg_write & (dstaddr_in[7:2]==`SPI_CONFIG);
   assign status_write    = reg_write & (dstaddr_in[7:2]==`SPI_STATUS);
   assign cmd_write       = reg_write & (dstaddr_in[7:2]==`SPI_CMD);
   assign psize_write     = reg_write & (dstaddr_in[7:2]==`SPI_PSIZE);
   assign clkdiv_write    = reg_write & (dstaddr_in[7:2]==`SPI_CLKDIV);
   assign tx_write        = reg_write & (dstaddr_in[7:2]==`SPI_TX);   
   assign tx_manualstart  = reg_write & (dstaddr_in[7:2]==`SPI_START);

   //autostart on write to lowest tx register
   assign tx_autostart    = tx_write &  (dstaddr_in[4:3]==2'b00);   

   //####################################
   //# CONFIG
   //####################################
   
   always @ (posedge clk or negedge nreset)
     if (~nreset)
       config_reg[7:0] <= 'b0;   
     else if(config_write)
       config_reg[7:0] <= data_in[7:0];
   
   assign spi_en     = config_reg[0];   // enable spi
   assign irq_en     = config_reg[1];   // enable interrupt
   assign cpol       = config_reg[2];   // cpol
   assign cpha       = config_reg[3];   // cpha
   assign auto_mode  = config_reg[4];   // auto starts transfer on tx write
   
   assign tx_access  = auto_mode ? tx_autostart :
  		                   tx_manualstart;
      
   //####################################
   //# STATUS
   //####################################

   always @ (posedge clk or negedge nreset)
     if (~nreset)
       status_reg[7:0] <= 'b0;   
     else if(status_write)
       status_reg[7:0] <= reg_wdata[7:0];
     else
       status_reg[7:0] <= {4'b0,                        //7:4
			   spi_state[2:0],              //3:1
			   (rx_access | status_reg[0])};//0
   
			  
   //####################################
   //# PSIZE (packet size)
   //####################################

   always @ (posedge clk or negedge nreset)
     if (~nreset)
       psize_reg[7:0] <= PSIZE;   
     else if(psize_write)
       psize_reg[7:0] <= reg_wdata[7:0];
   
   //####################################
   //# CLKDIV 
   //####################################

   always @ (posedge clk or negedge nreset)
     if (~nreset)
       clkdiv_reg[7:0] <= CLKDIV;   
     else if(psize_write)
       clkdiv_reg[7:0] <= reg_wdata[7:0];
   
   //####################################
   //# COMMAND REG
   //####################################
   always @ (posedge clk or negedge nreset)
     if(cmd_write)
       cmd_reg[7:0] <= reg_wdata[7:0];
   
   //####################################
   //# RX REG
   //####################################
   always @ (posedge clk)
     if(rx_access)
       rx_reg[7:0] <= rx_data[7:0];
   
   //####################################
   //# TX REGS
   //####################################

   //auto start on writing to lowest tx data register
  

   assign write_mask[63:0] = (datamode_in[1:0]==2'b00) ? 64'h00000000000000FF :
			     (datamode_in[1:0]==2'b01) ? 64'h000000000000FFFF :
			     (datamode_in[1:0]==2'b10) ? 64'h00000000FFFFFFFF :
			                                 64'hFFFFFFFFFFFFFFFF;
   
   always @ (posedge clk)
     for(i=0;i<64;i=i+1)	   
       if(tx_write & write_mask[i])	       
 	 tx_reg[dstaddr_in[4:3]][i] <= reg_wdata[i]; 
   
   assign tx_vector[255:0]= {tx_reg[3],
                             tx_reg[2],
			     tx_reg[1],
			     tx_reg[0]};
   //only taking 
   assign tx_data[PW-1:0] = tx_vector[PW-1:0];
   
endmodule // spi_master_regs

// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:
