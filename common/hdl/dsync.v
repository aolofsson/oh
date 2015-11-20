/* A control signal synchronizer with "PS" number of stages 
 */

module dsync (/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   clk, din
   );

   parameter PS   = 2; //number of sync pipeline stages
   parameter DW   = 1; //number of bits to synchronize
   
   input           clk;
   input [DW-1:0]  din;
   output [DW-1:0] dout;
   
 
`ifdef TARGET_SIM
   reg [DW-1:0]    sync_pipe[PS-1:0];
`else
   (* ASYNC_REG = "TRUE"  *) (* DONT_TOUCH =  "TRUE" *) reg [DW-1:0]    sync_pipe[PS-1:0];   
`endif
   
   genvar 	   i;
   generate          
      for(i=0;i<PS;i=i+1)
	if(i==0)
	  begin
	     always @ (posedge clk)
	       sync_pipe[0][DW-1:0] <= din[DW-1:0];	     
	  end
	else
	  begin
	  always @ (posedge clk )
	    sync_pipe[i][DW-1:0] <= sync_pipe[i-1][DW-1:0];	     
	  end // else: !if(i==0)      
   endgenerate
   
   assign dout[DW-1:0] = sync_pipe[PS-1][DW-1:0];
 
   
endmodule // dsync

