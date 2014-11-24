/*
  File: eio_tx.v
 
  This file is part of the Parallella Project .

  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Fred Huettig <fred@adapteva.com>

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

module eio_tx (/*AUTOARG*/
   // Outputs
   TX_LCLK_P, TX_LCLK_N, TX_FRAME_P, TX_FRAME_N, TX_DATA_P, TX_DATA_N,
   tx_wr_wait, tx_rd_wait,
   // Inputs
   reset, ioreset, TX_WR_WAIT_P, TX_WR_WAIT_N, TX_RD_WAIT_P,
   TX_RD_WAIT_N, txlclk_p, txlclk_s, txlclk_out, txframe_p, txdata_p,
   ecfg_tx_enable, ecfg_tx_gpio_mode, ecfg_tx_clkdiv, ecfg_dataout
   );

   parameter IOSTD_ELINK = "LVDS_25";
   
   //###########
   //# eLink pins
   //###########
   output       TX_LCLK_P, TX_LCLK_N; // Differential clock from PLL to eLink
   input        reset;
   input        ioreset;

   output       TX_FRAME_P, TX_FRAME_N;  // Outputs to eLink
   output [7:0] TX_DATA_P, TX_DATA_N;

   input        TX_WR_WAIT_P, TX_WR_WAIT_N;
   input        TX_RD_WAIT_P, TX_RD_WAIT_N;

   //#############
   //# Fabric interface, 1/8 bit rate of eLink
   //#############
   input        txlclk_p;   // Parallel clock in (bit rate / 8)
   input        txlclk_s;   // Serial clock in (bit rate / 2)
   input        txlclk_out; // "LCLK" source in, 90deg from lclk_s
   input [7:0]  txframe_p;
   input [63:0] txdata_p;
   output       tx_wr_wait;
   output       tx_rd_wait;
   
   //#############
   //# Configuration bits
   //#############
   input         ecfg_tx_enable;         //enable signal for rx  
   input         ecfg_tx_gpio_mode;      //forces rx wait pins to constants
   input [3:0]   ecfg_tx_clkdiv;         // TODO: Implement this
   input [10:0]  ecfg_dataout;           // frame & data for GPIO mode

   //############
   //# REGS
   //############
   
   //############
   //# WIRES
   //############
   wire [7:0]    tx_data;  // High-speed serial data outputs
   wire [7:0]    tx_data_t; // Tristate signal to OBUF's
   wire          tx_frame; // serial frame signal
   wire          tx_lclk;
   
   //#############################
   //# Serializer instantiations
   //#############################

   reg [63:0]   pdata;
   reg [7:0]    pframe;
   reg [1:0]    txenb_sync;
   wire         txenb = txenb_sync[0];
   reg [1:0]    txgpio_sync;
   wire         txgpio = txgpio_sync[0];
   integer      n;
   
      // Sync these control bits into our domain
   always @ (posedge txlclk_p) begin

      txenb_sync <= {ecfg_tx_enable, txenb_sync[1]};
      txgpio_sync <= {ecfg_tx_gpio_mode, txgpio_sync[1]};
      
      if(txgpio) begin

         pframe <= {8{ecfg_dataout[8]}};
         
         for(n=0; n<8; n=n+1)
           pdata[n*8+7 -: 8] <= ecfg_dataout[7:0];

      end else if(txenb) begin

         pframe <= txframe_p;
         pdata  <= txdata_p;
         
      end else begin

         pframe <= 8'd0;
         pdata <= 64'd0;

      end // else: !if(txgpio)

   end // always @ (posedge txlclk_p)
   
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
             // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
             .SHIFTOUT1(),
             .SHIFTOUT2(),
             .TBYTEOUT(),       // 1-bit output: Byte group tristate
             .TFB(),            // 1-bit output: 3-state control
             .TQ(tx_data_t[i]), // 1-bit output: 3-state control
             .CLK(txlclk_s),    // 1-bit input: High speed clock
             .CLKDIV(txlclk_p), // 1-bit input: Divided clock
             // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
             .D1(pdata[i+56]),  // First data out
             .D2(pdata[i+48]),
             .D3(pdata[i+40]),
             .D4(pdata[i+32]),
             .D5(pdata[i+24]),
             .D6(pdata[i+16]),
             .D7(pdata[i+8]),
             .D8(pdata[i]),   // Last data out
             .OCE(1'b1),      // 1-bit input: Output data clock enable
             .RST(ioreset),   // 1-bit input: Reset
             // SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
             .SHIFTIN1(1'b0),
             .SHIFTIN2(1'b0),
             // T1 - T4: 1-bit (each) input: Parallel 3-state inputs
             .T1(~ecfg_tx_enable),
             .T2(1'b0),
             .T3(1'b0),
             .T4(1'b0),
             .TBYTEIN(1'b0),   // 1-bit input: Byte group tristate
             .TCE(1'b1)          // 1-bit input: 3-state clock enable
             );     
     end // block: gen_serdes
   endgenerate
   
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
        .CLK(txlclk_s),    // 1-bit input: High speed clock
        .CLKDIV(txlclk_p), // 1-bit input: Divided clock
        // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
        .D1(pframe[7]),  // first data out
        .D2(pframe[6]),
        .D3(pframe[5]),
        .D4(pframe[4]),
        .D5(pframe[3]),
        .D6(pframe[2]),
        .D7(pframe[1]),
        .D8(pframe[0]),  // last data out
        .OCE(1'b1),      // 1-bit input: Output data clock enable
        .RST(ioreset),   // 1-bit input: Reset
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
   //# LClock Creation
   //################################

   ODDR 
     #(
       .DDR_CLK_EDGE  ("SAME_EDGE"), 
	   .INIT          (1'b0),
       .SRTYPE        ("ASYNC"))
   oddr_lclk_inst
     (
      .Q  (tx_lclk),
      .C  (txlclk_out),
      .CE (1'b1),
      .D1 (txenb),
      .D2 (1'b0),
      .R  (1'b0),
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
        .O   (TX_DATA_P),
        .OB  (TX_DATA_N),
        .I   (tx_data),
        .T   (tx_data_t)
        );

   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFDS_txframe
       (
        .O   (TX_FRAME_P),
        .OB  (TX_FRAME_N),
        .I   (tx_frame)
        );

   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFDS_lclk
       (
        .O   (TX_LCLK_P),
        .OB  (TX_LCLK_N),
        .I   (tx_lclk)
        );

   //################################
   //# Wait Input Buffers
   //################################

   IBUFDS
	 #(.DIFF_TERM  ("TRUE"),     // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_txwrwait
	 (.I     (TX_WR_WAIT_P),
      .IB    (TX_WR_WAIT_N),
      .O     (tx_wr_wait));

   // On Parallella this signal comes in single-ended
   assign tx_rd_wait = TX_RD_WAIT_P;
   
endmodule // eio_rx
