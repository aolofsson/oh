//#############################################################################
//# Function: Data Syncrhonizer                                               #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module asic_dsync #(parameter PROP = "DEFAULT")   (
    input  clk,    // clock
    input  nreset, // async active low reset
    input  in,     // input data
    output out     // synchronized data
    );

   localparam SYNCPIPE=2;

   reg [SYNCPIPE-1:0] sync_pipe;
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       sync_pipe[SYNCPIPE-1:0] <= 'b0;
     else
       sync_pipe[SYNCPIPE-1:0] <= {sync_pipe[SYNCPIPE-1:0],in};

   assign out = sync_pipe[SYNCPIPE-1];

endmodule
