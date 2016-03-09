module dut(/*AUTOARG*/
   // Outputs
   dut_active, wait_out, access_out, packet_out,
   // Inputs
   core_packet, core_access, clk, clk1, clk2, nreset, vdd, vss,
   clkout, access_in, packet_in, wait_in
   );

   parameter SREGS = 40;   
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

   /*AUTOINPUT*/ 
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		clk;			// To spi_master of spi_master.v, ...
   input		core_access;		// To spi_slave of spi_slave.v
   input [PW-1:0]	core_packet;		// To spi_slave of spi_slave.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			core_spi_access;	// From spi_slave of spi_slave.v
   wire [PW-1:0]	core_spi_packet;	// From spi_slave of spi_slave.v
   wire			core_spi_wait;		// From spi_slave of spi_slave.v
   wire			miso;			// From spi_slave of spi_slave.v
   wire			mosi;			// From spi_master of spi_master.v
   wire			sclk;			// From spi_master of spi_master.v
   wire [SREGS*8-1:0]	spi_regs;		// From spi_slave of spi_slave.v
   wire			ss;			// From spi_master of spi_master.v
   // End of automatics

   //###################
   // GLUE
   //###################
   assign clkout     = clk1;
   assign clk        = clk1;
   assign wait_out   = 1'b0;
   assign dut_active = 1'b1;

   //######################################################################
   //# DUT
   //######################################################################

   spi_master #(.AW(AW))
   spi_master  (/*AUTOINST*/
		// Outputs
		.sclk			(sclk),
		.mosi			(mosi),
		.ss			(ss),
		.wait_out		(wait_out),
		.access_out		(access_out),
		.packet_out		(packet_out[PW-1:0]),
		// Inputs
		.clk			(clk),
		.nreset			(nreset),
		.miso			(miso),
		.access_in		(access_in),
		.packet_in		(packet_in[PW-1:0]),
		.wait_in		(wait_in));
   
   spi_slave #(.AW(AW),
	       .SREGS(SREGS)
	       )
   spi_slave (/*AUTOINST*/
	      // Outputs
	      .spi_regs			(spi_regs[SREGS*8-1:0]),
	      .miso			(miso),
	      .core_spi_access		(core_spi_access),
	      .core_spi_packet		(core_spi_packet[PW-1:0]),
	      .core_spi_wait		(core_spi_wait),
	      // Inputs
	      .clk			(clk),
	      .nreset			(nreset),
	      .sclk			(sclk),
	      .mosi			(mosi),
	      .ss			(ss),
	      .core_access		(core_access),
	      .core_packet		(core_packet[PW-1:0]));

   
endmodule // dut

// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/hdl")
// End:

