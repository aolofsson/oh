module testbench();

   localparam N = 32;

   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			clk1;			// From oh_simctrl of oh_simctrl.v
   wire			clk2;			// From oh_simctrl of oh_simctrl.v
   wire			nreset;			// From oh_simctrl of oh_simctrl.v
   wire			out;			// From oh_pulse of oh_pulse.v
   wire			start;			// From oh_simctrl of oh_simctrl.v
   wire			vdd;			// From oh_simctrl of oh_simctrl.v
   wire			vss;			// From oh_simctrl of oh_simctrl.v
   // End of automatics

   oh_pulse #(.N(N))
   oh_pulse(.en		(1'b1),
	    .clk	(clk1),
	    .mask	(32'h0000000f),
	     /*AUTOINST*/
	    // Outputs
	    .out			(out),
	    // Inputs
	    .nreset			(nreset));

   oh_simctrl oh_simctrl(//TODO: implement
			.stim_done	(1'b0),
			.test_done	(1'b0),
			.test_diff	(1'b0),
			.dut_active     (1'b1),
			/*AUTOINST*/
			 // Outputs
			 .nreset		(nreset),
			 .clk1			(clk1),
			 .clk2			(clk2),
			 .start			(start),
			 .vdd			(vdd),
			 .vss			(vss));

endmodule // tb
// Local Variables:
// verilog-library-directories:("." "../hdl")
// End:
