//#############################################################################
//# Function: Achive high latch                                               #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_lat1 #(parameter DW    = 1         //data width
		 )
   ( input 	     clk, // clk, latch when clk=1
     input [DW-1:0]  in,  // input data
     output [DW-1:0] out  // output data (stable/latched when clk=0)
     );

   localparam ASIC = `CFG_ASIC;  // use ASIC lib

   generate
      if(ASIC)
	begin : g0
	   asic_lat1 i_lat [DW-1:0] (.clk(clk),
				     .in(in[DW-1:0]),
				     .out(out[DW-1:0]));
	end
      else
	begin : g0
	   reg [DW-1:0] out_reg;	   
	   always @ (clk or in)
	     if (clk)
	       out_reg[DW-1:0] <= in[DW-1:0];
	   assign out[DW-1:0] = out_reg[DW-1:0];	   
	end
   endgenerate
   
endmodule // oh_lat1
