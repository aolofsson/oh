//#############################################################################
//# Function: Binary adder                                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_add
  #(parameter N    = 32,        // block width
    parameter SYN  = "TRUE",    // synthesizable
    parameter TYPE = "DEFAULT"  // implementation type
    )
   (//inputs
    input [N-1:0]  a, // first operand
    input [N-1:0]  b, // second operand
    input [N-1:0]  k, // carrry kill signal (active high)
    input 	   cin,// carry in
    //outputs
    output [N-1:0] sum,// sum
    output [N-1:0] carry,// complete carry out vector
    output 	   cout// carry out from msb
    );

   generate
      if(SYN == "TRUE")  begin
	 assign {cout,sum[N-1:0]} = a[N-1:0] + b[N-1:0] + cin;
	 //TODO: FIX
	 assign carry = 'b0;
      end
      else begin
	 asic_add #(.TYPE(TYPE),
		    .N(N))
	 asic_add (// Outputs
		   .sum		(sum[N-1:0]),
		   .carry	(carry[N-1:0]),
		   .cout	(cout),
		   // Inputs
		   .a		(a[N-1:0]),
		   .b		(b[N-1:0]),
		   .k		(k[N-1:0]),
		   .cin		(cin));

      end
   endgenerate
endmodule
