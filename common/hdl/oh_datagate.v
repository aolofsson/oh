module oh_datagate (/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   clk, en, din
   );

   parameter DW = 32;
   parameter PS = 3;
   
   input           clk;
   input           en;
   input [DW-1:0]  din;   
   output [DW-1:0] dout;	  
	 
   reg [PS-1:0]    enable_pipe;   
   wire 	   enable;
   
   always @ (posedge clk)
     enable_pipe[PS-1:0] <= {enable_pipe[PS-2:0],en};
   
   assign enable = {enable_pipe[PS-1:0],en};

   assign dout[DW-1:0] =  {(DW){enable}} & din[DW-1:0];
   
  
endmodule // oh_datagate
