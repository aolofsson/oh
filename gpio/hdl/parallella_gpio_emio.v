/*
  File: parallella_gpio_emio.v
 
  This file is part of the Parallella FPGA Reference Design.

  Copyright (C) 2013-2014 Adapteva, Inc.
  Contributed by Fred Huettig

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

// Implements GPIO pins from the PS/EMIO
// Works with 7010 (24 pins) or 7020 (48 pins) and
// either single-ended or differential IO

// Required global defines:
//   TARGET_7Z010 | TARGET_7Z020 - Choose FPGA
//   IOSTD_GPIO                  - Choose IO standard
//   [FEATURE_GPIO_DIFF]         - OPTIONAL to use differential IO,
//                                 otherwise SE

// Set # of GPIO pin-pairs based on target FPGA
`ifdef TARGET_7Z020
  `define GPIO_NUM 24
`elsif TARGET_7Z010
  `define  GPIO_NUM 12
`endif  // else throw an error!

// Number of GPIO signals
`ifdef FEATURE_GPIO_DIFF
 `define GPIO_SIGS `GPIO_NUM
`else
 `define GPIO_SIGS (2 * `GPIO_NUM)
`endif

module parallella_gpio_emio
  (/*AUTOARG*/
   // Outputs
   GPIO_I,
   // Inouts
   GPIO_P, GPIO_N,
   // Inputs
   GPIO_O, GPIO_T
   );

   inout [`GPIO_NUM-1:0] GPIO_P;
   inout [`GPIO_NUM-1:0] GPIO_N;

   output [63:0]  GPIO_I;
   input  [63:0]  GPIO_O;
   input  [63:0]  GPIO_T;

   wire [`GPIO_SIGS-1:0] gpio_i;
   assign GPIO_I[`GPIO_SIGS-1:0] = gpio_i;
   wire [`GPIO_SIGS-1:0] gpio_o
                         = GPIO_O[`GPIO_SIGS-1:0];
   wire [`GPIO_SIGS-1:0] gpio_t
                         = GPIO_T[`GPIO_SIGS-1:0];
   
`ifdef FEATURE_GPIO_DIFF

   IOBUFDS
     #(
       .DIFF_TERM("TRUE"),
       .IBUF_LOW_PWR("TRUE"),
       .IOSTANDARD(`IOSTD_GPIO),
       .SLEW("FAST")
       )
   GPIOBUF_DS [`GPIO_NUM-1:0]
     (
      .O(gpio_i),         // Buffer output
      .IO(GPIO_P),        // Diff_p inout (connect directly to top-level port)
      .IOB(GPIO_N),       // Diff_n inout (connect directly to top-level port)
      .I(gpio_o),         // Buffer input
      .T(gpio_t)          // 3-state enable input, high=input, low=output
      );

`else  // single-ended

   wire [`GPIO_NUM-1:0]  gpio_i_n, gpio_i_p;
   wire [`GPIO_NUM-1:0]  gpio_o_n, gpio_o_p;
   wire [`GPIO_NUM-1:0]  gpio_t_n, gpio_t_p;

   // Map P/N pins to single-ended signals
   genvar       m;
   generate
      for(m=0; m<`GPIO_NUM; m=m+2) begin : assign_se_sigs

         assign gpio_i[2*m]   = gpio_i_n[m];
         assign gpio_i[2*m+1] = gpio_i_n[m+1];
         assign gpio_i[2*m+2] = gpio_i_p[m];
         assign gpio_i[2*m+3] = gpio_i_p[m+1];

         assign gpio_o_n[m]   = gpio_o[2*m];
         assign gpio_o_n[m+1] = gpio_o[2*m+1];
         assign gpio_o_p[m]   = gpio_o[2*m+2];
         assign gpio_o_p[m+1] = gpio_o[2*m+3];
   
         assign gpio_t_n[m]   = gpio_t[2*m];
         assign gpio_t_n[m+1] = gpio_t[2*m+1];
         assign gpio_t_p[m]   = gpio_t[2*m+2];
         assign gpio_t_p[m+1] = gpio_t[2*m+3];

      end // block: assign_se_sigs
   endgenerate
   
   IOBUF
     #(
       .DRIVE(8), // Specify the output drive strength
       .IBUF_LOW_PWR("TRUE"), // Low Power - "TRUE", High Performance = "FALSE"
       .IOSTANDARD(`IOSTD_GPIO), // Specify the I/O standard
       .SLEW("SLOW") // Specify the output slew rate
       )
   GPIOBUF_SE_N [`GPIO_NUM-1:0]
     (
      .O(gpio_i_n), // Buffer output
      .IO(GPIO_N),  // Buffer inout port (connect directly to top-level port)
      .I(gpio_o_n), // Buffer input
      .T(gpio_t_n)  // 3-state enable input, high=input, low=output
      );

   IOBUF
     #(
       .DRIVE(8), // Specify the output drive strength
       .IBUF_LOW_PWR("TRUE"), // Low Power - "TRUE", High Performance = "FALSE"
       .IOSTANDARD(`IOSTD_GPIO), // Specify the I/O standard
       .SLEW("SLOW") // Specify the output slew rate
       )
   GPIOBUF_SE_P [`GPIO_NUM-1:0]
     (
      .O(gpio_i_p), // Buffer output
      .IO(GPIO_P),  // Buffer inout port (connect directly to top-level port)
      .I(gpio_o_p), // Buffer input
      .T(gpio_t_p)  // 3-state enable input, high=input, low=output
      );

`endif // !`ifdef FEATURE_GPIO_DIFF

   // Tie unused PS signals back to themselves
   genvar    n;
   generate for(n=`GPIO_SIGS; n<63; n=n+1) begin : unused_ps_sigs
      assign GPIO_I[n]
               = GPIO_O[n] &
                 ~GPIO_T[n];
   end
   endgenerate
   
endmodule // parallella_gpio_emio
