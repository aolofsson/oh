module etx_io (/*AUTOARG*/
   // Outputs
   txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n, txo_data_p,
   txo_data_n, tx_wr_wait, tx_rd_wait,
   // Inputs
   reset, txi_wr_wait_p, txi_wr_wait_n, txi_rd_wait_p, txi_rd_wait_n,
   tx_lclk_div4, tx_lclk, tx_lclk90, tx_frame_par, tx_data_par
   );

   parameter IOSTD_ELINK = "LVDS_25";
   //###########
   //# reset
   //###########
   input        reset;              
   
   //###########
   //# eLink pins
   //###########
   output 	 txo_lclk_p, txo_lclk_n;       //tx clock (up to 500MHz)
   output        txo_frame_p, txo_frame_n;     //tx frame signal
   output [7:0]  txo_data_p, txo_data_n;       //tx data (dual data rate)
   input 	 txi_wr_wait_p,txi_wr_wait_n;  //tx write pushback
   input 	 txi_rd_wait_p, txi_rd_wait_n; //tx read pushback

   //#############
   //# Fabric interface
   //#############
   input        tx_lclk_div4;  // Slow lclk for parallel side (bit rate / 8)
   input        tx_lclk;       // High speed clock for serdesd (bit rate / 2)
   input        tx_lclk90;     // High speed lclk output clock (90deg from tx_lclk)

   input [7:0]  tx_frame_par; // Parallel frame for serdes
   input [63:0] tx_data_par;  // Parallel data for serdes
   output       tx_wr_wait;
   output       tx_rd_wait;
   
   //############
   //# REGS
   //############
   reg [63:0] 	pdata;
   reg [7:0] 	pframe;
   reg [1:0]    txenb_sync;  
   reg [1:0] 	txgpio_sync;
  

   //############
   //# WIRES
   //############
   wire [7:0]    tx_data;    // High-speed serial data outputs
   wire [7:0]    tx_data_t;  // Tristate signal to OBUF's
   wire          tx_frame;   // serial frame signal
   wire          tx_lclk_buf;
   integer 	 n;
   //#############################
   //# Serializer instantiations
   //#############################  
  
   //FRAME SERDES
   genvar        i;
   generate for(i=0; i<8; i=i+1)
     begin : gen_serdes
        OSERDESE2 
          #(
            .DATA_RATE_OQ("DDR"),  // DDR, SDR
            .DATA_RATE_TQ("BUF"),  // DDR, BUF, SDR
            .DATA_WIDTH(8),        // Parallel data width (2-8,10,14)
            .INIT_OQ(1'b0),        // Initial value of OQ output (1'b0,1'b1)
            .INIT_TQ(1'b1),        // Initial value of TQ output (1'b0,1'b1)
            .SERDES_MODE("MASTER"), // MASTER, SLAVE
            .SRVAL_OQ(1'b0),       // OQ output value when SR is used (1'b0,1'b1)
            .SRVAL_TQ(1'b1),       // TQ output value when SR is used (1'b0,1'b1)
            .TBYTE_CTL("FALSE"),   // Enable tristate byte operation (FALSE, TRUE)
            .TBYTE_SRC("FALSE"),   // Tristate byte source (FALSE, TRUE)
            .TRISTATE_WIDTH(1)     // 3-state converter width (1,4)
            ) OSERDESE2_txdata 
            (
             .OFB(),   // 1-bit output: Feedback path for data
             .OQ(tx_data[i]),     // 1-bit output: Data path output
             .SHIFTOUT1(),
             .SHIFTOUT2(),
             .TBYTEOUT(),       // 1-bit output: Byte group tristate
             .TFB(),            // 1-bit output: 3-state control
             .TQ(tx_data_t[i]), // 1-bit output: 3-state control
             .CLK(tx_lclk),      // 1-bit input: High speed clock
             .CLKDIV(tx_lclk_div4), // 1-bit input: Divided clock
             // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
             .D1(tx_data_par[i+56]),  // First data out
             .D2(tx_data_par[i+48]),
             .D3(tx_data_par[i+40]),
             .D4(tx_data_par[i+32]),
             .D5(tx_data_par[i+24]),
             .D6(tx_data_par[i+16]),
             .D7(tx_data_par[i+8]),
             .D8(tx_data_par[i]),   // Last data out
             .OCE(1'b1),      // 1-bit input: Output data clock enable
             .RST(reset),   // 1-bit input: Reset
             .SHIFTIN1(1'b0),
             .SHIFTIN2(1'b0),
             .T1(1'b0), //TODO: Which clock is this one??
             .T2(1'b0),
             .T3(1'b0),
             .T4(1'b0),
             .TBYTEIN(1'b0),   // 1-bit input: Byte group tristate
             .TCE(1'b1)          // 1-bit input: 3-state clock enable
             );     
     end // block: gen_serdes
   endgenerate

   //DATA SERDES
   OSERDESE2 
     #(
       .DATA_RATE_OQ("DDR"),  // DDR, SDR
       .DATA_RATE_TQ("SDR"),  // DDR, BUF, SDR
       .DATA_WIDTH(8),        // Parallel data width (2-8,10,14)
       .INIT_OQ(1'b0),        // Initial value of OQ output (1'b0,1'b1)
       .INIT_TQ(1'b0),        // Initial value of TQ output (1'b0,1'b1)
       .SERDES_MODE("MASTER"), // MASTER, SLAVE
       .SRVAL_OQ(1'b0),       // OQ output value when SR is used (1'b0,1'b1)
       .SRVAL_TQ(1'b0),       // TQ output value when SR is used (1'b0,1'b1)
       .TBYTE_CTL("FALSE"),   // Enable tristate byte operation (FALSE, TRUE)
       .TBYTE_SRC("FALSE"),   // Tristate byte source (FALSE, TRUE)
       .TRISTATE_WIDTH(1)     // 3-state converter width (1,4)
       ) OSERDESE2_tframe
       (
        .OFB(),   // 1-bit output: Feedback path for data
        .OQ(tx_frame),     // 1-bit output: Data path output
        // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
        .SHIFTOUT1(),
        .SHIFTOUT2(),
        .TBYTEOUT(),       // 1-bit output: Byte group tristate
        .TFB(),            // 1-bit output: 3-state control
        .TQ(),             // 1-bit output: 3-state control
        .CLK(tx_lclk),      // 1-bit input: High speed clock
        .CLKDIV(tx_lclk_div4), // 1-bit input: Divided clock
        // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
        .D1(tx_frame_par[7]),  // first data out
        .D2(tx_frame_par[6]),
        .D3(tx_frame_par[5]),
        .D4(tx_frame_par[4]),
        .D5(tx_frame_par[3]),
        .D6(tx_frame_par[2]),
        .D7(tx_frame_par[1]),
        .D8(tx_frame_par[0]),  // last data out
        .OCE(1'b1),      // 1-bit input: Output data clock enable
        .RST(reset),   // 1-bit input: Reset
        // SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
        .SHIFTIN1(1'b0),
        .SHIFTIN2(1'b0),
        // T1 - T4: 1-bit (each) input: Parallel 3-state inputs
        .T1(1'b0),
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),
        .TBYTEIN(1'b0),   // 1-bit input: Byte group tristate
        .TCE(1'b0)          // 1-bit input: 3-state clock enable
        );

   //################################
   //# LCLK Creation (and gating)
   //################################
   
   //Don't worry about glitching, no dynamic frequency switching
   //TODO: Enable dynamic frequency throttling (but why?)

   //TODO: FIX!!!!
   ODDR 
     #(
       .DDR_CLK_EDGE  ("SAME_EDGE"), 
	   .INIT          (1'b0),
       .SRTYPE        ("ASYNC"))
   oddr_lclk_inst
     (
      .Q  (tx_lclk_buf),
      .C  (tx_lclk90),
      .CE (1'b0),
      .D1 (1'b1),
      .D2 (1'b0),
      .R  (1'b0),//no reset
      .S  (1'b0));

   //################################
   //# Output Buffers
   //################################
   OBUFTDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFTDS_txdata [7:0]
       (
        .O   (txo_data_p),
        .OB  (txo_data_n),
        .I   (tx_data),
        .T   (tx_data_t)            //not sure about this??
        );

   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFDS_txframe
       (
        .O   (txo_frame_p),
        .OB  (txo_frame_n),
        .I   (tx_frame)
        );

   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFDS_lclk
       (
        .O   (txo_lclk_p),
        .OB  (txo_lclk_n),
        .I   (tx_lclk_buf)
        );

   //################################
   //# Wait Input Buffers
   //################################
   //TODO: make differential an option on both 
   
   IBUFDS
     #(.DIFF_TERM  ("TRUE"),     // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_txwrwait
     (.I     (txi_wr_wait_p),
      .IB    (txi_wr_wait_n),
      .O     (tx_wr_wait));
  
//TODO: Come up with cleaner defines for this
//Parallella and other platforms...   
`ifdef TODO
  IBUFDS
     #(.DIFF_TERM  ("TRUE"),     // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_txwrwait
     (.I     (txi_rd_wait_p),
      .IB    (txi_rd_wait_n),
      .O     (tx_rd_wait));
`else
   //On Parallella this signal comes in single-ended
   assign tx_rd_wait = txi_rd_wait_p;
`endif


   
endmodule // etx_io

/*
  This file is part of the Parallella Project .

  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Fred Huettig <fred@adapteva.com>
  Contributed by Andreas Olofsson <andreas@adapteva.com>
 
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
