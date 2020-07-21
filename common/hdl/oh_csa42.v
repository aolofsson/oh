//#############################################################################
//# Function: Carry Save Adder (4:2)                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_csa42 #( parameter DW    = 1 // data width
		   )
   ( input [DW-1:0]  in0, //input
     input [DW-1:0]  in1,//input
     input [DW-1:0]  in2,//input
     input [DW-1:0]  in3,//input
     input 	     cin,//intra stage carry in
     output 	     cout, //intra stage carry out (2x sum)
     output [DW-1:0] s, //sum 
     output [DW-1:0] c //carry (2x sum)
     );

   wire [DW-1:0]     sum_int;
   wire [DW:0] 	     carry_int;
   
   //Edges
   assign cout         = carry_int[DW];
   
   //Full Adders
   oh_csa32 #(.DW(DW))
   fa0 (//inputs
	.in0(in0[DW-1:0]),
	.in1(in1[DW-1:0]),
	.in2(in2[DW-1:0]),
	//outputs
	.c(carry_int[DW:1]),
	.s(sum_int[DW-1:0]));
   
   oh_csa32 #(.DW(DW))
   fa1 (//inputs
	.in0(in3[DW-1:0]),
	.in1(sum_int[DW-1:0]),
	.in2({carry_int[DW-1:1],cin}),
	//outputs
	.c(c[DW-1:0]),
	.s(s[DW-1:0]));

endmodule // oh_csa42



