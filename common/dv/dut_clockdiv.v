module dut(/*AUTOARG*/
   // Outputs
   dut_active, clkout, wait_out, access_out, packet_out,
   // Inputs
   clk1, clk2, nreset, vdd, vss, access_in, packet_in, wait_in
   );

   parameter N  = 1;
   parameter PW = 104;
      
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

   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   /*AUTOWIRE*/
    

   //tie offs for Dv
   assign dut_active   = 1'b1;
   assign wait_out     = 1'b0;
   assign clk          = clk1;   
   
   oh_clockdiv oh_clockdiv (.clkout	(clkout),
			    .clkout90	(clkout90),
			    .clk	(clk),
			    .nreset     (nreset),
			    .en		(1'b1),
			    .divcfg	(packet_in[11:8])
			    );
   
   
endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/dv" "../../emesh/hdl")
// End:

