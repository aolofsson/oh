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

/*###########################################################################
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

module e_mmu (/*AUTOARG*/
   // Outputs
   mi_data_out, emesh_access_out, emesh_write_out, emesh_datamode_out,
   emesh_ctrlmode_out, emesh_dstaddr_out, emesh_srcaddr_out,
   emesh_data_out,
   // Inputs
   clk, mmu_en, mi_access, mi_write, mi_addr, mi_data_in,
   emesh_access_in, emesh_write_in, emesh_datamode_in,
   emesh_ctrlmode_in, emesh_dstaddr_in, emesh_srcaddr_in,
   emesh_data_in
   );
   parameter DW   = 32;        //data width of
   parameter AW   = 32;        //data width of 
   parameter IW   = 12;        //index size of table
   parameter PAW  = 64;        //physical address width of output
   parameter MW   = PAW-AW+IW; //table data width
   parameter MD   = 1<<IW;     //memory depth
   
   /*****************************/
   /*CONFIGURATION INTERFACE    */
   /*****************************/
   input              clk;   
   input 	      mmu_en;       //enables mmu
   input              mi_access;
   input              mi_write;
   input  [IW:0]      mi_addr;      //one '64' bit entry per slice 
   input  [DW-1:0]    mi_data_in;   //width of table (> 32 bits)
   output [DW-1:0]    mi_data_out;

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
   /*EMESH OUTPUTS              */
   /*****************************/
   output 	      emesh_access_out;
   output 	      emesh_write_out;
   output [1:0]       emesh_datamode_out;
   output [3:0]       emesh_ctrlmode_out;
   output [63:0]      emesh_dstaddr_out;  //32 or 64 bits
   output [AW-1:0]    emesh_srcaddr_out;
   output [DW-1:0]    emesh_data_out; 

   /*****************************/
   /*WIRES                      */
   /*****************************/
   wire [63:0] 	      emmu_mem_rd_data;
   wire [63:0] 	      emmu_mem_wr_data;   
   wire [7:0] 	      emmu_mem_wr_en;
   wire 	      emmu_write;
   
   /*****************************/
   /*REGISTERS                  */
   /*****************************/
   reg 		      emesh_access_out;
   reg 		      emesh_write_out;
   reg [1:0] 	      emesh_datamode_out;
   reg [3:0] 	      emesh_ctrlmode_out;
   reg [AW-1:0]       emesh_srcaddr_out;
   reg [DW-1:0]	      emesh_data_out; 
   reg [MW-1:0]       emmu_mem_array[MD-1:0];  
   reg [63:0] 	      emmu_table_data_out;
   reg [AW-1:0]       emesh_dstaddr_reg;
   
   /*****************************/
   /*WRITE LOGIC                */
   /*****************************/

   //Duplicating 32 bit data
   assign emmu_mem_wr_data[63:0] = {mi_data_in[31:0],
			           mi_data_in[31:0]};
   
   //Enabling lower/upper 32 bit data write 
   assign emmu_write             = mi_access & mi_write;

   assign emmu_mem_wr_en[7:0]    = (emmu_write & mi_addr[0])  ? 8'b11110000 :
				   (emmu_write & ~mi_addr[0]) ? 8'b00001111 :
				                                8'b00000000;
   
   /*****************************/
   /*DUAL PORT MEMORY           */
   /*****************************/
   memory_dp #(.DW(PAW),.AW(IW)) 
   memory_dp (
	      // Outputs
	      .rd_data	(emmu_mmu_rd_data[63:0]),
	      // Inputs
	      .wr_clk	(clk),
	      .wr_en	(emmu_mem_wr_en[7:0]),     //parametrize?
	      .wr_addr	(mi_addr[IW:1]),           //shift by one bit
	      .wr_data	(emmu_mem_wr_data[63:0]),
	      .rd_clk	(clk),
	      .rd_en	(emesh_access_in),
	      .rd_addr	(emesh_dstaddr_in[AW-1:20])
	      );
   
   /*****************************/
   /*EMESH OUTPUT TRANSACTION   */
   /*****************************/   
   //unconditional pipeline to compensate for table lookup pipeline     
   always @ (posedge clk or posedge reset)
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
   
   //TODO: make the 32 vs 64 bit configurable, for now assume 64 bit support
   //TODO:

   assign emesh_dstaddr_out[63:0]      = mmu_en ? {emmu_mem_rd_data[MW-1:0],emesh_dstaddr_reg[19:0]} :
				                  {32'b0,emesh_dstaddr_reg[AW-1:0]};
   
//fix
   
endmodule // emmu
// Local Variables:
// verilog-library-directories:("." "../memory")
// End:



   