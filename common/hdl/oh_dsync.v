//#############################################################################
//# Function: Clock synchronizer                                              #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_dsync
  #(parameter PS    = 2,     // number of sync stages
    parameter DELAY = 0,      // random delay
    parameter TYPE  = "soft" // hard=hard macro,soft=synthesizable
    )
   (
    input  clk, // clock
    input  nreset, // clock
    input  din, // input data
    output dout    // synchronized data
    );

   generate
      if(TYPE=="soft")
	begin
	   reg [PS:0] sync_pipe;
	   always @ (posedge clk or negedge nreset)
	     if(!nreset)
	       sync_pipe[PS:0] <= 'b0;
	     else
	       sync_pipe[PS:0] <= {sync_pipe[PS-1:0],din};
	   // drive randomize delay from testbench
	   assign dout = (DELAY & sync_pipe[PS]) |  //extra cycle
			 (~DELAY & sync_pipe[PS-1]); //default
	end // block: reg
      else
	begin
	   asic_dsync asic_dsync (.clk(clk),
				  .nreset(nreset),
				  .din(din),
				  .dout(dout));
	end
   endgenerate
endmodule // oh_dsync
