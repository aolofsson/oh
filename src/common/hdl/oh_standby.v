//#############################################################################
//# Purpose: Low power standby state machine                                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_standby #( parameter PD  = 5) //cycles to stay awake after "wakeup" 
   (
    input  clkin, //clock input
    input  nreset, //sync reset
    input  wakeup, //wake up now!
    input  idle, //core is in idle
    output clkout //clock output
    );
      
   //Wire declarations
   reg [PD-1:0]	wakeup_pipe;
   reg          idle_reg;
   wire 	state_change;
   wire 	clk_en;
   
   
   // detect an idle state change (wake up on any)
   always @ (posedge clkin)     
     idle_reg <= idle;   
   assign state_change = (idle ^ idle_reg);
      
   always @ (posedge clkin)    
     wakeup_pipe[PD-1:0] <= {wakeup_pipe[PD-2:0],(state_change | wakeup)};

   //block enable signal
   assign  clk_en    =  ~nreset                | //always on during reset
                        wakeup                 | //immediate wakeup
			state_change           | //incoming transition
                        (|wakeup_pipe[PD-1:0]) | //anything in pipe
		        ~idle;                   //core not in idle

   //clock gater (technology specific)
   oh_clockgate clockgate  (.eclk(clkout),
			    .clk(clkin),
			    .en(clk_en),
			    .nrst(nreset),
     			    .se(1'b0));
    
endmodule // oh_standby


	
