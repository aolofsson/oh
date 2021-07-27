//#############################################################################
//# Function: Buffer that propagates "X" if power supply is invalid           #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT  (see LICENSE file in OH! repository)                       #
//#############################################################################

module oh_pwr_buf #( parameter N = 1) // width of data inputs
 (
  input 	 vdd, // supply (set to 1 if valid)
  input 	 vss, // ground (set to 0 if valid)
  input [N-1:0]  in, // input signal
  output [N-1:0] out    // buffered output signal
  );

`ifdef TARGET_SIM
   assign out[N-1:0] = ((vdd===1'b1) && (vss===1'b0)) ? in[N-1:0]:
		       {(N){1'bX}};
`else
   assign out[N-1:0] = in[N-1:0];
`endif


endmodule // oh_pwr_buf
