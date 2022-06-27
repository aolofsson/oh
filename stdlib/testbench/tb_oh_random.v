//#############################################################################
//# Function: Testbench for "oh_random"
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module testbench
  #(parameter PW        = 256,         // packet total width
    parameter CW        = 16,          // packet control width
    parameter N         = 32,          // ctrl/status width
    parameter DEPTH     = 8192,        // simulus memory depth
    parameter TARGET    = "DEFAULT",   // physical synthesis/sim target
    parameter FILENAME  = "NONE"     // Simulus hexfile for $readmemh
    )
   (
    // control signals to drive
    input 	    nreset, // async active low reset
    input 	    clk, // core clock
    input 	    fastclk, // fast clock
    input 	    slowclk, //slow clock
    input [2:0]     mode, //0=load,1=go,2=bypass,3=rng
    input [N-1:0]   ctrl, // generic ctrl vector
    input [PW-1:0]  seed, // seed(s) for rng
    // external write interface
    input 	    ext_clk, //ext packet clock
    input 	    ext_valid, // ext valid signal
    input [PW-1:0]  ext_packet, // ext packet
    input 	    ext_ready, // external ready to receive
    // dut response packets
    output 	    dut_clk, // due packet clock
    output 	    dut_valid, //dut packet valid signal
    output [PW-1:0] dut_packet, // dut packet to drive
    output 	    dut_ready, // dut is ready for packet
    // dut status interface
    output [N-1:0]  dut_status, // generic status vector
    output 	    dut_error,// dut error flag (leads to failure)
    output 	    dut_done, // test done
    output 	    dut_fail  // test failed
    );

   //#################################
   // LOCAL WIRES
   //#################################

   wire dut_active;
   wire dut_ready;
   wire dut_error;
   wire dut_done;
   wire dut_valid;
   wire tb_xrandom;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			stim_done;		// From oh_stimulus of oh_stimulus.v
   wire [PW-1:0]	stim_packet;		// From oh_stimulus of oh_stimulus.v
   wire			stim_valid;		// From oh_stimulus of oh_stimulus.v
   // End of automatics

   /*AUTOINPUT*/

   //#################################
   // DUT LOGIC
   //#################################

   assign dut_active = 1'b1;
   assign dut_ready  = 1'b1;
   assign dut_error  = 1'b0;
   assign dut_done   = 1'b0;
   assign dut_valid  = 1'b0;
   assign dut_clk    = clk;

   /*oh_random AUTO_TEMPLATE (
    .en	    (tb_go),
    .out    (dut_status[N-1:0]),
    );
    */

   oh_random #(.N(N))
   oh_random(.mask	({(N){1'b1}}),
	     .taps	({(N){1'b1}}),
	     .entaps	(1'b0),
	     .en	(tb_go),
	     .seed      ({(N/4){4'hA}}),
	     /*AUTOINST*/
	     // Outputs
	     .out			(dut_status[N-1:0]),	 // Templated
	     // Inputs
	     .clk			(clk),
	     .nreset			(nreset));

   //#################################
   // STIMULUS
   //#################################

   oh_stimulus #(.PW(PW),
		 .CW(CW),
		 .DEPTH(DEPTH),
		 .TARGET(TARGET),
		 .FILENAME(FILENAME))
   oh_stimulus(/*AUTOINST*/
	       // Outputs
	       .stim_valid		(stim_valid),
	       .stim_packet		(stim_packet[PW-1:0]),
	       .stim_done		(stim_done),
	       // Inputs
	       .nreset			(nreset),
	       .mode			(mode[1:0]),
	       .seed			(seed[PW-1:0]),
	       .ext_clk			(ext_clk),
	       .ext_valid		(ext_valid),
	       .ext_packet		(ext_packet[PW-1:0]),
	       .dut_clk			(dut_clk),
	       .dut_ready		(dut_ready));

endmodule // tb
// Local Variables:
// verilog-library-directories:("." "../rtl")
// End:
