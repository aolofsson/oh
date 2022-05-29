module dv_top ();
   parameter DW       = 64;        // Memory width
   parameter MAW      = 15;        // Memory address width

   //regs/wires
   reg [1023:0] filename;
   wire [DW-1:0] ext_packet;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			nreset;			// From dv_ctrl of dv_ctrl.v
   wire			start;			// From dv_ctrl of dv_ctrl.v
   wire			stim_access;		// From stimulus of stimulus.v
   wire			stim_done;		// From stimulus of stimulus.v
   wire [DW-1:0]	stim_packet;		// From stimulus of stimulus.v
   wire			vdd;			// From dv_ctrl of dv_ctrl.v
   wire			vss;			// From dv_ctrl of dv_ctrl.v
   // End of automatics

   assign test_done  = 1'b1;
   assign dut_active = 1'b1;
   //Reset and clocks
   dv_ctrl dv_ctrl(.clk1		(ext_clk),
		   .clk2		(dut_clk),
		   /*AUTOINST*/
		   // Outputs
		   .nreset		(nreset),
		   .start		(start),
		   .vdd			(vdd),
		   .vss			(vss),
		   // Inputs
		   .dut_active		(dut_active),
		   .stim_done		(stim_done),
		   .test_done		(test_done));

   //Stimulus
   assign ext_start   = start;
   assign ext_access  = 'b0;
   assign ext_packet  = 'b0;
   assign dut_wait    = 'b0;

   
   stimulus #(.DW(DW),.MAW(MAW),.HEXFILE("firmware.hex"))
   stimulus(
		     /*AUTOINST*/
	    // Outputs
	    .stim_access		(stim_access),
	    .stim_packet		(stim_packet[DW-1:0]),
	    .stim_done			(stim_done),
	    // Inputs
	    .nreset			(nreset),
	    .ext_start			(ext_start),
	    .ext_clk			(ext_clk),
	    .ext_access			(ext_access),
	    .ext_packet			(ext_packet[DW-1:0]),
	    .dut_clk			(dut_clk),
	    .dut_wait			(dut_wait));
   

endmodule // unmatched end(function|task|module|primitive|interface|package|class|clocking)
