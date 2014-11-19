/*
  File: eio_rx.v
 
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

module eio_rx (/*AUTOARG*/
   // Outputs
   RX_WR_WAIT_P, RX_WR_WAIT_N, RX_RD_WAIT_P, RX_RD_WAIT_N, rxlclk_p,
   rxframe_p, rxdata_p, ecfg_datain,
   // Inputs
   RX_LCLK_P, RX_LCLK_N, reset, ioreset, RX_FRAME_P, RX_FRAME_N,
   RX_DATA_P, RX_DATA_N, rx_wr_wait, rx_rd_wait, ecfg_rx_enable,
   ecfg_rx_gpio_mode, ecfg_rx_loopback_mode, ecfg_dataout, tx_wr_wait,
   tx_rd_wait, txlclk_p, loopback_data, loopback_frame
   );

   parameter IOSTD_ELINK = "LVDS_25";
   
   //###########
   //# eLink pins
   //###########
   input       RX_LCLK_P, RX_LCLK_N; // Differential clock from IOB
   input       reset;
   input       ioreset;

   input       RX_FRAME_P, RX_FRAME_N;  // Inputs from eLink
   input [7:0] RX_DATA_P, RX_DATA_N;

   output      RX_WR_WAIT_P, RX_WR_WAIT_N;
   output      RX_RD_WAIT_P, RX_RD_WAIT_N;

   //#############
   //# Fabric interface, 1/8 bit rate of eLink
   //#############
   output        rxlclk_p; // Parallel clock output
   output [7:0]  rxframe_p;
   output [63:0] rxdata_p;
   input         rx_wr_wait;
   input         rx_rd_wait;
   
   //#############
   //# Configuration bits
   //#############
   input         ecfg_rx_enable;         //enable signal for rx  
   input         ecfg_rx_gpio_mode;      //forces rx wait pins to constants
   input         ecfg_rx_loopback_mode;  //loops back tx to rx receiver (after serdes)
   input [10:0]  ecfg_dataout;           // rd_wait, wr_wait for GPIO mode
   output [10:0] ecfg_datain;
   input         tx_wr_wait, tx_rd_wait; // copies of wait signals for GPIO mode

   // Data & frame from TX module for loopback
   input         txlclk_p;   // TODO: Need to mux this in during loopback!
   input [63:0]  loopback_data;
   input [7:0]   loopback_frame;
   
   //############
   //# REGS
   //############
   reg [63:0]    rxdata_p;    // output registers
   reg [7:0]     rxframe_p;
   
   //############
   //# WIRES
   //############
   wire [7:0]    rx_data;  // High-speed serial data
   wire          rx_frame; // serial frame
   wire          serdes_reset;
   
   //################################
   //# Input Buffers Instantiation
   //################################
   IBUFDS
	 #(.DIFF_TERM  ("TRUE"),     // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
	 ibufds_rxdata[0:7]
	   (.I     (RX_DATA_P),
        .IB    (RX_DATA_N),
        .O     (rx_data));

   IBUFDS
	 #(.DIFF_TERM  ("TRUE"),     // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
	 ibufds_rxframe
	   (.I     (RX_FRAME_P),
        .IB    (RX_FRAME_N),
        .O     (rx_frame));

   //#####################
   //# Clock Buffers
   //#####################

   wire          rx_lclk;  // Single-ended clock
   wire          rx_lclk_s;  // Serial clock after BUFIO
   
   IBUFGDS
     #(.DIFF_TERM  ("TRUE"),   // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_rxlclk
     (.I          (RX_LCLK_P),
      .IB         (RX_LCLK_N),
      .O          (rx_lclk));

   BUFIO bufio_rxlclk
     (.I (rx_lclk),
      .O (rx_lclk_s));
   

   // BUFR generates the slow clock
   BUFR
     #(.SIM_DEVICE("7SERIES"),
     .BUFR_DIVIDE("4"))
   clkout_bufr
     (.O (rxlclk_p),
      .CE(1'b1),
      .CLR(1'b0),
      .I (rx_lclk));

   //#############################
   //# Deserializer instantiations
   //#############################

   wire [63:0]   rxdata_des;
   wire [7:0]    rxframe_des;
   wire          rx_lclk_sn = ~rx_lclk_s;
   
   genvar        i;
   generate for(i=0; i<8; i=i+1)
     begin : gen_serdes
        ISERDESE2 
          #(
            .DATA_RATE("DDR"),  // DDR, SDR
            .DATA_WIDTH(8),     // Parallel data width (2-8,10,14)
            .DYN_CLKDIV_INV_EN("FALSE"), // Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
            .DYN_CLK_INV_EN("FALSE"),  // Enable DYNCLKINVSEL inversion (FALSE, TRUE)
            // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
            .INIT_Q1(1'b0),
            .INIT_Q2(1'b0),
            .INIT_Q3(1'b0),
            .INIT_Q4(1'b0),
            .INTERFACE_TYPE("NETWORKING"),
            // MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
            .IOBDELAY("NONE"),  // NONE, BOTH, IBUF, IFD
            .NUM_CE(2),         // Number of clock enables (1,2)
            .OFB_USED("FALSE"), // Select OFB path (FALSE, TRUE)
            .SERDES_MODE("MASTER"),  // MASTER, SLAVE
            // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
            .SRVAL_Q1(1'b0),
            .SRVAL_Q2(1'b0),
            .SRVAL_Q3(1'b0),
            .SRVAL_Q4(1'b0)
            )
        ISERDESE2_rxdata
          (
           .O(),  // 1-bit output: Combinatorial output
           // Q1 - Q8: 1-bit (each) output: Registered data outputs
           .Q1(rxdata_des[i]),      // Last data in?
           .Q2(rxdata_des[i+8]),
           .Q3(rxdata_des[i+16]),
           .Q4(rxdata_des[i+24]),
           .Q5(rxdata_des[i+32]),
           .Q6(rxdata_des[i+40]),
           .Q7(rxdata_des[i+48]),
           .Q8(rxdata_des[i+56]),   // First data in?
           // SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
           .SHIFTOUT1(),
           .SHIFTOUT2(),
           .BITSLIP(1'b0), // 1-bit input: The BITSLIP pin performs a Bitslip operation 
           // synchronous to CLKDIV when asserted (active High). Subsequently, the data 
           // seen on the Q1 to Q8 output ports will shift, as in a barrel-shifter 
           // operation, one position every time Bitslip is invoked.  DDR operation is 
           // different from SDR.
           // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
           .CE1(1'b1),
           .CE2(1'b1),
           .CLKDIVP(1'b0),  // 1-bit input: TBD
           // Clocks: 1-bit (each) input: ISERDESE2 clock input ports
           .CLK(rx_lclk_s),   // 1-bit input: High-speed clock
           .CLKB(rx_lclk_sn),     // 1-bit input: High-speed secondary clock
           .CLKDIV(rxlclk_p), // 1-bit input: Divided clock
           .OCLK(1'b0),     // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY"
           // Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
           .DYNCLKDIVSEL(1'b0), // 1-bit input: Dynamic CLKDIV inversion
           .DYNCLKSEL(1'b0),    // 1-bit input: Dynamic CLK/CLKB inversion
           // Input Data: 1-bit (each) input: ISERDESE2 data input ports
           .D(rx_data[i]),      // 1-bit input: Data input
           .DDLY(1'b0),         // 1-bit input: Serial data from IDELAYE2
           .OFB(1'b0),          // 1-bit input: Data feedback from OSERDESE2
           .OCLKB(1'b0),   // 1-bit input: High speed negative edge output clock
           .RST(serdes_reset), // 1-bit input: Active high asynchronous reset
           // SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
           .SHIFTIN1(1'b0),
           .SHIFTIN2(1'b0)
           );
     end // block: gen_serdes
   endgenerate
   
   ISERDESE2 
     #(
       .DATA_RATE("DDR"),  // DDR, SDR
       .DATA_WIDTH(8),     // Parallel data width (2-8,10,14)
       .DYN_CLKDIV_INV_EN("FALSE"), // Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
       .DYN_CLK_INV_EN("FALSE"),  // Enable DYNCLKINVSEL inversion (FALSE, TRUE)
       // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
       .INIT_Q1(1'b0),
       .INIT_Q2(1'b0),
       .INIT_Q3(1'b0),
       .INIT_Q4(1'b0),
       .INTERFACE_TYPE("NETWORKING"),
       // MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
       .IOBDELAY("NONE"),  // NONE, BOTH, IBUF, IFD
       .NUM_CE(2),         // Number of clock enables (1,2)
       .OFB_USED("FALSE"), // Select OFB path (FALSE, TRUE)
       .SERDES_MODE("MASTER"),  // MASTER, SLAVE
       // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
       .SRVAL_Q1(1'b0),
       .SRVAL_Q2(1'b0),
       .SRVAL_Q3(1'b0),
       .SRVAL_Q4(1'b0)
       )
   ISERDESE2_rxframe
     (
      .O(),  // 1-bit output: Combinatorial output
      // Q1 - Q8: 1-bit (each) output: Registered data outputs
      .Q1(rxframe_des[0]),
      .Q2(rxframe_des[1]),
      .Q3(rxframe_des[2]),
      .Q4(rxframe_des[3]),
      .Q5(rxframe_des[4]),
      .Q6(rxframe_des[5]),
      .Q7(rxframe_des[6]),
      .Q8(rxframe_des[7]),
      // SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
      .SHIFTOUT1(),
      .SHIFTOUT2(),
      .BITSLIP(1'b0), // 1-bit input: The BITSLIP pin performs a Bitslip operation 
      // synchronous to CLKDIV when asserted (active High). Subsequently, the data 
      // seen on the Q1 to Q8 output ports will shift, as in a barrel-shifter 
      // operation, one position every time Bitslip is invoked.  DDR operation is 
      // different from SDR.
      // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
      .CE1(1'b1),
      .CE2(1'b1),
      .CLKDIVP(1'b0),  // 1-bit input: TBD
      // Clocks: 1-bit (each) input: ISERDESE2 clock input ports
      .CLK(rx_lclk_s),   // 1-bit input: High-speed clock
      .CLKB(rx_lclk_sn),     // 1-bit input: High-speed secondary clock
      .CLKDIV(rxlclk_p), // 1-bit input: Divided clock
      .OCLK(1'b0),     // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY"
      // Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
      .DYNCLKDIVSEL(1'b0), // 1-bit input: Dynamic CLKDIV inversion
      .DYNCLKSEL(1'b0),    // 1-bit input: Dynamic CLK/CLKB inversion
      // Input Data: 1-bit (each) input: ISERDESE2 data input ports
      .D(rx_frame),        // 1-bit input: Data input
      .DDLY(1'b0),         // 1-bit input: Serial data from IDELAYE2
      .OFB(1'b0),          // 1-bit input: Data feedback from OSERDESE2
      .OCLKB(1'b0),   // 1-bit input: High speed negative edge output clock
      .RST(serdes_reset), // 1-bit input: Active high asynchronous reset
      // SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
      .SHIFTIN1(1'b0),
      .SHIFTIN2(1'b0)
      );

   // Sync control signals into our RX clock domain
   reg [1:0]   rxenb_sync;
   wire        rxenb = rxenb_sync[0];
   assign      serdes_reset = ~rxenb;
   reg [1:0]   rxloopback_sync;
   wire        rxloopback = rxloopback_sync[0];
   reg [1:0]   rxgpio_sync;
   wire        rxgpio = rxgpio_sync[0];
   
   // Register outputs once for good measure, then mux in loopback data if enabled
   reg [63:0]  rxdata_reg;
   reg [7:0]   rxframe_reg;

   wire        rxreset = reset | ~ecfg_rx_enable;
   
   always @ (posedge rxlclk_p or posedge rxreset) begin
      if(rxreset)
        rxenb_sync <= 'd0;
      else
        rxenb_sync <= {1'b1, rxenb_sync[1]};
   end

   always @ (posedge rxlclk_p) begin
      
      rxloopback_sync <= {ecfg_rx_loopback_mode, rxloopback_sync[1]};
      rxgpio_sync <= {ecfg_rx_gpio_mode, rxgpio_sync[1]};
      
      rxdata_reg  <= rxdata_des;
      rxframe_reg <= rxframe_des & {8{rxenb}} & {8{~rxgpio}};

      if(rxloopback) begin
         rxdata_p  <= loopback_data;
         rxframe_p <= loopback_frame;
      end else begin
         rxdata_p  <= rxdata_reg;
         rxframe_p <= rxframe_reg;
      end
   end // always @ (posedge rxlclk_p)

   //#############
   //# GPIO mode inputs
   //#############
   reg [10:0] datain_reg;
   reg [10:0] ecfg_datain;

   always @ (posedge rxlclk_p) begin

      datain_reg[10]  <= tx_wr_wait;
      datain_reg[9]   <= tx_rd_wait;
      datain_reg[8]   <= rxframe_p[0];
      datain_reg[7:0] <= rxdata_p[7:0];
      ecfg_datain     <= datain_reg;
      
   end

   //#############
   //# Wait signals (asynchronous)
   //#############

   wire wr_wait = rxgpio ? ecfg_dataout[9]  : rx_wr_wait;
   wire rd_wait = rxgpio ? ecfg_dataout[10] : rx_rd_wait;

   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("SLOW")
       ) OBUFDS_RXWRWAIT
       (
        .O(RX_WR_WAIT_P),
        .OB(RX_WR_WAIT_N),
        .I(wr_wait)
        );
   
   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("SLOW")
       ) OBUFDS_RXRDWAIT
       (
        .O(RX_RD_WAIT_P),
        .OB(RX_RD_WAIT_N),
        .I(rd_wait)
        );
   
endmodule // eio_rx
