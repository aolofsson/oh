//#############################################################################
//# Function: 4:1 one hot mux                                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_mux4 #(parameter DW = 1 ) // width of mux
   (
    input 	    sel3,
    input 	    sel2,
    input 	    sel1,
    input 	    sel0,
    input [DW-1:0]  in3,
    input [DW-1:0]  in2,
    input [DW-1:0]  in1,
    input [DW-1:0]  in0, 
    output [DW-1:0] out  //selected data output
    );

   assign out[DW-1:0] = ({(DW){sel0}} & in0[DW-1:0] |
			 {(DW){sel1}} & in1[DW-1:0] |
			 {(DW){sel2}} & in2[DW-1:0] |
			 {(DW){sel3}} & in3[DW-1:0]);

`ifdef TARGET_SIM
   wire 	    error;
   assign error = (sel0 | sel1 | sel2 | sel3) &
   		  ~(sel0 ^ sel1 ^ sel2 ^ sel3);

   always @ (posedge error)
     begin
	#1 if(error)
	  $display ("ERROR at in oh_mux4 %m at ",$time);
     end
`endif   			
endmodule // oh_mux4

