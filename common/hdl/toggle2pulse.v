
module toggle2pulse(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, in, reset
   );
   
   //clocks
   input  clk; 
   
   input  in;   
   output out;

   //reset
   input  reset;
   reg 	  out_reg;
         
   always @ (posedge clk)
     if(reset)
       out_reg <= 1'b0;
     else
       out_reg <= in;
      
   assign out = in ^ out_reg;

endmodule 
