

// Implements GPIO pins from the PS/EMIO
// Works with 7010 (24 pins) or 7020 (48 pins) and
// either single-ended or differential IO

module parallella_gpio_emio
  (/*AUTOARG*/
   // Outputs
   PS_GPIO_I,
   // Inouts
   GPIO_P, GPIO_N,
   // Inputs
   PS_GPIO_O, PS_GPIO_T
   );

   parameter  NUM_GPIO_PAIRS = 24;       // 12 or 24
   parameter  DIFF_GPIO      = 0;        // 0 or 1
   parameter  NUM_PS_SIGS    = 64;
   
   inout [NUM_GPIO_PAIRS-1:0] GPIO_P;
   inout [NUM_GPIO_PAIRS-1:0] GPIO_N;

   output [NUM_PS_SIGS-1:0]  PS_GPIO_I;
   input  [NUM_PS_SIGS-1:0]  PS_GPIO_O;
   input  [NUM_PS_SIGS-1:0]  PS_GPIO_T;

   genvar                    m;

   generate
      if( DIFF_GPIO == 1 ) begin: GPIO_DIFF
         
         IOBUFDS
           #(
             .DIFF_TERM("TRUE"),
             .IBUF_LOW_PWR("TRUE"),
             .IOSTANDARD("LVDS_25"),
             .SLEW("FAST")
             )
         GPIOBUF_DS [NUM_GPIO_PAIRS-1:0]
           (
            .O(PS_GPIO_I),      // Buffer output
            .IO(GPIO_P),        // Diff_p inout (connect directly to top-level port)
            .IOB(GPIO_N),       // Diff_n inout (connect directly to top-level port)
            .I(PS_GPIO_O),      // Buffer input
            .T(PS_GPIO_T)       // 3-state enable input, high=input, low=output
            );

      end else begin: GPIO_SE  // single-ended

         wire [NUM_GPIO_PAIRS-1:0]  gpio_i_n, gpio_i_p;
         wire [NUM_GPIO_PAIRS-1:0]  gpio_o_n, gpio_o_p;
         wire [NUM_GPIO_PAIRS-1:0]  gpio_t_n, gpio_t_p;

         // Map P/N pins to single-ended signals
         for(m=0; m<NUM_GPIO_PAIRS; m=m+2) begin : assign_se_sigs

            assign PS_GPIO_I[2*m]   = gpio_i_n[m];
            assign PS_GPIO_I[2*m+1] = gpio_i_n[m+1];
            assign PS_GPIO_I[2*m+2] = gpio_i_p[m];
            assign PS_GPIO_I[2*m+3] = gpio_i_p[m+1];

            assign gpio_o_n[m]   = PS_GPIO_O[2*m];
            assign gpio_o_n[m+1] = PS_GPIO_O[2*m+1];
            assign gpio_o_p[m]   = PS_GPIO_O[2*m+2];
            assign gpio_o_p[m+1] = PS_GPIO_O[2*m+3];
   
            assign gpio_t_n[m]   = PS_GPIO_T[2*m];
            assign gpio_t_n[m+1] = PS_GPIO_T[2*m+1];
            assign gpio_t_p[m]   = PS_GPIO_T[2*m+2];
            assign gpio_t_p[m+1] = PS_GPIO_T[2*m+3];

         end // block: assign_se_sigs
   
         IOBUF
           #(
             .DRIVE(8), // Specify the output drive strength
             .IBUF_LOW_PWR("TRUE"), // Low Power - "TRUE", High Performance = "FALSE"
             .IOSTANDARD("LVCMOS25"), // Specify the I/O standard
             .SLEW("SLOW") // Specify the output slew rate
             )
         GPIOBUF_SE_N [NUM_GPIO_PAIRS-1:0]
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
             .IOSTANDARD("LVCMOS25"), // Specify the I/O standard
             .SLEW("SLOW") // Specify the output slew rate
             )
         GPIOBUF_SE_P [NUM_GPIO_PAIRS-1:0]
           (
            .O(gpio_i_p), // Buffer output
            .IO(GPIO_P),  // Buffer inout port (connect directly to top-level port)
            .I(gpio_o_p), // Buffer input
            .T(gpio_t_p)  // 3-state enable input, high=input, low=output
            );

      end // block: GPIO_SE
   endgenerate
   
   // Tie unused PS signals back to themselves
   genvar    n;
   generate for(n=NUM_GPIO_PAIRS*2; n<48; n=n+1) begin : unused_ps_sigs
      assign PS_GPIO_I[n]
               = PS_GPIO_O[n] &
                 ~PS_GPIO_T[n];
   end
   endgenerate
   
endmodule // parallella_gpio_emio
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
