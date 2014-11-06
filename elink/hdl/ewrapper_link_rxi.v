/*
  File: ewrapper_link_rxi.v
 
  This file is part of the Parallella FPGA Reference Design.

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
module ewrapper_link_rxi (/*AUTOARG*/
   // Outputs
   rxo_wait, emesh_access_inb, emesh_write_inb, emesh_datamode_inb,
   emesh_ctrlmode_inb, emesh_dstaddr_inb, emesh_srcaddr_inb,
   emesh_data_inb,
   // Inputs
   reset, rxi_data, rxi_lclk, rxi_frame, emesh_wait_outb, rxi_rd
   );

   //#########
   //# INPUTS
   //#########

   input          reset;       //reset input

   //# From the lvds-serdes
   input [63:0]   rxi_data;  //Eight Parallel Byte words
   input 	  rxi_lclk;  //receive clock (synchronized to the data)
   input [7:0] 	  rxi_frame; //Parallel frame signals representing 
                             // 4 transmission clock cycles

   //# From the emesh interface
   input 	  emesh_wait_outb; 

   //# constant control (distinguish read and write instances)
   input 	  rxi_rd;    //this is read transactions instance
   
   //##########
   //# OUTPUTS
   //##########

   //# To the transmitter
   output 	  rxo_wait;  //wait indicator

   //# To the emesh interface
   output 	  emesh_access_inb;
   output 	  emesh_write_inb;
   output [1:0]   emesh_datamode_inb;
   output [3:0]   emesh_ctrlmode_inb;
   output [31:0]  emesh_dstaddr_inb;
   output [31:0]  emesh_srcaddr_inb;
   output [31:0]  emesh_data_inb;  

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#########
   //# Regs
   //#########
   reg 		  rxi_frame_last;
   reg [7:0] 	  rxi_data_last;
   reg [3:0] 	  frame_reg;
   reg [3:0] 	  frame_reg_del;
   reg [7:0] 	  first_byte0;
   reg [3:0] 	  first_ctrlmode;
   reg [31:0] 	  first_dstaddr;
   reg [1:0] 	  first_datamode;
   reg 		  first_write;
   reg 		  first_access;
   reg [15:0] 	  first_data;
   reg [3:0] 	  frame_redge_first_reg;
   reg 		  new_tran_reg;
   reg [7:0] 	  second_byte0;
   reg [3:0] 	  second_ctrlmode;
   reg [31:0] 	  second_dstaddr;
   reg [1:0] 	  second_datamode;
   reg 		  second_write;
   reg 		  second_access;
   reg [31:0] 	  second_data;
   reg [31:0] 	  second_srcaddr;
   reg [3:0] 	  frame_redge_first_reg1;
   reg 		  burst_byte6;
   reg 		  burst_byte0;
   reg 		  burst_byte2;
   reg 		  burst_byte4;
   reg [63:0] 	  data_long;
   reg [63:0] 	  data_long_reg;
   reg [103:0] 	  fifo_in;
   reg 		  fifo_wr;
   reg [103:0] 	  fifo_out_reg;
   reg 		  emesh_access_inb;
   reg 		  rxo_wait;
   reg 		  add_latency;
   reg [31:0] 	  ref_dstaddr;

   //#########
   //# Wires
   //#########
   wire 	  rxi_frame_76;
   wire 	  rxi_frame_54;
   wire 	  rxi_frame_32;
   wire 	  rxi_frame_10;
   wire 	  rxi_add_latency;
   wire 	  rxi_frame_07;
   wire 	  rxi_frame_65;
   wire 	  rxi_frame_43;
   wire 	  rxi_frame_21;
   wire 	  rxi_remove_latency;
   wire [7:0] 	  rxi_frame_aligned;
   wire [63:0] 	  rxi_data_aligned;
   wire [3:0] 	  frame_redge_first_int;
   wire [3:0] 	  frame_redge_first;
   wire [7:0] 	  rxi_byte7;
   wire [7:0] 	  rxi_byte6;
   wire [7:0] 	  rxi_byte5;
   wire [7:0] 	  rxi_byte4;
   wire [7:0] 	  rxi_byte3;
   wire [7:0] 	  rxi_byte2;
   wire [7:0] 	  rxi_byte1;
   wire [7:0] 	  rxi_byte0;
   wire [63:0] 	  rxi_data_long;
   wire [7:0] 	  data_byte7;
   wire [7:0] 	  data_byte6;
   wire [7:0] 	  data_byte5;
   wire [7:0] 	  data_byte4;
   wire [7:0] 	  data_byte3;
   wire [7:0] 	  data_byte2;
   wire [7:0] 	  data_byte1;
   wire [7:0] 	  data_byte0;
   wire [7:0] 	  tran_byte0_int;
   wire [3:0] 	  tran_ctrlmode_int0;
   wire [31:0] 	  tran_dstaddr_int0;
   wire [1:0] 	  tran_datamode_int0;
   wire 	  tran_write_int0;
   wire 	  tran_access_int0;
   wire 	  new_tran;
   wire [31:0] 	  tran_dstaddr_int1;
   wire [1:0] 	  tran_datamode_int1;
   wire 	  tran_write_int1;
   wire 	  tran_access_int1;
   wire [31:0] 	  tran_data_int1;
   wire [31:0] 	  tran_srcaddr_int1;
   wire [31:0] 	  tran_srcaddr_int2;
   wire 	  burst_start_byte6;
   wire 	  burst_start_byte0;
   wire 	  burst_start_byte2;
   wire 	  burst_start_byte4;
   wire 	  burst_stop_byte6;
   wire 	  burst_stop_byte0;
   wire 	  burst_stop_byte2;
   wire 	  burst_stop_byte4;
   wire [63:0] 	  burst_data;
   wire 	  byte0_inc8;
   wire [31:0] 	  burst_dstaddr;
   wire [3:0] 	  tran_ctrlmode;
   wire [31:0] 	  tran_dstaddr;
   wire [1:0] 	  tran_datamode;
   wire 	  tran_write;
   wire 	  tran_access;
   wire [31:0] 	  tran_data;
   wire [31:0] 	  tran_srcaddr;
   wire [103:0]   assembled_tran;
   wire 	  tran_ready;
   wire [107:0]   fifo_out;
   wire 	  fifo_rd;
   wire 	  fifo_empty;
   wire 	  mine_tran;
   wire 	  frame_redge_first_or20_reg1;

   //# "add/remove latency" detection
   assign rxi_frame_76 = ~rxi_frame[7] & rxi_frame[6];
   assign rxi_frame_54 = ~rxi_frame[5] & rxi_frame[4];
   assign rxi_frame_32 = ~rxi_frame[3] & rxi_frame[2];
   assign rxi_frame_10 = ~rxi_frame[1] & rxi_frame[0];
   assign rxi_add_latency = rxi_frame_76 | rxi_frame_54 |
			    rxi_frame_32 | rxi_frame_10;

   assign rxi_frame_07 = ~rxi_frame_last    & rxi_frame[7];
   assign rxi_frame_65 = ~rxi_frame[6]      & rxi_frame[5];
   assign rxi_frame_43 = ~rxi_frame[4]      & rxi_frame[3];
   assign rxi_frame_21 = ~rxi_frame[2]      & rxi_frame[1];
   assign rxi_remove_latency = rxi_frame_07 | rxi_frame_65 |
			       rxi_frame_43 | rxi_frame_21;

   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       add_latency <= 1'b0;
     else if(rxi_add_latency)
       add_latency <= 1'b1;
     else if(rxi_remove_latency)
       add_latency <= 1'b0;

   //# frame alignment
   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       rxi_frame_last <= 1'b0;
     else
       rxi_frame_last <= rxi_frame[0];

   assign rxi_frame_aligned[7:0] = (rxi_add_latency | add_latency) ?
			       {rxi_frame_last,rxi_frame[7:1]} : rxi_frame[7:0];
				   
   //# data alignment
   //# we should interleave the received data:
   assign rxi_byte0[7:0] ={rxi_data[63],rxi_data[55],rxi_data[47],rxi_data[39],
                            rxi_data[31],rxi_data[23],rxi_data[15],rxi_data[7]};
   
   assign rxi_byte1[7:0] ={rxi_data[62],rxi_data[54],rxi_data[46],rxi_data[38],
                            rxi_data[30],rxi_data[22],rxi_data[14],rxi_data[6]};
   
   assign rxi_byte2[7:0] ={rxi_data[61],rxi_data[53],rxi_data[45],rxi_data[37],
                            rxi_data[29],rxi_data[21],rxi_data[13],rxi_data[5]};
   
   assign rxi_byte3[7:0] ={rxi_data[60],rxi_data[52],rxi_data[44],rxi_data[36],
                            rxi_data[28],rxi_data[20],rxi_data[12],rxi_data[4]};
   
   assign rxi_byte4[7:0] ={rxi_data[59],rxi_data[51],rxi_data[43],rxi_data[35],
                            rxi_data[27],rxi_data[19],rxi_data[11],rxi_data[3]};
   
   assign rxi_byte5[7:0] ={rxi_data[58],rxi_data[50],rxi_data[42],rxi_data[34],
                            rxi_data[26],rxi_data[18],rxi_data[10],rxi_data[2]};
   
   assign rxi_byte6[7:0] ={rxi_data[57],rxi_data[49],rxi_data[41],rxi_data[33],
                            rxi_data[25],rxi_data[17],rxi_data[9], rxi_data[1]};
   
   assign rxi_byte7[7:0] ={rxi_data[56],rxi_data[48],rxi_data[40],rxi_data[32],
                            rxi_data[24],rxi_data[16],rxi_data[8], rxi_data[0]};

   assign rxi_data_long[63:0] = {rxi_byte0[7:0],rxi_byte1[7:0],
                                 rxi_byte2[7:0],rxi_byte3[7:0],
                                 rxi_byte4[7:0],rxi_byte5[7:0],
                                 rxi_byte6[7:0],rxi_byte7[7:0]};

   always @ (posedge rxi_lclk)
     rxi_data_last[7:0] <= rxi_byte7[7:0];

   assign rxi_data_aligned[63:0] = (rxi_add_latency | add_latency) ?
			           {rxi_data_last[7:0],rxi_data_long[63:8]} : 
				                       rxi_data_long[63:0];
				   
   //################################
   //# Main "After Alignment" Logic
   //################################

   //# frame
   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       begin
	  frame_reg[3:0]     <= 4'b0000;
	  frame_reg_del[3:0] <= 4'b0000;
       end
     else
       begin
	  frame_reg[3:0]     <= {rxi_frame_aligned[7],rxi_frame_aligned[5],
			         rxi_frame_aligned[3],rxi_frame_aligned[1]};
	  frame_reg_del[3:0] <= frame_reg[3:0];
       end

   //# data
   always @ (posedge rxi_lclk)
     data_long[63:0] <= rxi_data_aligned[63:0];

   assign data_byte7[7:0] = data_long[7:0];
   assign data_byte6[7:0] = data_long[15:8];
   assign data_byte5[7:0] = data_long[23:16];
   assign data_byte4[7:0] = data_long[31:24];
   assign data_byte3[7:0] = data_long[39:32];
   assign data_byte2[7:0] = data_long[47:40];
   assign data_byte1[7:0] = data_long[55:48];
   assign data_byte0[7:0] = data_long[63:56];

   //# frame rising edge detection
   assign frame_redge_first_int[3] = frame_reg[3] & ~frame_reg_del[0]; 
   assign frame_redge_first_int[2] = frame_reg[2] & ~frame_reg[3];
   assign frame_redge_first_int[1] = frame_reg[1] & ~frame_reg[2];
   assign frame_redge_first_int[0] = frame_reg[0] & ~frame_reg[1];

   //# First Cycle of the Transaction

   //# new transactions is detected when the type of transaction matches
   //# type of the instance (read or write) during the rising edge of frame

   assign mine_tran = ~(tran_byte0_int[7] ^ rxi_rd);

   assign frame_redge_first[3:0] =frame_redge_first_int[3:0] & {(4){mine_tran}};
   assign new_tran = |(frame_redge_first[3:0]);

   assign tran_byte0_int[7:0] = frame_redge_first_int[3] ? data_byte0[7:0] :
				frame_redge_first_int[2] ? data_byte2[7:0] :
				frame_redge_first_int[1] ? data_byte4[7:0] :
				                           data_byte6[7:0];

   assign tran_ctrlmode_int0[3:0] = frame_redge_first[3] ? data_byte1[7:4] :
				    frame_redge_first[2] ? data_byte3[7:4] :
				    frame_redge_first[1] ? data_byte5[7:4] :
				                           data_byte7[7:4];

   assign tran_dstaddr_int0[31:28] = frame_redge_first[3] ? data_byte1[3:0] :
				     frame_redge_first[2] ? data_byte3[3:0] :
				     frame_redge_first[1] ? data_byte5[3:0] :
				                            data_byte7[3:0];
				    
   assign tran_dstaddr_int0[27:20] = frame_redge_first[3] ? data_byte2[7:0] :
				     frame_redge_first[2] ? data_byte4[7:0] :
				                            data_byte6[7:0];

   assign tran_dstaddr_int0[19:12] = frame_redge_first[3] ? data_byte3[7:0] :
				     frame_redge_first[2] ? data_byte5[7:0] :
				                            data_byte7[7:0];

   assign tran_dstaddr_int0[11:4] = frame_redge_first[3] ? data_byte4[7:0] :
				                           data_byte6[7:0];

   assign tran_dstaddr_int0[3:0] = frame_redge_first[3] ? data_byte5[7:4] :
				                          data_byte7[7:4];

   assign tran_datamode_int0[1:0] = frame_redge_first[3] ? data_byte5[3:2] :
				                           data_byte7[3:2];

   assign tran_write_int0 = frame_redge_first[3] ? data_byte5[1] :
				                   data_byte7[1];

   assign tran_access_int0 = frame_redge_first[3] ? data_byte5[0] :
				                    data_byte7[0];

   always @ (posedge rxi_lclk)
     if (new_tran)
       begin
	  first_byte0[7:0]    <= tran_byte0_int[7:0];
	  first_ctrlmode[3:0] <= tran_ctrlmode_int0[3:0];
	  first_dstaddr[31:0] <= tran_dstaddr_int0[31:0];
	  first_datamode[1:0] <= tran_datamode_int0[1:0];
	  first_write         <= tran_write_int0;
	  first_access        <= tran_access_int0;
	  first_data[15:0]    <= {data_byte6[7:0],data_byte7[7:0]};
       end
   
   //# Second Cycle of the Transaction
   always @ (posedge rxi_lclk or posedge reset)
     if (reset)
       begin
	  frame_redge_first_reg[3:0] <= 4'b0000;
	  new_tran_reg               <= 1'b0;
       end
     else
       begin
	  frame_redge_first_reg[3:0] <= frame_redge_first[3:0];
	  new_tran_reg               <= new_tran;
       end

   assign tran_dstaddr_int1[31:28] = first_dstaddr[31:28];

   assign tran_dstaddr_int1[27:12] = 
		 frame_redge_first_reg[0] ? {data_byte0[7:0],data_byte1[7:0]} :
				             first_dstaddr[27:12];

   assign tran_dstaddr_int1[11:4] = frame_redge_first_reg[1] ? data_byte0[7:0] :
				    frame_redge_first_reg[0] ? data_byte2[7:0] :
				                           first_dstaddr[11:4];

   assign tran_dstaddr_int1[3:0] = frame_redge_first_reg[1] ? data_byte1[7:4] :
				   frame_redge_first_reg[0] ? data_byte3[7:4] :
				                           first_dstaddr[3:0];

   assign tran_datamode_int1[1:0] = frame_redge_first_reg[1] ? data_byte1[3:2] :
				    frame_redge_first_reg[0] ? data_byte3[3:2] :
				                           first_datamode[1:0];

   assign tran_write_int1 = frame_redge_first_reg[1] ? data_byte1[1] :
			    frame_redge_first_reg[0] ? data_byte3[1] :
			                               first_write;

   assign tran_access_int1 = frame_redge_first_reg[1] ? data_byte1[0] :
			     frame_redge_first_reg[0] ? data_byte3[0] :
			                                first_access;

   assign tran_data_int1[31:24] = frame_redge_first_reg[2] ? data_byte0[7:0] :
				  frame_redge_first_reg[1] ? data_byte2[7:0] :
				  frame_redge_first_reg[0] ? data_byte4[7:0] :
				                             first_data[15:8];

   assign tran_data_int1[23:16] = frame_redge_first_reg[2] ? data_byte1[7:0] :
				  frame_redge_first_reg[1] ? data_byte3[7:0] :
				  frame_redge_first_reg[0] ? data_byte5[7:0] :
				                             first_data[7:0];
 
   assign tran_data_int1[15:8] = frame_redge_first_reg[3] ? data_byte0[7:0] :
				 frame_redge_first_reg[2] ? data_byte2[7:0] :
				 frame_redge_first_reg[1] ? data_byte4[7:0] :
				                            data_byte6[7:0];

   assign tran_data_int1[7:0] = frame_redge_first_reg[3] ? data_byte1[7:0] :
				frame_redge_first_reg[2] ? data_byte3[7:0] :
				frame_redge_first_reg[1] ? data_byte5[7:0] :
				                           data_byte7[7:0];

   assign tran_srcaddr_int1[31:24] = frame_redge_first_reg[3] ? data_byte2[7:0]:
				     frame_redge_first_reg[2] ? data_byte4[7:0]:
				                                data_byte6[7:0];

   assign tran_srcaddr_int1[23:16] = frame_redge_first_reg[3] ? data_byte3[7:0]:
				     frame_redge_first_reg[2] ? data_byte5[7:0]:
				                                data_byte7[7:0];

   assign tran_srcaddr_int1[15:8] = frame_redge_first_reg[3] ? data_byte4[7:0] :
				                               data_byte6[7:0];

   assign tran_srcaddr_int1[7:0] = frame_redge_first_reg[3] ? data_byte5[7:0] :
				                              data_byte7[7:0];

   always @ (posedge rxi_lclk)
     if (new_tran_reg)
       begin
	  second_byte0[7:0]    <= first_byte0[7:0];
	  second_ctrlmode[3:0] <= first_ctrlmode[3:0];
	  second_dstaddr[31:0] <= tran_dstaddr_int1[31:0];
	  second_datamode[1:0] <= tran_datamode_int1[1:0];
	  second_write         <= tran_write_int1;
	  second_access        <= tran_access_int1;
	  second_data[31:0]    <= tran_data_int1[31:0];
	  second_srcaddr[31:0] <= tran_srcaddr_int1[31:0];
       end // if (new_tran_reg)

   //# Third Cycle of the Transaction
   always @ (posedge rxi_lclk or posedge reset)
     if (reset)
       frame_redge_first_reg1[3:0] <= 4'b0000;
     else
       frame_redge_first_reg1[3:0] <= frame_redge_first_reg[3:0];

   assign tran_srcaddr_int2[31:16] = 
		frame_redge_first_reg1[0] ? {data_byte0[7:0],data_byte1[7:0]} :
		          		     second_srcaddr[31:16];

   assign tran_srcaddr_int2[15:8] = frame_redge_first_reg1[1] ? data_byte0[7:0]:
				    frame_redge_first_reg1[0] ? data_byte2[7:0]:
				                           second_srcaddr[15:8];

   assign tran_srcaddr_int2[7:0] = frame_redge_first_reg1[1] ? data_byte1[7:0]:
				   frame_redge_first_reg1[0] ? data_byte3[7:0]:
				                            second_srcaddr[7:0];

   //############################################
   //# Data Collection of the Burst Transactions
   //############################################

   assign burst_start_byte6 = frame_redge_first_reg[3]  & frame_reg[0];
   assign burst_start_byte0 = frame_redge_first_reg1[2] & frame_reg[3];
   assign burst_start_byte2 = frame_redge_first_reg1[1] & frame_reg[2];
   assign burst_start_byte4 = frame_redge_first_reg1[0] & frame_reg[1];

   assign burst_stop_byte6 = ~frame_reg[0] & frame_reg_del[0];
   assign burst_stop_byte0 = ~frame_reg[3] & frame_reg_del[3];
   assign burst_stop_byte2 = ~frame_reg[2] & frame_reg_del[2];
   assign burst_stop_byte4 = ~frame_reg[1] & frame_reg_del[1];

   always @ (posedge rxi_lclk or posedge reset)
     if (reset)
       burst_byte6 <= 1'b0;
     else if(burst_start_byte6)
       burst_byte6 <= 1'b1;
     else if(burst_stop_byte6)
       burst_byte6 <= 1'b0;

   always @ (posedge rxi_lclk or posedge reset)
     if (reset)
       burst_byte0 <= 1'b0;
     else if(burst_start_byte0)
       burst_byte0 <= 1'b1;
     else if(burst_stop_byte0)
       burst_byte0 <= 1'b0;

   always @ (posedge rxi_lclk or posedge reset)
     if (reset)
       burst_byte2 <= 1'b0;
     else if(burst_start_byte2)
       burst_byte2 <= 1'b1;
     else if(burst_stop_byte2)
       burst_byte2 <= 1'b0;

   always @ (posedge rxi_lclk or posedge reset)
     if (reset)
       burst_byte4 <= 1'b0;
     else if(burst_start_byte4)
       burst_byte4 <= 1'b1;
     else if(burst_stop_byte4)
       burst_byte4 <= 1'b0;

   always @ (posedge rxi_lclk)
     data_long_reg[63:0] <= data_long[63:0];

   assign burst_data[63:0] = 
			burst_byte6 ? {data_long_reg[15:0],data_long[63:16]} :
			burst_byte0 ?  data_long_reg[63:0] :
			burst_byte2 ? {data_long_reg[47:0],data_long[63:48]} :
			              {data_long_reg[31:0],data_long[63:32]};
		
   //###############################################
   //# Address Calculation of the Burst Transaction
   //###############################################

   always @ (posedge rxi_lclk)
     if (tran_ready)
       ref_dstaddr[31:0] <= tran_dstaddr[31:0];

   assign byte0_inc8   = ~second_byte0[2];
   assign burst_dstaddr[31:0] = ref_dstaddr[31:0] + 
				               {{(28){1'b0}},byte0_inc8,3'b000};

   //##########################################
   //# Assembled Transaction to enter the FIFO
   //##########################################
   
   assign frame_redge_first_or20_reg1 = |(frame_redge_first_reg1[2:0]);

   assign tran_ctrlmode[3:0] = frame_redge_first_reg[3] ? first_ctrlmode[3:0] :
			                                  second_ctrlmode[3:0];
   assign tran_datamode[1:0] = frame_redge_first_reg[3] ? tran_datamode_int1[1:0]:
			                                  second_datamode[1:0];
   assign tran_write         = frame_redge_first_reg[3] ? tran_write_int1 : 
			                                  second_write;
   assign tran_access        = frame_redge_first_reg[3] ? tran_access_int1 :
			                                  second_access;
   assign tran_srcaddr[31:0] = frame_redge_first_reg[3]    ? tran_srcaddr_int1[31:0]:
			       frame_redge_first_or20_reg1 ? tran_srcaddr_int2[31:0]:
			                                     burst_data[31:0];
   assign tran_data[31:0]    = frame_redge_first_reg[3]    ? tran_data_int1[31:0]:
			       frame_redge_first_or20_reg1 ? second_data[31:0]:
			                                     burst_data[63:32];
   assign tran_dstaddr[31:0] = frame_redge_first_reg[3]    ? tran_dstaddr_int1[31:0]:
			       frame_redge_first_or20_reg1 ? second_dstaddr[31:0]:
			                                     burst_dstaddr[31:0];

   assign assembled_tran[103:0] = {tran_srcaddr[31:0],
                                   tran_data[31:0],
                                   tran_dstaddr[31:0],
                                   tran_ctrlmode[3:0],
                                   tran_datamode[1:0],
                                   tran_write,
                                   tran_access};

   assign tran_ready = frame_redge_first_reg[3] | frame_redge_first_or20_reg1 |
		       burst_byte6 | burst_byte0 | burst_byte2 | burst_byte4;

   //# The transaction is latched before entering FIFO to prevent timing
   //# issues
   always @ (posedge rxi_lclk)
	fifo_in[103:0] <= assembled_tran[103:0];

   always @ (posedge rxi_lclk or posedge reset)
     if (reset)
       fifo_wr <= 1'b0;
     else
       fifo_wr <= tran_ready;

   //# Wait logic
   always @ (posedge rxi_lclk or posedge reset)
     if (reset)
       rxo_wait <= 1'b0;
     else if (emesh_wait_outb)
       rxo_wait <= 1'b1;
     else if (fifo_empty)
       rxo_wait <= 1'b0;

   assign emesh_srcaddr_inb[31:0] = fifo_out_reg[103:72];
   assign emesh_data_inb[31:0]    = fifo_out_reg[71:40];
   assign emesh_dstaddr_inb[31:0] = fifo_out_reg[39:8];
   assign emesh_ctrlmode_inb[3:0] = fifo_out_reg[7:4];
   assign emesh_datamode_inb[1:0] = fifo_out_reg[3:2];
   assign emesh_write_inb         = fifo_out_reg[1];

   always @ (posedge rxi_lclk or posedge reset)
     if (reset)
       emesh_access_inb <= 1'b0;
     else if (~emesh_wait_outb)
       emesh_access_inb <= fifo_rd;
       
   always @ (posedge rxi_lclk)
     if (~emesh_wait_outb)
	  fifo_out_reg[103:0] <= fifo_out[103:0];

   assign fifo_rd = ~(fifo_empty | emesh_wait_outb);

   /*fifo AUTO_TEMPLATE(.rd_clk	       (rxi_lclk),
                        .wr_clk	       (rxi_lclk),
		        .wr_data       (fifo_in[103:0]),
                        .rd_data       (fifo_out[103:0]), 
                        .rd_fifo_empty (fifo_empty),
                        .wr_fifo_full  (),
                        .wr_write      (fifo_wr),
                        .rd_read       (fifo_rd),
                       );
    */

   //# We have 32 entries of 104 bits each
   fifo #(.DW(104), .AW(5)) fifo_rxi(/*AUTOINST*/
				     // Outputs
				     .rd_data		(fifo_out[103:0]), // Templated
				     .rd_fifo_empty	(fifo_empty),	 // Templated
				     .wr_fifo_full	(),		 // Templated
				     // Inputs
				     .reset		(reset),
				     .wr_clk		(rxi_lclk),	 // Templated
				     .rd_clk		(rxi_lclk),	 // Templated
				     .wr_write		(fifo_wr),	 // Templated
				     .wr_data		(fifo_in[103:0]), // Templated
				     .rd_read		(fifo_rd));	 // Templated




endmodule // ewrapper_link_rxi
