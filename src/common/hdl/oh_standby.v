//#############################################################################
//# Purpose: Low power standby state machine                                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_standby #( parameter PD   = 5,  // cycles to stay awake after "wakeup" 
		     parameter N    = 5) // project name 
   (
    input 	  clkin, //clock input
    input 	  nreset,//async active low reset
    input [N-1:0] wakeup, //wake up event vector
    input 	  idle, //core is in idle
    output 	  clkout //clock output
    );

   //Wire declarations
   reg [PD-1:0]	wakeup_pipe;
   reg          idle_reg;
   wire 	state_change;
   wire 	clk_en;   
   wire [N-1:0] wakeup_pulse;
   wire 	wakeup_now;

   // Wake up on any external event change
   oh_edge2pulse #(.DW(N))
   oh_edge2pulse (.out	  (wakeup_pulse[N-1:0]),
		  .clk	  (clkin),
		  .nreset (nreset),
		  .in	  (wakeup[N-1:0]));
   
   assign wakeup_now = |(wakeup_pulse[N-1:0]);
      
   // Stay away for PD cycles
   always @ (posedge clkin or negedge nreset)
     if(!nreset)
       wakeup_pipe[PD-1:0] <= 'b0;   
     else
       wakeup_pipe[PD-1:0] <= {wakeup_pipe[PD-2:0], wakeup_now};
   
   // Clock enable
   assign  clk_en    =  wakeup_now             | //immediate wakeup
                        (|wakeup_pipe[PD-1:0]) | //anything in pipe
		        ~idle;                   //core not in idle

   // Clock gating cell
   oh_clockgate oh_clockgate  (.eclk(clkout),
		  .clk(clkin),
		  .en(clk_en),
     		  .te(1'b0));
   
endmodule // oh_standby


	
