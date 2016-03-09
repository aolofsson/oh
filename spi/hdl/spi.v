//# REFERENCE: 
//# [0] https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus
//# [1] http://www.nxp.com/files/microcontrollers/doc/ref_manual/M68HC11RM.pdf
//# [2] http://www.atmel.com/images/doc32017.pdf
//# [3] https://www.adafruit.com/datasheets/1897_datasheet.pdf
//# [4] https://www.analog.com/media/en/technical-documentation/application-notes/56755538964965031881813AN_877.pdf?doc=AD9652.pdf

module spi (/*AUTOARG*/
   // Outputs
   spi_irq, access_out, packet_out, wait_out, sclk_out, mosi_out,
   ss_out, miso_out,
   // Inputs
   ss_slave, ss_master, sclk, rxdata, reg_packet, reg_access, mosi,
   miso, master_mode, access, nreset, clk, spi_clk, access_in,
   packet_in, wait_in, miso_in, sclk_in, mosi_in, ss_in
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
   input 	   spi_clk;    // spi clock (for master mode)
   output 	   spi_irq;    // interrupt output
   
   //packet from core
   input 	   access_in;  // access from core
   input [PW-1:0]  packet_in;  // packet from core
   input 	   wait_in;    // pushback from io   

   //packet to core
   output 	   access_out; // access to core
   output [PW-1:0] packet_out; // packet to core
   output 	   wait_out;   // pushback from core

   //master spi interface
   output          sclk_out;   // master clock
   output 	   mosi_out;   // master output
   output 	   ss_out;     // slave select
   input 	   miso_in;    // master input
   
   //slave spi interface
   input 	   sclk_in;    // slave clock
   input 	   mosi_in;    // slave input
   input 	   ss_in;      // slave select
   output 	   miso_out;   // slave output
   
   //##################################################################
   //# BODY
   //##################################################################

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		access;			// To spi_tx of spi_tx.v
   input		master_mode;		// To spi_rx of spi_rx.v
   input		miso;			// To spi_rx of spi_rx.v
   input		mosi;			// To spi_rx of spi_rx.v
   input		reg_access;		// To spi_regs of spi_regs.v
   input [PW-1:0]	reg_packet;		// To spi_regs of spi_regs.v
   input [7:0]		rxdata;			// To spi_regs of spi_regs.v
   input		sclk;			// To spi_rx of spi_rx.v
   input		ss_master;		// To spi_rx of spi_rx.v
   input		ss_slave;		// To spi_rx of spi_rx.v
   // End of automatics
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			cpha;			// From spi_regs of spi_regs.v
   wire			cpol;			// From spi_regs of spi_regs.v
   wire			mo;			// From spi_tx of spi_tx.v
   wire [31:0]		reg_rdata;		// From spi_regs of spi_regs.v
   wire			so;			// From spi_tx of spi_tx.v
   wire [7:0]		txdata;			// From spi_regs of spi_regs.v
   // End of automatics

   spi_regs spi_regs (/*AUTOINST*/
		      // Outputs
		      .reg_rdata	(reg_rdata[31:0]),
		      .cpol		(cpol),
		      .cpha		(cpha),
		      .txdata		(txdata[7:0]),
		      // Inputs
		      .nreset		(nreset),
		      .clk		(clk),
		      .reg_access	(reg_access),
		      .reg_packet	(reg_packet[PW-1:0]),
		      .rxdata		(rxdata[7:0]));
      
   spi_tx spi_tx (/*AUTOINST*/
		  // Outputs
		  .mo			(mo),
		  .so			(so),
		  // Inputs
		  .nreset		(nreset),
		  .clk			(clk),
		  .access		(access),
		  .txdata		(txdata[7:0]),
		  .cpol			(cpol),
		  .cpha			(cpha));

   spi_rx spi_rx (/*AUTOINST*/
		  // Outputs
		  .access_out		(access_out),
		  .packet_out		(packet_out[7:0]),
		  // Inputs
		  .clk			(clk),
		  .master_mode		(master_mode),
		  .sclk			(sclk),
		  .mosi			(mosi),
		  .miso			(miso),
		  .ss_master		(ss_master),
		  .ss_slave		(ss_slave));
   
   
endmodule // spi
