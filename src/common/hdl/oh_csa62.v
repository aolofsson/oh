//CSA6:2 Compressor
//#############################################################################
//# Function: Carry Save Adder (6:2)                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_csa62  #(parameter DW = 1 // data width
		   )
   ( input [DW-1:0]  in0, //input
     input [DW-1:0]  in1,//input
     input [DW-1:0]  in2,//input
     input [DW-1:0]  in3,//input
     input [DW-1:0]  in4,//input
     input [DW-1:0]  in5,//input
     input [DW-1:0]  cin0,//carry in
     input [DW-1:0]  cin1,//carry in
     input [DW-1:0]  cin2,//carry in
     output [DW-1:0] s, //sum 
     output [DW-1:0] c, //carry
     output [DW-1:0] cout0, //carry out
     output [DW-1:0] cout1, //carry out
     output [DW-1:0] cout2  //carry out
     );
      
   wire   [DW-1:0] s_int0;
   wire [DW-1:0]   s_int1;

   oh_csa32 #(.DW(DW)) csa32_0 (.in0(in0[DW-1:0]),
				.in1(in1[DW-1:0]),
				.in2(in2[DW-1:0]),
				.c(cout0[DW-1:0]),
				.s(s_int0[DW-1:0]));

   oh_csa32 #(.DW(DW)) csa32_1 (.in0(in3[DW-1:0]),
				.in1(in4[DW-1:0]),
				.in2(in5[DW-1:0]),
				.c(cout1[DW-1:0]),
				.s(s_int1[DW-1:0]));

   oh_csa42 #(.DW(DW)) csa42 (.in0(s_int0[DW-1:0]),
			      .in1(s_int1[DW-1:0]),
			      .in2(cin0[DW-1:0]),
			      .in3(cin1[DW-1:0]),
			      .cin(cin2[DW-1:0]),
			      .cout(cout2[DW-1:0]),
			      .c(c[DW-1:0]),
			      .s(s[DW-1:0]));

endmodule // oh_csa62

