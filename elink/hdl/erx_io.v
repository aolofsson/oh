
module erx_io (/*AUTOARG*/
   // Outputs
   rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p, rxo_rd_wait_n,
   rx_lclk_div4, rx_frame_par, rx_data_par, ecfg_rx_datain,
   // Inputs
   reset, rxi_lclk_p, rxi_lclk_n, rxi_frame_p, rxi_frame_n,
   rxi_data_p, rxi_data_n, rx_wr_wait, rx_rd_wait, ecfg_rx_enable,
   ecfg_rx_gpio_enable, ecfg_dataout
   );

   parameter IOSTD_ELINK = "LVDS_25";


   //###########
   //# eLink pins
   //###########
   input       reset;      // Reset (from ecfg)


   //###########
   //# eLink pins
   //###########
   input        rxi_lclk_p,  rxi_lclk_n;     //link rx clock input
   input        rxi_frame_p,  rxi_frame_n;   //link rx frame signal
   input [7:0]  rxi_data_p,   rxi_data_n;    //link rx data
   output       rxo_wr_wait_p,rxo_wr_wait_n; //link rx write pushback output
   output       rxo_rd_wait_p,rxo_rd_wait_n; //link rx read pushback output
  
   //#############
   //# Fabric interface, 1/8 bit rate of eLink
   //#############
   output        rx_lclk_div4; // Parallel clock output (slow)
   output [7:0]  rx_frame_par;
   output [63:0] rx_data_par;
   input         rx_wr_wait;
   input         rx_rd_wait;
   
   //#############
   //# Configuration bits
   //#############
   input         ecfg_rx_enable;         //enable signal for rx  
   input         ecfg_rx_gpio_enable;    //forces rx wait pins to constants
   input [1:0] 	 ecfg_dataout;           //rd_wait, wr_wait for GPIO mode
   output [8:0]  ecfg_rx_datain;         //gpio data in (data in and frame)

   //############
   //# REGS
   //############
   reg [63:0]    rx_data_par;    // output registers
   reg [7:0]     rx_frame_par;
   
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
	 ibufds_rxdata[7:0]
	   (.I     (rxi_data_p[7:0]),
        .IB    (rxi_data_n[7:0]),
        .O     (rx_data[7:0]));

   IBUFDS
	 #(.DIFF_TERM  ("TRUE"),     // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
	 ibufds_rx_frame
	   (.I     (rxi_frame_p),
        .IB    (rxi_frame_n),
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
     (.I          (rxi_lclk_p),
      .IB         (rxi_lclk_n),
      .O          (rx_lclk));

   BUFIO bufio_rxlclk
     (.I (rx_lclk),
      .O (rx_lclk_s));
   
   // BUFR generates the slow clock
   BUFR
     #(.SIM_DEVICE("7SERIES"),
     .BUFR_DIVIDE("4"))
   clkout_bufr
     (.O (rx_lclk_div4),
      .CE(1'b1),
      .CLR(1'b0),
      .I (rx_lclk));

   //#############################
   //# Deserializer instantiations
   //#############################

   wire [63:0]   rx_data_des;
   wire [7:0]    rx_frame_des;
   wire          rx_lclk_sn = ~rx_lclk_s;//TODO: Not important, only for MEMORY_QDR mode?
   
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
           .Q1(rx_data_des[i]),      // Last data in?
           .Q2(rx_data_des[i+8]),
           .Q3(rx_data_des[i+16]),
           .Q4(rx_data_des[i+24]),
           .Q5(rx_data_des[i+32]),
           .Q6(rx_data_des[i+40]),
           .Q7(rx_data_des[i+48]),
           .Q8(rx_data_des[i+56]),   // First data in?
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
           .CLKDIV(rx_lclk_div4), // 1-bit input: Divided clock
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
   ISERDESE2_rx_frame
     (
      .O(),  // 1-bit output: Combinatorial output
      // Q1 - Q8: 1-bit (each) output: Registered data outputs
      .Q1(rx_frame_des[0]),
      .Q2(rx_frame_des[1]),
      .Q3(rx_frame_des[2]),
      .Q4(rx_frame_des[3]),
      .Q5(rx_frame_des[4]),
      .Q6(rx_frame_des[5]),
      .Q7(rx_frame_des[6]),
      .Q8(rx_frame_des[7]),
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
      .CLKDIV(rx_lclk_div4), // 1-bit input: Divided clock
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
   reg [1:0]   rxgpio_sync;
   wire        rxgpio = rxgpio_sync[0];
   
   // Register outputs once for good measure, then mux in loopback data if enabled
   reg [63:0]  rx_data_reg;
   reg [7:0]   rx_frame_reg;

   wire        rxreset = reset | ~ecfg_rx_enable;
   
   always @ (posedge rx_lclk_div4 or posedge rxreset) 
     begin
	if(rxreset)
          rxenb_sync <= 'd0;
	else
          rxenb_sync <= {1'b1, rxenb_sync[1]};
     end
   
   always @ (posedge rx_lclk_div4) 
     begin      
	rxgpio_sync       <= {ecfg_rx_gpio_enable, rxgpio_sync[1]};      
	rx_data_reg[63:0] <= rx_data_des[63:0];
	rx_data_par[63:0] <= rx_data_reg[63:0];
	rx_frame_reg[7:0] <= rx_frame_des & {8{rxenb}} & {8{~rxgpio}};     
	rx_frame_par[7:0] <= rx_frame_reg[7:0];
     end

//#############
//# GPIO mode inputs
//#############
reg [8:0] datain_reg;
reg [8:0] ecfg_rx_datain;

   always @ (posedge rx_lclk_div4) 
     begin
      datain_reg[8]       <= rx_frame_par[0];
      datain_reg[7:0]     <= rx_data[7:0];
      ecfg_rx_datain[8:0] <= datain_reg[8:0];      
   end

   //#############
   //# Wait signals (asynchronous)
   //#############

   wire rd_wait = rxgpio ? ecfg_dataout[0]  : rx_rd_wait;
   wire wr_wait = rxgpio ? ecfg_dataout[1] : rx_wr_wait;

   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("SLOW")
       ) OBUFDS_RXWRWAIT
       (
        .O(rxo_wr_wait_p),
        .OB(rxo_wr_wait_n),
        .I(wr_wait)
        );
   
   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("SLOW")
       ) OBUFDS_RXRDWAIT
       (
        .O(rxo_rd_wait_p),
        .OB(rxo_rd_wait_n),
        .I(rd_wait)
        );
   
endmodule // erx_io


/*
  File: e_rx_io.v
 
  This file is part of the Parallella Project .

  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Fred Huettig <fred@adapteva.com>
  Contributed by Andreas Olofsson <fred@adapteva.com>

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
