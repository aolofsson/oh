
`timescale 1 ns / 1 ps

`include "emaxi_v1_0_tb_include.vh"

module emaxi_v1_0_tb;
	reg tb_ACLK;
	reg tb_ARESETn;

	reg M00_AXI_INIT_AXI_TXN;
	wire M00_AXI_TXN_DONE;
	wire M00_AXI_ERROR;

	// Create an instance of the example tb
	`BD_WRAPPER dut (.ACLK(tb_ACLK),
				.ARESETN(tb_ARESETn),
				.M00_AXI_TXN_DONE(M00_AXI_TXN_DONE),
				.M00_AXI_ERROR(M00_AXI_ERROR),
				.M00_AXI_INIT_AXI_TXN(M00_AXI_INIT_AXI_TXN));

	// Simple Reset Generator and test
	initial begin
		tb_ARESETn = 1'b0;
	  #500;
		// Release the reset on the posedge of the clk.
		@(posedge tb_ACLK);
	  tb_ARESETn = 1'b1;
		@(posedge tb_ACLK);
	end

	// Simple Clock Generator
	initial tb_ACLK = 1'b0;
	always #10 tb_ACLK = !tb_ACLK;

	// Drive the BFM
	initial begin
		// Wait for end of reset
		wait(tb_ARESETn === 0) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     

		M00_AXI_INIT_AXI_TXN = 1'b0;
		#500 M00_AXI_INIT_AXI_TXN = 1'b1;

		$display("EXAMPLE TEST M00_AXI:");
		wait( M00_AXI_TXN_DONE == 1'b1);
		$display("M00_AXI: PTGEN_TEST_FINISHED!");
		if ( M00_AXI_ERROR ) begin
		  $display("PTGEN_TEST: FAILED!");
		end else begin
		  $display("PTGEN_TEST: PASSED!");
		end

	end

endmodule
