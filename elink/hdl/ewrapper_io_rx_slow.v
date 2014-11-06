/*
  File: ewrapper_io_rx_slow.v
 
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
module ewrapper_io_rx_slow (/*AUTOARG*/
   // Outputs
   CLK_DIV_OUT, DATA_IN_TO_DEVICE,
   // Inputs
   CLK_IN_P, CLK_IN_N, CLK_RESET, IO_RESET, DATA_IN_FROM_PINS_P,
   DATA_IN_FROM_PINS_N, BITSLIP
   );

   //###########
   //# INPUTS
   //###########
   input       CLK_IN_P; // Differential clock from IOB
   input       CLK_IN_N;
   input       CLK_RESET;
   input       IO_RESET;
   
   input [8:0] DATA_IN_FROM_PINS_P;
   input [8:0] DATA_IN_FROM_PINS_N;
   input       BITSLIP; 
   

   //#############
   //# OUTPUTS
   //#############
   output 	 CLK_DIV_OUT; // Slow clock output
   output [71:0] DATA_IN_TO_DEVICE;
   
   //############
   //# REGS
   //############
   reg [3:0] 	 clk_edge;
   reg           rx_pedge_first;
   reg [8:0] 	 clk_even_reg;
   reg [8:0] 	 clk_odd_reg;
   reg [8:0] 	 clk0_even;
   reg [8:0] 	 clk1_even;
   reg [8:0] 	 clk2_even;
   reg [8:0] 	 clk3_even;
   reg [8:0] 	 clk0_odd;
   reg [8:0] 	 clk1_odd;
   reg [8:0] 	 clk2_odd;
   reg [8:0] 	 clk3_odd;
   reg [71:0] 	 rx_out_sync_pos;
   reg           rx_outclock_del_45;
   reg           rx_outclock_del_135;
   reg [71:0] 	 rx_out;
      
   //############
   //# WIRES
   //############
   wire          reset;
   wire          rx_outclock;
   wire          rxi_lclk;
   wire [71:0] 	 rx_out_int;
   wire [8:0]    rx_in_t;
   wire [8:0] 	 rx_in;
   wire [8:0] 	 clk_even;
   wire [8:0] 	 clk_odd;
   wire [8:0]    iddr_q1;
   wire [8:0]    iddr_q2;
      
   // Inversions for E16/E64 migration
`ifdef TARGET_E16
   assign   rx_in = rx_in_t;
   assign   clk_even = iddr_q1;
   assign   clk_odd  = iddr_q2;
   `define CLKEDGE_DDR  "SAME_EDGE_PIPELINED"
`elsif TARGET_E64
   assign   rx_in = ~rx_in_t;
   assign   clk_even = iddr_q2;
   assign   clk_odd  = iddr_q1;
   `define CLKEDGE_DDR  "SAME_EDGE"
