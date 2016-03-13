//#########################################################################
//# Function: A digital debounce circuit
//# Usage: Set the BOUNCE and CLKPERIOD values during instantional to suite
//# your switch and clkperiod.
//#
//########################################################################
module oh_debouncer (/*AUTOARG*/
   // Outputs
   clean_out,
   // Inputs
   clk, nreset, noisy_in
   );

   // parameters (in milliseconds)
   parameter BOUNCE     = 100;                     // bounce time of switch (s)
   parameter CLKPERIOD  = 0.00001;                 // period (10ns=0.0001ms))
   parameter CW         = $clog2(BOUNCE/CLKPERIOD);// counter width needed
   
   // signal interface
   input  clk;         // clock to synchronize to
   input  nreset;      // syncronous active high reset
   input  noisy_in;    // noisy input signal to filter
   output clean_out;   // clean signal to logic
    
   //temp variables
   wire   noisy_synced;
   reg 	  noisy_reg;
   reg 	  clean_out;
   wire   nreset_synced;
   
   
   // synchronize reset
   oh_dsync dsync (.dout (noisy_synced),
		   .clk	 (clk),
		   .din	 (noisy_in));
   
   // synchronize input to clk (always!)
   oh_rsync rsync (.nrst_out (nreset_synced),
		   .clk	     (clk),
		   .nrst_in  (nreset));
   
   // detecting change in state on input
   always @ (posedge clk)     
     noisy_reg <= noisy_synced;

   assign change_detected = noisy_reg ^ noisy_synced;

   // synchronous counter
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
   always @ (posedge clk)
     if(carry)
       clean_out <= noisy_reg;   

endmodule
     
