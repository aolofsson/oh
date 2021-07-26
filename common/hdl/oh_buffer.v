//#############################################################################
//# Function: Buffer                                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_buffer
  #(parameter N    = 1,         // vector width
    parameter SYN  = "TRUE",    // synthesize buffer
    parameter TYPE = "DEFAULT") // buffer type
   (
     input [N-1:0]  in, // input
     output [N-1:0] out // output
     );
   generate
      if(SYN == "TRUE") begin
	 assign out[N-1:0] = in[N-1:0];
      end
      else begin
	 genvar 	     i;
	 for (i=0;i<N;i=i+1) begin
	    asic_buffer #(.TYPE(TYPE))
	    asic_buffer (.out (out[N-1:0]),
			 .in  (in[N-1:0]));
	 end
      end
   endgenerate
endmodule // oh_buffer
