// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2 (lin64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
// Date        : Wed Nov  4 19:05:28 2015
// Host        : parallella running 64-bit Ubuntu 14.04.3 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/aolofsson/Work_all/oh/memory/ip/xilinx/fifo_async_104x32_stub.v
// Design      : fifo_async_104x32
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v12_0,Vivado 2015.2" *)
module fifo_async_104x32(wr_clk, wr_rst, rd_clk, rd_rst, din, wr_en, rd_en, dout, full, almost_full, empty, valid, prog_full)
/* synthesis syn_black_box black_box_pad_pin="wr_clk,wr_rst,rd_clk,rd_rst,din[103:0],wr_en,rd_en,dout[103:0],full,almost_full,empty,valid,prog_full" */;
  input wr_clk;
  input wr_rst;
  input rd_clk;
  input rd_rst;
  input [103:0]din;
  input wr_en;
  input rd_en;
  output [103:0]dout;
  output full;
  output almost_full;
  output empty;
  output valid;
  output prog_full;
endmodule
