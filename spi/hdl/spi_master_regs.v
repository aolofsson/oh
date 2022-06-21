//#############################################################################
//# Purpose: SPI master Registers                                             #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

`include "spi_regmap.vh"

module spi_master_regs # (parameter  CLKDIV = 1,    // default clkdiv     
			  parameter  AW     = 32,   // addresss width
			  parameter  PW     = 104   // packet width
			  )
   (
    //clk,reset, cfg
    input 	     clk, // core clock
    input 	     nreset, // async active low reset
    input 	     hw_en, // block enable
    //io interface
    input [63:0]     rx_data, // rx data
    input 	     rx_access, // rx access pulse
    //control
    output 	     cpol, // clk polarity (default is 0)
    output 	     cpha, // clk phase shift (default is 0)
    output 	     lsbfirst, // send lsbfirst
    output 	     spi_en, // enable transmitter   
    output 	     manual_mode,// sets manual ss control
    output 	     send_data, // controls ss in manual ss mode    
    output reg [7:0] clkdiv_reg, // baud rate setting
    input [2:0]      spi_state, // transmit state
    input 	     fifo_prog_full, // fifo reached half/full
    input 	     fifo_wait, // tx transfer wait
    //packet to transmit
    input 	     access_in, // access from core
    input [PW-1:0]   packet_in, // data to core
    output 	     wait_out, // pushback from spi master
    //return packet
    output reg 	     access_out, // writeback from spi 
    output [PW-1:0]  packet_out, // writeback data from spi
    input 	     wait_in         // pushback by core
    );

   //###############
   //# LOCAL WIRES
   //###############
   reg [7:0] 	     config_reg;
   reg [7:0] 	     status_reg;
   reg [63:0] 	     rx_reg; 
   reg [AW-1:0]      reg_rdata;
   reg 		     autotran;
   reg [AW-1:0]      dstaddr_out;   
   reg [4:0] 	     ctrlmode_out;   
   reg [1:0] 	     datamode_out;
   wire [31:0] 	     reg_wdata;
   wire 	     reg_write;
   wire 	     reg_read;
   wire 	     config_write;
   wire 	     status_write;
   wire 	     clkdiv_write;
   wire 	     cmd_write;
   wire 	     tx_write;
   wire 	     irq_en;
   wire 	     wait_pulse;
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

   packet2emesh #(.AW(AW),
		  .PW(PW))
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
   
   assign config_write    = reg_write & (dstaddr_in[5:0]==`SPI_CONFIG);
   assign status_write    = reg_write & (dstaddr_in[5:0]==`SPI_STATUS);
   assign clkdiv_write    = reg_write & (dstaddr_in[5:0]==`SPI_CLKDIV);
   assign cmd_write       = reg_write & (dstaddr_in[5:0]==`SPI_CMD);
   assign tx_write        = reg_write & (dstaddr_in[5:0]==`SPI_TX);

   //####################################
   //# CONFIG
   //####################################
   
   always @ (posedge clk or negedge nreset)
     if (~nreset)
       config_reg[7:0] <= 'b0;   
     else if(config_write)
       config_reg[7:0] <= data_in[7:0];
   
   assign spi_en       = hw_en & ~config_reg[0]; // disable spi (on by default)
   assign irq_en       = config_reg[1];          // enable interrupt
   assign cpol         = config_reg[2];          // cpol
   assign cpha         = config_reg[3];          // cpha
   assign lsbfirst     = config_reg[4];          // send lsb first
   assign manual_mode  = config_reg[5];          // manual control of ss bit
   assign send_data    = config_reg[6];          // ss bit
   
   //####################################
   //# STATUS
   //####################################

   always @ (posedge clk or negedge nreset)
     if (~nreset)
       status_reg[7:0] <= 'b0;   
     else if(status_write)
       status_reg[7:0] <= reg_wdata[7:0];
     else
       status_reg[7:0] <= {5'b0,                 //7:4
			   fifo_prog_full,       //3
			   1'b0,                 //reserved
			   (rx_access | (~tx_write & status_reg[0]))};//0
   			       
   //####################################
   //# CLKDIV 
   //####################################

   always @ (posedge clk or negedge nreset)
     if (~nreset)
       clkdiv_reg[7:0] <= CLKDIV;   
     else if(clkdiv_write)
       clkdiv_reg[7:0] <= reg_wdata[7:0];

   //####################################
   //# RX REG
   //####################################
   always @ (posedge clk)
     if(rx_access)
       rx_reg[63:0] <= rx_data[63:0];
   
   //####################################
   //# READBACK
   //####################################
  
   //read back registers
   always @ (posedge clk)
     if(reg_read)
       case(dstaddr_in[4:0])
	 `SPI_CONFIG : reg_rdata[31:0] <= {24'b0,config_reg[7:0]};
	 `SPI_STATUS : reg_rdata[31:0] <= {24'b0,status_reg[7:0]};
	 `SPI_CLKDIV : reg_rdata[31:0] <= {24'b0,clkdiv_reg[7:0]};
	 `SPI_RX0    : reg_rdata[31:0] <= rx_reg[31:0];
	 `SPI_RX1    : reg_rdata[31:0] <= rx_reg[63:32];	 
	 default     : reg_rdata[31:0] <= 32'hDEADBEEF;	 
       endcase // case (dstaddr_in[5:0])

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       access_out          <= 1'b0;
     else
       access_out          <= reg_read;

   always @ (posedge clk)
     begin
	dstaddr_out[AW-1:0] <= srcaddr_in[AW-1:0];
	ctrlmode_out[4:0]   <= ctrlmode_in[4:0];
	datamode_out[1:0]   <= datamode_in[1:0];
     end
   
   //create a single cycle pulse on register read
   oh_edge2pulse e2pulse (.out    (wait_pulse),
			  .nreset (nreset),
   			  .clk    (clk),
			  .in     (reg_read));
   
   //TODO: fix!
   assign wait_out = fifo_wait;
   
   emesh2packet #(.AW(AW),
		  .PW(PW))
   e2p (.write_out	(1'b1),
	.srcaddr_out	({(AW){1'b0}}),
	.data_out	(reg_rdata[AW-1:0]),
	/*AUTOINST*/
	// Outputs
	.packet_out			(packet_out[PW-1:0]),
	// Inputs
	.datamode_out			(datamode_out[1:0]),
	.ctrlmode_out			(ctrlmode_out[4:0]),
	.dstaddr_out			(dstaddr_out[AW-1:0]));
   
endmodule // spi_master_regs

// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:
