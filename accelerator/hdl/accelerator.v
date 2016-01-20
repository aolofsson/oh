`include "accelerator_regmap.v"
module accelerator (/*AUTOARG*/
   // Outputs
   m_wr_access, m_wr_packet, m_rd_access, m_rd_packet, m_rr_wait,
   s_wr_wait, s_rd_wait, s_rr_access, s_rr_packet,
   // Inputs
   clk, nreset, m_wr_wait, m_rd_wait, m_rr_access, m_rr_packet,
   s_wr_access, s_wr_packet, s_rd_access, s_rd_packet, s_rr_wait
   );   

   //##############################################################
   //#INTERFACE
   //###############################################################

   parameter AW   = 32;          //native address width
   parameter PW   = 2 * AW + 40; //packet width   
   parameter ID   = 12'h810;     //epiphany ID for elink (ie addr[31:20])
   parameter RFAW = 6;
   
   //clock and reset
   input 	  clk;           // single system clock for master/slave FIFOs
   input          nreset;        // reset for axi facing logic (active low)
      
   //############################
   // ACCELERATOR GENERATERD 
   //############################
   //Master Write (from RX)
   output 	   m_wr_access;
   output [PW-1:0] m_wr_packet;
   input 	   m_wr_wait;
      
   //Master Read Request
   output 	   m_rd_access;
   output [PW-1:0] m_rd_packet;
   input 	   m_rd_wait;

   //Master Read Response
   input 	   m_rr_access;
   input [PW-1:0]  m_rr_packet;
   output 	   m_rr_wait;

   //############################
   // HOST GENERATERD 
   //############################
   //Slave Write
   input 	   s_wr_access;
   input [PW-1:0]  s_wr_packet;
   output 	   s_wr_wait;

   //Slave Read Request
   input 	   s_rd_access;
   input [PW-1:0]  s_rd_packet;
   output 	   s_rd_wait;

   //Slave Read Response
   output 	   s_rr_access;
   output [PW-1:0] s_rr_packet;
   input 	   s_rr_wait;

   //##############################################################
   //#BODY
   //###############################################################
   wire 	   access_in;
   wire [PW-1:0]   packet_in;
   reg [31:0] 	   data_out;
   reg 		   s_rr_access;
   wire [31:0] 	   result;
   reg [31:0] 	   reg_input0;
   reg [31:0] 	   reg_input1;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From s_wr of packet2emesh.v
   wire [AW-1:0]	data_in;		// From s_wr of packet2emesh.v
   wire [1:0]		datamode_in;		// From s_wr of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From s_wr of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From s_wr of packet2emesh.v
   wire			write_in;		// From s_wr of packet2emesh.v
   // End of automatics
   
   //############################
   // INPUTS
   //############################
   
   emesh_mux #(.N(2),.AW(AW))
   mux2(// Outputs
	.wait_out   ({s_rd_wait, s_wr_wait}),
	.access_out (access_in),
	.packet_out (packet_in[PW-1:0]),
	// Inputs
	.access_in  ({s_rd_access, s_wr_access}),
	.packet_in  ({s_rd_packet[PW-1:0],s_wr_packet[PW-1:0]}),
	.wait_in    (s_rr_wait)
	);
   
   packet2emesh #(.AW(AW))
   s_wr(/*AUTOINST*/
	// Outputs
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[4:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]),
	// Inputs
	.packet_in			(packet_in[PW-1:0]));	 // Templated // Templated)
   
   
   //#####################
   //#ACCELERATOR
   //#####################

   //registers
   assign acc_match   = access_in                &
			(dstaddr_in[31:20]==ID)  &
		        (dstaddr_in[19:16]==`EGROUP_MMR);
   
   assign input0_match  = acc_match & (dstaddr_in[RFAW+1:2]==`REG_INPUT0);
   assign input1_match  = acc_match & (dstaddr_in[RFAW+1:2]==`REG_INPUT1);
   assign output_match  = acc_match & (dstaddr_in[RFAW+1:2]==`REG_OUTPUT);
   
   assign input0_write  = input0_match  &  write_in;
   assign input1_write  = input1_match  &  write_in;
   assign output_read   = output_match  & ~write_in;

   //input0
   always @ (posedge clk)
     if(input0_write)
       reg_input0[31:0] <= data_in[31:0];

   //input1
   always @ (posedge clk)
     if(input1_write)
       reg_input1[31:0] <= data_in[31:0];

   //arithmetic
   assign result[31:0] = reg_input0[31:0] +
			 reg_input1[31:0];
   
   //#########################
   //#READBACK WITH PIPELINE
   //#########################
   
   always @ (posedge clk)
     if(~nreset)
       s_rr_access    <= 'b0;   
     else
       s_rr_access  <= output_read;
   
   always @ (posedge clk)
     data_out[31:0] <= result[31:0];	

   emesh2packet #(.AW(32))
   p2e (.packet_out			(s_rr_packet[PW-1:0]),
	.write_out			(1'b1),
	.datamode_out			(2'b10),
	.ctrlmode_out			(5'b0),
	.dstaddr_out			(32'b0),
	.srcaddr_out			(32'b0),
	/*AUTOINST*/
	// Inputs
	.data_out			(data_out[AW-1:0]));
   
endmodule // elink


// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emesh/hdl" )
// End:




