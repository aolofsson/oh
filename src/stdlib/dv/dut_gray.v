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

   wire [31:0] 	     gray;
   
   //tie offs for Dv
   assign dut_active = 1'b1;
   assign wait_out   = 1'b0;
   assign clkout     = clk1;
   assign access_out = access_in;
   
   //convert binary to gray
   oh_bin2gray #(.DW(32))
   b2g (.gray (gray[31:0]),
	.bin  (packet_in[39:8]));
   
   //convert gray back to binary
   oh_gray2bin #(.DW(32))
   g2b(.bin  (packet_out[39:8]),
       .gray (gray[31:0]));

   //check for error
   assign error = |(packet_in[39:8] ^ packet_out[39:8]);
   
endmodule // dut

// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/dv" "../../emesh/hdl")
// End:

