//#############################################################################
//# Function: Barrel shifter                                                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_shift
  #(parameter DW   = 32,        // Operator width (8,16,32,64,128)
    parameter S    = $clog2(DW),// stages=shift width
    parameter TYPE = "SOFT"     // SOFT /
    )
   (
    //Inputs
    input [DW-1:0]  in, // data to be shifted
    input 	    arithmetic,// shifts in in[DW-1] instead of 0
    input 	    rightshift,// shift right (default is left shift)
    input [S-1:0]   shamt, //shift amount (unsigned)
    //Outputs
    output [DW-1:0] out //shifted output
    );

   generate
      if(TYPE=="SOFT")  begin: gbehavioral

	 wire [2*DW-1:0] in_sext;
	 wire [DW-1:0] 	 sr_result;
	 wire [DW-1:0] 	 sl_result;

	 assign shift_in          = arithmetic & in[DW-1];
	 assign in_sext[2*DW-1:0] = {{(DW){shift_in}},in[DW-1:0]};
	 assign sr_result[DW-1:0] = in_sext[2*DW-1:0] >> shamt[S-1:0];
	 assign sl_result[DW-1:0] = in[DW-1:0]        << shamt[S-1:0];

	 assign out[DW-1:0]       = rightshift ? sr_result[DW-1:0] :
				                 sl_result[DW-1:0];

      end
endgenerate

endmodule // oh_shift
