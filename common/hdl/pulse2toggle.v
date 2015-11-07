module pulse2toggle(/*AUTOARG*/
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
   input  reset;  //do we need this???


   reg 	  out;
   wire   toggle;
   
   //if input goes high, toggle output
   //note1: input can only be high for one clock cycle
   //note2: be careful with clock gating

   assign toggle = in ? ~out :
		         out;
   

   always @ (posedge clk or posedge reset)
     if(reset)
       out <= 1'b0;
     else
       out <= toggle;
   
endmodule // pulse2toggle

