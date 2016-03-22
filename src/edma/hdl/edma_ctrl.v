//#############################################################################
//# Purpose: DMA sequencer                                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################
module edma_ctrl (/*AUTOARG*/
   // Outputs
   dma_state, outerloop, master_active, update,
   // Inputs
   clk, nreset, dma_en, chainmode, mastermode, access_in, wait_in
   );

   // clk, reset, config
   input           clk;        // main clock
   input 	   nreset;     // async active low reset   
   input 	   dma_en;     // dma is enabled
   input 	   chainmode;  // chainmode configuration
   input 	   mastermode; // dma configured in mastermode
      
   // packet control
   input 	   access_in;    // slave access
   input 	   wait_in;      // controls machine stall

   // status
   output [2:0]    dma_state;    // state of dma
   output 	   outerloop;    // dma currently in outerloop (2D)
   output 	   master_active;// master is active
   output 	   update;     // update registers

   assign update = ~wait_in &
		     (master_active | access_in);
   
endmodule // edma_ctrl

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


