//#############################################################################
//# Function: Barrel shifter                                                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_shift
  #(parameter DW   = 32,         // Operator width (8,16,32,64,128)
    parameter S    = $clog2(DW), // stages=shift width
    parameter SYN = "TRUE"       // TRUE is synthesizable
    )
   (
    input [DW-1:0]  in,         // data to be shifted
    input 	    arithmetic, // shifts in in[DW-1] instead of 0
    input 	    right,      // shift right (default is left shift)
    input [S-1:0]   shamt,      // shift amount (unsigned)
    output [DW-1:0] out         //shifted output
    );

   generate
      if(SYN=="TRUE")  begin: gbehavioral

	 wire [2*DW-1:0] in_sext;
	 wire [DW-1:0] 	 sr_result;
	 wire [DW-1:0] 	 sl_result;

	 assign shift_in          = arithmetic & in[DW-1];

	 assign in_sext[2*DW-1:0] = {{(DW){shift_in}},in[DW-1:0]};

	 assign sr_result[DW-1:0] = in_sext[2*DW-1:0] >> shamt[S-1:0];

	 assign sl_result[DW-1:0] = in[DW-1:0]        << shamt[S-1:0];

	 assign out[DW-1:0]       = right ? sr_result[DW-1:0] :
				            sl_result[DW-1:0];

      end // block: gbehavioral
      else begin
	 asic_shift #(.TYPE(TYPE),
		      .DW(DW))
	 asic_shift (// Outputs
		     .out	 (out[DW-1:0]),
		     // Inputs
		     .in	 (in[DW-1:0]),
		     .arithmetic (arithmetic),
		     .right      (right),
		     .shamt	 (shamt[S-1:0]));

      end
   endgenerate
endmodule
