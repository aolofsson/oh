//#############################################################################
//# Function: Delay element                                                   #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_delay  #(parameter DW   = 1, // width of data
		   parameter DELAY= 0  // delay
		   )   
   (
    input [DW-1:0]  in, // input 
    output [DW-1:0] out // output
    );

`ifdef CFG_ASIC
   asic_delay i_delay[DW-1:0] (.in(in[DW-1:0]),
			       .out(out[DW-1:0]));
`else
   assign out[DW-1:0] = in [DW-1:0];
`endif
     
endmodule // oh_delay



