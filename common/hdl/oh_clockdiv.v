//#############################################################################
//# Purpose: Simple clock divider (modulo 2)                                  #
//#          clkdiv: 0-->divide by 1                                          #
//#          clkdiv: 1-->divide by 2                                          #
//#          clkdiv: 2-->divide by 4                                          #
//#          clkdiv: 2-->divide by 8  etc..                                   #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

module oh_clockdiv(/*AUTOARG*/
   // Outputs
   period_match, phase_match, clkout,
   // Inputs
   clk, nreset, en, clkdiv
   );

   parameter DW   = 8;          // divider counter width
   parameter CW   = $clog2(DW); // config width
      
   input          clk;          // main clock
   input          nreset;       // async active low reset
   input          en;           // counter enable
   input [CW-1:0] clkdiv;       // counter width
   
   output         period_match; // period match
   output         phase_match;  // phase match
   output 	  clkout;       // output clock
   
   reg [DW-1:0]   counter;      //free running counter!
   reg 		  clkout;
   
   //baud counter
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       counter[7:0] <= 'b0;
     else if(en)
       if(period_match)
	 counter[7:0] <= 'b0;
       else
	 counter[7:0] <= counter[7:0] + 1'b1;

   assign period_match=(counter[DW-1:0]==((1<<clkdiv[CW-1:0])-1'b1));
   assign phase_match =(counter[DW-1:0]==((1<<(clkdiv[CW-1:0])>> 1)-1'b1));
      
   //clock generator
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       clkout <= 1'b0;      
     else if(phase_match)
       clkout <= 1'b1;
     else if(period_match)
       clkout <= 1'b0;

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



    
