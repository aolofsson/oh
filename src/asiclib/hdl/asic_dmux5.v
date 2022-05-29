//#############################################################################
//# Function: 5:1 one hot mux                                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module asic_dmux5 #(parameter PROP = "DEFAULT")   (
    input  sel4,
    input  sel3,
    input  sel2,
    input  sel1,
    input  sel0,
    input  in4,
    input  in3,
    input  in2,
    input  in1,
    input  in0,
    output out
    );

   assign out = sel0 & in0 |
		sel1 & in1 |
		sel2 & in2 |
		sel3 & in3 |
		sel4 & in4;

endmodule
