/*
 #######################################################
 # Synchronizer circuit
 #######################################################
  */
module synchronizer (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   in, clk, reset
   );

   parameter DW = 1;
   
   //Input Side   
   input  [DW-1:0] in;   
   input           clk;
   input 	   reset;
   
   //Output Side
   output [DW-1:0] out;

   //Three stages
   reg [DW-1:0] sync_reg0;
   reg [DW-1:0] out;
     
   //We use two flip-flops for metastability improvement
   always @ (posedge clk or posedge reset)
     if(reset)
       begin
	  sync_reg0[DW-1:0] <= {(DW){1'b0}};
	  out[DW-1:0]       <= {(DW){1'b0}};
	 end
     else
       begin
	  sync_reg0[DW-1:0] <= in[DW-1:0];
	  out[DW-1:0]       <= sync_reg0[DW-1:0];
       end
   

endmodule // synchronizer
