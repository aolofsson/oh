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

   localparam ASIC = `CFG_ASIC;

   generate
      if(ASIC)
	 begin : asic
	    asic_buf #(.SIZE(SIZE)) ibuf [N-1:0] (.in(in[N-1:0]),
						  .out(out[N-1:0]));
	 end
      else
	begin : generic
	   assign out[N-1:0] = in[N-1:0];	   
	end
   endgenerate   
endmodule // oh_buffer



