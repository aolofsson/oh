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
    input 	    clk,    // clock
    input 	    nreset, // clock
    input [DW-1:0]  din,    // input data
    output [DW-1:0] dout    // synchronized data
    );
   
   reg [DW-1:0]     sync_pipe[PS:0]; //extra cycle for DV
   

   // variable length synchronizer pipe
   genvar 	    i;
   generate          
      for(i=0;i<(PS+1);i=i+1)
	if(i==0)
	  always @ (posedge clk or negedge nreset)
	    if(!nreset)
	      sync_pipe[0][DW-1:0] <= 'b0;	     
	    else
	      sync_pipe[0][DW-1:0] <= din[DW-1:0];	     
	else
	  always @ (posedge clk or negedge nreset)
	    if(!nreset)
	      sync_pipe[i][DW-1:0] <= 'b0;	   
	    else
	      sync_pipe[i][DW-1:0] <= sync_pipe[i-1][DW-1:0];	     
   endgenerate
   
`ifdef TARGET_SIM
   // randomize sync delay based on value in per bit delay register
   // delay to be forced from testbench
   reg [DW-1:0]     delay = 0;
   assign dout[DW-1:0] = (delay[DW-1:0]  & sync_pipe[PS][DW-1:0]) |  //extra cycle
			 (~delay[DW-1:0] & sync_pipe[PS-1][DW-1:0]); //default
`else
   assign dout[DW-1:0] = sync_pipe[PS-1][DW-1:0];   
`endif
    
endmodule // oh_dsync


