/*
 ###########################################################################
 # Function: A address translator for the eMesh/eLink protocol   
 #           Table writeable from mi_* configuration interface.
 #           12 bit index used for table lookup (bits 31:20 of dstaddr)
 #
 #           Assumes that output is always ready to receive. (no pushback)
 #
 #           32bit address output = {table_data[11:0],dstaddr[19:0]}
 #           64bit address output = {table_data[43:0],dstaddr[19:0]}
 #
 ############################################################################
 */
 
module emmu (/*AUTOARG*/
   // Outputs
   mi_dout, emmu_access_out, emmu_packet_out, emmu_packet_hi_out,
   // Inputs
   clk, reset, mmu_en, mi_clk, mi_en, mi_we, mi_addr, mi_din,
   emesh_access_in, emesh_packet_in
   );
   parameter DW     = 32;         //data width
   parameter AW     = 32;         //address width 
   parameter PW     = 104;
   parameter EPW    = 136;        //extended by 32 bits
   
   /*****************************/
   /*DATAPATH CLOCk             */
   /*****************************/
   input             clk;
   input 	     reset;
   
   /*****************************/
   /*MMU LOOKUP DATA            */
   /*****************************/
   input 	     mmu_en;              //enables mmu

   /*****************************/
   /*Register Access Interface  */
   /*****************************/
   input 	     mi_clk;              //source synchronous clock
   input 	     mi_en;               //memory access 
   input  	     mi_we;               //byte wise write enable
   input [15:0]      mi_addr;             //address
   input [DW-1:0]    mi_din;              //input data  
   output [DW-1:0]   mi_dout;             //read back (TODO?? not implemented)
  
   /*****************************/
   /*EMESH INPUTS               */
   /*****************************/
   input              emesh_access_in;
   input [PW-1:0]     emesh_packet_in;
   
   /*****************************/
   /*EMESH OUTPUTS              */
   /*****************************/
   output 	      emmu_access_out;
   output [PW-1:0]    emmu_packet_out;   
   output [31:0]      emmu_packet_hi_out;
       
   /*****************************/
   /*REGISTERS                  */
   /*****************************/
   reg 		      emmu_access_out;
   reg [PW-1:0]       emmu_packet_reg;
   wire [63:0] 	      emmu_dstaddr_out;
   
   
   wire [47:0] 	      emmu_lookup_data;
   wire [63:0] 	      mi_wr_data;
   wire [5:0] 	      mi_wr_vec;


   /*****************************/
   /*MMU WRITE LOGIC            */
   /*****************************/
   //write controls
   assign mi_wr_vec[5:0] = (mi_en & mi_we & ~mi_addr[2]) ? 6'b001111 :
	                   (mi_en & mi_we & mi_addr[2])  ? 6'b110000 :
			                                    6'b000000 ;

   //write data
   assign mi_wr_data[63:0] = {mi_din[31:0], mi_din[31:0]};

   memory_dp #(.DW(48),.AW(12)) memory_dp (
					   // Outputs
					   .rd_data		(emmu_lookup_data[47:0]),
					   // Inputs
					   .wr_clk		(mi_clk),
					   .wr_en		(mi_wr_vec[5:0]),
					   .wr_addr		(mi_addr[14:3]),
					   .wr_data		(mi_wr_data[47:0]),
					   .rd_clk		(clk),
					   .rd_en		(emesh_access_in),
					   .rd_addr		(emesh_packet_in[39:28])
					   );
   		       
   /*****************************/
   /*EMESH OUTPUT TRANSACTION   */
   /*****************************/   
   //pipeline to compensate for table lookup pipeline 
   //assumes one cycle memory access!     
  
   always @ (posedge  clk)
     emmu_access_out               <= emesh_access_in;
   
   always @ (posedge clk)
     if(emesh_access_in)   
       emmu_packet_reg[PW-1:0]  <= emesh_packet_in[PW-1:0];	  
   
   assign emmu_dstaddr_out[63:0] = mmu_en ? {emmu_lookup_data[43:0],
					     emmu_packet_reg[27:8]} :      //20 bits
				             {32'b0,emmu_packet_reg[39:8]};//ugly
      

   //Concatenating output packet
   assign emmu_packet_out[PW-1:0] = {emmu_packet_reg[PW-1:40],
                                     emmu_dstaddr_out[31:0],
                                     emmu_packet_reg[7:0]
				    };
   

   assign emmu_packet_hi_out[31:0] = emmu_dstaddr_out[63:32];
      
endmodule // emmu
// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../memory/hdl")
// End:

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



   
