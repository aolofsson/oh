//#############################################################################
//# Function: "ONE HOT" N:1 MUX                                               #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_mux #( parameter DW  = 1, // width of data inputs
		 parameter N   = 2  // number of inputs
		 )
   (
    input [N-1:0]    sel, // select vector
    input [N*DW-1:0] in, // concatenated input {..,in1[DW-1:0],in0[DW-1:0]
    output [DW-1:0]  out  // output
    );
   
   reg [DW-1:0]     out;
   
   integer 	    i;   
   always @*
     begin
	out[DW-1:0] = 'b0;
	for(i=0;i<N;i=i+1)
	  out[DW-1:0] = out[DW-1:0] | ({(DW){sel[i]}} & in[((i+1)*DW-1)-:DW]);
     end

endmodule // oh_mux



