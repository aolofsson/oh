//#############################################################################
//# Purpose: SPI slave                                                        #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module spi_slave #( parameter UREGS = 13,  // number of spi slave regs   
		    parameter AW    = 32,  // addresss width
		    parameter PW    = 104 // packet width
		    )
   (
    //clk,reset, cfg
    input 	    clk, // core clock
    input 	    nreset, // async active low reset
    input 	    hw_en, // block enbale pin   
    output [511:0]  spi_regs, // all registers for control
    output 	    spi_irq, // interrupt
    //IO interface
    input 	    sclk, // spi clock
    input 	    mosi, // slave input
    input 	    ss, // slave select
    output 	    miso, // slave output
    // read request to core
    output 	    access_out, // valid transaction
    output [PW-1:0] packet_out, // data to core (from spi port)
    input 	    wait_in, // pushback from core (not implemented)
    // return from core
    input 	    access_in, // read response from core
    input [PW-1:0]  packet_in, // read response packet from core
    output 	    wait_out        // pushback (not used)
    );
   
   //###############
   //# LOCAL WIRES
   //###############
   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			cpha;			// From spi_slave_regs of spi_slave_regs.v
   wire			cpol;			// From spi_slave_regs of spi_slave_regs.v
   wire			irq_en;			// From spi_slave_regs of spi_slave_regs.v
   wire			lsbfirst;		// From spi_slave_regs of spi_slave_regs.v
   wire [5:0]		spi_addr;		// From spi_slave_io of spi_slave_io.v
   wire			spi_clk;		// From spi_slave_io of spi_slave_io.v
   wire			spi_en;			// From spi_slave_regs of spi_slave_regs.v
   wire [7:0]		spi_rdata;		// From spi_slave_regs of spi_slave_regs.v, ...
   wire [7:0]		spi_wdata;		// From spi_slave_io of spi_slave_io.v
   wire			spi_write;		// From spi_slave_io of spi_slave_io.v
   // End of automatics
   
   spi_slave_regs #(.AW(AW),
		    .PW(PW),
		    .UREGS(UREGS))
   spi_slave_regs (/*AUTOINST*/
		   // Outputs
		   .spi_rdata		(spi_rdata[7:0]),
		   .spi_en		(spi_en),
		   .cpol		(cpol),
		   .cpha		(cpha),
		   .lsbfirst		(lsbfirst),
		   .irq_en		(irq_en),
		   .spi_regs		(spi_regs[511:0]),
		   .wait_out		(wait_out),
		   // Inputs
		   .clk			(clk),
		   .nreset		(nreset),
		   .hw_en		(hw_en),
		   .spi_clk		(spi_clk),
		   .spi_wdata		(spi_wdata[7:0]),
		   .spi_write		(spi_write),
		   .spi_addr		(spi_addr[5:0]),
		   .access_out		(access_out),
		   .access_in		(access_in),
		   .packet_in		(packet_in[PW-1:0]));
   

   spi_slave_io #(.PW(PW))
   spi_slave_io (/*AUTOINST*/
		 // Outputs
		 .miso			(miso),
		 .spi_clk		(spi_clk),
		 .spi_write		(spi_write),
		 .spi_addr		(spi_addr[5:0]),
		 .spi_wdata		(spi_wdata[7:0]),
		 .spi_rdata		(spi_rdata[7:0]),
		 .access_out		(access_out),
		 .packet_out		(packet_out[PW-1:0]),
		 // Inputs
		 .sclk			(sclk),
		 .mosi			(mosi),
		 .ss			(ss),
		 .spi_en		(spi_en),
		 .cpol			(cpol),
		 .cpha			(cpha),
		 .lsbfirst		(lsbfirst),
		 .clk			(clk),
		 .nreset		(nreset),
		 .wait_in		(wait_in));
   
   
endmodule // spi_slave
