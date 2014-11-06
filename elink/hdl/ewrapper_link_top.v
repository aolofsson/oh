/*
  File: ewrapper_link_top.v
 
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
module ewrapper_link_top (/*AUTOARG*/
   // Outputs
   emesh_clk_inb, emesh_access_inb, emesh_write_inb,
   emesh_datamode_inb, emesh_ctrlmode_inb, emesh_dstaddr_inb,
   emesh_srcaddr_inb, emesh_data_inb, emesh_wr_wait_inb,
   emesh_rd_wait_inb, txo_data_p, txo_data_n, txo_frame_p,
   txo_frame_n, txo_lclk_p, txo_lclk_n, rxo_wr_wait_p, rxo_wr_wait_n,
   rxo_rd_wait_p, rxo_rd_wait_n, rxi_cclk_p, rxi_cclk_n,
   // Inputs
   reset, clkin_100, elink_disable, elink_cclk_enb, elink_clk_div,
   emesh_access_outb, emesh_write_outb, emesh_datamode_outb,
   emesh_ctrlmode_outb, emesh_dstaddr_outb, emesh_srcaddr_outb,
   emesh_data_outb, emesh_wr_wait_outb, emesh_rd_wait_outb,
   rxi_data_p, rxi_data_n, rxi_frame_p, rxi_frame_n, rxi_lclk_p,
   rxi_lclk_n, txi_wr_wait_p, txi_wr_wait_n, txi_rd_wait_p,
   txi_rd_wait_n, burst_en
   );

   //#############
   //# INPUTS
   //#############

   input 	   reset;
   input 	   clkin_100;

   //# Controls
   input       elink_disable;
   input       elink_cclk_enb;
   input [1:0] elink_clk_div;
   
   //# From the emesh interface
   input           emesh_access_outb;
   input           emesh_write_outb;
   input [1:0]     emesh_datamode_outb;
   input [3:0]     emesh_ctrlmode_outb;
   input [31:0]    emesh_dstaddr_outb;
   input [31:0]    emesh_srcaddr_outb;
   input [31:0]    emesh_data_outb;   
   input           emesh_wr_wait_outb; 
   input           emesh_rd_wait_outb; 

   //# From the chip (hsmc port)
   input [7:0] 	   rxi_data_p;
   input [7:0] 	   rxi_data_n;
   input 	   rxi_frame_p;
   input 	   rxi_frame_n;
   input 	   rxi_lclk_p;
   input 	   rxi_lclk_n;
   input 	   txi_wr_wait_p;
   input 	   txi_wr_wait_n;
   input 	   txi_rd_wait_p;
   input 	   txi_rd_wait_n;

   input 	   burst_en; // Burst enable control

   //###################
   //# OUTPUTS
   //###################

   //# To the emesh interface
   output 	   emesh_clk_inb;
   output 	   emesh_access_inb;
   output 	   emesh_write_inb;
   output [1:0]    emesh_datamode_inb;
   output [3:0]    emesh_ctrlmode_inb;
   output [31:0]   emesh_dstaddr_inb;
   output [31:0]   emesh_srcaddr_inb;
   output [31:0]   emesh_data_inb;  
   output 	   emesh_wr_wait_inb;  
   output 	   emesh_rd_wait_inb; 

   //# To the chip (hsmc port)
   output [7:0]    txo_data_p;
   output [7:0]    txo_data_n;
   output 	   txo_frame_p;
   output 	   txo_frame_n;
   output 	   txo_lclk_p;
   output 	   txo_lclk_n;
   output 	   rxo_wr_wait_p;
   output 	   rxo_wr_wait_n;
   output 	   rxo_rd_wait_p;
   output 	   rxo_rd_wait_n;

   output          rxi_cclk_p;
   output 	   rxi_cclk_n;
   
   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [71:0]          tx_in;                  // From ctrl_tx of ewrapper_link_transmitter.v
   // End of automatics

   //############
   //# REGS
   //############

   //############
   //# WIRES
   //############
   wire [63:0] 	   rxi_data_paral;
   wire [7:0] 	   rxi_frame_paral;
   wire [8:0] 	   rx_in_p;
   wire [8:0] 	   rx_in_n;
   wire [71:0] 	   rx_out;
   wire 	   rx_outclock;
   wire [8:0] 	   tx_out_p;
   wire [8:0] 	   tx_out_n;
   wire 	   rxi_cclk;
   wire 	   clk_fast_deg0;
   wire            clk_slow_deg0;
   wire 	   clk_fast_deg90;
   wire 	   rxo_wr_wait;
   wire 	   rxo_rd_wait;
   wire 	   txi_wr_wait;
   wire 	   txi_rd_wait;

   // Inversions for E16/E64 migration
`ifdef TARGET_E16
   wire     elink_invert = 1'b0;
`elsif TARGET_E64
   wire     elink_invert = 1'b1;
