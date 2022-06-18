module testbench();

   localparam DW = 144;
   localparam CW = 8;
   localparam FILENAME = "test.mem"; //

   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			nreset;			// From oh_simctrl of oh_simctrl.v
   wire			start;			// From oh_simctrl of oh_simctrl.v
   wire			stim_done;		// From oh_stimulus of oh_stimulus.v
   wire [DW-1:0]	stim_packet;		// From oh_stimulus of oh_stimulus.v
   wire			stim_valid;		// From oh_stimulus of oh_stimulus.v
   wire			vdd;			// From oh_simctrl of oh_simctrl.v
   wire			vss;			// From oh_simctrl of oh_simctrl.v
   // End of automatics

   oh_stimulus #(.DW(DW),
		 .CW(CW),
		 .FILENAME(FILENAME))
   oh_stimulus(.dut_ready		(1'b1),
	       .dut_clk			(dut_clk),
	       .ext_valid		(1'b0),
	       .ext_packet		({(DW + CW){1'b0}}),
	       .ext_clk			(ext_clk),
	       .ext_start		(start),
	       /*AUTOINST*/
	       // Outputs
	       .stim_valid		(stim_valid),
	       .stim_packet		(stim_packet[DW-1:0]),
	       .stim_done		(stim_done),
	       // Inputs
	       .nreset			(nreset));

   oh_simctrl oh_simctrl(.stim_done	(1'b0),
			 .test_done	(1'b1),
			 .test_diff	(1'b0),
			 .dut_active    (1'b1),
			 .clk1		(ext_clk),
			 .clk2		(dut_clk),
			 /*AUTOINST*/
			 // Outputs
			 .nreset		(nreset),
			 .start			(start),
			 .vdd			(vdd),
			 .vss			(vss));

endmodule // tb
// Local Variables:
// verilog-library-directories:("." "../hdl")
// End:
