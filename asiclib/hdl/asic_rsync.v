//#############################################################################
//# Function:  Reset synchronizer                                             #
//             (async assert, sync deassert)                                  #
//# Copyright: OH Project Authors. All rights Reserved.                       #
//# License:   MIT (see LICENSE file in OH repository)                        #
//#############################################################################

module asic_rsync #(parameter PROP = "DEFAULT")  (
   input  clk,
   input  nrst_in,
   output nrst_out
   );

   localparam SYNCPIPE=2;

   reg [SYNCPIPE-1:0] sync_pipe;
   always @ (posedge clk or negedge nrst_in)
     if(!nrst_in)
       sync_pipe[SYNCPIPE-1:0] <= 'b0;
     else
       sync_pipe[SYNCPIPE-1:0] <= {sync_pipe[SYNCPIPE-2:0],1'b1};
   assign nrst_out = sync_pipe[SYNCPIPE-1];

endmodule
