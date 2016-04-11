//#############################################################################
//# Function: Latch data when clk=1                                           #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_lat1 #(parameter DW = 1) // data width
   ( input 	     clk, // clk, latch when clk=1
     input [DW-1:0]  in,  // input data
     output [DW-1:0] out  // output data (stable/latched when clk=0)
     );

   reg [DW-1:0]      out;
   always @ (clk or in)
     if (clk)
       out[DW-1:0] <= in[DW-1:0];

endmodule // oh_lat1


