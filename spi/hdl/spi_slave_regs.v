//#############################################################################
//# Purpose: SPI slave port register file                                     #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

`include "spi_regmap.vh"
module spi_slave_regs (/*AUTOARG*/
   // Outputs
   spi_rdata, spi_en, cpol, cpha, lsbfirst, irq_en, emode, spi_regs,
   wait_out,
   // Inputs
   clk, nreset, spi_clk, spi_wdata, spi_write, spi_addr, access_in,
   packet_in
   );

   //parameters
   parameter  UREGS  = 13;        // number of user regs (max 48)
   parameter  CHIPID = 0;         // reset chipid value   
   parameter  AW     = 32;        // address width
   localparam PW     = (2*AW+40); // packet width
   localparam SREGS  = UREGS+32;  // total regs
           
   // clk, rest, chipid
   input 	   clk;           // core clock
   input 	   nreset;        // asych active low 

   // sclk io domain
   input 	   spi_clk;       // slave clock
   input [7:0] 	   spi_wdata;     // slave write data in (for write)
   input 	   spi_write;     // slave write
   input [5:0] 	   spi_addr;      // slave write addr (64 regs)
   output [7:0]    spi_rdata;     // slave read data 
    
   // cfg bits
   output 	   spi_en;        // enable spi
   output 	   cpol;          // clk polarity (default is 0)
   output 	   cpha;          // clk phase shift (default is 0)
   output 	   lsbfirst;      // send lsbfirst
   output 	   irq_en;        // interrupt enable
   output 	   emode;         // epiphany auto mode   
   output [511:0]  spi_regs;      // all regs concatenated for easy read
   
   // split transaction for core clock domain   
   input 	   access_in; 
   input [PW-1:0]  packet_in;    // writeback data
   output 	   wait_out;     // 0   
   
   //regs
   reg [7:0] 	   spi_config;
   reg [7:0] 	   spi_status;
   reg [7:0] 	   spi_cmd;
   reg [7:0] 	   spi_psize;
   
   reg [63:0] 	   core_regs;
   reg [7:0] 	   user_regs[UREGS-1:0];
   reg [511:0]     spi_regs;
   wire [63:0] 	   core_data;   
   integer 	   i;

   //#####################################
   //# SPI DECODE
   //#####################################
   
   assign spi_config_write  = spi_write & (spi_addr[5:0]==`SPI_CONFIG);
   assign spi_status_write  = spi_write & (spi_addr[5:0]==`SPI_STATUS);
   assign spi_user_write    = spi_write & (spi_addr[5]);

   //#####################################
   //# CORE DECODE
   //#####################################

   assign wait_out = 1'b0;
   packet2emesh #(.AW(AW))
   pe2 (.write_in	(),
	.datamode_in	(),
	.ctrlmode_in	(),
	.dstaddr_in	(),
	.srcaddr_in	(core_data[63:32]),
	.data_in	(core_data[31:0]),
	// Inputs
	.packet_in	(packet_in[PW-1:0]));

   //#####################################
   //# CONFIG [0]
   //#####################################
  
   always @ (negedge spi_clk or negedge nreset)
     if(!nreset)
       spi_config[7:0] <= 'b0;
     else if(spi_config_write)
       spi_config[7:0] <= spi_wdata[7:0];

   assign spi_en   = ~spi_config[0]; // disable spi (for security)
   assign irq_en   = spi_config[1];  // enable interrupt
   assign cpol     = spi_config[2];  // cpol
   assign cpha     = spi_config[3];  // cpha
   assign lsbfirst = spi_config[4];  // lsb shifted in first
   assign valid    = spi_config[5];  // user regs enable
   assign emode    = spi_config[6];  // epiphany mode
   
   //#####################################
   //# STATUS [1]
   //#####################################

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       spi_status[7:0] <= 'b0;    
     else if (1'b0)
       spi_status[7:0] <= 1'b0; // todo: clear with spi request   
     else if(access_in)
       spi_status[7:0] <= {7'b0,
			   1'b1}; //data ready
        
   //#####################################
   //# DATA FROM SPLIT TRANSACTION (8/16)
   //#####################################

   //Data to sample
   always @ (posedge clk)
     if(access_in)
       core_regs[63:0] <= core_data[63:0];
  
   //#####################################
   //# USER SPACE REGISTERS
   //#####################################

   always @ (negedge spi_clk)
     if(spi_user_write)
       user_regs[spi_addr[4:0]] <= spi_wdata[7:0]; 

   //#####################################
   //# REGISTER VECTOR (FOR FLEXIBILITY)
   //#####################################

   always @*
     begin
	spi_regs[7:0]   = spi_config[7:0];
	spi_regs[15:8]  = spi_status[7:0];
	spi_regs[63:16] = 'b0;
	spi_regs[127:64] = core_regs[63:0];
	spi_regs[255:128] = 'b0;
	for(i=0;i<32;i=i+1)
	  spi_regs[256+8*i+:8] = user_regs[i];
     end

   
   //#####################################
   //# READBACK
   //#####################################

   assign spi_rdata[7:0] = spi_regs[8*spi_addr[5:0]+:8];
   
endmodule // spi_slave_regs

// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emesh/hdl")
// End:

//////////////////////////////////////////////////////////////////////////////
// The MIT License (MIT)                                                    //
//                                                                          //
// Copyright (c) 2015-2016, Adapteva, Inc.                                  //
//                                                                          //
// Permission is hereby granted, free of charge, to any person obtaining a  //
// copy of this software and associated documentation files (the "Software")//
// to deal in the Software without restriction, including without limitation// 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, //
// and/or sell copies of the Software, and to permit persons to whom the    //
// Software is furnished to do so, subject to the following conditions:     //
//                                                                          //
// The above copyright notice and this permission notice shall be included  // 
// in all copies or substantial portions of the Software.                   //
//                                                                          //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS  //
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF               //
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.   //
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY     //
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT//
// OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR //
// THE USE OR OTHER DEALINGS IN THE SOFTWARE.                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
