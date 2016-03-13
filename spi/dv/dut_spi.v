module dut(/*AUTOARG*/
   // Outputs
   dut_active, clkout, wait_out, access_out, packet_out,
   // Inputs
   clk1, clk2, nreset, vdd, vss, access_in, packet_in, wait_in
   );

   parameter UREGS = 13;   
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

   //DUT driven transaction
   output [N-1:0]    access_out;
   output [N*PW-1:0] packet_out;
   input [N-1:0]     wait_in;


   wire 	     clk;
   
   /*AUTOINPUT*/ 
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			m_mosi;			// From master of spi.v
   wire			m_sclk;			// From master of spi.v
   wire			m_ss;			// From master of spi.v
   wire			s_miso;			// From slave of spi.v
   wire			spi_irq;		// From master of spi.v, ...
   // End of automatics

   //###################
   // GLUE
   //###################
   assign clkout     = clk1;
   assign clk        = clk1;
   assign dut_active = 1'b1;

   //######################################################################
   //# DUT
   //######################################################################

   //drive through master, observe on slave
   
   spi #(.AW(AW),
	 .UREGS(UREGS)
	 )

   master  (.m_miso			(s_miso),
	    .master_mode		(1'b1),
	    .s_miso			(),	
	    .s_sclk			(1'b0),
	    .s_mosi			(1'b0),
	    .s_ss			(1'b1),
	    .wait_in			(1'b0),
	    .access_out			(),
	    .packet_out			(),
	    /*AUTOINST*/
	    // Outputs
	    .spi_irq			(spi_irq),
	    .wait_out			(wait_out),
	    .m_sclk			(m_sclk),
	    .m_mosi			(m_mosi),
	    .m_ss			(m_ss),
	    // Inputs
	    .nreset			(nreset),
	    .clk			(clk),
	    .access_in			(access_in),
	    .packet_in			(packet_in[PW-1:0]));
   
   spi #(.AW(AW),
	 .UREGS(UREGS)
	 )

   slave ( .s_sclk			(m_sclk),
	   .s_mosi			(m_mosi),
	   .s_ss			(m_ss),
	   .master_mode			(1'b0),
	   .access_in			(1'b0),
	   .packet_in			(),
	   .m_miso			(),
	   .m_sclk			(),
	   .m_mosi			(),
	   .m_ss			(),
	   .wait_out			(),
	  /*AUTOINST*/
	  // Outputs
	  .spi_irq			(spi_irq),
	  .access_out			(access_out),
	  .packet_out			(packet_out[PW-1:0]),
	  .s_miso			(s_miso),
	  // Inputs
	  .nreset			(nreset),
	  .clk				(clk),
	  .wait_in			(wait_in));
   
endmodule // dut

// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/hdl")
// End:

