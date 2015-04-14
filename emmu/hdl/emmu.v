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
   mi_dout, emmu_access_out, emmu_write_out, emmu_datamode_out,
   emmu_ctrlmode_out, emmu_dstaddr_out, emmu_srcaddr_out,
   emmu_data_out,
   // Inputs
   clk, mmu_en, mi_clk, mi_en, mi_we, mi_addr, mi_din,
   emesh_access_in, emesh_write_in, emesh_datamode_in,
   emesh_ctrlmode_in, emesh_dstaddr_in, emesh_srcaddr_in,
   emesh_data_in
   );
   parameter DW     = 32;         //data width
   parameter AW     = 32;         //address width 
   parameter IDW    = 12;         //index size of table
   parameter PAW    = 64;         //physical address width of output
   parameter MW     = PAW-AW+IDW; //table data width
   parameter RFAW   = IDW+1;      //width of mi_addr
   
   /*****************************/
   /*DATAPATH CLOCk             */
   /*****************************/
   input             clk;
   
   /*****************************/
   /*MMU LOOKUP DATA            */
   /*****************************/
   input 	     mmu_en;              //enables mmu

   /*****************************/
   /*MMU table access interface */
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
   input              emesh_write_in;
   input [1:0]        emesh_datamode_in;
   input [3:0]        emesh_ctrlmode_in;
   input [AW-1:0]     emesh_dstaddr_in;
   input [AW-1:0]     emesh_srcaddr_in;
   input [DW-1:0]     emesh_data_in; 

   /*****************************/
   /*EMESH OUTPUTS              */
   /*****************************/
   output 	      emmu_access_out;
   output 	      emmu_write_out;
   output [1:0]       emmu_datamode_out;
   output [3:0]       emmu_ctrlmode_out;
   output [63:0]      emmu_dstaddr_out;
   output [AW-1:0]    emmu_srcaddr_out;
   output [DW-1:0]    emmu_data_out; 

   /*****************************/
   /*REGISTERS                  */
   /*****************************/
   reg 		      emmu_access_out;
   reg 		      emmu_write_out;
   reg [1:0] 	      emmu_datamode_out;
   reg [3:0] 	      emmu_ctrlmode_out;
   reg [AW-1:0]       emmu_srcaddr_out;
   reg [DW-1:0]	      emmu_data_out; 
   reg [AW-1:0]       emmu_dstaddr_reg;

   wire [47:0] 	      emmu_lookup_data;
   wire [63:0] 	      emmu_wr_data;
   wire 	      emmu_write;
   wire [5:0] 	      emmu_wr_en;
   
   /*****************************/
   /*MMU WRITE LOGIC            */
   /*****************************/
   assign emmu_write  = mi_en & mi_we;
      
   //write controls
   assign emmu_wr_en[5:0] = (emmu_write & ~mi_addr[2]) ? 6'b001111 :
	                    (emmu_write & mi_addr[2])  ? 6'b110000 :
			                                 6'b000000 ;

   //write data
   assign emmu_wr_data[63:0] = {mi_din[31:0], mi_din[31:0]};

`ifdef TARGET_XILINX
   memory_dp_48x4096 memory_dp_48x4096(
				       //write (portA)
				       .clka	(mi_clk),
				       .ena	(mi_en),
				       .wea	(emmu_wr_en[5:0]),
				       .addra	(mi_addr[14:3]),
				       .dina	(emmu_wr_data[47:0]),
				       //read (portB)
				       .doutb	(emmu_lookup_data[47:0]),
				       .clkb	(clk),
				       .enb	(emesh_access_in),
				       .addrb	(emesh_dstaddr_in[31:20])
				       );

`else // !`ifdef TARGET_XILINX
   
   assign emmu_lookup_data[47:0]=48'b0;
				 
`endif // !`ifdef TARGET_XILINX
   
				       
   /*****************************/
   /*EMESH OUTPUT TRANSACTION   */
   /*****************************/   
   //pipeline to compensate for table lookup pipeline 
   //assumes one cycle memory access!     

   always @ (posedge clk)
     emmu_access_out               <= emesh_access_in;
   
   always @ (posedge clk)
     if(emesh_access_in)   
       begin
	  emmu_write_out           <= emesh_write_in;
	  emmu_data_out[DW-1:0]    <= emesh_data_in[DW-1:0];
	  emmu_srcaddr_out[AW-1:0] <= emesh_srcaddr_in[AW-1:0];
	  emmu_dstaddr_reg[AW-1:0] <= emesh_dstaddr_in[AW-1:0];
	  emmu_ctrlmode_out[3:0]   <= emesh_ctrlmode_in[3:0];
	  emmu_datamode_out[1:0]   <= emesh_datamode_in[1:0];
       end
   
   assign emmu_dstaddr_out[63:0] = mmu_en ? {emmu_lookup_data[43:0],
					     emmu_dstaddr_reg[19:0]} :
				             {32'b0,emmu_dstaddr_reg[31:0]};
   
endmodule // emmu
// Local Variables:
// verilog-library-directories:("." "../../stubs/hdl")
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



   
