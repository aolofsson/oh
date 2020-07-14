module oh_simchecker #(parameter DW = 32 // Datapath width
		       )
  (
   //Inputs 
   input 	  clk,
   input 	  nreset,
   input [DW-1:0] result, // result to check
   input [DW-1:0] reference, // reference result
   output reg 	  fail //fail indicator
   );
   
   always @ (negedge clk or negedge nreset)
     if(~nreset)
       fail <= 1'b0;   
     else  if(result!==reference)
       begin
	  fail <= 1'b1;	  
`ifdef CFG_SIM 
	  $display("ERROR(%0t): result=%b reference=%b", $time, result, reference);
`endif
       end	 
endmodule // oh_simchecker

