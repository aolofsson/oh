//#############################################################################
//# Function: Binary multiplier                                               #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_mult
  #(parameter DW   = 32,        // block width
    parameter SYN  = "TRUE",    // synthesizable
    parameter TYPE = "DEFAULT"  // implementation type
    )
   (
    //Inputs
    input [DW-1:0]    a,       // a input (multiplier)
    input [DW-1:0]    b,       // b input (multiplicand)
    input 	      asigned, // a operand is signed
    input 	      bsigned, // b oeprand is signed
    //Outputs
    output [2*DW-1:0] product, // a*b final product
    output [2*DW-1:0] sum,     // a*b partial sum
    output [2*DW-1:0] carry    // a*b partial carry
    );

   generate
      if(SYN=="TRUE")  begin
	 wire a_sext = asigned & a[DW-1];
	 wire b_sext = bsigned & b[DW-1];
	 assign product[2*DW-1:0] = $signed({a_sext,a[DW-1:0]}) *
				    $signed({b_sext,b[DW-1:0]});
      end
      else begin
	 asic_mult #(.TYPE(TYPE),
		     .DW(DW))
	 asic_mult (// Outputs
		    .product	(product[2*DW-1:0]),
		    .sum	(sum[2*DW-1:0]),
		    .carry	(carry[2*DW-1:0]),
		    // Inputs
		    .a		(a[DW-1:0]),
		    .b		(b[DW-1:0]),
		    .asigned	(asigned),
		    .bsigned	(bsigned));

      end
   endgenerate
endmodule
