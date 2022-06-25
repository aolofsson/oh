//#############################################################################
//# Function: Common testbench for simulator and fpga                         #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module testbench
  #(parameter PW             = 256,         // packet width
    parameter CW             = 16,         // control width
    parameter N              = 32,          // ctrl/status width
    parameter PERIOD_CLK     = 10,          // core clock period
    parameter PERIOD_FASTCLK = 20,          // fast clock period
    parameter PERIOD_SLOWCLK = 20,          // slow clock period
    parameter TIMEOUT        = 5000,        // timeout value
    parameter RANDOMIZE      = 0,           // 1=randomize period
    parameter SIMULATE       = 1,           // 1=VERILOG SIM
    parameter FILENAME       = "NONE",      // Simulus hexfile for $readmemh
    parameter DEPTH          = 8192,        // simulus memory depth
    parameter SEED           = 32'haaaaaaaa,// seed for random generation
    parameter TARGET         = "DEFAULT"    // physical synthesis/sim target
    )
   (
    // control signals to drive
    input 	   nreset, // async active low reset
    input 	   clk, // core clock
    input 	   fastclk,
    input 	   slowclk,
    input 	   go, // start signal
    input [N-1:0]  ctrl, //generic ctrl vector
    output [N-1:0] status, //generic status vector
    output 	   dut_error,
    output 	   dut_done,
    // external write interface
    input 	   ext_clk,
    input [PW-1:0] ext_packet,
    input 	   ext_ready,
    input 	   ext_valid
    );

   //#################################
   // LOCAL WIRES, PARAMETERS
   //#################################

   wire [PW-1:0]   tb_packet;
   wire 	   tb_ready;
   wire 	   tb_valid;
   wire [N-1:0]    tb_ctrl;
   wire 	   tb_nreset;
   wire 	   tb_clk;
   wire 	   tb_slowclk;
   wire 	   tb_fastclk;
   wire 	   tb_go;

   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			dut_active;		// From tb_dut of tb_dut.v
   wire [PW-1:0]	dut_packet;		// From tb_dut of tb_dut.v
   wire			dut_ready;		// From tb_dut of tb_dut.v
   wire [N-1:0]		dut_status;		// From tb_dut of tb_dut.v
   wire			dut_valid;		// From tb_dut of tb_dut.v
   // End of automatics

   //#################################
   // CONTROL INTERFACE
   //#################################

   assign tb_ctrl[N-1:0]  = ctrl[N-1:0];

   generate
      if (SIMULATE) begin
	 /*oh_simctrl AUTO_TEMPLATE (
	  .dut_\(.*\) (dut_\1[]),
	  .\(.*\) (tb_\1[]),
	  );
	  */
	 oh_simctrl #(.PERIOD_CLK(PERIOD_CLK),
		      .PERIOD_SLOWCLK(PERIOD_SLOWCLK),
		      .PERIOD_FASTCLK(PERIOD_FASTCLK),
		      .TIMEOUT(TIMEOUT),
		      .RANDOMIZE(RANDOMIZE))
	 oh_simctrl(/*AUTOINST*/
		    // Outputs
		    .nreset		(tb_nreset),		 // Templated
		    .clk		(tb_clk),		 // Templated
		    .fastclk		(tb_fastclk),		 // Templated
		    .slowclk		(tb_slowclk),		 // Templated
		    .go			(tb_go),		 // Templated
		    // Inputs
		    .dut_active		(dut_active),		 // Templated
		    .dut_done		(dut_done),		 // Templated
		    .dut_error		(dut_error));		 // Templated
      end
      else begin
	 assign tb_nreset     = nreset;
	 assign tb_clk        = clk;
	 assign tb_slowclk    = slowclk;
	 assign tb_fastclk    = fastclk;
	 assign tb_go         = go;
      end
   endgenerate

   //#################################
   // DUT
   //#################################
   /*tb_dut AUTO_TEMPLATE (
	  .dut_\(.*\) (dut_\1[]),
	  .\(.*\) (tb_\1[]),
	  );
	  */
   tb_dut #(.PW(PW),
	    .N(N),
	    .SEED(SEED),
	    .TARGET(TARGET))
   tb_dut(.valid		(tb_valid),
	  .packet		(tb_packet[PW-1:0]),
	  .ready		(tb_ready),
	  /*AUTOINST*/
	  // Outputs
	  .dut_active			(dut_active),		 // Templated
	  .dut_error			(dut_error),		 // Templated
	  .dut_done			(dut_done),		 // Templated
	  .dut_status			(dut_status[N-1:0]),	 // Templated
	  .dut_valid			(dut_valid),		 // Templated
	  .dut_packet			(dut_packet[PW-1:0]),	 // Templated
	  .dut_ready			(dut_ready),		 // Templated
	  // Inputs
	  .clk				(tb_clk),		 // Templated
	  .fastclk			(tb_fastclk),		 // Templated
	  .slowclk			(tb_slowclk),		 // Templated
	  .nreset			(tb_nreset),		 // Templated
	  .go				(tb_go),		 // Templated
	  .ctrl				(tb_ctrl[N-1:0]));	 // Templated

   //#################################
   // STIMULUS
   //#################################

   oh_stimulus #(.PW(PW),
		 .CW(CW),
		 .DEPTH(DEPTH),
		 .TARGET(TARGET),
		 .FILENAME(FILENAME))
   oh_stimulus(.dut_clk		(clk),
	       .stim_valid	(tb_valid),
	       .stim_packet	(tb_packet[PW-CW-1:0]),
	       .stim_done	(tb_done),
	       /*AUTOINST*/
	       // Inputs
	       .nreset			(nreset),
	       .go			(go),
	       .ext_clk			(ext_clk),
	       .ext_valid		(ext_valid),
	       .ext_packet		(ext_packet[PW-1:0]),
	       .dut_ready		(dut_ready));

endmodule // testbench
// Local Variables:
// verilog-library-directories:("." "../rtl")
// End:
