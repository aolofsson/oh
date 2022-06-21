//#############################################################################
//# Function: Clock synchronizer                                              #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_dsync
  #(parameter SYNCPIPE = 2,        // number of sync stages
    parameter DELAY    = 0,        // random delay
    parameter TARGET   = "DEFAULT" // scell type/size
    )
   (
    input  clk, // clock
    input  nreset, // clock
    input  din, // input data
    output dout    // synchronized data
    );

   generate
      if(TARGET == "DEFAULT")	begin
	 reg [SYNCPIPE:0] sync_pipe;
	 always @ (posedge clk or negedge nreset)
	   if(!nreset)
	     sync_pipe[SYNCPIPE:0] <= 'b0;
	   else
	     sync_pipe[SYNCPIPE:0] <= {sync_pipe[SYNCPIPE-1:0],din};
	 // drive randomize delay from testbench
	 assign dout = (DELAY & sync_pipe[SYNCPIPE]) |  //extra cycle
		       (~DELAY & sync_pipe[SYNCPIPE-1]); //default
      end // block: reg
      else
	begin
	   asic_dsync  #(.TARGET(TARGET),
			 .SYNCPIPE(SYNCPIPE))
	   asic_dsync (.clk(clk),
		       .nreset(nreset),
		       .din(din),
		       .dout(dout));
	end
   endgenerate
endmodule // oh_dsync
