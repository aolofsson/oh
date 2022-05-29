// ###########################################################################
// # MEMORY TRANSACTION TRANSLATOR
// # 
// # This block uses the upper 12 bits [31:20] of a memory address as an index
// # to read an entry from a table.
// #
// # Writes are done from the register config interface
// #
// # The table can be configured as 12 bits wide or 44 bits wide.
// #
// # 32bit address output = {table_data[11:0],dstaddr[19:0]}
// # 64bit address output = {table_data[43:0],dstaddr[19:0]}
// #
// ############################################################################
module emmu (/*AUTOARG*/
   // Outputs
   reg_rdata, emesh_access_out, emesh_packet_out,
   // Inputs
   wr_clk, rd_clk, nreset, mmu_en, reg_access, reg_packet,
   emesh_access_in, emesh_packet_in, emesh_wait_in
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   // parameters
   parameter  AW     = 32;            // address width 
   parameter  MW     = 48;            // width of table
   parameter  MAW    = 12;            // memory addres width (entries = 1<<MAW)
   localparam PW     = 2*AW+40;       // packet width
   
   //reset    
   input 	     nreset;          // async active low reset
   
   //config
   input 	     mmu_en;          // enables mmu (by config register)

   //write port
   input 	     wr_clk;          // single clock
   input 	     reg_access;      // valid packet
   input [PW-1:0]    reg_packet;      // packet
   output [31:0]     reg_rdata;       // readback data
   
   //read port
   input 	     rd_clk;          // single clock
   input 	     emesh_access_in; // valid packet
   input [PW-1:0]    emesh_packet_in; // input packet
   input 	     emesh_wait_in;   // pushback

   //translated packet
   output 	     emesh_access_out;// valid packet 
   output [PW-1:0]   emesh_packet_out;// output packet
   
   //#####################################################################
   //# BODY
   //#####################################################################

   //wires + regs
   reg 		      emesh_access_out;
   reg [PW-1:0]       emesh_packet_reg;
   wire [63:0] 	      emesh_dstaddr_out;   
   wire [MW-1:0]      emmu_lookup_data;
   wire [MW-1:0]      mem_wem;
   wire [MW-1:0]      mem_data;   
   wire [AW-1:0]      emesh_dstaddr_in;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		reg_ctrlmode;		// From pe2 of packet2emesh.v
   wire [AW-1:0]	reg_data;		// From pe2 of packet2emesh.v
   wire [1:0]		reg_datamode;		// From pe2 of packet2emesh.v
   wire [AW-1:0]	reg_dstaddr;		// From pe2 of packet2emesh.v
   wire [AW-1:0]	reg_srcaddr;		// From pe2 of packet2emesh.v
   wire			reg_write;		// From pe2 of packet2emesh.v
   // End of automatics
   
   //###########################
   //# WRITE LOGIC
   //###########################

   /*packet2emesh  AUTO_TEMPLATE ( .\(.*\)_in  (reg_\1[]));*/   

   packet2emesh #(.AW(AW))
   pe2 (/*AUTOINST*/
	// Outputs
	.write_in			(reg_write),		 // Templated
	.datamode_in			(reg_datamode[1:0]),	 // Templated
	.ctrlmode_in			(reg_ctrlmode[4:0]),	 // Templated
	.dstaddr_in			(reg_dstaddr[AW-1:0]),	 // Templated
	.srcaddr_in			(reg_srcaddr[AW-1:0]),	 // Templated
	.data_in			(reg_data[AW-1:0]),	 // Templated
	// Inputs
	.packet_in			(reg_packet[PW-1:0]));	 // Templated
   
   //write controls
   assign mem_wem[MW-1:0] = ~reg_dstaddr[2] ? {{(MW-32){1'b0}},32'hFFFFFFFF} :
                                              {{(MW-32){1'b1}},32'h00000000};
      
   assign mem_write       = reg_access & 
			    reg_write;
      
   assign mem_data[MW-1:0] = {reg_data[31:0], reg_data[31:0]};

   //###########################
   //# EMESh PACKET DECODE 
   //###########################

   packet2emesh  #(.AW(32))
   p2e (// Outputs
	.write_in	(),
	.datamode_in	(),
	.ctrlmode_in	(),
	.dstaddr_in	(emesh_dstaddr_in[AW-1:0]),
	.srcaddr_in	(),
	.data_in	(),
	// Inputs
	.packet_in	(emesh_packet_in[PW-1:0]));
   
   //###########################
   //# LOOKUP TABLE
   //###########################  

   oh_memory_dp #(.DW(MW),
		  .DEPTH(4096))
   memory_dp (//read port
	      .rd_dout       (emmu_lookup_data[MW-1:0]),
	      .rd_en	     (emesh_access_in),
	      .rd_addr	     (emesh_dstaddr_in[31:20]),
	      .rd_clk	     (rd_clk),
	      //write port
	      .wr_en	     (mem_write),
	      .wr_wem	     (mem_wem[MW-1:0]),
	      .wr_addr	     (reg_dstaddr[14:3]),
 	      .wr_din	     (mem_data[MW-1:0]),
	      .wr_clk	     (wr_clk)
	      );
   
   //###########################
   //# OUTPUT PACKET
   //###########################         

   //pipeline (compensates for 1 cycle memory access)

   always @ (posedge  rd_clk)
     if (!nreset)
       emesh_access_out         <=  1'b0;   
     else if(~emesh_wait_in)
       emesh_access_out         <=  emesh_access_in;

   always @ (posedge  rd_clk)
     if(~emesh_wait_in)
       emesh_packet_reg[PW-1:0] <=  emesh_packet_in[PW-1:0];	  
     	 
   //like base register for trampolining to 64 bit space
   assign emesh_dstaddr_out[63:0] = mmu_en ? {emmu_lookup_data[43:0], 
					      emesh_packet_reg[27:8]} :
				             {32'b0,emesh_packet_reg[39:8]}; 

   //concatenating output packet
   assign emesh_packet_out[PW-1:0] = {emesh_packet_reg[PW-1:40],
                                      emesh_dstaddr_out[31:0],
                                      emesh_packet_reg[7:0]
				     };
   

   //assign emesh_packet_hi_out[31:0] = emesh_dstaddr_out[63:32];
      
endmodule // emmu
// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../memory/hdl" "../../emesh/hdl")
// End:



   
