module oh_oddr (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, ce, din1, din2
   );
   //#########################################################
   //# INTERFACE
   //#########################################################

   //parameters
   parameter DW            = 32;
   
   //signals
   input           clk;   // clock input
   input           ce;    // clock enable input
   input [DW-1:0]  din1;  // data input1
   input [DW-1:0]  din2;  // data input2
   output [DW-1:0] out;   // ddr output

   //#########################################################
   //# BODY
   //#########################################################

   reg [DW-1:0]    q1;   
   reg [DW-1:0]    q2;
   reg [DW-1:0]    q2_reg;
   
   //Generate different logic based on parameters
   always @ (posedge clk)
     q1[DW-1:0] <= din1[DW-1:0];

   always @ (posedge clk)
     q2[DW-1:0] <= din2[DW-1:0];
  
   always @ (negedge clk)
     q2_reg[DW-1:0] <= q2[DW-1:0];
       
   assign q = clk ? q1[DW-1:0] : q2_reg[DW-1:0];
      
endmodule // oh_oddr


