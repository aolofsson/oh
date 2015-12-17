module oh_add (/*AUTOARG*/
   // Outputs
   sum, cout, zero, neg, overflow,
   // Inputs
   a, b, opt_sub, cin
   );


   //###############################################################
   //# Parameters
   //###############################################################
   parameter DW = 64;
          
   //###############################################################
   //# Interface
   //###############################################################

   //inputs
   input [DW-1:0]  a;         //first operand
   input [DW-1:0]  b;         //second operand
   input 	   opt_sub;   //subtraction option
   input 	   cin;       //carry in

   //outputs
   output [DW-1:0] sum;       //sum
   output 	   cout;      //cary out
   output 	   zero;      //zero flag
   output 	   neg;       //negative flag
   output 	   overflow;  //overflow indication
            
   //###############################################################
   //# BODY
   //###############################################################
   wire [DW-1:0]   b_sub;
   
   assign b_sub[DW-1:0] =  {(DW){opt_sub}} ^ b[DW-1:0];

   assign {cout,sum[DW-1:0]}  = a[DW-1:0]     + 
                                b_sub[DW-1:0] + 
                                opt_sub       +
                                cin;
   
endmodule // oh_add
