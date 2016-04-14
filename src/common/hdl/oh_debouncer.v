//#############################################################################
//# Function: A digital debouncer circuit                                     #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_debouncer #( parameter BOUNCE     = 100,    // bounce time (s)
		       parameter CLKPERIOD  = 0.00001 // period (10ns=0.0001ms)
		       )
   (
    input  clk, // clock to synchronize to
    input  nreset, // syncronous active high reset
    input  noisy_in, // noisy input signal to filter
    output clean_out // clean signal to logic
    );
   
   //################################
   //# wires/regs/ params
   //################################     
   parameter integer CW  = $clog2(BOUNCE/CLKPERIOD);// counter width needed
     
   //regs
   reg 	  noisy_reg;
   reg 	  clean_out;
   
   // synchronize incoming signal
   oh_dsync dsync (.dout   (noisy_synced),
		   .clk	   (clk),
		   .nreset (nreset),
		   .din	   (noisy_in));
   
   // synchronize reset to clk
   oh_rsync rsync (.nrst_out (nreset_synced),
		   .clk	     (clk),
		   .nrst_in  (nreset));
   
   // detecting change in state on input
   always @ (posedge clk or negedge nreset)     
     if(!nreset)
       noisy_reg <= 1'b0;   
     else
       noisy_reg <= noisy_synced;

   assign change_detected = noisy_reg ^ noisy_synced;

   // synchronous counter "filter"
   oh_counter #(.DW(CW))  
   oh_counter (// Outputs
	       .count	  (),
	       .carry	  (carry),
	       .zero	  (),
	       // Inputs
	       .clk	  (clk),
	       .in	  (1'b1),
	       .en	  (~carry),  //done if you reach carry
	       .load  	  (change_detected | ~nreset_synced),
	       .load_data ({(CW){1'b0}})
	       );
   
   // sample noisy signal safely
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       clean_out <= 'b0;   
     else if(carry)
       clean_out <= noisy_reg;   

endmodule // oh_debouncer

     
