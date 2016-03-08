//#############################################################################
//# Purpose: SPI slave port register file                                     #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

`include "spi_regmap.vh"
module spi_slave_regs (/*AUTOARG*/
   // Outputs
   spi_regs,
   // Inputs
   nreset, chipid, spi_clk, spi_data, spi_write, spi_addr, core_clk,
   core_access, core_packet, core_spi_read
   );

   //parameters
   parameter  REGS   = 16;           // number of total regs (>16)   
   parameter  AW     = 32;           // address width
   localparam PW     = (2*AW+40);    // packet width
        
   // power on defaults
   input 	       nreset;       // asych active low 
   input [7:0] 	       chipid;       // default chipid

   // sclk domain
   input 	       spi_clk;      // slave clock
   input [7:0] 	       spi_data;     // slave data in (for write)
   input 	       spi_write;    // slave write
   input [5:0] 	       spi_addr;     // slave write addr (64 regs)
   output [REGS*8-1:0] spi_regs;     // all regs concatenated
   
   // extension for core clock domain
   input 	       core_clk;
   input 	       core_access; 
   input [PW-1:0]      core_packet;  // writeback data
   input 	       core_spi_read;// read
   
   //regs
   reg [7:0] 	    spi_config;
   reg [7:0] 	    spi_packetsize;  
   reg [7:0] 	    user_regs[47:0];
   reg [63:0] 	    core_regs;
   reg [7:0] 	    core_valid;   
   reg [REGS*8-1:0] spi_regs;
   wire [7:0] 	    spi_chipid;
   wire [4*8-1:0]   spi_reserved;
   wire [63:0] 	    core_data;   
   integer 	    i;
   
   //#####################################
   //# SPI DECODE
   //#####################################
   
   assign spi_config_write     = spi_write & (spi_addr[5:0]==`SPI_CONFIG);
   assign spi_packetsize_write = spi_write & (spi_addr[5:0]==`SPI_PACKETSIZE);
   assign spi_user_write       = spi_write & (|spi_addr[5:4]);

   //#####################################
   //# CORE DECODE
   //#####################################

   packet2emesh #(.AW(AW))
   pe2 (.write_in	(core_write),
	.datamode_in	(),
	.ctrlmode_in	(),
	.dstaddr_in	(),
	.srcaddr_in	(core_data[63:32]),
	.data_in	(core_data[31:0]),
	// Inputs
	.packet_in	(core_packet[PW-1:0]));
   
   //#####################################
   //# CONFIG [0]
   //#####################################
   //[0]    = 1--> user regs valid (default is off)
   //[1]    = 1--> disable spi port (default is enabled)
   //[7:2]  = reserved

   always @ (posedge spi_clk or negedge nreset)
     if(!nreset)
       spi_config[7:0] <= 'b0;
     else if(spi_config_write)
       spi_config[7:0] <= spi_data[7:0];

   //#####################################
   //# PACKET SIZE [1]
   //#####################################

   always @ (posedge spi_clk or negedge nreset)
     if(!nreset)
       spi_packetsize[7:0] <= PW;
     else if(spi_packetsize_write)
       spi_packetsize[7:0] <= spi_data[7:0];
   
   //#####################################
   //# CHIPID [2]
   //#####################################

   assign spi_chipid[7:0] = chipid[7:0];

   //#####################################
   //# RESERVED [6:3]
   //#####################################

   assign spi_reserved[4*8-1:0] = 'b0;

   //#####################################
   //# CORE STATUS [7]
   //#####################################

   //TODO: implement per byte valid   

   always @ (posedge core_clk or negedge nreset)
     if(!nreset)
       core_valid[7:0] <= 'b0;
     else if (core_write & core_access)
       core_valid[7:0] <= 8'b1;   
     else if (core_spi_read)
       core_valid[7:0] <= 'b0;
   
   //#####################################
   //# CORE DATA [15:8]
   //#####################################

   always @ (posedge core_clk)
     if(core_write & core_access)
       core_regs[63:0] <= core_data[63:0];
  
   //#####################################
   //# USER SPACE REGISTERS
   //#####################################

   always @ (posedge spi_clk)
     if(spi_user_write)
       user_regs[spi_addr[5:0]] <= spi_data[7:0]; 
   
   //#####################################
   //# CONCATENATE ALL REGISTERS TOGETHER
   //#####################################

   //TODO: parametrize to make the smaller config efficient
   //user configs should get optimized away
    
   always @*
     begin
	//3 config regs
	spi_regs[7:0]    = spi_config[7:0];
	spi_regs[15:8]   = spi_packetsize[7:0];
	spi_regs[23:16]  = spi_chipid[7:0];
	//4 reserved regs
	spi_regs[56:24]  = spi_reserved[4*8-1:0];
	//1 core data valid reg
	spi_regs[63:56]  = core_valid[7:0];
	//8 core data regs	
	spi_regs[127:64] = core_regs[63:0];
	//48 user regs
	for(i=0;i<REGS-16;i=i+1)
	  spi_regs[128+i*8 +:8] = user_regs[i];
     end
     
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
