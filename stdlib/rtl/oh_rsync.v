//#############################################################################
//# Function: Reset synchronizer (async assert, sync deassert)                #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_rsync
  #(parameter SYNCPIPE = 2,        // number of sync stages
    parameter TARGET   = "DEFAULT" // scell type/size
    )
   (
    input  clk,
    input  nrst_in,
    output nrst_out
    );

   generate
      if(TARGET == "DEFAULT")
	begin
	   reg [SYNCPIPE-1:0] sync_pipe;
	   always @ (posedge clk or negedge nrst_in)
	     if(!nrst_in)
	       sync_pipe[SYNCPIPE-1:0] <= 'b0;
	     else
	       sync_pipe[SYNCPIPE-1:0] <= {sync_pipe[SYNCPIPE-2:0],1'b1};
	   assign nrst_out = sync_pipe[SYNCPIPE-1];
	end
      else
	begin
	   asic_rsync #(.TARGET(TARGET),
			.SYNCPIPE(SYNCPIPE))
	   asic_rsync (.clk(clk),
		       .nrst_in(nrst_in),
		       .nrst_out(nrst_out));
	end
   endgenerate
endmodule // oh_rsync
