module etx_io (/*AUTOARG*/
   // Outputs
   txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n, txo_data_p,
   txo_data_n, tx_wr_wait, tx_rd_wait,
   // Inputs
   reset, txi_wr_wait_p, txi_wr_wait_n, txi_rd_wait_p, txi_rd_wait_n,
   tx_lclk_par, tx_lclk, tx_lclk_out, tx_frame_par, tx_data_par,
   ecfg_tx_enable, ecfg_tx_gpio_enable, ecfg_tx_clkdiv, ecfg_dataout
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
   input        tx_lclk_par;  // Slow lclk for parallel side (bit rate / 8)
   input        tx_lclk;      // High speed clock for serdesd (bit rate / 2)
   input        tx_lclk_out;  // High speed lclk output clock (90deg from tx_lclk)

   input [7:0]  tx_frame_par; // Parallel frame for serdes
   input [63:0] tx_data_par;  // Parallel data for serdes
   output       tx_wr_wait;
   output       tx_rd_wait;
   
   //#############
   //# Configuration bits
   //#############
   input         ecfg_tx_enable;     //enable signal for tx  
   input         ecfg_tx_gpio_enable;//forces tx wait pins to constants
   input [3:0]   ecfg_tx_clkdiv;     // TODO: Implement this
   input [8:0] 	 ecfg_dataout;       // frame & data for GPIO mode

   //############
   //# REGS
   //############
   reg [63:0] 	pdata;
   reg [7:0] 	pframe;
   reg [1:0]    txenb_sync;  
   reg [1:0] 	txgpio_sync;
   reg [1:0] 	txenb_out_sync;

   //############
   //# WIRES
   //############
   wire [7:0]    tx_data;    // High-speed serial data outputs
   wire [7:0]    tx_data_t;  // Tristate signal to OBUF's
   wire          tx_frame;   // serial frame signal
   wire          tx_lclk_buf;
   wire 	 txenb;   
   wire 	 txgpio;
   integer 	 n;
   //#############################
   //# Serializer instantiations
   //#############################  
   assign         txenb = txenb_sync[0];   
   assign         txgpio = txgpio_sync[0];

   // Sync these control bits into our domain
   always @ (posedge tx_lclk_par) 
     begin
	txenb_sync[1:0]  <= {ecfg_tx_enable, txenb_sync[1]};
	txgpio_sync[1:0] <= {ecfg_tx_gpio_enable, txgpio_sync[1]};      
	if(txgpio) 
	  begin
             pframe <= {8{ecfg_dataout[8]}};           
             for(n=0; n<8; n=n+1)
               pdata[n*8+7 -: 8] <= ecfg_dataout[7:0];	   
	  end else if(txenb) 
	    begin
               pframe[7:0]  <= tx_frame_par[7:0];
               pdata[63:0]  <= tx_data_par[63:0];         
	    end 
	  else 
	    begin	   
               pframe[7:0] <= 8'd0;
               pdata[63:0] <= 64'd0;	   
	    end
     end
   

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
             .CLKDIV(tx_lclk_par), // 1-bit input: Divided clock
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
             .RST(reset),   // 1-bit input: Reset
             .SHIFTIN1(1'b0),
             .SHIFTIN2(1'b0),
             .T1(~ecfg_tx_enable), //TODO: Which clock is this one??
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
        .CLKDIV(tx_lclk_par), // 1-bit input: Divided clock
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

   // sync the enable signal to the phase-shifted output clock
   always @ (posedge tx_lclk_out)
     txenb_out_sync[1:0] <= {txenb_out_sync[0],ecfg_tx_enable};
   
   ODDR 
     #(
       .DDR_CLK_EDGE  ("SAME_EDGE"), 
	   .INIT          (1'b0),
       .SRTYPE        ("ASYNC"))
   oddr_lclk_inst
     (
      .Q  (tx_lclk_buf),
      .C  (tx_lclk_out),
      .CE (1'b1),
      .D1 (txenb_out_sync[1]), //TODO: meaning of D1? Shouldn't this be on CE?
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
