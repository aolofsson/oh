module dut(/*AUTOARG*/
   // Outputs
   dut_active, clkout, wait_out, access_out, packet_out,
   // Inputs
   clk1, clk2, nreset, vdd, vss, access_in, packet_in, wait_in
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter N       =  1;   
   parameter AW      = 32;               // address width
   parameter NMIO    =  8;               // IO data width
   parameter DEF_CFG =  18'h1070;        // for 104 bits   
   parameter DEF_CLK =  7;   
   localparam PW     = 2*AW + 40;        // standard packet   
   
   //clock, reset
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

   //DUT driven transactoin
   output [N-1:0]    access_out;
   output [N*PW-1:0] packet_out;
   input [N-1:0]     wait_in;

   //########################################
   //# BODY
   //########################################

   //wires
   wire 	     reg_access_in;   
   wire [PW-1:0]     reg_packet_in;
   wire 	     reg_wait_in;
   wire 	     edma_access_in;
   
   /*AUTOINPUT*/
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			irq;			// From edma of edma.v
   wire			reg_access_out;		// From edma of edma.v
   wire [PW-1:0]	reg_packet_out;		// From edma of edma.v
   wire			reg_wait_out;		// From edma of edma.v
   // End of automatics
 
   
   assign dut_active       = 1'b1;
   assign clkout           = clk1;

   //########################################
   //# DECODE (SPLITTING CTRL+DATA)
   //########################################

   //hack: send to regfile if addr[31:20] is zero
   assign edma_access_in   = access_in & |packet_in[39:28];
   assign reg_access_in    = access_in & ~(|packet_in[39:28]);   
   assign reg_packet_in    = packet_in;
   assign reg_wait_in      = wait_in;

   //########################################
   //# DUT: EDMA
   //########################################
   
   /*edma  AUTO_TEMPLATE (
            .clk	    (clk1),
            .access_in	    (edma_access_in),
         
    );
    */
 
   edma #(.AW(AW))
	
   edma (/*AUTOINST*/
	 // Outputs
	 .irq				(irq),
	 .wait_out			(wait_out),
	 .access_out			(access_out),
	 .packet_out			(packet_out[PW-1:0]),
	 .reg_wait_out			(reg_wait_out),
	 .reg_access_out		(reg_access_out),
	 .reg_packet_out		(reg_packet_out[PW-1:0]),
	 // Inputs
	 .clk				(clk1),			 // Templated
	 .nreset			(nreset),
	 .access_in			(edma_access_in),	 // Templated
	 .packet_in			(packet_in[PW-1:0]),
	 .wait_in			(wait_in),
	 .reg_access_in			(reg_access_in),
	 .reg_packet_in			(reg_packet_in[PW-1:0]),
	 .reg_wait_in			(reg_wait_in));
   
     
endmodule // dut
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../common/hdl" "../../emesh/dv" "../../emesh/hdl")
// End:

