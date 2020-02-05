//#############################################################################
//# Function: Carry Save Adder (3:2)                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_csa32 #(parameter DW   = 1 // data width
		  )
   ( input [DW-1:0]  in0, //input
     input [DW-1:0]  in1,//input
     input [DW-1:0]  in2,//input
     output [DW-1:0] s, //sum 
     output [DW-1:0] c   //carry
     );

`ifdef CFG_ASIC
   asic_csa32 i_csa32[DW-1:0] (.s(s[DW-1:0]),
			       .c(c[DW-1:0]),
			       .in2(in2[DW-1:0]),
			       .in1(in1[DW-1:0]),
			       .in0(in0[DW-1:0]));
`else
   assign s[DW-1:0] = in0[DW-1:0] ^ in1[DW-1:0] ^ in2[DW-1:0];
   assign c[DW-1:0] = (in0[DW-1:0] & in1[DW-1:0]) | 
		      (in1[DW-1:0] & in2[DW-1:0]) | 
		      (in2[DW-1:0] & in0[DW-1:0] );
`endif // !`ifdef CFG_ASIC
   
endmodule // oh_csa32


