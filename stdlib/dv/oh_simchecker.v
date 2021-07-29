module oh_simchecker #(parameter DW = 32 // Datapath width
		       )
  (
   //Inputs 
   input 	  clk,
   input 	  nreset,
   input [DW-1:0] result, // result to check
   input [DW-1:0] reference, // reference result
   output reg 	  diff //fail indicator
   );
   
   always @ (negedge clk or negedge nreset)
     if(~nreset)
       diff <= 1'b0;   
     else  if(result!==reference)
       begin
	  diff <= 1'b1;	  
`ifdef CFG_SIM 
	  $display("ERROR(%0t): result= %d(%h) reference= %d(%h)", $time, result,result, reference, reference);
`endif
       end
     else
       diff <= 1'b0;	  
   
endmodule // oh_simchecker

