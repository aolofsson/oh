//#############################################################################
//# Function: 2:1 one hot mux                                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module asic_dmux2 #(parameter PROP = "DEFAULT")   (
    input  sel1,
    input  sel0,
    input  in1,
    input  in0,
    output out
    );

   assign out = sel0 & in0 |
		sel1 & in1;

endmodule
