//# REFERENCE: 
//# [0] https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus
//# [1] http://www.nxp.com/files/microcontrollers/doc/ref_manual/M68HC11RM.pdf
//# [2] http://www.atmel.com/images/doc32017.pdf
//# [3] https://www.adafruit.com/datasheets/1897_datasheet.pdf
//# [4] https://www.analog.com/media/en/technical-documentation/application-notes/56755538964965031881813AN_877.pdf?doc=AD9652.pdf

module spi (/*AUTOARG*/
   // Outputs
   reg_rdata, spi_irq, m_sclk, m_mosi, m_ss, s_miso,
   // Inputs
   nreset, clk, reg_access, reg_packet, m_miso, s_sclk, s_mosi, s_ss
   );

   //##################################################################
   //# INTERFACE
   //##################################################################

   parameter AW     = 32;         // data width of fifo
   parameter PW     = 2*AW+40;    // packet size
   parameter DEPTH  = 32;         // fifo depth

   //clk+reset
   input          nreset;         // asynchronous active low reset
   input 	  clk;            // write clock
   
   //register access
   input 	  reg_access;     // register access (read only)
   input [PW-1:0] reg_packet;     // data/address
   output [31:0]  reg_rdata;      // readback data

   //interrupt
   output 	  spi_irq;        // interrupt output

   //master spi
   output         m_sclk;         // master  clock
   output         m_mosi;         // master output
   output 	  m_ss;           // slave select
   input 	  m_miso;         // master input
   
   //slave spi
   input 	  s_sclk;         // slave clock
   input 	  s_mosi;         // slave input
   input 	  s_ss;           // slave select
   output 	  s_miso;         // slave output
   
   //##################################################################
   //# BODY
   //##################################################################

   /*AUTOINPUT*/
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			access;			// From spi_rx of spi_rx.v
   wire			cpha;			// From spi_regs of spi_regs.v
   wire			cpol;			// From spi_regs of spi_regs.v
   wire			miso;			// From spi_tx of spi_tx.v
   wire			mosi;			// From spi_tx of spi_tx.v
   wire [7:0]		rxdata;			// From spi_rx of spi_rx.v
   wire			sclk;			// From spi_tx of spi_tx.v
   wire			ss;			// From spi_tx of spi_tx.v
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
		  .sclk			(sclk),
		  .mosi			(mosi),
		  .miso			(miso),
		  .ss			(ss),
		  // Inputs
		  .nreset		(nreset),
		  .clk			(clk),
		  .access		(access),
		  .txdata		(txdata[7:0]),
		  .cpol			(cpol),
		  .cpha			(cpha));

   spi_rx spi_rx (/*AUTOINST*/
		  // Outputs
		  .access		(access),
		  .rxdata		(rxdata[7:0]),
		  // Inputs
		  .nreset		(nreset),
		  .clk			(clk),
		  .cpol			(cpol),
		  .cpha			(cpha),
		  .sclk			(sclk),
		  .mosi			(mosi),
		  .miso			(miso),
		  .ss			(ss));
   
   
endmodule // spi
