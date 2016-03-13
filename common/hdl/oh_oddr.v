//##################################################################
//# ***DUAL DATA RATE OUTPUT***
//#
//# * Equivalent to "SAME_EDGE" for xilinx
//# * din1/din2 presented together on rising edge of clk
//# * din1 follows rising edge
//# * din2 follows falling edge
//##################################################################

module oh_oddr (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, ce, din1, din2
   );
  
   //parameters
   parameter DW            = 32;
   
   //signals
   input           clk;   // clock input
   input           ce;    // clock enable input
   input [DW-1:0]  din1;  // data input1
   input [DW-1:0]  din2;  // data input2
   output [DW-1:0] out;   // ddr output

   //regs("sl"=stable low, "sh"=stable high)
   reg [DW-1:0]    q1_sl;   
   reg [DW-1:0]    q2_sl;
   reg [DW-1:0]    q2_sh;
      
   //Generate different logic based on parameters
   always @ (posedge clk)
     if (ce)
       begin
	  q1_sl[DW-1:0] <= din1[DW-1:0];
	  q2_sl[DW-1:0] <= din2[DW-1:0];
       end
   
   always @ (negedge clk)
     q2_sh[DW-1:0] <= q2_sl[DW-1:0];
       
   assign out[DW-1:0] = clk ? q1_sl[DW-1:0] : 
	                      q2_sh[DW-1:0];
      
endmodule // oh_oddr


