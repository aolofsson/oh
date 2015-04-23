/*Differential output buffer primitive
 *
 * 
 */

module OBUFDS (/*AUTOARG*/
   // Outputs
   O, OB,
   // Inputs
   I
   );

    parameter CAPACITANCE = "DONT_CARE";
    parameter IOSTANDARD = "DEFAULT";
    parameter SLEW = "SLOW";
    
   input  I;    
   output O, OB;


   assign O  = I;
   assign OB = ~I;

endmodule // OBUFDS

