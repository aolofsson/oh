module dut(/*AUTOARG*/
   // Outputs
   dut_active, clkout, wait_out, access_out, packet_out,
   // Inputs
   clk1, clk2, nreset, vdd, vss, access_in, packet_in, wait_in
   );

   parameter N  = 1;
   parameter PW = 104;
      
   //clock, reset
   input             clk1;
   input 	     clk2;   
   input             nreset;
   input [N*N-1:0]   vdd;
   input 	     vss;
   output 	     dut_active;
   output 	     clkout;
   
   //Stimulus Driven Transaction
   input [N-1:0]     access_in;
   input [N*PW-1:0]  packet_in;
   output [N-1:0]    wait_out;

   //DUT driven transactoin
   output [N-1:0]    access_out;
   output [N*PW-1:0] packet_out;
   input [N-1:0]     wait_in;

   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   /*AUTOWIRE*/
    

   //tie offs for Dv
   assign dut_active   = 1'b1;
   assign clkout       = clk2;
   
   oh_fifo_cdc #(.DW(PW),
		 .DEPTH(16))
   oh_fifo_cdc(.clk_in			(clk1), 
	       .clk_out			(clk2),
	       /*AUTOINST*/
	       // Outputs
	       .wait_out		(wait_out),
	       .access_out		(access_out),
	       .packet_out		(packet_out[PW-1:0]),
	       // Inputs
	       .nreset			(nreset),
	       .access_in		(access_in),
	       .packet_in		(packet_in[PW-1:0]),
	       .wait_in			(wait_in));
   
endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/dv" "../../emesh/hdl")
// End:

