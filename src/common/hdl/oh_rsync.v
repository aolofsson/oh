//#############################################################################
//# Function: Reset synchronizer (async assert, sync deassert)                #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_rsync #(parameter PS =2)  // number of sync stages
   (
    input  clk,
    input  nrst_in,
    output nrst_out
    );
  
   reg [PS-1:0] sync_pipe;
   
   always @ (posedge clk or negedge nrst_in)		 
     if(!nrst_in)
       sync_pipe[PS-1:0] <= 1'b0;
     else
       sync_pipe[PS-1:0] <= {sync_pipe[PS-2:0],1'b1};	      
   
   assign nrst_out = sync_pipe[PS-1];
   		    	
endmodule // oh_rsync

