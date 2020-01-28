//#############################################################################
//# Function: Bidirectional port with output-enable                           #
//#############################################################################
//# Author:   Ola Jeppsson                                                    #
//# SPDX-License-Identifier:     MIT                                          #
//#############################################################################

module oh_tristate #(parameter N = 1) // width of port
   (
    inout  [N-1:0]  io,   // bidirectional port
    input  [N-1:0]  oe,   // output enable (1 = output, 0 = input)
    output [N-1:0]  in,   // port as input
    input  [N-1:0]  out   // port as output
    );

    assign in[N-1:0] = io[N-1:0];

    genvar i;
    generate
      for (i = 0; i < N; i = i + 1)
      begin : gen_oh_tristate
	assign io[i] = oe[i] ? out[i] : 1'bZ;
      end
    endgenerate

endmodule // oh_tristate
