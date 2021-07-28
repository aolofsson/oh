//#############################################################################
//# Function: Dual data rate output buffer                                    #
//# Copyright: OH Project Authors. All rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_oddr #(parameter PROP = "DEFAULT")  (
   input  clk, // clock input
   input  in0, // data for clk=0
   input  in1, // data for clk=1
   output out  // dual data rate output
   );

   //Making in1 stable for clk=1
   reg 	  in1_sh;
   always @ (clk or in1)
     if(~clk)
       in1_sh <= in1;

   //Using clock as data selctor
   assign out = clk ? in1_sh : in0;

endmodule
