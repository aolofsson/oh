//#############################################################################
//# Purpose: Low power standby state machine                                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_standby #(parameter PD = 5,// cycles to stay awake after "wakeup" 
		    parameter N  = 5)// cycles delay of irq_reset after posedge
   (//inputs
    input  clkin, //clock input
    input  nreset,//async active low reset
    input  testenable,//disable standby (static signal)
    input  wakeup, //wake up (level, active high)
    input  idle, //idle indicator
    //outputs
    output resetout,//synchronous one clock reset pulse
    output clkout //clock output
    );

   //Wire declarations
   reg [PD-1:0]	wakeup_pipe;
   wire 	sync_reset;
   wire 	sync_reset_pulse;
   wire 	wakeup_now;
   wire 	clk_en;
   
   //####################################################################
   // -Creating an edge one clock cycle pulse on rising edge of reset
   // -Event can be used to boot a CPU and any other master as an example
   // -Given the clock dependancies, it was deemed safest to put this 
   //  function here
   //####################################################################
   
   // Synchronizing reset to clock to avoid metastability
   oh_dsync #(.PS(2)) oh_dsync (//outputs
				.dout(sync_reset),
				//inputs
				.nreset(nreset),
				.din(nreset),
				.clk(clkin)
				);
   
   // Detecting rising edge of delayed reset
   oh_edge2pulse oh_e2p (//outputs
			 .out	 (sync_reset_pulse),
			 //inputs
			 .clk	 (clkin),
			 .nreset (nreset),
			 .in	 (sync_reset));

   // Delay irq event by N clock cycles
   oh_delay #(.N(N)) oh_delay (//outputs
			       .out	 (resetout),
			       //inputs
			       .in	 (sync_reset_pulse),
			       .clk	 (clkin));
   
   //####################################################################
   // Clock gating circuit for output clock
   // EVent can be used to boot a CPU andcany other master as an example
   //####################################################################

   //Adding reset to wakeup signal
   assign wakeup_now = sync_reset_pulse | wakeup;   

   // Stay awake for PD cycles
   always @ (posedge clkin or negedge nreset)
     if(!nreset)
       wakeup_pipe[PD-1:0] <= 'b0;   
     else
       wakeup_pipe[PD-1:0] <= {wakeup_pipe[PD-2:0], wakeup_now};
   
   // Clock enable
   assign  clk_en    =  wakeup                 | //immediate wakeup
                        (|wakeup_pipe[PD-1:0]) | //anything in pipe
		        ~idle;                   //core not in idle

   // Clock gating cell
   oh_clockgate oh_clockgate  (.eclk(clkout),
			       .clk(clkin),
			       .en(clk_en),
     			       .te(testenable));

endmodule // oh_standby



	
