//#############################################################################
//# Function: 9:1 one hot mux                                                #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_mux9 #( parameter DW = 1 ) // width of mux
   (
    input 	    sel8,
    input 	    sel7,
    input 	    sel6,
    input 	    sel5,
    input 	    sel4,
    input 	    sel3,
    input 	    sel2,
    input 	    sel1,
    input 	    sel0,
    input [DW-1:0]  in8,
    input [DW-1:0]  in7,
    input [DW-1:0]  in6,
    input [DW-1:0]  in5,
    input [DW-1:0]  in4,
    input [DW-1:0]  in3,
    input [DW-1:0]  in2,
    input [DW-1:0]  in1,
    input [DW-1:0]  in0, 
    output [DW-1:0] out  //selected data output
    );

   assign out[DW-1:0] = ({(DW){sel0}} & in0[DW-1:0] |
			 {(DW){sel1}} & in1[DW-1:0] |
			 {(DW){sel2}} & in2[DW-1:0] |
			 {(DW){sel3}} & in3[DW-1:0] |
			 {(DW){sel4}} & in4[DW-1:0] |
			 {(DW){sel5}} & in5[DW-1:0] |
			 {(DW){sel6}} & in6[DW-1:0] |
			 {(DW){sel7}} & in7[DW-1:0] | 
			 {(DW){sel8}} & in8[DW-1:0]);
      
endmodule // oh_mux9

