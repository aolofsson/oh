module dut(/*AUTOARG*/
   // Outputs
   dut_active, wait_out, access_out, packet_out,
   // Inputs
   clk, nreset, vdd, vss, access_in, packet_in, wait_in
   );

   parameter AW    = 32;
   parameter DW    = 32;
   parameter CW    = 2; 
   parameter IDW   = 12;
   parameter M_IDW = 6;
   parameter S_IDW = 12;
   parameter PW    = 104;     
   parameter N     = 1;
   
   //#######################################
   //# CLOCK AND RESET
   //#######################################
   input            clk;
   input            nreset;
   input [N*N-1:0]  vdd;
   input 	    vss;
   output 	    dut_active;
   
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
   wire [AW-1:0]	gpio_en;		// From gpio of gpio.v
   wire [AW-1:0]	gpio_ilat;		// From gpio of gpio.v
   wire			gpio_irq;		// From gpio of gpio.v
   wire [AW-1:0]	gpio_out;		// From gpio of gpio.v
   wire [31:0]		reg_rdata;		// From gpio of gpio.v
   // End of automatics

   wire [AW-1:0] 	gpio_in;		// To gpio of gpio.v
   reg [N-1:0] 		access_out;

   //######################################################################
   //DUT
   //######################################################################

   assign gpio_in[AW-1:0] = 32'h87654321;
   assign wait_out[N-1:0] = 'b0;
   assign dut_active      = 1'b1;
   
   always @ (posedge clk)
     access_out[0] <= access_in[0] & ~packet_in[0];

   emesh2packet e2p (// Outputs
		     .packet_out	(packet_out[PW-1:0]),
		     // Inputs
		     .write_out		(1'b0),
		     .datamode_out	(2'b10),
		     .ctrlmode_out	(5'b0),
		     .dstaddr_out	({(AW){1'b0}}),
		     .data_out		(reg_rdata[AW-1:0]),
		     .srcaddr_out	({(AW){1'b0}})
		     );

   /*gpio AUTO_TEMPLATE(.gpio_irq     (gpio_irq),
                        .gpio_\(.*\)  (gpio_\1[AW-1:0]),
    );
   */
   gpio #(.N(AW))
   gpio (.reg_access			(access_in[0]),
	 .reg_packet			(packet_in[PW-1:0]),
	 .gpio_in			(gpio_in[AW-1:0]),
	 /*AUTOINST*/
	 // Outputs
	 .reg_rdata			(reg_rdata[31:0]),
	 .gpio_out			(gpio_out[AW-1:0]),	 // Templated
	 .gpio_en			(gpio_en[AW-1:0]),	 // Templated
	 .gpio_irq			(gpio_irq),		 // Templated
	 .gpio_ilat			(gpio_ilat[AW-1:0]),	 // Templated
	 // Inputs
	 .nreset			(nreset),
	 .clk				(clk));
        
endmodule // dut

// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/hdl")
// End:

