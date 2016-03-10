//#############################################################################
//# Function: Converts a rising edge to a single cycle pulse                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

module oh_rise2pulse(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, in
   );

   //########################################
   //# INTERFACE
   //########################################

   parameter DW  = 1;       // width of data inputs

   input           clk;     // clock  
   input [DW-1:0]  in;      // edge input
   output [DW-1:0] out;     // one cycle pulse

   //########################################
   //# BODY
   //########################################
   reg [DW-1:0]    in_reg;
   
   always @ (posedge clk)
     in_reg[DW-1:0]  <= in[DW-1:0] ;
   
   assign out[DW-1:0]  = in[DW-1:0] & ~in_reg[DW-1:0] ;
   
endmodule // oh_edge2pulse

//////////////////////////////////////////////////////////////////////////////
// The MIT License (MIT)                                                    //
//                                                                          //
// Copyright (c) 2015-2016, Adapteva, Inc.                                  //
//                                                                          //
// Permission is hereby granted, free of charge, to any person obtaining a  //
// copy of this software and associated documentation files (the "Software")//
// to deal in the Software without restriction, including without limitation// 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, //
// and/or sell copies of the Software, and to permit persons to whom the    //
// Software is furnished to do so, subject to the following conditions:     //
//                                                                          //
// The above copyright notice and this permission notice shall be included  // 
// in all copies or substantial portions of the Software.                   //
//                                                                          //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS  //
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF               //
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.   //
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY     //
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT//
// OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR //
// THE USE OR OTHER DEALINGS IN THE SOFTWARE.                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
