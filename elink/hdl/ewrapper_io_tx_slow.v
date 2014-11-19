/*
  File: ewrapper_io_tx_slow.v
 
  This file is part of the Parallella Project .

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
module ewrapper_io_tx_slow
  (/*AUTOARG*/
   // Outputs
   DATA_OUT_TO_PINS_P, DATA_OUT_TO_PINS_N, LCLK_OUT_TO_PINS_P,
   LCLK_OUT_TO_PINS_N,
   // Inputs
   CLK_IN, CLK_IN_90, CLK_DIV_IN, CLK_RESET, IO_RESET, elink_disable,
   DATA_OUT_FROM_DEVICE
   );
   
   //###########
   //# INPUTS
   //###########
   input        CLK_IN;     // Fast clock input from PLL/MMCM
   input        CLK_IN_90;  // Fast clock input with 90deg phase shift
   input        CLK_DIV_IN; // Slow clock input from PLL/MMCM
   input        CLK_RESET;
   input        IO_RESET;
   input        elink_disable;
   input [71:0] DATA_OUT_FROM_DEVICE;
      
   //#############
   //# OUTPUTS
   //#############
   output [8:0] DATA_OUT_TO_PINS_P;
   output [8:0] DATA_OUT_TO_PINS_N;
   output 	LCLK_OUT_TO_PINS_P;
   output 	LCLK_OUT_TO_PINS_N;

   //############
   //# REGS
   //############
   reg [1:0] 	 clk_cnt;
   reg 		 tx_coreclock_del_45;
   reg 		 tx_coreclock_del_135;
   reg [8:0] 	 clk_even_reg;
   reg [8:0] 	 clk_odd_reg;
   reg [71:0] 	 tx_in_sync;
   reg          tx_pedge_first;
   reg [3:0]    cycle_sel;
   
   //############
   //# WIRES
   //############
   wire 	txo_lclk;
   wire 	txo_lclk90;
   wire 	tx_coreclock;
   wire 	reset;

   wire [8:0] 	clk_even;
   wire [8:0] 	clk0_even;
   wire [8:0] 	clk1_even;
   wire [8:0] 	clk2_even;
   wire [8:0] 	clk3_even;
   wire [8:0] 	clk_odd;
   wire [8:0] 	clk0_odd;
   wire [8:0] 	clk1_odd;
   wire [8:0] 	clk2_odd;
   wire [8:0] 	clk3_odd;
   
   wire [71:0] 	tx_in;   
   wire [8:0] 	tx_out;
   wire 	tx_lclk_out;
   wire [8:0] 	DATA_OUT_TO_PINS_P;
   wire [8:0] 	DATA_OUT_TO_PINS_N;
   wire 	LCLK_OUT_TO_PINS_P;
   wire 	LCLK_OUT_TO_PINS_N;

   // Inversions for E16/E64 migration
`ifdef TARGET_E16
   wire     elink_invert = 1'b0;
`elsif TARGET_E64
   wire     elink_invert = 1'b1;
`endif
      
   /*AUTOINPUT*/
   /*AUTOWIRE*/
   
   assign reset         = IO_RESET;

   assign tx_in[71:0]  = DATA_OUT_FROM_DEVICE[71:0];
   assign txo_lclk     = CLK_IN;
   assign txo_lclk90   = CLK_IN_90;
   assign tx_coreclock = CLK_DIV_IN;

   //#################################################
   //# Synchronize incoming data to fast clock domain
   //#################################################

   always @ (posedge txo_lclk)
     if(tx_pedge_first)
       tx_in_sync <= elink_invert ? ~tx_in : tx_in;
   
   //################################
   //# Output Buffers Instantiation
   //################################

   OBUFTDS #(.IOSTANDARD (`IOSTD_ELINK))
   obufds_inst [8:0]
     (.O   (DATA_OUT_TO_PINS_P),
      .OB  (DATA_OUT_TO_PINS_N),
      .I   (tx_out),
      .T   ({1'b0, {8{elink_disable}}}));  // Frame is always enabled

   OBUFDS #(.IOSTANDARD (`IOSTD_ELINK))
   obufds_lclk_inst
     (.O   (LCLK_OUT_TO_PINS_P),
      .OB  (LCLK_OUT_TO_PINS_N),
      .I   (tx_lclk_out));
   
   //#############################
   //# ODDR instantiation
   //#############################
   
   ODDR #(
          .DDR_CLK_EDGE  ("SAME_EDGE"), 
		  .INIT          (1'b0),
          .SRTYPE        ("ASYNC"))
   oddr_inst [8:0] 
     (
      .Q  (tx_out),
      .C  (txo_lclk),
      .CE (1'b1),
      .D1 (clk_even_reg),
      .D2 (clk_odd_reg),
      .R  (reset),
      .S  (1'b0));

   ODDR #(
          .DDR_CLK_EDGE  ("SAME_EDGE"), 
	      .INIT          (1'b0),
          .SRTYPE        ("ASYNC"))
   oddr_lclk_inst
     (
      .Q  (tx_lclk_out),
      .C  (txo_lclk90),
      .CE (1'b1),
      .D1 (~elink_invert & ~elink_disable),
      .D2 (elink_invert & ~elink_disable),
      .R  (CLK_RESET),
      .S  (1'b0));
   
   //########################
   //# Data Serialization
   //########################

   always @ (posedge txo_lclk) begin
      clk_even_reg[8:0] <= clk_even[8:0];
      clk_odd_reg[8:0]  <= clk_odd[8:0];
   end
   
   mux4 #(18) mux4
     (// Outputs
      .out ({clk_even[8:0],clk_odd[8:0]}),
      // Inputs
      .in0 ({clk0_even[8:0],clk0_odd[8:0]}),
      .sel0 (cycle_sel[0]),
      .in1 ({clk1_even[8:0],clk1_odd[8:0]}),
      .sel1 (cycle_sel[1]),
      .in2 ({clk2_even[8:0],clk2_odd[8:0]}),
      .sel2 (cycle_sel[2]),
      .in3 ({clk3_even[8:0],clk3_odd[8:0]}),
      .sel3 (cycle_sel[3]));
   
   //#################################
   //# Serialization Cycle Counter
   //#################################

   always @ (posedge txo_lclk) begin

      tx_pedge_first <= tx_coreclock_del_45 & tx_coreclock_del_135;

      cycle_sel[0] <= tx_pedge_first;
      cycle_sel[3:1] <= cycle_sel[2:0];

   end
   
   //################################################################
   //# Posedge Detection of the Slow Clock in the Fast Clock Domain
   //################################################################

   always @ (negedge txo_lclk) begin
     tx_coreclock_del_45  <= tx_coreclock;
     tx_coreclock_del_135 <= tx_coreclock_del_45;
   end


   //##################################
   //# Data Alignment Channel-to-Byte
   //##################################
   
   assign clk0_even[8:0] ={tx_in_sync[71],tx_in_sync[63],tx_in_sync[55],
			   tx_in_sync[47],tx_in_sync[39],tx_in_sync[31],
                           tx_in_sync[23],tx_in_sync[15],tx_in_sync[7]};
   
   assign clk0_odd[8:0]  ={tx_in_sync[70],tx_in_sync[62],tx_in_sync[54],
			   tx_in_sync[46],tx_in_sync[38],tx_in_sync[30],
                           tx_in_sync[22],tx_in_sync[14],tx_in_sync[6]};
   
   assign clk1_even[8:0] ={tx_in_sync[69],tx_in_sync[61],tx_in_sync[53],
			   tx_in_sync[45],tx_in_sync[37],tx_in_sync[29],
                           tx_in_sync[21],tx_in_sync[13],tx_in_sync[5]};
   
   assign clk1_odd[8:0]  ={tx_in_sync[68],tx_in_sync[60],tx_in_sync[52],
			   tx_in_sync[44],tx_in_sync[36],tx_in_sync[28],
                           tx_in_sync[20],tx_in_sync[12],tx_in_sync[4]};
   
   assign clk2_even[8:0] ={tx_in_sync[67],tx_in_sync[59],tx_in_sync[51],
			   tx_in_sync[43],tx_in_sync[35],tx_in_sync[27],
                           tx_in_sync[19],tx_in_sync[11],tx_in_sync[3]};
   
   assign clk2_odd[8:0]  ={tx_in_sync[66],tx_in_sync[58],tx_in_sync[50],
			   tx_in_sync[42],tx_in_sync[34],tx_in_sync[26],
                           tx_in_sync[18],tx_in_sync[10],tx_in_sync[2]};
   
   assign clk3_even[8:0] ={tx_in_sync[65],tx_in_sync[57],tx_in_sync[49],
			   tx_in_sync[41],tx_in_sync[33],tx_in_sync[25],
                           tx_in_sync[17],tx_in_sync[9], tx_in_sync[1]};
   
   assign clk3_odd[8:0]  ={tx_in_sync[64],tx_in_sync[56],tx_in_sync[48],
			   tx_in_sync[40],tx_in_sync[32],tx_in_sync[24],
                           tx_in_sync[16],tx_in_sync[8], tx_in_sync[0]};

endmodule // ewrapper_io_tx_slow
