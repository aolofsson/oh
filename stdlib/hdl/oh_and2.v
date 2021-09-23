//#############################################################################
//# Function: 2 Input And Gate                                                #
//#                                                                           #
//# Copyright: OH Project Authors. All rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module oh_and2  #(parameter N  = 1,        // block width
		  parameter SYN  = "TRUE",    // synthesizable
		  parameter TYPE = "DEFAULT"  // implementation type
		  )
   (
    input [N-1:0]  a,
    input [N-1:0]  b,
    output [N-1:0] z
    );

   generate
      if(SYN == "TRUE")  begin
	 assign z = a & b;
      end
      else begin

	 oh_and2 #(.TYPE(TYPE))
	 oh_and2 (/*AUTOINST*/
		  // Outputs
		  .z			(z[N-1:0]),
		  // Inputs
		  .a			(a[N-1:0]),
		  .b			(b[N-1:0]));
      end
   endgenerate
endmodule
