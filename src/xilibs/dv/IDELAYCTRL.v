/*An empty IDELAYCTRL model*/
module IDELAYCTRL (/*AUTOARG*/
   // Outputs
   RDY,
   // Inputs
   REFCLK, RST
   );

   output  RDY;    //goes high when delay has been calibrated
   input   REFCLK; //reference clock for setting tap delay
   input   RST;    //reset pulse for setting 
   
   reg 	    RDY;
   
   always @ (posedge REFCLK or posedge RST)
     if(RST)
       RDY <= 1'b0;
     else
       RDY <= 1'b1; //one clock cycle on REFCLK
   
endmodule // IDELAYCTRL


   


