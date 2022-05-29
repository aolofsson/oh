/*WARNING: ONLY SAME EDGE SUPPORTED FOR NOW*/
//D1,D2 sampled on rising edge of C 
module ODDR (/*AUTOARG*/
   // Outputs
   Q,
   // Inputs
   C, CE, D1, D2, R, S
   );

   parameter DDR_CLK_EDGE=0; //clock recovery mode
   parameter INIT=0; //Q init value
   parameter SRTYPE=0;//"SYNC", "ASYNC"
   
   input  C;    // Clock input
   input  CE;   // Clock enable input
   input  D1;   // Data input1
   input  D2;   // Data input2
   input  R;    // Reset (depends on SRTYPE)
   input  S;    // Active high asynchronous pin
   output Q;    // Data Output that connects to the IOB pad

   reg 	  Q1,Q2;
   reg 	  Q2_reg;
   
   //Generate different logic based on parameters

   //Only doing same edge and async reset for now   
   
   always @ (posedge C or posedge R)
     if (R)
       Q1 <= 1'b0;
     else
       Q1 <= D1;

   always @ (posedge C or posedge R)
     if (R)
       Q2 <= 1'b0;
     else
       Q2 <= D2;
  
   always @ (negedge C or posedge R)
     if (R)
       Q2_reg <= 1'b0;
     else
       Q2_reg <= Q2;

       
   assign Q = C ? Q1 : Q2_reg;
      
endmodule // ODDR

