//#############################################################################
//# Function: Clock synchronizer                                              #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_dsync  #(parameter PS   = 2,        // number of sync stages
		   parameter ASIC = `CFG_ASIC // use asic library
		   )
   (
    input  clk, // clock
    input  nreset, // clock
    input  din, // input data
    output dout    // synchronized data
    );
   
   generate
      if(ASIC)	
	begin : g0
	   asic_dsync asic_dsync (.clk(clk),
				  .nreset(nreset),
				  .din(din),
				  .dout(dout));
	end
      else
	begin : g0
	   reg [PS:0]   sync_pipe; 
	   reg 		delay = 0;
	   always @ (posedge clk or negedge nreset)		 
	     if(!nreset)
	       sync_pipe[PS:0] <= 1'b0;
	     else
	       sync_pipe[PS:0] <= {sync_pipe[PS-1:0],din};	      	      
	   // drive randomize delay from testbench
	   assign dout = (delay & sync_pipe[PS]) |  //extra cycle
			 (~delay & sync_pipe[PS-1]); //default
      	end 
   endgenerate
   
endmodule // oh_dsync


