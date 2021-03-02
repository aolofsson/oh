//#############################################################################
//# Function: Latch data when clk=0                                           #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_lat0 #(parameter DW = 1            // data width
		 ) 
   ( input 	     clk, // clk, latch when clk=0
     input [DW-1:0]  in, // input data
     output [DW-1:0] out  // output data (stable/latched when clk=1)
     );


`ifdef CFG_ASIC
   asic_lat0 ilat [DW-1:0] (.clk(clk),
			    .in(in[DW-1:0]),
				    .out(out[DW-1:0]));
`else
   reg [DW-1:0]      out_reg;	   
   always_latch @ (clk or in)
     if (!clk)
       out_reg[DW-1:0] <= in[DW-1:0];
   assign out[DW-1:0] = out_reg[DW-1:0];
`endif

endmodule // oh_lat0


