//#############################################################################
//# Function: 3 Input Or Gate                                                 #
//# Copyright: OH Project Authors. All rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_or3 #(parameter PROP = "DEFAULT")  (
    input a,
    input b,
    input c,
    output z
   );

   assign z = a | b | c ;

endmodule
