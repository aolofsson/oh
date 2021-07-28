//#############################################################################
//# Function: 3:1 one hot mux                                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module asic_dmux3 #(parameter PROP = "DEFAULT")   (
    input  sel2,
    input  sel1,
    input  sel0,
    input  in2,
    input  in1,
    input  in0,
    output out
    );

   assign out = sel0 & in0 |
		sel1 & in1 |
		sel2 & in2;

endmodule
