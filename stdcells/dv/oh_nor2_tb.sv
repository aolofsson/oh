`timescale 1ns/1ps
module testbench();
   supply0 vss;
   supply1 vdd;
   
   // Skeleton
   initial
     begin
	$dumpfile("waveform.vcd");
	$dumpvars(0, testbench);
	#(1000)
	$finish;	
     end
   
   // Stimulus
   reg a,b;
   initial
     begin
	#100 a = 0; b = 0 ;
	#100 a = 0; b = 1 ;
	#100 a = 1; b = 0 ;
	#100 a = 1; b = 1 ;
     end
   
   // DUT
   defparam dut.NMODEL = "nmos";
   defparam dut.PMODEL = "pmos";   
   defparam dut.W      = {0,1,2,3};
   defparam dut.L      = {0,1,2,3};
   defparam dut.M      = {0,1,2,3};
   defparam dut.NF     = {0,1,2,3};
   
   oh_nor2 dut (/*AUTOINST*/
		 // Outputs
		 .z			(z),
		 // Inputs
		 .vdd			(vdd),
		 .vss			(vss),
		 .a			(a),
		 .b			(b));
   
   
endmodule // top
// Local Variables:
// verilog-library-directories:("." "../netlist")
// End:
