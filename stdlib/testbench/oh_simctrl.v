//#############################################################################
//# Function: Simulation control (clk/reset/go/finish)
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_simctrl
  #( parameter PERIOD_CLK      = 10,   // core clock period
     parameter PERIOD_FASTCLK  = 20,   // fast clock period
     parameter PERIOD_SLOWCLK  = 20,   // slow clock period
     parameter TIMEOUT         = 5000, // timeout value
     parameter RANDOMIZE       = 0     // randomize period
     )
   (
    //control signals to drive
    output reg nreset, // async active low reset
    output reg clk, // main clock
    output reg fastclk, // second(fast) clock
    output reg slowclk, // third (slow) clock
    output reg go, // start test (level)
    //input from testbench
    input      dut_active, // dut reset sequence is done
    input      dut_done, // dut/tb signaled done
    input      dut_error // dut/tb per cycle error
    );

   //signal declarations
   reg [6:0]   clk_phase;
   reg [6:0]   fastclk_phase;
   reg [6:0]   slowclk_phase;
   reg 	       fail;
   integer     seed,r;

   //#################################
   // CONFIGURATION
   //#################################

   initial
     begin
	$timeformat(-9, 0, " ns", 20);
	$dumpfile("waveform.vcd");
	$dumpvars(0, testbench);
     end


   //#################################
   // RESET/STARUP
   //#################################

   initial
     begin
	#(1)
	nreset   = 'b0;
	clk      = 'b0;
	fastclk  = 'b0;
	slowclk  = 'b0;
	#(clk_phase * 40 + 10)   //hold reset a while
	nreset   = 'b1;
     end

   //#################################
   // CLK GENERATORS
   //#################################

   generate
      if (RANDOMIZE) begin
	 initial
	   begin
	      r=$value$plusargs("SEED=%s", seed);
	      clk_phase = 1 + {$random(seed)}; //generate random values
	      fastclk_phase = 1 + {$random(seed)}; //generate random values
	      slowclk_phase = 1 + {$random(seed)}; //generate random values
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
   // "GO"
   //#################################

   // start test
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       go <= 1'b0;
     else if(dut_active & ~go)
       go <= 1'b1;

   //#################################
   // STICKY ERROR FLAG
   //#################################

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       fail <= 1'b0;
     else if (dut_error & dut_active)
       fail <= 1'b1;

   //#################################
   // END OF TEST
   //#################################

   always @ (posedge clk)
     if(dut_done)
       begin
	  #500
	    if(fail)
	      $display("[OH] DUT FAILED");
	    else
	      $display("[OH] DUT PASSED");
	  $finish;
       end

   //#################################
   // TIMEOUT
   //#################################
   initial
     begin
	#(TIMEOUT)
	$display("[OH] DUT TIMEOUT");
	$finish;
     end

endmodule
