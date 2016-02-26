/* verilator lint_off STMTDLY */
module dv_ctrl(/*AUTOARG*/
   // Outputs
   nreset, clk1, clk2, start,
   // Inputs
   dut_active, stim_done, test_done
   );

   parameter CFG_CLK1_PERIOD = 10;   
   parameter CFG_CLK1_PHASE  = CFG_CLK1_PERIOD/2;
   parameter CFG_CLK2_PERIOD = 100;
   parameter CFG_CLK2_PHASE  = CFG_CLK2_PERIOD/2;
   parameter CFG_TIMEOUT     = 50000;

   output nreset;     // async active low reset
   output clk1;       // main clock
   output clk2;       // secondary clock
   output start;      // start test (level)

   input  dut_active; // reset sequence is done
   input  stim_done;  //stimulus is done  
   input  test_done;  //test is done
   
   //signal declarations
   reg 	     nreset;
   reg 	     start;
   reg 	     clk1=0;
   reg 	     clk2=0;
   reg [6:0] clk1_phase;
   reg [6:0] clk2_phase;   
   integer   seed,r;

   //#################################
   // RANDOM NUMBER GENERATOR
   // (SEED SUPPLIED EXERNALLY)
   //#################################
   initial
     begin
	r=$value$plusargs("SEED=%s", seed);	
	$display("SEED=%d", seed);	
`ifdef CFG_RANDOM
	clk1_phase = {$random(seed)}; //generate random values
	clk2_phase = {$random(seed)}; //generate random values
`else
	clk1_phase = CFG_CLK1_PHASE;	
	clk2_phase = CFG_CLK2_PHASE; 
`endif
	$display("clk1_phase=%d clk2_phase=%d", clk1_phase,clk2_phase);	
     end
   
   //#################################
   //CLK1 GENERATOR
   //#################################
   always
     #(clk1_phase + 1) clk1 = ~clk1; //add one to avoid "DC" state

   //#################################
   //CLK2 GENERATOR
   //#################################
   always
     #(clk2_phase + 1) clk2 = ~clk2;

   //#################################
   //RESET
   //#################################
   initial
     begin	
	#(1)
	nreset   = 'b0;	
	#(clk1_phase * 20 + 100)   //hold reset for 20 clk cycles
	nreset   = 'b1;
     end

   //START TEST
   always @ (posedge clk1 or negedge nreset)
     if(!nreset)
       start = 1'b0;
     else if(dut_active)       
       start = 1'b1;

   //STOP SIMULATION
   always @ (posedge clk1)
     if(stim_done & test_done)       
       #(CFG_TIMEOUT) $finish;	  
   	   
   //WAVEFORM DUMP
   //Better solution?
`ifndef VERILATOR 
   initial
     begin
	$dumpfile("waveform.vcd");
	$dumpvars(0, dv_top);
     end
`endif
   
endmodule // dv_ctrl



