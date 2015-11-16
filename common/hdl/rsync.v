/* A synchronization circuit for reset signals
 * Async reset assertion and sync reset deassertion on otput
 */ 
module rsync (/*AUTOARG*/
   // Outputs
   nrst_out,
   // Inputs
   clk, nrst_in
   );

   parameter PS   = 2; //number of sync pipeline stages
   parameter DW   = 1; //number of bits to synchronize
   
   input           clk;
   input [DW-1:0]  nrst_in;
   output [DW-1:0] nrst_out;
   
`ifdef TARGET_SIM
   reg [DW-1:0]    sync_pipe[PS-1:0];
`else
   (* ASYNC_REG = "TRUE"  *) (* DONT_TOUCH =  "TRUE" *) reg [DW-1:0]    sync_pipe[PS-1:0];   
`endif
   
   genvar 	i;
   genvar 	j;   
   generate          
      for(i=0;i<PS;i=i+1)
	if(i==0)
	  begin
	     for(j=0;j<DW;j=j+1)		 
	       begin
		  always @ (posedge clk or negedge nrst_in[j])		 
		    if(!nrst_in[j])
		      sync_pipe[0][j] <= 1'b0;
		    else
		      sync_pipe[0][j] <= 1'b1;	     
	       end
	  end
	else
	  begin
	     for(j=0;j<DW;j=j+1)		 
	       begin
		  always @ (posedge clk or negedge nrst_in[j])		 
		    if(!nrst_in[j])
		      sync_pipe[i][j] <= 1'b0;
		    else
		      sync_pipe[i][j] <=  sync_pipe[i-1][j]; 
	       end
	  end	  	 
   endgenerate
   
   assign nrst_out[DW-1:0] = sync_pipe[PS-1][DW-1:0];
   		    	
endmodule // rsync
