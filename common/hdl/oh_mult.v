//#############################################################################
//# Function: Binary multiplier                                               #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_mult
  #(parameter N    = 32,        // block width
    parameter SYN  = "TRUE",    // synthesizable
    parameter TYPE = "DEFAULT"  // implementation type
    )
   (
    //Inputs
    input [N-1:0]    a,       // a input (multiplier)
    input [N-1:0]    b,       // b input (multiplicand)
    input 	      asigned, // a operand is signed
    input 	      bsigned, // b oeprand is signed
    //Outputs
    output [2*N-1:0] product, // a*b final product
    output [2*N-1:0] sum,     // a*b partial sum
    output [2*N-1:0] carry    // a*b partial carry
    );

   generate
      if(SYN=="TRUE")  begin
	 wire a_sext = asigned & a[N-1];
	 wire b_sext = bsigned & b[N-1];
	 assign product[2*N-1:0] = $signed({a_sext,a[N-1:0]}) *
				    $signed({b_sext,b[N-1:0]});
      end
      else begin
	 asic_mult #(.TYPE(TYPE),
		     .N(N))
	 asic_mult (// Outputs
		    .product	(product[2*N-1:0]),
		    .sum	(sum[2*N-1:0]),
		    .carry	(carry[2*N-1:0]),
		    // Inputs
		    .a		(a[N-1:0]),
		    .b		(b[N-1:0]),
		    .asigned	(asigned),
		    .bsigned	(bsigned));

      end
   endgenerate
endmodule
