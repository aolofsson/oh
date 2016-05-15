//#############################################################################
//# Purpose: DMA sequencer                                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

`include "edma_regmap.vh"
module edma_ctrl (/*AUTOARG*/
   // Outputs
   fetch_access, fetch_packet, dma_state, update, update2d,
   master_active,
   // Inputs
   clk, nreset, dma_en, chainmode, manualmode, mastermode, count,
   curr_descr, next_descr, reg_wait_in, access_in, wait_in
   );

   parameter  AW  = 32;            // address width
   parameter  PW  = 2*AW+40;      // fetch packet width
   parameter  ID  = 4'b0000;      // group id for DMA regs [10:8]
   
   // clk, reset, config
   input           clk;           // main clock
   input 	   nreset;        // async active low reset   
   input 	   dma_en;        // dma is enabled
   input 	   chainmode;     // chainmode configuration
   input 	   manualmode;    // descriptor fetch   
   input 	   mastermode;    // dma configured in mastermode
   input [31:0]    count;         // current transfer count    
   input [15:0]    curr_descr;	  
   input [15:0]    next_descr;	

   // descriptor fetch interface
   output 	   fetch_access;  // fetch descriptor
   output [PW-1:0] fetch_packet;  // fetch packet
   input 	   reg_wait_in;   // register access wait
   
   // slave access
   input 	   access_in;     // slave access
   input 	   wait_in;       // master/slave transfer stall
   
   // status
   output [3:0]    dma_state;     // state of dma
   output 	   update;        // update registers
   output 	   update2d;      // dma currently in outerloop (2D)
   output 	   master_active; // master is active

   //###########################################################################
   //# BODY
   //###########################################################################

   reg [3:0] 	   dma_state;
   wire [15:0] 	   descr;
   wire [15:0] 	   fetch_addr;
   wire [AW-1:0]   srcaddr_out;
   wire [4:0] 	   reg_addr;
   wire 	   dma_error;
   wire 	   incount_zero;
   wire 	   outcount_zero;

   //###########################################
   //# STATE MACHINE                           
   //###########################################
   
  `define DMA_IDLE    4'b0000 // dma idle
  `define DMA_FETCH0  4'b0001 // fetch cfg, next-ptr, stride_in
  `define DMA_FETCH1  4'b0010 // fetch cnt_out,cnt_in, stride_out
  `define DMA_FETCH2  4'b0011 // fetch srcaddr, dstaddr
  `define DMA_FETCH3  4'b0100 // fetch srcaddr64, dstaddr64
  `define DMA_FETCH4  4'b0101 // stall (no bypass)
  `define DMA_INNER   4'b0110 // dma inner loop
  `define DMA_OUTER   4'b0111 // dma outer loop
  `define DMA_DONE    4'b1000 // dma outer loop
  `define DMA_ERROR   4'b1001 // dma error
   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       dma_state[3:0] <= `DMA_IDLE;
     else if(dma_error)
       dma_state[3:0] <= `DMA_ERROR;
     else
       case(dma_state[3:0])
	 `DMA_IDLE: 
	   casez({dma_en,manualmode})
	     2'b0?  : dma_state[3:0]   <= `DMA_IDLE;
	     2'b11  : dma_state[3:0]   <= `DMA_INNER;
	     2'b10  : dma_state[3:0]   <= `DMA_FETCH0;
	   endcase // casez (dma_reg_write_config)	    
	 `DMA_FETCH0: 
	   dma_state[3:0] <= reg_wait_in ? `DMA_FETCH0 : `DMA_FETCH1;
	 `DMA_FETCH1: 
	   dma_state[3:0] <= reg_wait_in ? `DMA_FETCH1 : `DMA_FETCH2;
	 `DMA_FETCH2: 
	   dma_state[3:0] <= reg_wait_in ? `DMA_FETCH2 : `DMA_FETCH3;
	 `DMA_FETCH3: 
	   dma_state[3:0] <= reg_wait_in ? `DMA_FETCH3 : `DMA_FETCH3;
	 `DMA_FETCH4: 
	   dma_state[3:0] <= reg_wait_in ? `DMA_FETCH4 : `DMA_INNER;
	 `DMA_INNER:
	   casez({update,incount_zero,outcount_zero})
	     3'b0?? : dma_state[3:0] <= `DMA_INNER;
	     3'b10? : dma_state[3:0] <= `DMA_INNER;
	     3'b110 : dma_state[3:0] <= `DMA_OUTER;
	     3'b111 : dma_state[3:0] <= `DMA_DONE;
	   endcase
 	 `DMA_OUTER:
	   dma_state[3:0]   <= update ? `DMA_INNER : `DMA_OUTER;
	 `DMA_DONE:
	   casez({chainmode,manualmode})
	     2'b0? : dma_state[3:0]  <= `DMA_DONE;
	     2'b11 : dma_state[3:0]  <= `DMA_IDLE;
	     2'b10 : dma_state[3:0]  <= `DMA_FETCH0;
	   endcase
	 `DMA_ERROR:
	   dma_state[3:0] <= dma_en ? `DMA_ERROR: `DMA_IDLE;
       endcase

   //###########################################
   //# ACTIVE SIGNALS                           
   //###########################################

   assign dma_error     = 1'b0;  //TODO: define error conditions

   assign update        = ~wait_in & (master_active | access_in);

   assign update2d      = update & (dma_state[3:0]==`DMA_OUTER);   

   assign master_active = mastermode & 
			  ((dma_state[3:0]==`DMA_INNER) |
			   (dma_state[3:0]==`DMA_OUTER));
   

   assign incount_zero  = ~(|count[15:0]);

   assign outcount_zero = ~(|count[31:16]);
   
   //###########################################
   //# DESCRIPTOR FETCH ENGINE
   //###########################################

   assign fetch_access = (dma_state[3:0]==`DMA_FETCH0) |
			 (dma_state[3:0]==`DMA_FETCH1) |
			 (dma_state[3:0]==`DMA_FETCH2);
   

   // fetch address
   assign  descr[15:0] = (dma_state[3:0]==`DMA_FETCH0) ? next_descr[15:0] :
		                                         curr_descr[15:0];
   
   oh_mux3 #(.DW(16))
   mux3d (.out	(fetch_addr[15:0]),
	  .in0	(descr[15:0]),        .sel0 (dma_state[3:0]==`DMA_FETCH0),
	  .in1	(descr[15:0]+16'd8),  .sel1 (dma_state[3:0]==`DMA_FETCH1),
	  .in2	(descr[15:0]+16'd16), .sel2 (dma_state[3:0]==`DMA_FETCH2)
	  );


   //address of first reg to fetch
   oh_mux3 #(.DW(5))
   mux3s (.out	(reg_addr[4:0]),
	  .in0	(`EDMA_CONFIG),  .sel0 (dma_state[3:0]==`DMA_FETCH0),
	  .in1	(`EDMA_COUNT),   .sel1 (dma_state[3:0]==`DMA_FETCH1),
	  .in2	(`EDMA_SRCADDR), .sel2 (dma_state[3:0]==`DMA_FETCH2)
	  );

   // constructing the address to return fetch to
   assign srcaddr_out[AW-1:0] = {{(AW-11){1'b0}},  //31-11
				 ID,               //10-7
				 reg_addr[4:0],    //6-2
				 2'b0};            //1-0
   
   // constructing fetch packet
   emesh2packet #(.AW(AW),
		  .PW(PW))
   e2p (//outputs
	.packet_out	(fetch_packet[PW-1:0]),
	//inputs        
	.write_out	(1'b0),
	.datamode_out	(2'b11),
	.ctrlmode_out	(5'b0),
	.dstaddr_out	({{(AW-16){1'b0}},fetch_addr[15:0]}),
	.data_out	({(AW){1'b0}}),
	.srcaddr_out	(srcaddr_out[AW-1:0]));
   
   			  
endmodule // edma_ctrl
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../common/hdl" "../../emesh/hdl")
// End:

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


