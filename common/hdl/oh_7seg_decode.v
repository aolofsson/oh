//#############################################################################
//# Function: BCD Seven Segment Decoderh                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_7seg_decode ( input [3:0] bcd,  //0-9 
			output a, //a segment (1=0ff)
			output b, //b segment
			output c, //c segment
			output d, //d segment
			output e, //e segment
			output f, //f segment
			output g    //g segment
			);

   reg 	a,b,c,d,e,f,g;
   
   always @ (*)
     case(bcd[3:0])
       4'h0  : {a,b,c,d,e,f,g} = 7'b0000001;
       4'h1  : {a,b,c,d,e,f,g} = 7'b1001111;
       4'h2  : {a,b,c,d,e,f,g} = 7'b0010010;
       4'h3  : {a,b,c,d,e,f,g} = 7'b0000110;
       4'h4  : {a,b,c,d,e,f,g} = 7'b1001100;
       4'h5  : {a,b,c,d,e,f,g} = 7'b0100100;
       4'h6  : {a,b,c,d,e,f,g} = 7'b0100000;
       4'h7  : {a,b,c,d,e,f,g} = 7'b0001111;
       4'h8  : {a,b,c,d,e,f,g} = 7'b0000000;
       4'h9  : {a,b,c,d,e,f,g} = 7'b0001100;
       default : {a,b,c,d,e,f,g} = 7'b1111111;
     endcase // case (in[3:0])
   
endmodule
   



