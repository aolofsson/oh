module dut(/*AUTOARG*/
   // Outputs
   dut_active, clkout, wait_out, access_out, packet_out,
   // Inputs
   clk1, clk2, nreset, vdd, vss, access_in, packet_in, wait_in
   );

   parameter AW    = 32;
   parameter DW    = 32;
   parameter CW    = 2; 
   parameter IDW   = 12;
   parameter M_IDW = 6;
   parameter S_IDW = 12;
   parameter PW    = 104;     
   parameter N     = 32;
   
   //#######################################
   //# CLOCK AND RESET
   //#######################################
   input            clk1;
   input            clk2;
   input            nreset;
   input [N*N-1:0]  vdd;
   input 	    vss;
   output 	    dut_active;
   output 	    clkout;   

   //#######################################
   //#EMESH INTERFACE 
   //#######################################
   
   //Stimulus Driven Transaction
   input [N-1:0]     access_in;
   input [N*PW-1:0]  packet_in;
   output [N-1:0]    wait_out;

   //DUT driven transactoin
   output [N-1:0]    access_out;
   output [N*PW-1:0] packet_out;
   input [N-1:0]     wait_in;

   /*AUTOINPUT*/ 
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [AW-1:0]	gpio_dir;		// From gpio of gpio.v
   wire			gpio_irq;		// From gpio of gpio.v
   wire [AW-1:0]	gpio_out;		// From gpio of gpio.v
   // End of automatics

   wire 		clk;
   wire [AW-1:0] 	gpio_in;		// To gpio of gpio.v

   //######################################################################
   //DUT
   //######################################################################

   assign wait_out[N-1:0] = 'b0;
   assign dut_active      = 1'b1;
   assign clkout          = clk1;
   assign clk             = clk1;
   
   /*gpio AUTO_TEMPLATE (
	 .gpio_irq	 (gpio_irq),
         .gpio_\(.*\)    (gpio_\1[AW-1:0]),
    );
    */
   gpio #(.N(AW),
	  .AW(AW))
   gpio (.gpio_in			(gpio_out[AW-1:0]),
	 /*AUTOINST*/
	 // Outputs
	 .wait_out			(wait_out),
	 .access_out			(access_out),
	 .packet_out			(packet_out[PW-1:0]),
	 .gpio_out			(gpio_out[AW-1:0]),	 // Templated
	 .gpio_dir			(gpio_dir[AW-1:0]),	 // Templated
	 .gpio_irq			(gpio_irq),		 // Templated
	 // Inputs
	 .nreset			(nreset),
	 .clk				(clk),
	 .access_in			(access_in),
	 .packet_in			(packet_in[PW-1:0]),
	 .wait_in			(wait_in));
        
endmodule // dut

// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/hdl")
// End:

