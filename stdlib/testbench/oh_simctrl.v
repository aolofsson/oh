//#############################################################################
//# Function: Simulation control (clk/reset/go/finish)
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_simctrl
  #(parameter TIMEOUT         = 5000, // timeout value (cycles)
    parameter PERIOD_CLK      = 10,   // core clock period
    parameter PERIOD_FASTCLK  = 10,   // fast clock period
    parameter PERIOD_SLOWCLK  = 10,   // slow clock period
    parameter RANDOM_CLK       = 0,   // randomize clock
    parameter RANDOM_DATA      = 0    // randomize data
    )
   (
    //control signals to drive
    output reg 	     nreset, // async active low reset
    output reg 	     clk, // main clock
    output reg 	     fastclk, // second(fast) clock
    output reg 	     slowclk, // third (slow) clock
    output reg [2:0] mode, //0=idle,1=load,2=go,3=rng,4=bypass
    //input from testbench
    input 	     dut_fail, // dut fail indicator
    input 	     dut_done // dut/tb signaled done
    );

   // TODO: parametrize?
   localparam TIME_RESET = 50;
   localparam TIME_WAIT  = 50;
   localparam TIME_LOAD  = 50;

   //signal declarations
   reg [6:0]   clk_phase;
   reg [6:0]   fastclk_phase;
   reg [6:0]   slowclk_phase;
   integer     seed, r;
   wire [2:0]  gomode;

   //#################################
   // CONFIGURATION
   //#################################

   initial
     begin
	$timeformat(-9, 0, " ns", 20);
     end

   //#################################
   // RESET/STARTUP SEQUENCE
   //#################################
   generate
      if (RANDOM_DATA)
	assign gomode = 3'b011;//rng
      else
  	assign gomode = 3'b010;//stim data
   endgenerate

   initial
     begin
	#(1)
	nreset   = 'b0;
	clk      = 'b0;
	fastclk  = 'b0;
	slowclk  = 'b0;
	mode     = 3'b0;
	#(clk_phase * TIME_RESET)  //hold reset a while
	nreset   = 'b1;
	#(clk_phase * TIME_WAIT)
	mode     = 3'b001;    // load stimulus
	#(clk_phase * TIME_LOAD)
	mode     = gomode;
     end // initial begin

   //#################################
   // CLK GENERATORS
   //#################################

   generate
      if (RANDOM_CLK) begin
	 initial
	   begin
	      //TODO: improve
	      clk_phase     = $urandom_range(50,50);
	      fastclk_phase = $urandom_range(500,50);
	      slowclk_phase = $urandom_range(50,1);
	   end
      end
      else begin
	 initial begin
	    clk_phase     = PERIOD_CLK/2;
	    fastclk_phase = PERIOD_FASTCLK/2;
	    slowclk_phase = PERIOD_SLOWCLK/2;
	 end
      end
   endgenerate

   always
     #(clk_phase) clk = ~clk;

   always
     #(fastclk_phase) fastclk = ~fastclk;

   always
     #(slowclk_phase) slowclk = ~slowclk;

   //#################################
   // END OF TEST
   //#################################

   always @ (posedge clk)
     if(dut_done)
       begin
	  #500
	    if(dut_fail)
	      $display("[OH] DUT TEST FAILED");
	    else
	      $display("[OH] DUT TEST PASSED");
	  $finish;
       end

   //#################################
   // TIMEOUT
   //#################################
   initial
     begin
	#(TIMEOUT)
	$display("[OH] DUT TEST TIMEOUT");
	$finish;
     end

endmodule
