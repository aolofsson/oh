//#############################################################################
//# Function: Binary adder                                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_add
  #(parameter DW   = 32,        // block width
    parameter SYN  = "TRUE",    // synthesizable
    parameter TYPE = "DEFAULT"  // implementation type
    )
   (//inputs
    input [DW-1:0]  a, // first operand
    input [DW-1:0]  b, // second operand
    input [DW-1:0]  k, // carrry kill signal (active high)
    input 	    cin,// carry in
    //outputs
    output [DW-1:0] sum,// sum
    output [DW-1:0] carry,// complete carry out vector
    output 	    cout// carry out from msb
    );

   generate
      if(SYN=="TRUE")  begin
	 assign {cout,sum[DW-1:0]} = a[DW-1:0] + b[DW-1:0] + cin;
      end
      else begin
	 asic_add #(.TYPE(TYPE))
	 asic_add (// Outputs
		   .sum		(sum[DW-1:0]),
		   .carry	(carry[DW-1:0]),
		   .cout	(cout),
		   // Inputs
		   .a		(a[DW-1:0]),
		   .b		(b[DW-1:0]),
		   .k		(k[DW-1:0]),
		   .cin		(cin));

      end
   endgenerate
endmodule
