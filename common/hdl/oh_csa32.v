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
   genvar 	     i;
   for (i=0;i<DW;i=i+1)
     begin
	asic_csa32 asic_csa32  (.s(s[i]),
				.c(c[i]),
				.in2(in2[i]),
				.in1(in1[i]),
				.in0(in0[i]));
     end    	 
`else
   assign s[DW-1:0] = in0[DW-1:0] ^ in1[DW-1:0] ^ in2[DW-1:0];
   assign c[DW-1:0] = (in0[DW-1:0] & in1[DW-1:0]) | 
		      (in1[DW-1:0] & in2[DW-1:0]) | 
		      (in2[DW-1:0] & in0[DW-1:0] );
`endif // !`ifdef CFG_ASIC
   
endmodule // oh_csa32


