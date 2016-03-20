//#############################################################################
//# Purpose: Clock divider with 2 outputs                                     #
//           Secondary clock must be multiple of first clock                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

module oh_clockdiv(/*AUTOARG*/
   // Outputs
   clkout0, clkrise0, clkfall0, clkout1, clkrise1, clkfall1,
   // Inputs
   clk, nreset, clken, clkdiv, clkphase0, clkphase1
   );

   //parameters
   parameter DW   = 8;          // divider counter width
      
   //inputs
   input          clk;          // main clock
   input          nreset;       // async active low reset
   input          clken;        // clock enable enable
   input [7:0]	  clkdiv;       // [7:0]=period
   input [15:0]	  clkphase0;    // [7:0]=rising,[15:8]=falling
   input [15:0]	  clkphase1;    // [7:0]=rising,[15:8]=falling
   
   //primary clock
   output 	  clkout0;      // primary output clock
   output         clkrise0;     // rising edge match
   output         clkfall0;     // falling edge match
  
   //secondary clock
   output 	  clkout1;      // secondary output clock
   output         clkrise1;     // rising edge match
   output         clkfall1;     // falling edge match 
   
   //################################
   //# BODY
   //################################

   //regs
   reg [DW-1:0]   counter;      // free running counter
   reg 		  clkout0;
   reg 		  clkout1_reg;
   reg 		  clkout1_shift;
   
   //baud counter
   always @ (posedge clk or negedge nreset)
     if (~nreset)
       counter[DW-1:0]   <= 'b0;
     else if(clken)
       if(period_match)
	 counter[DW-1:0] <= 'b0;
       else
	 counter[DW-1:0] <= counter[DW-1:0] + 1'b1;
   
   assign period_match = (counter[DW-1:0]==clkdiv[7:0]);   
   assign clkrise0     = (counter[DW-1:0]==clkphase0[7:0]);   
   assign clkfall0     = (counter[DW-1:0]==clkphase0[15:8]);   
   assign clkrise1     = (counter[DW-1:0]==clkphase1[7:0]);   
   assign clkfall1     = (counter[DW-1:0]==clkphase1[15:8]);   
       
   //clock generators
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       clkout0 <= 1'b0;      
     else if(clkrise0)
       clkout0 <= 1'b1;
     else if(clkfall0)
       clkout0 <= 1'b0;
   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       clkout1_reg <= 1'b0;      
     else if(clkrise1)
       clkout1_reg <= 1'b1;
     else if(clkfall1)
       clkout1_reg <= 1'b0;
   
   // creating shifted clock for divide by 2
   always @ (negedge clk)
     clkout1_shift <= clkout1_reg;
      
   //special case for divide by 2
   assign clkout1 = (clkdiv[7:0]==8'd1) ? clkout1_shift: 
		                          clkout1_reg;
      
endmodule // oh_clockdiv

///////////////////////////////////////////////////////////////////////////////
// The MIT License (MIT)                                                     //
//                                                                           //
// Copyright (c) 2015-2016, Adapteva, Inc.                                   //
//                                                                           //
// Permission is hereby granted, free of charge, to any person obtaining a   //
// copy of this software and associated documentation files (the "Software") //
// to deal in the Software without restriction, including without limitation // 
// the rights to use, copy, modify, merge, publish, distribute, sublicense,  //
// and/or sell copies of the Software, and to permit persons to whom the     //
// Software is furnished to do so, subject to the following conditions:      //
//                                                                           //
// The above copyright notice and this permission notice shall be included   // 
// in all copies or substantial portions of the Software.                    //
//                                                                           //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS   //
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF                //
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.    //
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY      //
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT //
// OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR  //
// THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                //
//                                                                           // 
///////////////////////////////////////////////////////////////////////////////



    
