//#############################################################################
//# Purpose: SPI slave port register file                                     #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

`include "spi_regmap.vh"
module spi_slave_regs (/*AUTOARG*/
   // Outputs
   spi_regs, wait_out,
   // Inputs
   clk, nreset, spi_clk, spi_data, spi_write, spi_addr, access_in,
   packet_in, spi_request
   );

   //parameters
   parameter  SREGS  = 40;           // number of total regs (>40)   
   parameter  CHIPID = 0;            // reset chipid value   
   parameter  AW     = 32;           // address width
   localparam PW     = (2*AW+40);    // packet width
        
   // clk, rest, chipid
   input 	        clk;          // core clock
   input 	        nreset;       // asych active low 

   // sclk domain
   input 	        spi_clk;      // slave clock
   input [7:0] 	        spi_data;     // slave data in (for write)
   input 	        spi_write;    // slave write
   input [5:0] 	        spi_addr;     // slave write addr (64 regs)
   output [SREGS*8-1:0] spi_regs;     // all regs concatenated
   
   // split transaction for core clock domain   
   input 		access_in; 
   input [PW-1:0] 	packet_in;    // writeback data
   output 		wait_out;     // 0   
   input 		spi_request; // read
   
   //regs
   reg [7:0] 	    spi_config;
   reg [7:0] 	    spi_status;
   reg [7:0] 	    spi_cmd;
   reg [7:0] 	    spi_psize;

   reg [63:0] 	    core_regs;
   reg [7:0] 	    user_regs[47:0];
   reg [1023:0]     spi_vector;
   wire [4*8-1:0]   spi_reserved;
   wire [63:0] 	    core_data;   
   integer 	    i;

   //#####################################
   //# JUNK
   //#####################################
   assign wait_out = 1'b0;
   
   
   //#####################################
   //# SPI DECODE
   //#####################################
   
   assign spi_config_write  = spi_write & (spi_addr[5:0]==`SPI_CONFIG);
   assign spi_user_write    = spi_write & (|spi_addr[5:4]);

   //#####################################
   //# CORE DECODE
   //#####################################

   packet2emesh #(.AW(AW))
   pe2 (.write_in	(write_in),
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
   //[0]    = 1--> user regs valid (default is off)
   //[1]    = 1--> disable spi port (default is enabled)
   //[7:2]  = reserved

   always @ (posedge spi_clk or negedge nreset)
     if(!nreset)
       spi_config[7:0] <= 'b0;
     else if(spi_config_write)
       spi_config[7:0] <= spi_data[7:0];
   
   //#####################################
   //# STATUS [1]
   //#####################################

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       spi_status[7:0] <= 'b0;
     else if (write_in & access_in)
       spi_status[7:0] <= 8'b1;   
     else if (spi_request)
       spi_status[7:0] <= 'b0;
   
   //#####################################
   //# CMD [2]
   //#####################################

   //TBD
     
   //#####################################
   //# CORE DATA [15:8]
   //#####################################

   always @ (posedge clk)
     if(write_in & access_in)
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
	//8 standard regs
	spi_vector[7:0]     = spi_config[7:0];    //0
	spi_vector[15:8]    = spi_status[7:0];    //1
	spi_vector[23:16]   = 8'b0;               //2
	spi_vector[31:24]   = spi_cmd[7:0];       //3
	spi_vector[63:32]   = 32'b0;              //7:4
	spi_vector[127:64]  = 64'b0;              //15:8
	//16 core data tx vector
	spi_vector[255:128] = core_regs[63:0];
	//16 core data rx vector
	spi_vector[511:256] = 'b0;	
	//32 user vector
	for(i=0;i<SREGS-40;i=i+1)
	  spi_vector[512+i*8 +:8] = user_regs[i];
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
