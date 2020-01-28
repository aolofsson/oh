//`include "elink_regmap.v"
module dut(/*AUTOARG*/
   // Outputs
   dut_active, clkout, wait_out, access_out, packet_out,
   // Inputs
   reg_write, reg_addr, clk1, clk2, nreset, vdd, vss, access_in,
   packet_in, wait_in
   );

   //##########################################################################
   //# INTERFACE 
   //##########################################################################

   parameter AW    = 32;
   parameter ID    = 12'h810;   
   parameter S_IDW = 12; 
   parameter M_IDW = 6; 
   parameter PW    = 2*AW + 40;     
   parameter N     = 1;
   parameter IW    = 10;
   
   //clock,reset
   input            clk1;
   input            clk2;
   input            nreset;
   input [N*N-1:0]  vdd;
   input 	    vss;
   output 	    dut_active;
   output 	    clkout;
   
   //Stimulus Driven Transaction
   input [N-1:0]     access_in;
   input [N*PW-1:0]  packet_in;
   output [N-1:0]    wait_out;

   //DUT driven transaction
   output [N-1:0]    access_out;
   output [N*PW-1:0] packet_out;
   input [N-1:0]     wait_in;

   //####################################################################
   //#BODY 
   //####################################################################

   wire 	     mem_rd_wait;
   wire 	     mem_wr_wait;
   wire 	     mem_access;
   wire [PW-1:0]     mem_packet;

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [5:0]		reg_addr;		// To pic of pic.v
   input		reg_write;		// To pic of pic.v
   // End of automatics
  
  
   
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	data_in;		// From p2e of packet2emesh.v
   wire [1:0]		datamode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From p2e of packet2emesh.v
   wire			ic_flush;		// From pic of pic.v
   wire [IW-1:0]	ic_ilat_reg;		// From pic of pic.v
   wire [IW-1:0]	ic_imask_reg;		// From pic of pic.v
   wire [IW-1:0]	ic_ipend_reg;		// From pic of pic.v
   wire [AW-1:0]	ic_iret_reg;		// From pic of pic.v
   wire			ic_irq;			// From pic of pic.v
   wire [AW-1:0]	ic_irq_addr;		// From pic of pic.v
   wire [AW-1:0]	srcaddr_in;		// From p2e of packet2emesh.v
   wire			write_in;		// From p2e of packet2emesh.v
   // End of automatics
      

   assign clkout     = clk1;   
   assign dut_active = 1'b1;
   assign wait_out   = 1'b0;

   assign reg_write     = write_in & access_in;
   assign reg_addr[5:0] = dstaddr_in[7:2];
   
   packet2emesh p2e (/*AUTOINST*/
		     // Outputs
		     .write_in		(write_in),
		     .datamode_in	(datamode_in[1:0]),
		     .ctrlmode_in	(ctrlmode_in[4:0]),
		     .dstaddr_in	(dstaddr_in[AW-1:0]),
		     .srcaddr_in	(srcaddr_in[AW-1:0]),
		     .data_in		(data_in[AW-1:0]),
		     // Inputs
		     .packet_in		(packet_in[PW-1:0]));
   


   pic  #(.AW(AW),
	  .IW(IW))
   pic (.reg_wdata	(data_in[31:0]),
        .ext_irq	({(IW){1'b0}}),
        .sq_pc_next	({(AW){1'b0}}),
        .de_rti		(1'b0),
        .sq_irq_en	(1'b1),
        .sq_ic_wait	(1'b0),
	.clk		(clk1),
	/*AUTOINST*/
	// Outputs
	.ic_iret_reg			(ic_iret_reg[AW-1:0]),
	.ic_imask_reg			(ic_imask_reg[IW-1:0]),
	.ic_ilat_reg			(ic_ilat_reg[IW-1:0]),
	.ic_ipend_reg			(ic_ipend_reg[IW-1:0]),
	.ic_flush			(ic_flush),
	.ic_irq				(ic_irq),
	.ic_irq_addr			(ic_irq_addr[AW-1:0]),
	// Inputs
	.nreset				(nreset),
	.reg_write			(reg_write),
	.reg_addr			(reg_addr[5:0]));
      
   
endmodule
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/hdl")
// End:


