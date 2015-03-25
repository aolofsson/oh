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

/*
 ###########################################################################
 # Function: A address translator for the eMesh/eLink protocol   
 #           Table writeable and readable from external interface.
 #           Index into 12 bits used for table lookup (bits 31:20 of addr)
 #           Assumes that output is always ready to receive.
 #
 #           32bit address output = {table[11:0],dstaddr[19:0]}
 #           64bit address output = {table[43:0],dstaddr[19:0]}
 #
 ############################################################################
 */

module emmu (/*AUTOARG*/
   // Outputs
   emesh_access_out, emesh_write_out, emesh_datamode_out,
   emesh_ctrlmode_out, emesh_dstaddr_out, emesh_srcaddr_out,
   emesh_data_out,
   // Inputs
   clk, mmu_en, emesh_access_in, emesh_write_in, emesh_datamode_in,
   emesh_ctrlmode_in, emesh_dstaddr_in, emesh_srcaddr_in,
   emesh_data_in, emmu_lookup_data
   );
   parameter DW   = 32;        //data width of
   parameter AW   = 32;        //data width of 
   parameter IW   = 12;        //index size of table
   parameter PAW  = 64;        //physical address width of output
   parameter MW   = PAW-AW+IW; //table data width
   parameter MD   = 1<<IW;     //memory depth
   parameter RFAW = 12;

   /*****************************/
   /*CLK/RESET                  */
   /*****************************/
   input              clk;
   
   /*****************************/
   /*MMU LOOKUP DATA            */
   /*****************************/
   input 	      mmu_en;           //enables mmu
  
   /*****************************/
   /*EMESH INPUTS               */
   /*****************************/
   input              emesh_access_in;
   input              emesh_write_in;
   input [1:0]        emesh_datamode_in;
   input [3:0]        emesh_ctrlmode_in;
   input [AW-1:0]     emesh_dstaddr_in;
   input [AW-1:0]     emesh_srcaddr_in;
   input [DW-1:0]     emesh_data_in; 

   /*****************************/
   /*MMU LOOKUP DATA            */
   /*****************************/
   input [MW-1:0]     emmu_lookup_data;   //entry based on emesh_dstaddr_in[31:20]
   
   /*****************************/
   /*EMESH OUTPUTS              */
   /*****************************/
   output 	      emesh_access_out;
   output 	      emesh_write_out;
   output [1:0]       emesh_datamode_out;
   output [3:0]       emesh_ctrlmode_out;
   output [63:0]      emesh_dstaddr_out;
   output [AW-1:0]    emesh_srcaddr_out;
   output [DW-1:0]    emesh_data_out; 

   /*****************************/
   /*REGISTERS                  */
   /*****************************/
   reg 		      emesh_access_out;
   reg 		      emesh_write_out;
   reg [1:0] 	      emesh_datamode_out;
   reg [3:0] 	      emesh_ctrlmode_out;
   reg [AW-1:0]       emesh_srcaddr_out;
   reg [DW-1:0]	      emesh_data_out; 
   reg [AW-1:0]       emesh_dstaddr_reg;
   
   /*****************************/
   /*EMESH OUTPUT TRANSACTION   */
   /*****************************/   

   //pipeline to compensate for table lookup pipeline 
   //assumes one cycle memory access!     
   always @ (posedge clk)
     emesh_access_out                  <= emesh_access_in;
   
   always @ (posedge clk)
     if(emesh_access_in)   
       begin
	  emesh_write_out              <= emesh_write_in;
	  emesh_data_out[DW-1:0]       <= emesh_data_in[DW-1:0];
	  emesh_srcaddr_out[AW-1:0]    <= emesh_srcaddr_in[AW-1:0];
	  emesh_dstaddr_reg[AW-1:0]    <= emesh_dstaddr_in[AW-1:0];
	  emesh_ctrlmode_out[3:0]      <= emesh_ctrlmode_in[3:0];
	  emesh_datamode_out[1:0]      <= emesh_datamode_in[1:0];
       end
   
   //TODO: make the 32 vs 64 bit configurable, for now assume 64 bit support (a few more gates...)

   assign emesh_dstaddr_out[63:0]   = mmu_en ? {emmu_lookup_data[MW-1:0],emesh_dstaddr_reg[19:0]} :
				               {32'b0,emesh_dstaddr_reg[AW-1:0]};
   
endmodule // emmu


   
