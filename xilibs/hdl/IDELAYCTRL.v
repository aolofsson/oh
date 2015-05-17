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

endmodule // IDELAYCTRL


   


