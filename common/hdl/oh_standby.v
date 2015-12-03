module oh_standby (/*AUTOARG*/
   // Outputs
   clk_out,
   // Inputs
   clk, nreset, wakeup, idle
   );

   parameter PD  = 5; //cycles to stay awake after "wakeup"

   //Basic Interface
   input     clk;     //clock input
   input     nreset;  //sync reset
   input     wakeup;  //wake up now!
   input     idle;    //core is in idle
   output    clk_out; //clock output
      
   //Wire declarations
   reg [PD-1:0]	wakeup_pipe;
   reg          idle_reg;
   wire         state_change;
   wire         clk_en;
   
   always @ (posedge clk )     
     idle_reg <= idle;
   
   assign state_change = (idle ^ idle_reg);
      
   always @ (posedge clk)    
     wakeup_pipe[PD-1:0] <= {wakeup_pipe[PD-2:0],(state_change | wakeup)};

   //block enable signal
   assign  clk_en    =  ~nreset                | //always on during reset
                        wakeup                 | //immediate wakeup
			state_change           | //incoming transition
                        (|wakeup_pipe[PD-1:0]) | //anything in pipe
		        ~idle;                   //core not in idle

   //clock gater (technology specific)
   oh_clockgate clockgate  (.eclk(clk_out),
			    .clk(clk),
			    .en(clk_en),
     			    .se(1'b0)
			    );
    
endmodule // standby

	
