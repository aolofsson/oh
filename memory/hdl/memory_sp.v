

/*###########################################################################
 # Function: Single port memory wrapper
 #
 ############################################################################
 */

`define USE_MEM_MODEL
module memory_sp(/*AUTOARG*/
   // Outputs
   data_out,
   // Inputs
   clk, en, wen, addr, data_in
   );

   parameter AW      = 14;   
   parameter DW      = 32;
   parameter WED     = 4;    //one per byte, how to parametrize   
   parameter MD      = 1<<AW;//memory depth

   //memory interface
   input               clk;     //write clock
   input               en;      //memory enable    
   input [WED-1:0]     wen;     //write enable vector
   input [AW-1:0]      addr;    //write address
   input [DW-1:0]      data_in; //write data
   output reg [DW-1:0] data_out;//read output data
   
   //////////////////////
   //SIMPLE MEMORY MODEL 
   //////////////////////   
`ifdef USE_MEM_MODEL     
   reg [DW-1:0]        ram    [MD-1:0];  
   
   //read port
   always @ (posedge clk)
     if(en)       
       data_out[DW-1:0] <= ram[addr[AW-1:0]];

   //write port
   generate
      genvar 	     i;
      for (i = 0; i < 8; i = i+1) begin: gen_ram
         always @(posedge clk)
           begin  
              if (wen[i]) 
                ram[addr[AW-1:0]][(i+1)*8-1:i*8] <= data_in[(i+1)*8-1:i*8];
           end
      end
   endgenerate
   
`endif

   //////////////////////
   //XILINX MEMORY 
   ////////////////////// 

   //////////////////////
   //CHIP MEMORY
   ////////////////////// 
  
   
endmodule // memory_dp


/*
  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Andreas Olofsson <andreas@adapteva.com>
 
   This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.This program is distributed in the hope 
  that it will be useful,but WITHOUT ANY WARRANTY; without even the implied 
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details. You should have received a copy 
  of the GNU General Public License along with this program (see the file 
  COPYING).  If not, see <http://www.gnu.org/licenses/>.
*/
  
     

