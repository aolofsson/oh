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
`timescale 1ns/1ps

module util_pulse_gen #(

  parameter   PULSE_WIDTH = 7,
  parameter   PULSE_PERIOD = 100000000)(         // t_period * clk_freq

  input               clk,
  input               rstn,

  input       [31:0]  pulse_period,
  input               pulse_period_en,

  output  reg         pulse
);

  // internal registers

  reg     [(PULSE_WIDTH-1):0]  pulse_width_cnt = {PULSE_WIDTH{1'b1}};
  reg     [31:0]               pulse_period_cnt = 32'h0;
  reg     [31:0]               pulse_period_d = 32'b0;

  wire                         end_of_period_s;

  // flop the desired period

  always @(posedge clk) begin
    pulse_period_d <= (pulse_period_en) ? pulse_period : PULSE_PERIOD;
  end

  // a free running pulse generator

  always @(posedge clk) begin
    if (rstn == 1'b0) begin
      pulse_period_cnt <= 32'h0;
    end else begin
      pulse_period_cnt <= (pulse_period_cnt == pulse_period_d) ? 32'b0 : (pulse_period_cnt + 1);
    end
  end

  assign  end_of_period_s = (pulse_period_cnt == pulse_period_d) ? 1'b1 : 1'b0;

  // generate pulse with a specified width

  always @(posedge clk) begin
    if (rstn == 1'b0) begin
      pulse_width_cnt <= 0;
      pulse <= 0;
    end else begin
      pulse_width_cnt <= (pulse == 1'b1) ? pulse_width_cnt + 1 : {PULSE_WIDTH{1'h0}};
      if(end_of_period_s == 1'b1) begin
        pulse <= 1'b1;
      end else if(pulse_width_cnt == {PULSE_WIDTH{1'b1}}) begin
        pulse <= 1'b0;
      end
    end
  end

endmodule
