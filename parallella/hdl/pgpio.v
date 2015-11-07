
// Implements GPIO pins from the PS/EMIO
// Works with 7010 (24 pins) or 7020 (48 pins) and
// either single-ended or differential IO
module pgpio(/*AUTOARG*/
   // Outputs
   ps_gpio_i,
   // Inouts
   gpio_p, gpio_n,
   // Inputs
   ps_gpio_o, ps_gpio_t
   );
  
   parameter  NGPIO   = 24;  // 12 or 24
   parameter  NPS     = 64;  // signals for PS
   parameter  DIFF    = 0;   // 0= single ended
                             // 1= differential 
   
   inout [NGPIO-1:0]      gpio_p;
   inout [NGPIO-1:0]      gpio_n;

   output [NPS-1:0]  ps_gpio_i;
   input  [NPS-1:0]  ps_gpio_o;
   input  [NPS-1:0]  ps_gpio_t;

   genvar                    m;

   generate
      if( DIFF == 1 ) begin: gpio_diff         
         IOBUFDS
           #(
             .DIFF_TERM("TRUE"),
             .IBUF_LOW_PWR("TRUE"),
             .IOSTANDARD("LVDS_25"),
             .SLEW("FAST")
             )
         i_iodiff [NGPIO-1:0]
           (
            .O(ps_gpio_i),      // Buffer output
            .IO(gpio_p),        // Diff_p inout (connect directly to top-level port)
            .IOB(gpio_n),       // Diff_n inout (connect directly to top-level port)
            .I(ps_gpio_o),      // Buffer input
            .T(ps_gpio_t)       // 3-state enable input, high=input, low=output
            );
	 
      end else begin: gpio_cmos  // single-ended

         wire [NGPIO-1:0]  gpio_i_n, gpio_i_p;
         wire [NGPIO-1:0]  gpio_o_n, gpio_o_p;
         wire [NGPIO-1:0]  gpio_t_n, gpio_t_p;

         // Map P/N pins to single-ended signals
         for(m=0; m<NGPIO; m=m+2) begin : assign_se_sigs

            assign ps_gpio_i[2*m]   = gpio_i_n[m];
            assign ps_gpio_i[2*m+1] = gpio_i_n[m+1];
            assign ps_gpio_i[2*m+2] = gpio_i_p[m];
            assign ps_gpio_i[2*m+3] = gpio_i_p[m+1];

            assign gpio_o_n[m]   = ps_gpio_o[2*m];
            assign gpio_o_n[m+1] = ps_gpio_o[2*m+1];
            assign gpio_o_p[m]   = ps_gpio_o[2*m+2];
            assign gpio_o_p[m+1] = ps_gpio_o[2*m+3];
   
            assign gpio_t_n[m]   = ps_gpio_t[2*m];
            assign gpio_t_n[m+1] = ps_gpio_t[2*m+1];
            assign gpio_t_p[m]   = ps_gpio_t[2*m+2];
            assign gpio_t_p[m+1] = ps_gpio_t[2*m+3];

         end // block: assign_se_sigs
   
         IOBUF
           #(
             .DRIVE(8), // Specify the output drive strength
             .IBUF_LOW_PWR("TRUE"), // Low Power - "TRUE", High Performance = "FALSE"
             .IOSTANDARD("LVCMOS25"), // Specify the I/O standard
             .SLEW("SLOW") // Specify the output slew rate
             )
         i_iocmos_n [NGPIO-1:0]
           (
            .O(gpio_i_n), // Buffer output
            .IO(gpio_n),  // Buffer inout port (connect directly to top-level port)
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
         i_iocmos_p [NGPIO-1:0]
           (
            .O(gpio_i_p), // Buffer output
            .IO(gpio_p),  // Buffer inout port (connect directly to top-level port)
            .I(gpio_o_p), // Buffer input
            .T(gpio_t_p)  // 3-state enable input, high=input, low=output
            );

      end // block: GPIO_SE
   endgenerate
   
   // Tie off unused PS EMIO signals for now
   genvar i;
   generate
      for (i=NGPIO*2;i<NPS;i=i+1)
	assign ps_gpio_i[i] = 1'b0;
   endgenerate
   
      
endmodule // parallella_gpio_emio


