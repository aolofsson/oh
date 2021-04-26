/* verilator lint_off STMTDLY */
module oh_simctrl #( parameter CFG_CLK1_PERIOD = 10,   
		     parameter CFG_CLK2_PERIOD = 20,
		     parameter CFG_TIMEOUT     = 500
		     )
   (
    //control signals to drive
    output nreset, // async active low reset
    output clk1, // main clock
    output clk2, // secondary clock
    output start, // start test (level)
    output vdd, // driving vdd
    output vss, // driving vss
    //input from testbench
    input  dut_active, // dut  reset sequence is done
    input  stim_done, // stimulus is done  
    input  test_done, // test is done
    input  test_diff  // diff between dut and reference
    );
   
   
   localparam CFG_CLK1_PHASE  = CFG_CLK1_PERIOD/2;
   localparam CFG_CLK2_PHASE  = CFG_CLK2_PERIOD/2;
   
   //signal declarations
   reg 	     vdd;
   reg 	     vss;   
   reg 	     nreset;
   reg 	     start;
   reg 	     clk1=0;
   reg 	     clk2=0;
   reg [6:0] clk1_phase;
   reg [6:0] clk2_phase;
   reg 	     test_fail;   
   integer   seed,r;
   reg [1023:0] testname;

   //#################################
   // CONFIGURATION
   //#################################
   initial
     begin
	r=$value$plusargs("TESTNAME=%s", testname[1023:0]);
	$timeformat(-9, 0, " ns", 20);
     end
   
`ifndef VERILATOR 
   initial
     begin
	$dumpfile("waveform.vcd");
	$dumpvars(0, testbench);
     end
`endif
   
   //#################################
   // RANDOM NUMBER GENERATOR
   // (SEED SUPPLIED EXERNALLY)
   //#################################
   initial
     begin
	r=$value$plusargs("SEED=%s", seed);
	//$display("SEED=%d", seed);	
`ifdef CFG_RANDOM
	clk1_phase = 1 + {$random(seed)}; //generate random values
	clk2_phase = 1 + {$random(seed)}; //generate random values
`else
	clk1_phase = CFG_CLK1_PHASE;	
	clk2_phase = CFG_CLK2_PHASE; 
`endif
	//$display("clk1_phase=%d clk2_phase=%d", clk1_phase,clk2_phase);	
     end
   
   //#################################
   //CLK GENERATORS
   //#################################

   always     
     #(clk1_phase) clk1 = ~clk1;

   always
     #(clk2_phase) clk2 = ~clk2;

   //#################################
   //ASYNC
   //#################################

   initial
     begin	
	#(1)
	nreset   = 'b0;
	vdd      = 'b0;
	vss      = 'b0;	
	#(clk1_phase * 10 + 10)   //ramping voltage
	vdd      = 'bx;
	#(clk1_phase * 10 + 10)   //voltage is safe
	vdd      = 'b1;
	#(clk1_phase * 40 + 10)   //hold reset for 20 clk cycles
	nreset   = 'b1;
     end

   //#################################
   //SYNCHRONOUS STIMULUS
   //#################################

   //START TEST
   always @ (posedge clk1 or negedge nreset)
     if(!nreset)
       start <= 1'b0;
     else if(dut_active & ~start)
       begin
	  $display("-------------------");
	  $display("TEST %0s STARTED", testname);
	  start <= 1'b1; 
       end
   
   //STOP SIMULATION ON END
   always @ (posedge clk1 or negedge nreset)
     if(!nreset)
       test_fail <= 1'b0;
     else if(stim_done & test_done)
       begin
	  #500
	  $display("-------------------");
	  if(test_fail | test_diff)
	    $display("TEST %0s FAILED", testname);
	  else
	    $display("TEST %0s PASSED", testname);	  
	  $finish;
       end
     else if (test_diff)
       test_fail <= 1'b1;
   
   //#################################
   // TIMEOUT
   //#################################
   initial
     begin
	#(CFG_TIMEOUT) 
	$display("TEST %0s FAILED ON TIMEOUT",testname);	
	$finish;
     end
   
endmodule // oh_simctrl





