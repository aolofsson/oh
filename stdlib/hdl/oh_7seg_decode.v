//#############################################################################
//# Function: BCD Seven Segment Decoder                                       #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_7seg_decode
  (
    input [3:0] bcd, // 0-9
    output 	a,   // a segment (1=0ff)
    output 	b,   // b segment
    output 	c,   // c segment
    output 	d,   // d segment
    output 	e,   // e segment
    output 	f,   // f segment
    output 	g    // g segment
    );

   assign a = (bcd[3:0] == 4'h1) | (bcd[3:0] == 4'h4);

   assign b = (bcd[3:0] == 4'h5) | (bcd[3:0] == 4'h6);

   assign c = (bcd[3:0] == 4'h2);

   assign d = (bcd[3:0] == 4'h1) | (bcd[3:0] == 4'h4)|
              (bcd[3:0] == 4'h7) | (bcd[3:0] == 4'h9);

   assign e = (bcd[3:0] == 4'h1) | (bcd[3:0] == 4'h3)|
	      (bcd[3:0] == 4'h4) | (bcd[3:0] == 4'h5)|
	      (bcd[3:0] == 4'h7) | (bcd[3:0] == 4'h9);

   assign f = (bcd[3:0] == 4'h1) | (bcd[3:0] == 4'h2)|
	      (bcd[3:0] == 4'h3) | (bcd[3:0] == 4'h7);


   assign g = (bcd[3:0] == 4'h0) | (bcd[3:0] == 4'h1) |
	      (bcd[3:0] == 4'h7);

endmodule
