//#############################################################################
//# Function: Clock synchronizer                                              #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_dsync  #(parameter DW = 1, // width of data
		   parameter PS = 3  // mnumber of sync stages
		   )
   (
    input 	    clk, // clock
    input [DW-1:0]  din, // input data
    output [DW-1:0] dout  // synchronized data
    );
   
   reg [DW-1:0]     sync_pipe[PS-1:0];
   
   genvar 	   i;
   generate          
      for(i=0;i<PS;i=i+1)
	if(i==0)
	  always @ (posedge clk)
	    sync_pipe[0][DW-1:0] <= din[DW-1:0];	     
	else
	  always @ (posedge clk )
	    sync_pipe[i][DW-1:0] <= sync_pipe[i-1][DW-1:0];	     
   endgenerate
   
   assign dout[DW-1:0] = sync_pipe[PS-1][DW-1:0];
    
endmodule // oh_dsync


