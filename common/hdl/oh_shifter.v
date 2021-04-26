//#############################################################################
//# Function: Barrel shifter                                                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_shifter #(parameter DW   = 1,   // data width
		    parameter TYPE = "LSL"// LSR, SR, LSL
		    ) 
   (
    input [DW-1:0]  in,   //first operand
    input [DW-1:0]  shift,//shift amount
    output [DW-1:0] out,  // shifted data out
    output 	    zero  //set if all output bits are zero
    );
   
endmodule // oh_shifter




