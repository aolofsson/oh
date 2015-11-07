//A reset signal synchronizer
//Async entry, synchronous exit!
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
   
   reg [PS-1:0]    sync_pipe[DW-1:0];   
   
   genvar 	i;
   integer 	j;
   
   generate    
      for(i=0;i<DW;i=i+1)
	begin
	   always @ (posedge clk or negedge nrst_in[i])
	     if(!nrst_in[i])
	       sync_pipe[i]  <= 'b0;
	     else
	       begin
		  sync_pipe[i][0] =1'b1;		  
		  for(j=1;j<PS;j=j+1)
		    sync_pipe[i][j] = sync_pipe[i][j-1];		  
	       end
	   assign nrst_out[i] = sync_pipe[i][PS-1];
	end      
   endgenerate

endmodule // rsync
