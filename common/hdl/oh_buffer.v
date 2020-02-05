//#############################################################################
//# Function: Buffer                                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_buffer #(parameter N    = 1,  // number of inputs
		   parameter SIZE = 1)  // size of buffer
   ( input [N-1:0] in, // input
     output [N-1:0] out // output
    );

`ifdef CFG_ASIC
   asic_buf #(.SIZE(SIZE)) ibuf [N-1:0] (.in(in[N-1:0]),
					 .out(out[N-1:0]));
`else
   assign out[N-1:0] = in[N-1:0];
`endif

endmodule // oh_buffer



