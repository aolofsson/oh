
/*###########################################################################
 # Function: Single port memory wrapper
 #           To run without hardware platform dependancy use:
 #           `define TARGET_CLEAN"
 ############################################################################
 */

module memory_sp(/*AUTOARG*/
   // Inputs
   clk, en, wen, addr, din, dout
   );

   parameter AW      = 14;   
   parameter DW      = 32;
   parameter WED     = DW/8; //one per byte  
   parameter MD      = 1<<AW;//memory depth

   //write-port
   input               clk; //write clock
   input               en;  //memory access   
   input [WED-1:0]     wen; //write enable vector
   input [AW-1:0]      addr;//address
   input [DW-1:0]      din; //data input
   input [DW-1:0]      dout;//data output
      
`ifdef TARGET_CLEAN     

   reg [DW-1:0]        ram    [MD-1:0];  
   reg [DW-1:0]        rd_data;
   
   //read port
   always @ (posedge clk)
     if(en)       
       dout[DW-1:0] <= ram[addr[AW-1:0]];

   //write port
   generate
      genvar 	     i;
      for (i = 0; i < WED; i = i+1) begin: gen_ram
	 always @(posedge clk)
           begin  
              if (wen[i]) 
                ram[addr[AW-1:0]][(i+1)*8-1:i*8] <= din[(i+1)*8-1:i*8];
           end
      end
   endgenerate
`elsif TARGET_XILINX
   //instantiate XILINX BRAM (based on parameter size)
      
`elsif TARGET_ALTERA
   //instantiate ALTERA BRAM (based on paremeter size)
`endif
   
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

  
     

