//#############################################################################
//# Function: A digital debouncer circuit                                     #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_debouncer
  #( parameter BOUNCE    = 100, // bounce time (s)
     parameter FREQUENCY = 1000000 // clock frequency (1Mhz)
     )
   (
    input  clk, // clock to synchronize to
    input  nreset, // syncronous active high reset
    input  noisy_in, // noisy input signal to filter
    output clean_out // clean signal to logic
    );

   parameter integer CW  = $clog2(BOUNCE*FREQUENCY);

   //regs
   reg 	  noisy_reg;
   reg 	  clean_reg;

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
	       .count	   (),
	       .wraparound (wraparound),
	       // Inputs
	       .clk	   (clk),
	       .in	   (1'b1),
	       .dir        (1'b0),//increment
	       .en	   (1'b1),
	       .autowrap   (1'b0),
	       .load  	   (change_detected | ~nreset_synced),
	       .load_data  ({(CW){1'b0}})
	       );

   // sample noisy signal safely
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       clean_reg <= 'b0;
     else if(wraparound)
       clean_reg <= noisy_reg;

   assign clean_out = clean_reg;

endmodule // oh_debouncer
