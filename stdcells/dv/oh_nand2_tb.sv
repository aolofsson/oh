`timescale 1ns/1ps
`define OH_DEBUG
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
   oh_nand2 #(.SIM("switch"),
	      .NMODEL("nmos"),
	      .PMODEL("pmos"),
	      .W({0,1,2,3}),
	      .L({4,5,6,7}),
	      .M({8,9,10,11}),
	      .NF({12,13,14,15}))
   dut (/*AUTOINST*/
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
