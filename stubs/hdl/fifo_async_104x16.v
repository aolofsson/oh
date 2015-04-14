// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.3.1 (lin64) Build 1056140 Thu Oct 30 16:30:39 MDT 2014
// Date        : Wed Apr  8 20:38:45 2015
// Host        : parallella running 64-bit Ubuntu 14.04.2 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/aolofsson/Work_all/parallella-hw/fpga/vivado/junk/junk.srcs/sources_1/ip/fifo_async_103x16/fifo_async_103x16_stub.v
// Design      : fifo_async_103x16
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v12_0,Vivado 2014.3.1" *)
module fifo_async_104x16(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, empty, prog_full)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[103:0],wr_en,rd_en,dout[103:0],full,empty,prog_full" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [103:0]din;
  input wr_en;
  input rd_en;
  output [103:0]dout;
  output full;
  output empty;
  output prog_full;

   assign empty       =1'b0;
   assign prog_full   =1'b0;
   assign dout[103:0] =103'b0;
   assign full        =1'b0;
   

endmodule
