/*
 ###########################################################################
 # **EMMU**
 # 
 # This block uses the upper 12 bits [31:20] of a memory address as an index
 # to read an entry from a table.
 #
 # The table is written from the mi_* configuration interface.
 #
 # The table can be configured as 12 bits wide or 44 bits wide.
 #
 # 32bit address output = {table_data[11:0],dstaddr[19:0]}
 # 64bit address output = {table_data[43:0],dstaddr[19:0]}
 #
 ############################################################################
 */
 
module emmu (/*AUTOARG*/
   // Outputs
   mi_dout, emesh_access_out, emesh_packet_out, emesh_packet_hi_out,
   // Inputs
   reset, rd_clk, wr_clk, mmu_en, mmu_bp, mi_en, mi_we, mi_addr,
   mi_din, emesh_access_in, emesh_packet_in, emesh_rd_wait,
   emesh_wr_wait
   );
   parameter DW     = 32;         //data width
   parameter AW     = 32;         //address width 
   parameter PW     = 104;
   parameter EPW    = 136;        //extended by 32 bits
   parameter MW     = 48;         //width of table
   parameter MAW    = 12;         //memory addres width (entries = 1<<MAW)   
   parameter GROUP  = 0;
   
   /*****************************/
   /*DATAPATH CLOCk             */
   /*****************************/  
   input 	     reset;
   input 	     rd_clk;
   input 	     wr_clk;

   /*****************************/
   /*MMU LOOKUP DATA            */
   /*****************************/
   input 	     mmu_en;              //enables mmu (static)
   input 	     mmu_bp;              //bypass mmu on read response

   /*****************************/
   /*Register Access Interface  */
   /*****************************/  
   input 	     mi_en;               //memory access 
   input  	     mi_we;               //byte wise write enable
   input [14:0]      mi_addr;             //address
   input [DW-1:0]    mi_din;              //input data  
   output [DW-1:0]   mi_dout;             //read back (TODO?? not implemented)
  
   /*****************************/
   /*EMESH INPUTS               */
   /*****************************/  
   input 	     emesh_access_in;
   input [PW-1:0]    emesh_packet_in;
   input 	     emesh_rd_wait;
   input 	     emesh_wr_wait;

   /*****************************/
   /*EMESH OUTPUTS              */
   /*****************************/
   output 	     emesh_access_out;
   output [PW-1:0]   emesh_packet_out;   
   output [31:0]     emesh_packet_hi_out;
   
   /*****************************/
   /*REGISTERS                  */
   /*****************************/
   reg 		      emesh_access_out;
   reg [PW-1:0]       emesh_packet_reg;

   wire [63:0] 	      emesh_dstaddr_out;   
   wire [MW-1:0]      emmu_lookup_data;
   wire [63:0] 	      mi_wr_data;
   wire [5:0] 	      mi_wr_vec;
   wire 	      mi_match;
   wire [MW-1:0]      emmu_rd_addr;
   wire 	      write_in;

   /*****************************/
   /*MMU WRITE LOGIC            */
   /*****************************/

   //write controls
   assign mi_wr_vec[5:0] = (mi_en & mi_we & ~mi_addr[2]) ? 6'b001111 :
	                   (mi_en & mi_we & mi_addr[2])  ? 6'b110000 :
			                                   6'b000000 ;

   //write data
   assign mi_wr_data[63:0] = {mi_din[31:0], mi_din[31:0]};

   //todo: implement readback? worth it?
   assign mi_dout[DW-1:0] = 'b0;

   /*****************************/
   /*MMU READ  LOGIC            */
   /*****************************/
   //TODO: could we do with less entries?
   
   assign write_in              = emesh_packet_in[1];
   assign emmu_rd_addr[MAW-1:0] = emesh_packet_in[39:28];
   
   memory_dp #(.DW(MW),.AW(MAW)) memory_dp (
					   // Outputs
					   .rd_data		(emmu_lookup_data[MW-1:0]),
					   // Inputs
					   .wr_clk		(wr_clk),
					   .wr_en		(mi_wr_vec[5:0]),
					   .wr_addr		(mi_addr[14:3]),
					   .wr_data		(mi_wr_data[MW-1:0]),
					   .rd_clk		(rd_clk),
					   .rd_en		(emesh_access_in),
					   .rd_addr		(emmu_rd_addr[MAW-1:0])
					   );
   		       
   /*****************************/
   /*EMESH OUTPUT TRANSACTION   */
   /*****************************/   
   //pipeline to compensate for table lookup pipeline 
   //assumes one cycle memory access!     


    always @ (posedge  rd_clk)     
     if (reset)
       begin
	  emesh_access_out         <= 1'b0;	  
       end
     else if((write_in & ~emesh_wr_wait) | (~write_in & ~emesh_rd_wait))
       begin
	  emesh_access_out         <= emesh_access_in;
	  emesh_packet_reg[PW-1:0] <= emesh_packet_in[PW-1:0];	  
       end
     	 
   assign emesh_dstaddr_out[63:0] = (mmu_en & ~mmu_bp) ? {emmu_lookup_data[43:0], emesh_packet_reg[27:8]} :
				                         {32'b0,emesh_packet_reg[39:8]}; 
      
   //Concatenating output packet
   assign emesh_packet_out[PW-1:0] = {emesh_packet_reg[PW-1:40],
                                     emesh_dstaddr_out[31:0],
                                     emesh_packet_reg[7:0]
				    };
   

   assign emesh_packet_hi_out[31:0] = emesh_dstaddr_out[63:32];
      
endmodule // emmu
// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../memory/hdl")
// End:

/*
  Copyright (C) 2015 Adapteva, Inc.
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



   
