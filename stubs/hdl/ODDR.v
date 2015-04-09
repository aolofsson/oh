module ODDR (/*AUTOARG*/
   // Outputs
   Q,
   // Inputs
   C, CE, D1, D2, R, S
   );

   parameter DDR_CLK_EDGE=0;
   parameter INIT=0;
   parameter SRTYPE=0;
   
   input C;
   input CE;
   input D1;
   input D2;
   input R;
   input S;
   output Q;

   assign Q=1'b0;
   
endmodule // ODDR