`endif

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   assign reset                   = IO_RESET;
   assign DATA_IN_TO_DEVICE[71:0] = rx_out[71:0];
   assign CLK_DIV_OUT             = rx_outclock;
   
   //################################
   //# Input Buffers Instantiation
   //################################
   IBUFDS
	 #(.DIFF_TERM  ("TRUE"),     // Differential termination
       .IOSTANDARD (`IOSTD_ELINK))
	 ibufds_inst[0:8]
	   (.I     (DATA_IN_FROM_PINS_P),
        .IB    (DATA_IN_FROM_PINS_N),
        .O     (rx_in_t));

   
   //#####################
   //# Clock Buffers
   //#####################

   IBUFGDS
     #(.DIFF_TERM  ("TRUE"),   // Differential termination
       .IOSTANDARD (`IOSTD_ELINK))
   ibufds_clk_inst
     (.I          (CLK_IN_P),
      .IB         (CLK_IN_N),
      .O          (rxi_lclk));

   // BUFR generates the slow clock
   BUFR
     #(.SIM_DEVICE("7SERIES"),
     .BUFR_DIVIDE("4"))
   clkout_buf_inst
     (.O (rx_outclock),
      .CE(1'b1),
      .CLR(CLK_RESET),
      .I (rxi_lclk));

   //#################################
   //# De-serialization Cycle Counter
   //#################################

   always @ (posedge rxi_lclk) begin
      if(rx_pedge_first)
        clk_edge <= 4'b1000;
      else
        clk_edge <= {clk_edge[2:0], clk_edge[3]};
   end

   //################################################################
   //# Posedge Detection of the Slow Clock in the Fast Clock Domain
   //################################################################
   
   always @ (negedge rxi_lclk) begin
      rx_outclock_del_45  <= rx_outclock;
      rx_outclock_del_135 <= rx_outclock_del_45;
      rx_pedge_first <= ~rx_outclock_del_45 & ~rx_outclock_del_135;
   end
   
   //#############################
   //# De-serialization Output
   //#############################

   // Synchronizing the clocks (fast to slow)
   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       rx_out_sync_pos <= 72'd0;
     else
       rx_out_sync_pos <= rx_out_int;

   always @ (posedge rx_outclock or posedge reset)
     if(reset)
       rx_out <= 72'd0;
     else
       rx_out <= rx_out_sync_pos;

   //#############################
   //# IDDR instantiation
   //#############################
   
   IDDR #(
	   .DDR_CLK_EDGE  (`CLKEDGE_DDR),
	   .SRTYPE ("ASYNC"))
     iddr_inst[0:8] (
            .Q1  (iddr_q1),
            .Q2  (iddr_q2),
		    .C   (rxi_lclk),
		    .CE  (1'b1),
		    .D   (rx_in),
		    .R   (1'b0),
		    .S   (1'b0));

   //#############################
   //# De-serialization Registers
   //#############################

   always @ (posedge rxi_lclk or posedge reset) begin
     if(reset) begin
        clk_even_reg <= 9'd0;
        clk_odd_reg  <= 9'd0;
        clk0_even    <= 9'd0;
        clk0_odd     <= 9'd0;
        clk1_even    <= 9'd0;
        clk1_odd     <= 9'd0;
        clk2_even    <= 9'd0;
        clk2_odd     <= 9'd0;
        clk3_even    <= 9'd0;
        clk3_odd     <= 9'd0;
        
     end else begin

	    clk_even_reg <= clk_even;
	    clk_odd_reg  <= clk_odd;

        if(clk_edge[0]) begin
           clk0_even <= clk_even_reg;
           clk0_odd  <= clk_odd_reg;
        end
      
        if(clk_edge[1]) begin
           clk1_even <= clk_even_reg;
           clk1_odd  <= clk_odd_reg;
        end
   
        if(clk_edge[2]) begin
           clk2_even <= clk_even_reg;
           clk2_odd  <= clk_odd_reg;
        end

        if(clk_edge[3]) begin
           clk3_even <= clk_even_reg;
           clk3_odd  <= clk_odd_reg;
        end

     end // else: !if(reset)
   end // always @ (posedge rxi_lclk or posedge reset)
   
   //#####################################
   //# De-serialization Data Construction
   //#####################################

   assign rx_out_int[71:64]={clk0_even[8],clk0_odd[8],clk1_even[8],clk1_odd[8],
			     clk2_even[8],clk2_odd[8],clk3_even[8],clk3_odd[8]};
   
   assign rx_out_int[63:56]={clk0_even[7],clk0_odd[7],clk1_even[7],clk1_odd[7],
			     clk2_even[7],clk2_odd[7],clk3_even[7],clk3_odd[7]};
   
   assign rx_out_int[55:48]={clk0_even[6],clk0_odd[6],clk1_even[6],clk1_odd[6],
			     clk2_even[6],clk2_odd[6],clk3_even[6],clk3_odd[6]};
   
   assign rx_out_int[47:40]={clk0_even[5],clk0_odd[5],clk1_even[5],clk1_odd[5],
			     clk2_even[5],clk2_odd[5],clk3_even[5],clk3_odd[5]};
   
   assign rx_out_int[39:32]={clk0_even[4],clk0_odd[4],clk1_even[4],clk1_odd[4],
			     clk2_even[4],clk2_odd[4],clk3_even[4],clk3_odd[4]};
   
   assign rx_out_int[31:24]={clk0_even[3],clk0_odd[3],clk1_even[3],clk1_odd[3],
			     clk2_even[3],clk2_odd[3],clk3_even[3],clk3_odd[3]};
   
   assign rx_out_int[23:16]={clk0_even[2],clk0_odd[2],clk1_even[2],clk1_odd[2],
			     clk2_even[2],clk2_odd[2],clk3_even[2],clk3_odd[2]};
   
   assign rx_out_int[15:8] ={clk0_even[1],clk0_odd[1],clk1_even[1],clk1_odd[1],
			     clk2_even[1],clk2_odd[1],clk3_even[1],clk3_odd[1]};
   
   assign rx_out_int[7:0]  ={clk0_even[0],clk0_odd[0],clk1_even[0],clk1_odd[0],
			     clk2_even[0],clk2_odd[0],clk3_even[0],clk3_odd[0]};
   
  
endmodule // dv_io_rx
