//#############################################################################
//# Purpose: SPI top (configurable as master or slave)                        #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module spi #( parameter AW     = 32,    // address width
	      parameter PW     = 104,   // packet size
	      parameter UREGS  = 13     // number of user slave regs
	      )
   (//clk, reset, irq
    input 	    nreset, // asynch active low reset   
    input 	    clk, // core clock
    input 	    hw_en, // block enable pin
    output 	    spi_irq, // interrupt output
    //packet from core
    input 	    access_in, // access from core
    input [PW-1:0]  packet_in, // packet from core
    input 	    wait_in, // pushback from io   
    //packet to core
    output 	    access_out, // access to core
    output [PW-1:0] packet_out, // packet to core
    output 	    wait_out, // pushback from core
    //master io interface
    output 	    m_sclk, // master clock
    output 	    m_mosi, // master output
    output 	    m_ss, // slave select
    input 	    m_miso, // master input
    //slave io interface
    input 	    s_sclk, // slave clock
    input 	    s_mosi, // slave input
    input 	    s_ss, // slave select
    output 	    s_miso    // slave output
    );
   
   //###############
   //# LOCAL WIRES
   //###############

   /*AUTOINPUT*/  
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			m_access_out;		// From spi_master of spi_master.v
   wire [PW-1:0]	m_packet_out;		// From spi_master of spi_master.v
   wire			m_wait_out;		// From spi_master of spi_master.v
   wire			s_access_out;		// From spi_slave of spi_slave.v
   wire [PW-1:0]	s_packet_out;		// From spi_slave of spi_slave.v
   wire [511:0]		s_spi_regs;		// From spi_slave of spi_slave.v
   wire			s_wait_out;		// From spi_slave of spi_slave.v
   // End of automatics

   //###########################################################
   //# SPI SLACE
   //###########################################################
   
   /*spi_master AUTO_TEMPLATE (.clk	  (clk),
			       .nreset	  (nreset),
    			       .hw_en	  (hw_en),
                               .\(.*\)_in (\1_in[]),
                               .\(.*\)    (m_\1[]),
    );
    */
   
   spi_master #(.AW(AW),
		.PW(PW))
   spi_master (/*AUTOINST*/
	       // Outputs
	       .sclk			(m_sclk),		 // Templated
	       .mosi			(m_mosi),		 // Templated
	       .ss			(m_ss),			 // Templated
	       .wait_out		(m_wait_out),		 // Templated
	       .access_out		(m_access_out),		 // Templated
	       .packet_out		(m_packet_out[PW-1:0]),	 // Templated
	       // Inputs
	       .clk			(clk),			 // Templated
	       .nreset			(nreset),		 // Templated
	       .hw_en			(hw_en),		 // Templated
	       .miso			(m_miso),		 // Templated
	       .access_in		(access_in),		 // Templated
	       .packet_in		(packet_in[PW-1:0]),	 // Templated
	       .wait_in			(wait_in));		 // Templated
   
   //###########################################################
   //# SPI SLAVE
   //###########################################################
   
   /*spi_slave AUTO_TEMPLATE (.clk	 (clk),
                              .spi_irq	 (spi_irq),
			      .nreset	 (nreset),
                              .hw_en	 (hw_en),
                              .\(.*\)_in (\1_in[]),
                              .\(.*\)    (s_\1[]),
    );
    */
   
   spi_slave #(.AW(AW),
	       .PW(PW),
	       .UREGS(UREGS))
   spi_slave (/*AUTOINST*/
	      // Outputs
	      .spi_regs			(s_spi_regs[511:0]),	 // Templated
	      .spi_irq			(spi_irq),		 // Templated
	      .miso			(s_miso),		 // Templated
	      .access_out		(s_access_out),		 // Templated
	      .packet_out		(s_packet_out[PW-1:0]),	 // Templated
	      .wait_out			(s_wait_out),		 // Templated
	      // Inputs
	      .clk			(clk),			 // Templated
	      .nreset			(nreset),		 // Templated
	      .hw_en			(hw_en),		 // Templated
	      .sclk			(s_sclk),		 // Templated
	      .mosi			(s_mosi),		 // Templated
	      .ss			(s_ss),			 // Templated
	      .wait_in			(wait_in),		 // Templated
	      .access_in		(access_in),		 // Templated
	      .packet_in		(packet_in[PW-1:0]));	 // Templated
   
   //###########################################################
   //# EMESH MUX
   //###########################################################

   assign wait_out = s_wait_out | m_wait_out;
   
   emesh_mux #(.N(2),
	       .AW(AW),
	       .PW(PW))
   emesh_mux (// Outputs
	      .wait_out	   (),
	      .access_out  (access_out),
	      .packet_out  (packet_out[PW-1:0]),
	      // Inputs
	      .access_in   ({s_access_out,m_access_out}),
	      .packet_in   ({s_packet_out[PW-1:0],m_packet_out[PW-1:0]}),
	      .wait_in	   (wait_in)	      
	      );
   
endmodule // spi
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/hdl")
// End:

