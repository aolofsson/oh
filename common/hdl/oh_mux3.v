//#############################################################################
//# Function: 3:1 one hot mux                                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_mux3 #(parameter DW = 1 ) // width of mux
   (
    input 	    sel2,
    input 	    sel1,
    input 	    sel0,
    input [DW-1:0]  in2,
    input [DW-1:0]  in1,
    input [DW-1:0]  in0, 
    output [DW-1:0] out  //selected data output
    );
  
   assign out[DW-1:0] = ({(DW){sel0}} & in0[DW-1:0] |
			 {(DW){sel1}} & in1[DW-1:0] |
			 {(DW){sel2}} & in2[DW-1:0]);
   			  
endmodule // oh_mux3

