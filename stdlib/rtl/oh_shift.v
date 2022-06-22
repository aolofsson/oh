//#############################################################################
//# Function: Barrel shifter                                                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_shift
  #(parameter N   = 32,         // Operator width (8,16,32,64,128)
    parameter S    = $clog2(N), // stages=shift width
    parameter SYN = "TRUE"       // TRUE is synthesizable
    )
   (
    input [N-1:0]  in,         // data to be shifted
    input 	    arithmetic, // shifts in in[N-1] instead of 0
    input 	    right,      // shift right (default is left shift)
    input [S-1:0]   shamt,      // shift amount (unsigned)
    output [N-1:0] out         //shifted output
    );

   generate
      if(SYN=="TRUE")  begin: gbehavioral

	 wire [2*N-1:0] in_sext;
	 wire [N-1:0] 	 sr_result;
	 wire [N-1:0] 	 sl_result;

	 assign shift_in          = arithmetic & in[N-1];

	 assign in_sext[2*N-1:0] = {{(N){shift_in}},in[N-1:0]};

	 assign sr_result[N-1:0] = in_sext[2*N-1:0] >> shamt[S-1:0];

	 assign sl_result[N-1:0] = in[N-1:0]        << shamt[S-1:0];

	 assign out[N-1:0]       = right ? sr_result[N-1:0] :
				            sl_result[N-1:0];

      end // block: gbehavioral
      else begin
	 asic_shift #(.TYPE(TYPE),
		      .N(N))
	 asic_shift (// Outputs
		     .out	 (out[N-1:0]),
		     // Inputs
		     .in	 (in[N-1:0]),
		     .arithmetic (arithmetic),
		     .right      (right),
		     .shamt	 (shamt[S-1:0]));

      end
   endgenerate
endmodule
