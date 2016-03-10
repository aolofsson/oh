//#############################################################################
//# Purpose: Parallel to Serial Converter                                     #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

module oh_par2ser (/*AUTOARG*/
   // Outputs
   dout, access_out, wait_out,
   // Inputs
   clk, nreset, din, load, shift, datasize, lsbfirst, fill, wait_in
   );

   //###########################
   //# INTERFACE
   //###########################

   // parameters
   parameter  PW   = 64;             // parallel packet width
   parameter  SW   = 1;              // serial packet width
   localparam CW   = $clog2(PW/SW);  // serialization factor (for counter)
      
   // reset, clk
   input           clk;       // sampling clock   
   input 	   nreset;    // async active low reset
   
   // data interface
   input [PW-1:0]  din;       // parallel data
   output [SW-1:0] dout;      // serial output data
   output 	   access_out;// output data valid    
   
   // control interface
   input 	   load;      // load parallel data (priority)   
   input 	   shift;     // shift data
   input [CW-1:0]  datasize;  // size of data to to shift 
   input 	   lsbfirst;  // lsb first order
   input 	   fill;      // fill bit  
   input 	   wait_in;   // wait input  
   output 	   wait_out;  // wait output (wait in | serial wait)
   
   //###########################
   //# BODY
   //###########################
   reg [PW-1:0]    shiftreg;
   reg [CW-1:0]    count;

   //##########################
   //# STATE MACHINE
   //##########################
   
   assign start_transfer = load & 
			   ~wait_in;
   
   //transfer counter
   always @ (posedge clk or negedge nreset)
     if(~nreset)
       count[CW-1:0] <= 'b0;   
     else if(start_transfer)
       count[CW-1:0] <= datasize[CW-1:0];   //1=1 byte
     else if(shift & busy)
       count[CW-1:0] <= count[CW-1:0] - 1'b1;

   assign access_out = (count[CW-1:0]==1'b1);

   //output data is valid while count>0
   assign busy = |count[CW-1:0];


   //wait until valid data is finished
   assign wait_out  = (busy & ~access_out) |
		      wait_in;
   
   //##########################
   //# SHIFT REGISTER
   //##########################
   
   always @ (posedge clk)
     if(start_transfer)
       shiftreg[PW-1:0] = din[PW-1:0];	   
     else if(shift & lsbfirst)		 
       shiftreg[PW-1:0] = {{(SW){fill}}, shiftreg[PW-SW-1:SW]};
     else if(shift)
       shiftreg[PW-1:0] = {shiftreg[PW-SW-1:0],{(SW){fill}}};

   assign dout[SW-1:0] = lsbfirst ? shiftreg[SW-1:0] : 
			            shiftreg[PW-1:PW-SW];	

endmodule // oh_par2ser

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


