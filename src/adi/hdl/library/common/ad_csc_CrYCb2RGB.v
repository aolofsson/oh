// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
// Transmit HDMI, CrYCb to RGB conversion
// The multiplication coefficients are in 1.4.12 format
// The addition coefficients are in 1.12.12 format
// R = (+408.583/256)*Cr + (+298.082/256)*Y + ( 000.000/256)*Cb + (-222.921);
// G = (-208.120/256)*Cr + (+298.082/256)*Y + (-100.291/256)*Cb + (+135.576);
// B = ( 000.000/256)*Cr + (+298.082/256)*Y + (+516.412/256)*Cb + (-276.836);

`timescale 1ns/100ps

module ad_csc_CrYCb2RGB #(

  parameter   DELAY_DATA_WIDTH = 16) (

  // Cr-Y-Cb inputs

  input                   clk,
  input       [DW:0]      CrYCb_sync,
  input       [23:0]      CrYCb_data,

  // R-G-B outputs

  output      [DW:0]      RGB_sync,
  output      [23:0]      RGB_data);

  localparam  DW = DELAY_DATA_WIDTH - 1;

  // red

  ad_csc_1 #(.DELAY_DATA_WIDTH(DELAY_DATA_WIDTH)) i_csc_1_R (
    .clk (clk),
    .sync (CrYCb_sync),
    .data (CrYCb_data),
    .C1 (17'h01989),
    .C2 (17'h012a1),
    .C3 (17'h00000),
    .C4 (25'h10deebc),
    .csc_sync_1 (RGB_sync),
    .csc_data_1 (RGB_data[23:16]));

  // green

  ad_csc_1 #(.DELAY_DATA_WIDTH(1)) i_csc_1_G (
    .clk (clk),
    .sync (1'd0),
    .data (CrYCb_data),
    .C1 (17'h10d01),
    .C2 (17'h012a1),
    .C3 (17'h10644),
    .C4 (25'h0087937),
    .csc_sync_1 (),
    .csc_data_1 (RGB_data[15:8]));

  // blue

  ad_csc_1 #(.DELAY_DATA_WIDTH(1)) i_csc_1_B (
    .clk (clk),
    .sync (1'd0),
    .data (CrYCb_data),
    .C1 (17'h00000),
    .C2 (17'h012a1),
    .C3 (17'h02046),
    .C4 (25'h1114d60),
    .csc_sync_1 (),
    .csc_data_1 (RGB_data[7:0]));

endmodule

// ***************************************************************************
// ***************************************************************************