`endif
      
   //#######################
   //# LVDS RECEIVER
   //#######################

   assign rxi_data_paral[63:0] = rx_out[63:0];
   assign rxi_frame_paral[7:0] = rx_out[71:64];
   assign rx_in_p[8:0]         = {rxi_frame_p,rxi_data_p[7:0]};
   assign rx_in_n[8:0]         = {rxi_frame_n,rxi_data_n[7:0]};

   ewrapper_link_receiver  ctrl_rx
     (.rxi_data	        (rxi_data_paral[63:0]),
	  .rxi_frame        (rxi_frame_paral[7:0]),
	  .rxi_lclk         (rx_outclock),
	  /*AUTOINST*/
      // Outputs
      .rxo_wr_wait                      (rxo_wr_wait),
      .rxo_rd_wait                      (rxo_rd_wait),
      .emesh_clk_inb                    (emesh_clk_inb),
      .emesh_access_inb                 (emesh_access_inb),
      .emesh_write_inb                  (emesh_write_inb),
      .emesh_datamode_inb               (emesh_datamode_inb[1:0]),
      .emesh_ctrlmode_inb               (emesh_ctrlmode_inb[3:0]),
      .emesh_dstaddr_inb                (emesh_dstaddr_inb[31:0]),
      .emesh_srcaddr_inb                (emesh_srcaddr_inb[31:0]),
      .emesh_data_inb                   (emesh_data_inb[31:0]),
      // Inputs
      .reset                            (reset),
      .emesh_wr_wait_outb               (emesh_wr_wait_outb),
      .emesh_rd_wait_outb               (emesh_rd_wait_outb));

   ewrapper_io_rx_slow io_rx
     (// Outputs
	  .CLK_DIV_OUT        (rx_outclock),
	  .DATA_IN_TO_DEVICE  (rx_out[71:0]),
	  // Inputs
	  .CLK_IN_P	          (rxi_lclk_p),
	  .CLK_IN_N	          (rxi_lclk_n),
	  .CLK_RESET          (reset),
	  .IO_RESET           (reset),
	  .DATA_IN_FROM_PINS_P(rx_in_p[8:0]),
	  .DATA_IN_FROM_PINS_N(rx_in_n[8:0]),
	  .BITSLIP            (1'b0));
   
   // xilinx ISERDESE2 ip instantiation
   // !!! Make sure that the DIFF_TERM attribute of IBUFDS and IBUFGDS
   // !!! is set to TRUE inside ewrapper_io_rx.v
   //ewrapper_io_rx io_rx(// Inputs
//			.CLK_IN_P            (rxi_lclk_p),
//			.CLK_IN_N            (rxi_lclk_n),
//                      .DATA_IN_FROM_PINS_P (rx_in_p[8:0]),
//			.DATA_IN_FROM_PINS_N (rx_in_n[8:0]),
//			.BITSLIP             (1'b0),
//			.CLK_RESET           (reset),
//			.IO_RESET            (reset),
//                       // Outputs
//			.DATA_IN_TO_DEVICE   (rx_out[71:0]),
//			.CLK_DIV_OUT         (rx_outclock));
   
   //#######################
   //# LVDS TRANSMITTER
   //#######################

   assign txo_frame_p     = tx_out_p[8];
   assign txo_frame_n     = tx_out_n[8];
   assign txo_data_p[7:0] = tx_out_p[7:0];
   assign txo_data_n[7:0] = tx_out_n[7:0];

   ewrapper_link_transmitter ctrl_tx
     (.txo_lclk		(clk_slow_deg0),
	  /*AUTOINST*/
      // Outputs
      .emesh_wr_wait_inb                (emesh_wr_wait_inb),
      .emesh_rd_wait_inb                (emesh_rd_wait_inb),
      .tx_in                            (tx_in[71:0]),
      // Inputs
      .reset                            (reset),
      .emesh_clk_inb                    (emesh_clk_inb),
      .emesh_access_outb                (emesh_access_outb),
      .emesh_write_outb                 (emesh_write_outb),
      .emesh_datamode_outb              (emesh_datamode_outb[1:0]),
      .emesh_ctrlmode_outb              (emesh_ctrlmode_outb[3:0]),
      .emesh_dstaddr_outb               (emesh_dstaddr_outb[31:0]),
      .emesh_srcaddr_outb               (emesh_srcaddr_outb[31:0]),
      .emesh_data_outb                  (emesh_data_outb[31:0]),
      .txi_wr_wait                      (txi_wr_wait),
      .txi_rd_wait                      (txi_rd_wait),
      .burst_en                         (burst_en));

   // xilinx MMCME2_ADV ip instantiation
   io_clock_gen_600mhz io_clock_gen(// Inputs
			     .CLK_IN1      (clkin_100),
			     .RESET        (reset),
                             // Outputs
			     .CLK_OUT1     (rxi_cclk),
			     .CLK_OUT2     (clk_fast_deg0),
			     .CLK_OUT3     (clk_slow_deg0),
			     .CLK_OUT4     (clk_fast_deg90),
			     .LOCKED       ());
   
   ewrapper_io_tx_slow io_tx(// Outputs
			     .DATA_OUT_TO_PINS_P(tx_out_p[8:0]),
			     .DATA_OUT_TO_PINS_N(tx_out_n[8:0]),
			     .LCLK_OUT_TO_PINS_P(txo_lclk_p),
			     .LCLK_OUT_TO_PINS_N(txo_lclk_n),
			     // Inputs
			     .CLK_IN		(clk_fast_deg0),
			     .CLK_IN_90		(clk_fast_deg90),
			     .CLK_DIV_IN	(clk_slow_deg0),
			     .CLK_RESET		(reset),
			     .IO_RESET		(reset),
                 .elink_disable  (elink_disable),
			     .DATA_OUT_FROM_DEVICE(tx_in[71:0]));
   
   // xilinx ISERDESE2 ip instantiation
   //
//   ewrapper_io_tx io_tx(// Inputs
//			.CLK_IN                 (clk_fast_deg0),
//			.CLK_DIV_IN             (clk_slow_deg0),
//			.DATA_OUT_FROM_DEVICE   (tx_in[71:0]),
//			.CLK_RESET              (reset),
//			.IO_RESET               (reset),
//			// Outputs
//			.DATA_OUT_TO_PINS_P     (tx_out_p[8:0]),
//			.DATA_OUT_TO_PINS_N     (tx_out_n[8:0]));
   
//   io_clock_fwd io_clock_fwd(// Inputs
//			.CLK_IN                 (clk_fast_deg45),
//			.CLK_DIV_IN             (clk_slow_deg45),
//			.DATA_OUT_FROM_DEVICE   (8'b01010101),
//			.CLK_RESET              (reset),
//			.IO_RESET               (reset),
//			// Outputs
//			.DATA_OUT_TO_PINS_P     (txo_lclk_p),
//			.DATA_OUT_TO_PINS_N     (txo_lclk_n));

`ifdef FEATURE_CCLK_DIV

   // Create adjustable (but fast) CCLK
   wire     rxi_cclk_out;
   reg [8:1] cclk_pattern;
   reg [1:0] clk_div_sync;
   reg       enb_sync;
   
   always @ (posedge clk_slow_deg0) begin

      clk_div_sync <= elink_clk_div;
      enb_sync     <= elink_cclk_enb;

      if(enb_sync)
        case(clk_div_sync)
          2'b00:   cclk_pattern <= 8'b10101010;  // Divide by 1
          2'b01:   cclk_pattern <= 8'b11001100;  // Divide by 2
          2'b10:   cclk_pattern <= 8'b11110000;  // Divide by 4
          default: cclk_pattern <= {8{~cclk_pattern[1]}}; // /8
        endcase
      else
        cclk_pattern <= 8'b00000000;

   end // always @ (posedge clk_slow_deg0)
      
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
       ) OSERDESE2_inst 
       (
        .OFB(),             // 1-bit output: Feedback path for data
        .OQ(rxi_cclk_out),  // 1-bit output: Data path output
        .SHIFTOUT1(),       // SHIFTOUTn: 1-bit (each): Data output expansion
        .SHIFTOUT2(),
        .TBYTEOUT(),        // 1-bit output: Byte group tristate
        .TFB(),             // 1-bit output: 3-state control
        .TQ(),              // 1-bit output: 3-state control
        .CLK(rxi_cclk),     // 1-bit input: High speed clock
        .CLKDIV(clk_slow_deg0), // 1-bit input: Divided clock
        .D1(cclk_pattern[1]), // D1 - D8: Parallel data inputs (1-bit each)
        .D2(cclk_pattern[2]),
        .D3(cclk_pattern[3]),
        .D4(cclk_pattern[4]),
        .D5(cclk_pattern[5]),
        .D6(cclk_pattern[6]),
        .D7(cclk_pattern[7]),
        .D8(cclk_pattern[8]),
        .OCE(1'b1),         // 1-bit input: Output data clock enable
        .RST(reset),        // 1-bit input: Reset
        .SHIFTIN1(1'b0),    // SHIFTINn: Data input expansion (1-bit each)
        .SHIFTIN2(1'b0),
        .T1(1'b0),          // T1 - T4: Parallel 3-state inputs
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),
        .TBYTEIN(1'b0),     // 1-bit input: Byte group tristate
        .TCE(1'b0)          // 1-bit input: 3-state clock enable
        );

`else  // Non-dividable CCLK

   reg       enb_sync;

   always @ (posedge clk_slow_deg0)
      enb_sync     <= elink_cclk_enb;

   // The following does not result in timing failures,
   //  but doesn't seem glitch-safe
   assign rxi_cclk_out = rxi_cclk & enb_sync;
   
`endif
   
   // xilinx OBUFDS instantiation
   //
   OBUFDS
     #(.IOSTANDARD (`IOSTD_ELINK)) 
   obufds_cclk_inst
     (.O   (rxi_cclk_p),
	  .OB  (rxi_cclk_n),
	  .I   (rxi_cclk_out));
   
   OBUFDS 
     #(.IOSTANDARD (`IOSTD_ELINK))
   rxo_wr_wait_inst
     (.O   (rxo_wr_wait_p),
      .OB  (rxo_wr_wait_n),
      .I   (rxo_wr_wait ^ elink_invert));

   OBUFDS
     #(.IOSTANDARD (`IOSTD_ELINK))
   rxo_rd_wait_inst
     (.O   (rxo_rd_wait_p),
      .OB  (rxo_rd_wait_n),
      .I   (rxo_rd_wait ^ elink_invert));
   
   // xilinx IBUFDS instantiation

   wire [1:0] txi_wr_wait_buf;

   IBUFDS_DIFF_OUT
     #(.DIFF_TERM  ("TRUE"),             // Differential termination
       .IOSTANDARD (`IOSTD_ELINK))
   txi_wr_wait_inst
     (.I   (txi_wr_wait_p),
      .IB  (txi_wr_wait_n),
      .O   (txi_wr_wait_buf[0]),
      .OB  (txi_wr_wait_buf[1]));

   assign txi_wr_wait = elink_invert ? txi_wr_wait_buf[1] : txi_wr_wait_buf[0];
   
//   IBUFDS #(.DIFF_TERM  ("TRUE"),             // Differential termination
//            .IOSTANDARD (`IOSTD_ELINK)) txo_rd_wait_inst (.I   (txo_rd_wait_p),
//                                                       .IB  (txo_rd_wait_n),
//                                                       .O   (txo_rd_wait));

   //No need for differential buffer
   assign txi_rd_wait = txi_rd_wait_p ^ elink_invert;
   
   //#################################
   //# Chip Scope Instantiation
   //#################################

`ifdef kCHIPSCOPE_EWRAPPER

   wire [7:0] 	   cs_ila2_TRIG3;
   wire [7:0] 	   cs_ila3_TRIG3;
   wire [35:0] 	   CONTROL0;
   wire [35:0] 	   CONTROL1;
   wire [35:0] 	   CONTROL2;
   wire [35:0] 	   CONTROL3;
      
   assign cs_ila2_TRIG3[7:0] = {emesh_wr_wait_inb,
				emesh_rd_wait_inb,
				emesh_ctrlmode_outb[1:0],
				emesh_datamode_outb[1:0],
				emesh_write_outb,
				emesh_access_outb};   

   assign cs_ila3_TRIG3[7:0] = {emesh_wr_wait_outb,
				emesh_rd_wait_outb,
				emesh_ctrlmode_inb[1:0],
				emesh_datamode_inb[1:0],
				emesh_write_inb,
				emesh_access_inb};   
   
   cs_ila0 cs_ila0(.TRIG0   (tx_in[71:0]),
		   .CONTROL (CONTROL0[35:0]),
		   .CLK     (clk_slow_deg0));

   cs_ila0 cs_ila1(.TRIG0   (rx_out[71:0]),
		   .CONTROL (CONTROL1[35:0]),
		   .CLK     (emesh_clk_inb));

   cs_ila1 cs_ila2(.TRIG0   (emesh_dstaddr_outb[31:0]),
		   .TRIG1   (emesh_data_outb[31:0]),
		   .TRIG2   (emesh_srcaddr_outb[31:0]),
		   .TRIG3   (cs_ila2_TRIG3[7:0]),
		   .CONTROL (CONTROL2[35:0]),
		   .CLK     (emesh_clk_inb));

   cs_ila1 cs_ila3(.TRIG0   (emesh_dstaddr_inb[31:0]),
		   .TRIG1   (emesh_data_inb[31:0]),
		   .TRIG2   (emesh_srcaddr_inb[31:0]),
		   .TRIG3   (cs_ila3_TRIG3[7:0]),
		   .CONTROL (CONTROL3[35:0]),
		   .CLK     (emesh_clk_inb));

   cs_icon cs_icon(.CONTROL0 (CONTROL0[35:0]),
		   .CONTROL1 (CONTROL1[35:0]),
		   .CONTROL2 (CONTROL2[35:0]),
		   .CONTROL3 (CONTROL3[35:0]));
`endif // kCHIPSCOPE_EWRAPPER
      
endmodule // ewrapper_link_top
