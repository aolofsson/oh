/*****************************************************************************
 * Very limited simulation wrapper for Icarus type Verilog simulators
 *
 * - instantiate testbench
 * - reset generation
 * - clock generation
 * - vcd dump
 * - end of test
 * - timeout
 *
 *****************************************************************************/
module top();

   // Enable define overrides

`ifdef OH_PW
   parameter PW  = `OH_PW;
`else
   parameter PW  = 32;
`endif

`ifdef OH_N
   parameter N  = `OH_N;
`else
   parameter N  = 32;
`endif

`ifdef OH_SEED
   parameter [N-1:0] SEED  = `OH_SEED;
`else
   parameter [N-1:0] SEED  = 1;
`endif

`ifdef OH_CTRL
   parameter [N-1:0]CTRL  = `OH_CTRL;
`else
   parameter [N-1:0] CTRL  = 1;
`endif

`ifdef OH_CW
   parameter CW  = `OH_CW;
`else
   parameter CW = 0;
`endif

`ifdef OH_TIMEOUT
   parameter TIMEOUT  = `OH_TIMEOUT;
`else
   parameter TIMEOUT  = 5000;
`endif

`ifdef OH_PERIOD_CLK
   parameter PERIOD_CLK  = `OH_PERIOD_CLK;
`else
   parameter PERIOD_CLK  = 10;
`endif

`ifdef OH_PERIOD_FASTCLK
   parameter PERIOD_FASTCLK  = `OH_PERIOD_FASTCLK;
`else
   parameter PERIOD_FASTCLK  = 20;
`endif

`ifdef OH_PERIOD_SLOWCLK
   parameter PERIOD_SLOWCLK  = `OH_PERIOD_SLOWCLK;
`else
   parameter PERIOD_SLOWCLK  = 20;
`endif

`ifdef OH_RANDOM_DATA
   parameter RANDOM_DATA  = `OH_RANDOM_DATA;
`else
   parameter RANDOM_DATA  = 0;
`endif

`ifdef OH_RANDOM_CLK
   parameter RANDOM_CLK  = `OH_RANDOM_CLK;
`else
   parameter RANDOM_CLK  = 0;
`endif

`ifdef OH_MEMDEPTH
   parameter DEPTH = `OH_MEMDEPTH;
`else
   parameter DEPTH  = 1024;
`endif

`ifdef OH_TARGET
   parameter TARGET = `OH_TARGET;
`else
   parameter TARGET  = "DEFAULT";
`endif

`ifdef OH_FILENAME
   parameter FILENAME = `OH_FILENAME;
`else
   parameter FILENAME  = "NONE";
`endif

   wire [N-1:0]	ctrl;			// To testbench of testbench.v
   wire [N-1:0] seed;			// To testbench of testbench.v

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			clk;			// From oh_simctrl of oh_simctrl.v
   wire			dut_clk;		// From testbench of testbench.v
   wire			dut_done;		// From testbench of testbench.v
   wire			dut_error;		// From testbench of testbench.v
   wire			dut_fail;		// From testbench of testbench.v
   wire [PW-1:0]	dut_packet;		// From testbench of testbench.v
   wire			dut_ready;		// From testbench of testbench.v
   wire [N-1:0]		dut_status;		// From testbench of testbench.v
   wire			dut_valid;		// From testbench of testbench.v
   wire			fastclk;		// From oh_simctrl of oh_simctrl.v
   wire [2:0]		mode;			// From oh_simctrl of oh_simctrl.v
   wire			nreset;			// From oh_simctrl of oh_simctrl.v
   wire			slowclk;		// From oh_simctrl of oh_simctrl.v
   // End of automatics
   /*AUTOINPUT*/

   //#################################
   // DUT
   //#################################


   assign seed[N-1:0] = SEED;
   assign ctrl[N-1:0] = CTRL;

   /*testbench AUTO_TEMPLATE (
    .ext_packet	 ({(PW){1'b0}}),
    .ext_\(.*\)  (1'b0),
    );
    */

   testbench #(.PW(PW),
	       .CW(CW),
	       .N(N),
	       .DEPTH(DEPTH),
	       .TARGET(TARGET),
	       .FILENAME(FILENAME))
   testbench(/*AUTOINST*/
	     // Outputs
	     .dut_clk			(dut_clk),
	     .dut_valid			(dut_valid),
	     .dut_packet		(dut_packet[PW-1:0]),
	     .dut_ready			(dut_ready),
	     .dut_status		(dut_status[N-1:0]),
	     .dut_error			(dut_error),
	     .dut_done			(dut_done),
	     .dut_fail			(dut_fail),
	     // Inputs
	     .nreset			(nreset),
	     .clk			(clk),
	     .fastclk			(fastclk),
	     .slowclk			(slowclk),
	     .mode			(mode[2:0]),
	     .ctrl			(ctrl[N-1:0]),
	     .seed			(seed[N-1:0]),
	     .ext_clk			(1'b0),			 // Templated
	     .ext_valid			(1'b0),			 // Templated
	     .ext_packet		({(PW){1'b0}}),		 // Templated
	     .ext_ready			(1'b0));			 // Templated


   //#################################
   // Simulation control
   //#################################

   oh_simctrl #(.TIMEOUT(TIMEOUT),
		.PERIOD_CLK(PERIOD_CLK),
		.PERIOD_SLOWCLK(PERIOD_SLOWCLK),
		.PERIOD_FASTCLK(PERIOD_FASTCLK),
		.RANDOM_DATA(RANDOM_DATA),
		.RANDOM_CLK(RANDOM_CLK))
   oh_simctrl(/*AUTOINST*/
	      // Outputs
	      .nreset			(nreset),
	      .clk			(clk),
	      .fastclk			(fastclk),
	      .slowclk			(slowclk),
	      .mode			(mode[2:0]),
	      // Inputs
	      .dut_fail			(dut_fail),
	      .dut_done			(dut_done));

   //#################################
   // Wavedump
   //#################################

   initial
     begin
	$timeformat(-9, 0, " ns", 20);
	$dumpfile("waveform.vcd");
	$dumpvars(0, testbench);
     end


endmodule // top
