//Variable pipeline depth syncrhonizer
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
   reg [PS-1:0]    sync_pipe[DW-1:0];
`else   
   (* ASYNC_REG = "TRUE"  *) (* DONT_TOUCH =  "TRUE" *) reg [PS-1:0]    sync_pipe[DW-1:0];   
`endif
   
   
   genvar 	i;
   integer 	j;

   generate
      for(i=0;i<DW;i=i+1)
	begin
	   always @ (posedge clk)
	     begin
		sync_pipe[i][0] = din;		  
		for(j=1;j<PS;j=j+1)
		  sync_pipe[i][j] = sync_pipe[i][j-1];		  
	     end
	   assign dout[i] = sync_pipe[i][PS-1];
	end 
   endgenerate
   
endmodule // dsync

