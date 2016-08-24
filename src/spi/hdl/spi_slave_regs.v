//#############################################################################
//# Purpose: SPI slave register file                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

`include "spi_regmap.vh"
module spi_slave_regs #( parameter UREGS = 13,      // # of user regs (max 48)
			 parameter SREGS = UREGS+32,// total regs
			 parameter AW    = 32,      // address width
			 parameter PW    = 104      // packet width
			 )
   (
   // clk, rest, chipid
   input 	     clk, // core clock
   input 	     nreset, // asych active low 
   input 	     hw_en, // block enable pin
   // sclk io domain
   input 	     spi_clk, // slave clock
   input [7:0] 	     spi_wdata, // slave write data in (for write)
   input 	     spi_write, // slave write
   input [5:0] 	     spi_addr, // slave write addr (64 regs)
   output [7:0]      spi_rdata, // slave read data 
   // cfg bits
   output 	     spi_en, // enable spi
   output 	     cpol, // clk polarity (default is 0)
   output 	     cpha, // clk phase shift (default is 0)
   output 	     lsbfirst, // send lsbfirst
   output 	     irq_en, // interrupt enable
   output reg [511:0] spi_regs, // all regs concatenated for easy read
   // split transaction for core clock domain   
   input 	     access_out, // signal used to clear status
   input 	     access_in, 
   input [PW-1:0]    packet_in, // writeback data
   output 	     wait_out 
    );

  //###############
  //# LOCAL WIRES
  //###############
   reg [7:0] 	   spi_config;
   reg [7:0] 	   spi_status;
   reg [7:0] 	   spi_cmd;
   reg [7:0] 	   spi_psize;
   reg [63:0] 	   core_regs;
   reg [7:0] 	   user_regs[UREGS-1:0];
   wire [63:0] 	   core_data;
   wire 	   config_write;
   wire 	   user_write;
   wire 	   status_write;
   wire 	   valid;
   
   
   integer 	   i;
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From pe2 of packet2emesh.v
   wire [AW-1:0]	data_in;		// From pe2 of packet2emesh.v
   wire [1:0]		datamode_in;		// From pe2 of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From pe2 of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From pe2 of packet2emesh.v
   wire			write_in;		// From pe2 of packet2emesh.v
   // End of automatics
   
   //#####################################
   //# SPI DECODE
   //#####################################
   
   assign config_write  = spi_write & (spi_addr[5:0]==`SPI_CONFIG);
   assign status_write  = spi_write & (spi_addr[5:0]==`SPI_STATUS);
   assign user_write    = spi_write & (spi_addr[5]);

   //#####################################
   //# CORE DECODE
   //#####################################
   assign wait_out = 1'b0;
   
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

   assign core_data[63:0]={srcaddr_in[31:0],data_in[31:0]};
      
   //#####################################
   //# CONFIG [0]
   //#####################################
  
   always @ (negedge spi_clk or negedge nreset)
     if(!nreset)
       spi_config[7:0] <= 'b0;
     else if(config_write)
       spi_config[7:0] <= spi_wdata[7:0];

   assign spi_en   = hw_en & ~spi_config[0]; // disable spi (for security)
   assign irq_en   = spi_config[1];          // enable interrupt
   assign cpol     = spi_config[2];          // cpol
   assign cpha     = spi_config[3];          // cpha
   assign lsbfirst = spi_config[4];          // lsb shifted in first
   assign valid    = spi_config[5];          // user regs enable

   //#####################################
   //# USER SPACE REGISTERS
   //#####################################

   always @ (negedge spi_clk)
     if(user_write)
       user_regs[spi_addr[4:0]] <= spi_wdata[7:0]; 

   //#####################################   
   //# STATUS [1]
   //#####################################

   always @ (posedge clk)
     if (access_out)
       spi_status[7:0] <= 8'b0; // clears previous data ready
     else if(access_in)
       spi_status[7:0] <= 8'd1; // data ready

   //#####################################
   //# RX DATA FOR FETCH
   //#####################################

   //Data to sample
   always @ (posedge clk)
     if(access_in)
       core_regs[63:0] <= core_data[63:0];

   
   //#####################################
   //# REGISTER VECTOR (FOR FLEXIBILITY)
   //#####################################

   always @*
     begin
	spi_regs[7:0]     = spi_config[7:0]; //config=7:0
	spi_regs[15:8]    = spi_status[7:0]; //status=15:8	
	spi_regs[127:16]  = 'b0;             //clkdiv=23:16
	                                     //cmd=31:24
	                                     //reserved=63:32
	                                     //tx=127:64
	spi_regs[191:128] = core_regs[63:0]; //user=191:128
	spi_regs[255:192] = 'b0;
	for(i=0;i<32;i=i+1)
	  spi_regs[256+8*i+:8] = user_regs[i];
     end
   
   //#####################################
   //# READBACK (TO SPI)
   //#####################################

   assign spi_rdata[7:0] = spi_regs[8*spi_addr[5:0]+:8];
   
endmodule // spi_slave_regs
// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emesh/hdl")
// End:
