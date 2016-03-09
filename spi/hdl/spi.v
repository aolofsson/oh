module spi (/*AUTOARG*/
   // Outputs
   spi_irq, access_out, packet_out, wait_out, m_sclk, m_mosi, m_ss,
   s_miso,
   // Inputs
   nreset, clk, master_mode, access_in, packet_in, wait_in, m_miso,
   s_sclk, s_mosi, s_ss
   );

   //##################################################################
   //# INTERFACE
   //##################################################################

   parameter AW     = 32;      // data width of fifo
   parameter PW     = 2*AW+40; // packet size
   parameter DEPTH  = 32;      // fifo depth

   //clk, reset, irq
   input           nreset;     // asynch active low reset
   input 	   clk;        // core clock   
   input 	   master_mode;// master mode selector
      
   //interrupt output
   output 	   spi_irq;    // interrupt output
   
   //packet from core
   input 	   access_in;  // access from core
   input [PW-1:0]  packet_in;  // packet from core
   input 	   wait_in;    // pushback from io   

   //packet to core
   output 	   access_out; // access to core
   output [PW-1:0] packet_out; // packet to core
   output 	   wait_out;   // pushback from core

   //master io interface
   output          m_sclk;    // master clock
   output 	   m_mosi;    // master output
   output 	   m_ss;      // slave select
   input 	   m_miso;    // master input
   
   //slave io interface
   input 	   s_sclk;    // slave clock
   input 	   s_mosi;    // slave input
   input 	   s_ss;      // slave select
   output 	   s_miso;    // slave output

   
   /*spi_master AUTO_TEMPLATE (.clk	  (clk),
			       .nreset	  (nreset),
                               .\(.*\)_in (\1_in[]),
                               .\(.*\)    (m_\1[]),
    );
    */
   

   spi_master spi_master (/*AUTOINST*/
			  // Outputs
			  .sclk			(m_sclk),	 // Templated
			  .mosi			(m_mosi),	 // Templated
			  .ss			(m_ss),		 // Templated
			  .wait_out		(m_wait_out),	 // Templated
			  .access_out		(m_access_out),	 // Templated
			  .packet_out		(m_packet_out[PW-1:0]), // Templated
			  // Inputs
			  .clk			(clk),		 // Templated
			  .nreset		(nreset),	 // Templated
			  .miso			(m_miso),	 // Templated
			  .access_in		(access_in),	 // Templated
			  .packet_in		(packet_in[PW-1:0]), // Templated
			  .wait_in		(wait_in));	 // Templated
   

   /*spi_slave AUTO_TEMPLATE (.clk	  (clk),
			       .nreset	  (nreset),
                               .\(.*\)_in (\1_in[]),
                               .\(.*\)    (m_\1[]),
    );
    */
   
   spi_slave spi_slave (/*AUTOINST*/
			// Outputs
			.spi_regs	(m_spi_regs[SREGS*8-1:0]), // Templated
			.miso		(m_miso),		 // Templated
			.core_spi_access(m_core_spi_access),	 // Templated
			.core_spi_packet(m_core_spi_packet[PW-1:0]), // Templated
			.core_spi_wait	(m_core_spi_wait),	 // Templated
			// Inputs
			.clk		(clk),			 // Templated
			.nreset		(nreset),		 // Templated
			.sclk		(m_sclk),		 // Templated
			.mosi		(m_mosi),		 // Templated
			.ss		(m_ss),			 // Templated
			.core_access	(m_core_access),	 // Templated
			.core_packet	(m_core_packet[PW-1:0])); // Templated
   

   
endmodule // spi
