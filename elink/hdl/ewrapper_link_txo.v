/*
  File: ewrapper_link_txo.v
 
  This file is part of the Parallella Project

  Copyright (C) 2013 Adapteva, Inc.
  Contributed by Roman Trogan <support@adapteva.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program (see the file COPYING).  If not, see
  <http://www.gnu.org/licenses/>.
*/
module ewrapper_link_txo(/*AUTOARG*/
   // Outputs
   txo_emesh_wait, tx_in,
   // Inputs
   reset, txo_lclk, txo_emesh_access, txo_emesh_write,
   txo_emesh_datamode, txo_emesh_ctrlmode, txo_emesh_dstaddr,
   txo_emesh_srcaddr, txo_emesh_data, burst_en
   );

   //#########
   //# INPUTS
   //#########

   input          reset;     //reset input
   input 	  txo_lclk;  //transmitter clock

   //# From the Emesh
   input 	  txo_emesh_access;
   input 	  txo_emesh_write;
   input [1:0] 	  txo_emesh_datamode;
   input [3:0] 	  txo_emesh_ctrlmode;
   input [31:0]   txo_emesh_dstaddr;
   input [31:0]   txo_emesh_srcaddr;
   input [31:0]   txo_emesh_data;   

   input 	  burst_en; // Burst enable control

   //##########
   //# OUTPUTS
   //##########

   //# To the Emesh
   output 	  txo_emesh_wait;

   //# To the lvds-serdes
//   output [63:0]  txo_data;  //Eight Parallel Byte words
//   output [7:0]   txo_frame; //Parallel frame signals representing 
//                             // 4 transmission clock cycles
   output [71:0]  tx_in;
   
   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#########
   //# Regs
   //#########
   reg 		  shadow_access;
   reg 		  shadow_write;
   reg [1:0] 	  shadow_datamode;
   reg [3:0] 	  shadow_ctrlmode;
   reg [31:0] 	  shadow_dstaddr;
   reg [31:0] 	  shadow_srcaddr;
   reg [31:0] 	  shadow_data;

   reg 		  cycle1_access;
   reg 		  cycle1_write;
   reg [1:0] 	  cycle1_datamode;
   reg [3:0] 	  cycle1_ctrlmode;
   reg [31:0] 	  cycle1_dstaddr;
   reg [31:0] 	  cycle1_srcaddr;
   reg [31:0] 	  cycle1_data;

   reg 		  cycle2_access;
   reg [31:0] 	  cycle2_dstaddr;
   reg [31:0] 	  cycle2_srcaddr;
   reg [31:0] 	  cycle2_data;   

   reg 		  cycle2_dbl; 
   reg [31:0] 	  cycle2_dstaddr_inc8;

   reg 		  byte0_inc0;
   reg 		  txo_emesh_wait;
   //reg [7:0] 	  txo_frame;
   //reg [63:0]   txo_data;
   reg [71:0] 	  tx_in;

   reg 		  cycle1_frame_bit_del;
   reg 		  inc0_match_del;

   //#########
   //# Wires
   //#########
   wire 	  emesh_access;
   wire 	  emesh_write;
   wire [1:0] 	  emesh_datamode;
   wire [3:0] 	  emesh_ctrlmode;
   wire [31:0] 	  emesh_dstaddr;
   wire [31:0] 	  emesh_srcaddr;
   wire [31:0] 	  emesh_data;   

   wire 	  cycle1_dbl; // Cycle1 has a valid double write transaction
   wire [31:0] 	  cycle1_dstaddr_inc8; 
   wire 	  inc8_match;
   wire 	  inc0_match;
   wire 	  burst_tran;
   wire 	  emesh_wait;

   wire 	  cycle1_frame_bit;
   wire 	  cycle2_frame_bit;
   wire [7:0] 	  cycle1_frame;
   wire [7:0] 	  cycle2_frame;
   wire [7:0] 	  txo_frame_int;
   wire [7:0] 	  tran_byte0;
   wire [63:0] 	  cycle1_data_long;
   wire [63:0] 	  cycle2_data_long;
   wire [63:0] 	  data_long;

   wire [7:0] 	  channel0;
   wire [7:0] 	  channel1;
   wire [7:0] 	  channel2;
   wire [7:0] 	  channel3;
   wire [7:0] 	  channel4;
   wire [7:0] 	  channel5;
   wire [7:0] 	  channel6;
   wire [7:0] 	  channel7;

//   wire [8:0] 	  channel0;
//   wire [8:0] 	  channel1;
//   wire [8:0] 	  channel2;
//   wire [8:0] 	  channel3;
//   wire [8:0] 	  channel4;
//   wire [8:0] 	  channel5;
//   wire [8:0] 	  channel6;
//   wire [8:0] 	  channel7;

//   wire [63:0] 	  txo_data_int;
   wire [71:0] 	  txo_data_int;
   
   //##########################
   //# Latch Emesh Transaction
   //##########################

   always @ (posedge txo_lclk or posedge reset)
     if (reset)
       shadow_access <= 1'b0;
     else if(~txo_emesh_wait)
       shadow_access <= txo_emesh_access;

   always @ (posedge txo_lclk)
     if (~txo_emesh_wait)
       begin
	  shadow_write         <= txo_emesh_write;            
	  shadow_datamode[1:0] <= txo_emesh_datamode[1:0];    
	  shadow_ctrlmode[3:0] <= txo_emesh_ctrlmode[3:0];    
	  shadow_dstaddr[31:0] <= txo_emesh_dstaddr[31:0];   
	  shadow_srcaddr[31:0] <= txo_emesh_srcaddr[31:0];   
	  shadow_data[31:0]    <= txo_emesh_data[31:0];
       end

   assign emesh_access = txo_emesh_wait ? shadow_access : txo_emesh_access;
   assign emesh_write  = txo_emesh_wait ? shadow_write  : txo_emesh_write;

   assign emesh_datamode[1:0] = txo_emesh_wait ? shadow_datamode[1:0] :
				                 txo_emesh_datamode[1:0];

   assign emesh_ctrlmode[3:0] = txo_emesh_wait ? shadow_ctrlmode[3:0] :
				                 txo_emesh_ctrlmode[3:0];

   assign emesh_dstaddr[31:0] = txo_emesh_wait ? shadow_dstaddr[31:0] :
				                 txo_emesh_dstaddr[31:0];

   assign emesh_srcaddr[31:0] = txo_emesh_wait ? shadow_srcaddr[31:0] :
				                 txo_emesh_srcaddr[31:0];

   assign emesh_data[31:0] = txo_emesh_wait ? shadow_data[31:0] :
			                      txo_emesh_data[31:0];

   //# Wait indication for emesh
   assign emesh_wait = cycle1_access & cycle2_access & ~burst_tran;

   always @ (posedge txo_lclk or posedge reset)
     if (reset)
       txo_emesh_wait <= 1'b0;
     else
       txo_emesh_wait <= emesh_wait;

   //# First Cycle of the transaction to LVDS-SERDES
   always @ (posedge txo_lclk or posedge reset)
     if (reset)
       cycle1_access <= 1'b0;
     else if(~emesh_wait)
       cycle1_access <= emesh_access;

   always @ (posedge txo_lclk)
     if (~emesh_wait)
       begin
	  cycle1_write         <= emesh_write;            
	  cycle1_datamode[1:0] <= emesh_datamode[1:0];    
	  cycle1_ctrlmode[3:0] <= emesh_ctrlmode[3:0];    
	  cycle1_dstaddr[31:0] <= emesh_dstaddr[31:0];   
	  cycle1_srcaddr[31:0] <= emesh_srcaddr[31:0];   
	  cycle1_data[31:0]    <= emesh_data[31:0];
       end

   //# Second Cycle of the transaction to LVDS-SERDES (never gets stalled)
   always @ (posedge txo_lclk or posedge reset)
     if (reset)
       cycle2_access <= 1'b0;
     else if(emesh_wait)
       cycle2_access <= 1'b0;
     else
       cycle2_access <= cycle1_access;
   
   always @ (posedge txo_lclk)
     begin
	cycle2_dstaddr[31:0]      <= cycle1_dstaddr[31:0];   
	cycle2_srcaddr[31:0]      <= cycle1_srcaddr[31:0];   
	cycle2_data[31:0]         <= cycle1_data[31:0];
	cycle2_dbl                <= cycle1_dbl;
	cycle2_dstaddr_inc8[31:0] <= cycle1_dstaddr_inc8[31:0];
     end
   
   always @ (posedge txo_lclk or posedge reset)
     if(reset)
       begin
	  cycle1_frame_bit_del <= 1'b0;
	  inc0_match_del       <= 1'b0;
       end
     else
       begin
	  cycle1_frame_bit_del <= cycle1_frame_bit;
	  inc0_match_del       <= inc0_match;
       end

   //# keeping track of the address increment mode of burst transaction
   always @ (posedge txo_lclk or posedge reset)
     if(reset)
       byte0_inc0     <= 1'b0;
     else if(cycle1_frame_bit_del)
       byte0_inc0     <= inc0_match_del;

   //# transaction type + transaction address comparison
   assign cycle1_dbl = cycle1_access & cycle1_write & 
		       (&(cycle1_datamode[1:0])) & ~(|(cycle1_ctrlmode[3:0]));
   
   assign cycle1_dstaddr_inc8[31:0] = cycle1_dstaddr[31:0] + 
				      {{(28){1'b0}},4'b1000};

   assign inc8_match = cycle1_dbl & cycle2_dbl & 
		       (cycle1_dstaddr[31:0] == cycle2_dstaddr_inc8[31:0]);
   assign inc0_match = cycle1_dbl & cycle2_dbl &
		       (cycle1_dstaddr[31:0] == cycle2_dstaddr[31:0]);

   //# this is burst transaction
   assign burst_tran = burst_en &
		       cycle1_dbl & cycle2_dbl &
		       ((inc8_match  & ~byte0_inc0) |  // address match
			(inc0_match  &  byte0_inc0));

   assign tran_byte0[7:0] = {~cycle1_write,4'b0000,byte0_inc0,2'b00};

   //###############################################
   //# Actual Interface with LVDS-SERDES (easy :-) )
   //###############################################

   assign cycle1_frame_bit  = cycle1_access & ~cycle2_access;
   assign cycle2_frame_bit  = cycle2_access;
   assign cycle1_frame[7:0] = {2'b00,{(6){cycle1_frame_bit}}};
   assign cycle2_frame[7:0] =        {(8){cycle2_frame_bit}};

   assign txo_frame_int[7:0] = cycle1_frame[7:0] | cycle2_frame[7:0];

   assign cycle1_data_long[63:0] = {{(8){1'b0}},
                                    {(8){1'b0}},
                                    tran_byte0[7:0],
                                    cycle1_ctrlmode[3:0],cycle1_dstaddr[31:28],
                                    cycle1_dstaddr[27:20],
                                    cycle1_dstaddr[19:12],
                                    cycle1_dstaddr[11:4],
	  cycle1_dstaddr[3:0],cycle1_datamode[1:0],cycle1_write,cycle1_access};

   assign cycle2_data_long[63:0] = {cycle2_data[31:0],cycle2_srcaddr[31:0]};

   assign data_long[63:0] = cycle2_access ? cycle2_data_long[63:0] :
			                    cycle1_data_long[63:0];

   //# data per-channel arrangement
   assign channel0[7:0] = {data_long[56],data_long[48], 
			   data_long[40],data_long[32], 
			   data_long[24],data_long[16], 
			   data_long[8], data_long[0]
			   };
//   assign channel0[8:0] = {txo_frame_int[0],data_long[7:0]};
   
   assign channel1[7:0] = {data_long[57],data_long[49], 
			   data_long[41],data_long[33], 
			   data_long[25],data_long[17], 
			   data_long[9], data_long[1]
			   };
//   assign channel1[8:0] = {txo_frame_int[1],data_long[15:8]};
   
   assign channel2[7:0] = {data_long[58],data_long[50], 
			   data_long[42],data_long[34], 
			   data_long[26],data_long[18], 
			   data_long[10],data_long[2]
			   };
//   assign channel2[8:0] = {txo_frame_int[2],data_long[23:16]};
   
   assign channel3[7:0] = {data_long[59],data_long[51], 
			   data_long[43],data_long[35], 
			   data_long[27],data_long[19], 
			   data_long[11],data_long[3]
			   };
//   assign channel3[8:0] = {txo_frame_int[3],data_long[31:24]};
   
   assign channel4[7:0] = {data_long[60],data_long[52], 
			   data_long[44],data_long[36], 
			   data_long[28],data_long[20], 
			   data_long[12],data_long[4]
			   };
//   assign channel4[8:0] = {txo_frame_int[4],data_long[39:32]};
   
   assign channel5[7:0] = {data_long[61],data_long[53], 
			   data_long[45],data_long[37], 
			   data_long[29],data_long[21], 
			   data_long[13],data_long[5]
			   };
//   assign channel5[8:0] = {txo_frame_int[5],data_long[47:40]};
   
   assign channel6[7:0] = {data_long[62],data_long[54], 
			   data_long[46],data_long[38], 
			   data_long[30],data_long[22], 
			   data_long[14],data_long[6]
			   };
//   assign channel6[8:0] = {txo_frame_int[6],data_long[55:48]};
   
   assign channel7[7:0] = {data_long[63],data_long[55], 
			   data_long[47],data_long[39], 
			   data_long[31],data_long[23], 
			   data_long[15],data_long[7]
			   };

//   assign channel7[8:0] = {txo_frame_int[7],data_long[63:56]};
   
   
   assign txo_data_int[71:0] =
		      {txo_frame_int[7:0],
		       channel7[7:0],channel6[7:0],channel5[7:0],channel4[7:0],
		       channel3[7:0],channel2[7:0],channel1[7:0],channel0[7:0]};

//   assign txo_data_int[71:0] =
//		      {channel7[8:0],channel6[8:0],channel5[8:0],channel4[8:0],
//		       channel3[8:0],channel2[8:0],channel1[8:0],channel0[8:0]};

//   always @ (posedge txo_lclk or posedge reset)
//     if (reset)
//       txo_frame[7:0] <= {(8){1'b0}};
//     else
//       txo_frame[7:0] <= txo_frame_int[7:0];

//   always @ (posedge txo_lclk)
//     txo_data[63:0] <= txo_data_int[63:0];

   always @ (posedge txo_lclk or posedge reset)
     if (reset)
       tx_in[71:0] <= {(72){1'b0}};
     else
       tx_in[71:0] <= txo_data_int[71:0];

endmodule // ewrapper_link_txo
