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
   rd_clk, wr_clk, mmu_en, mmu_bp, mi_en, mi_we, mi_addr, mi_din,
   emesh_access_in, emesh_packet_in, emesh_rd_wait, emesh_wr_wait
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
   input 	     rd_clk;
   input 	     wr_clk;
   
   /*****************************/
   /*MMU LOOKUP DATA            */
   /*****************************/
   input 	     mmu_en;              //enables mmu (static)
   input 	     mmu_bp;              //bypass mmu on read response (RX)

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
   wire [31:0]        emmu_rd_addr;
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
   packet2emesh  #(.AW(32))
   p2e (//outputs
	.write_in	(write_in),
	.datamode_in	(),
	.ctrlmode_in	(),
	.data_in	(),
	.dstaddr_in	(emmu_rd_addr[AW-1:0]),
	.srcaddr_in	(),
	//inputs
	.packet_in	(emesh_packet_in[PW-1:0]));
         
   oh_memory_dp #(.DW(MW),.AW(MAW)) memory_dp (
					   // Outputs
					   .rd_data		(emmu_lookup_data[MW-1:0]),
					   // Inputs
					   .wr_clk		(wr_clk),
					   .wr_en		(mi_wr_vec[5:0]),
					   .wr_addr		(mi_addr[14:3]),
					   .wr_data		(mi_wr_data[MW-1:0]),
					   .rd_clk		(rd_clk),
					   .rd_en		(emesh_access_in),
					   .rd_addr		(emmu_rd_addr[31:20])
					   );
   		       
   /*****************************/
   /*EMESH OUTPUT TRANSACTION   */
   /*****************************/   
   //pipeline to compensate for table lookup pipeline 
   //assumes one cycle memory access!
   //the pushback is needed stall async transmit path      

   always @ (posedge  rd_clk)
     if(~(emesh_wr_wait | emesh_rd_wait))
       begin
	  emesh_access_out         <=  emesh_access_in;
	  emesh_packet_reg[PW-1:0] <=  emesh_packet_in[PW-1:0];	  
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
// verilog-library-directories:("." "../../common/hdl" "../../memory/hdl" "../../emesh/hdl")
// End:



   
