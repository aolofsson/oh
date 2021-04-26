//#############################################################################
//# Purpose: "Mini-IO" (MIO)                                                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################
module mio #( parameter IOW     = 64,        // IO width
	      parameter AW      = 32,        // address width
	      parameter PW      = 104,       // emesh packet width
	      parameter DEF_CFG  = 18'h0010, // default config   
	      parameter DEF_CLK  = 7,        // clock divider   
	      parameter TARGET  = "GENERIC"  // GENERIC,XILINX,ALTERA,GENERIC,ASIC
	      )
   (// reset, clk, config
    input 	     clk, // main core clock   
    input 	     nreset, // async active low reset
    // io chip interface
    output 	     tx_clk, // phase shited io_clk   
    output 	     tx_access, // access signal for IO
    output [IOW-1:0] tx_packet, // packet for IO
    input 	     tx_wait, // pushback from IO
    input 	     rx_clk, // rx clock
    input 	     rx_access, // rx access
    input [IOW-1:0]  rx_packet, // rx packet
    output 	     rx_wait, // pushback from IO
    // mesh interface
    input 	     access_in, // access for tx
    input [PW-1:0]   packet_in, // access for tx
    output 	     wait_out, // access from tx fifo
    output 	     access_out, // access from rx
    output [PW-1:0]  packet_out, // packet from rx
    input 	     wait_in, // pushback for rx fifo
    // register interface
    input 	     reg_access_in, // config register access
    input [PW-1:0]   reg_packet_in, // config register packet
    output 	     reg_wait_out, // pushback by register read
    output 	     reg_access_out,// config readback
    output [PW-1:0]  reg_packet_out,// config reacback packet
    input 	     reg_wait_in   // pushback for readback
    );      

   // local wires
   wire 	     io_clk;
   // End of automatics
   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			amode;			// From mio_regs of mio_regs.v
   wire			clkchange;		// From mio_regs of mio_regs.v
   wire [7:0]		clkdiv;			// From mio_regs of mio_regs.v
   wire [15:0]		clkphase0;		// From mio_regs of mio_regs.v
   wire [15:0]		clkphase1;		// From mio_regs of mio_regs.v
   wire [4:0]		ctrlmode;		// From mio_regs of mio_regs.v
   wire [1:0]		datamode;		// From mio_regs of mio_regs.v
   wire			ddr_mode;		// From mio_regs of mio_regs.v
   wire			dmode;			// From mio_regs of mio_regs.v
   wire [AW-1:0]	dstaddr;		// From mio_regs of mio_regs.v
   wire			emode;			// From mio_regs of mio_regs.v
   wire			framepol;		// From mio_regs of mio_regs.v
   wire [1:0]		iowidth;		// From mio_regs of mio_regs.v
   wire			lsbfirst;		// From mio_regs of mio_regs.v
   wire			rx_empty;		// From mrx of mrx.v
   wire			rx_en;			// From mio_regs of mio_regs.v
   wire			rx_full;		// From mrx of mrx.v
   wire			rx_prog_full;		// From mrx of mrx.v
   wire			tx_empty;		// From mtx of mtx.v
   wire			tx_en;			// From mio_regs of mio_regs.v
   wire			tx_full;		// From mtx of mtx.v
   wire			tx_prog_full;		// From mtx of mtx.v
   // End of automatics
     
   //################################
   //# TRANSMIT
   //################################  
   
   mtx #(.IOW(IOW),
	 .AW(AW),
	 .PW(PW),
	 .TARGET(TARGET))
   mtx (.io_clk				(io_clk),
	/*AUTOINST*/
	// Outputs
	.tx_empty			(tx_empty),
	.tx_full			(tx_full),
	.tx_prog_full			(tx_prog_full),
	.wait_out			(wait_out),
	.tx_access			(tx_access),
	.tx_packet			(tx_packet[IOW-1:0]),
	// Inputs
	.clk				(clk),
	.nreset				(nreset),
	.tx_en				(tx_en),
	.ddr_mode			(ddr_mode),
	.lsbfirst			(lsbfirst),
	.emode				(emode),
	.iowidth			(iowidth[1:0]),
	.access_in			(access_in),
	.packet_in			(packet_in[PW-1:0]),
	.tx_wait			(tx_wait));

   //################################
   //# RECEIVE
   //################################  
   
   mrx #(.IOW(IOW),
	 .AW(AW),
	 .PW(PW),
	 .TARGET(TARGET))
   mrx (/*AUTOINST*/
	// Outputs
	.rx_empty			(rx_empty),
	.rx_full			(rx_full),
	.rx_prog_full			(rx_prog_full),
	.rx_wait			(rx_wait),
	.access_out			(access_out),
	.packet_out			(packet_out[PW-1:0]),
	// Inputs
	.clk				(clk),
	.nreset				(nreset),
	.ddr_mode			(ddr_mode),
	.iowidth			(iowidth[1:0]),
	.amode				(amode),
	.ctrlmode			(ctrlmode[4:0]),
	.datamode			(datamode[1:0]),
	.dstaddr			(dstaddr[AW-1:0]),
	.emode				(emode),
	.rx_clk				(rx_clk),
	.rx_access			(rx_access),
	.rx_packet			(rx_packet[IOW-1:0]),
	.wait_in			(wait_in));
   
   //################################
   //# MIO Control Registers
   //################################
   /*mio_regs  AUTO_TEMPLATE (.\(.*\)_out (reg_\1_out[]),
                              .\(.*\)_in  (reg_\1_in[]),
                            
    );
    */

   mio_regs  #(.AW(AW),
	       .PW(PW),
	       .DEF_CFG(DEF_CFG),
	       .DEF_CLK(DEF_CLK))
   mio_regs (/*AUTOINST*/
	     // Outputs
	     .wait_out			(reg_wait_out),		 // Templated
	     .access_out		(reg_access_out),	 // Templated
	     .packet_out		(reg_packet_out[PW-1:0]), // Templated
	     .tx_en			(tx_en),
	     .rx_en			(rx_en),
	     .ddr_mode			(ddr_mode),
	     .emode			(emode),
	     .amode			(amode),
	     .dmode			(dmode),
	     .datamode			(datamode[1:0]),
	     .iowidth			(iowidth[1:0]),
	     .lsbfirst			(lsbfirst),
	     .framepol			(framepol),
	     .ctrlmode			(ctrlmode[4:0]),
	     .dstaddr			(dstaddr[AW-1:0]),
	     .clkchange			(clkchange),
	     .clkdiv			(clkdiv[7:0]),
	     .clkphase0			(clkphase0[15:0]),
	     .clkphase1			(clkphase1[15:0]),
	     // Inputs
	     .clk			(clk),
	     .nreset			(nreset),
	     .access_in			(reg_access_in),	 // Templated
	     .packet_in			(reg_packet_in[PW-1:0]), // Templated
	     .wait_in			(reg_wait_in),		 // Templated
	     .tx_full			(tx_full),
	     .tx_prog_full		(tx_prog_full),
	     .tx_empty			(tx_empty),
	     .rx_full			(rx_full),
	     .rx_prog_full		(rx_prog_full),
	     .rx_empty			(rx_empty));
   
   //################################
   //# TX CLOCK DRIVER
   //################################
 
   oh_clockdiv oh_clockdiv(.clkrise0	(),
			   .clkfall0	(),
			   .clkrise1	(),
			   .clkfall1	(),
			   .clkstable	(),
			   .clkout0	(io_clk),
                           .clkout1	(tx_clk),
                           .clken	(tx_en),
			   /*AUTOINST*/
			   // Inputs
			   .clk			(clk),
			   .nreset		(nreset),
			   .clkchange		(clkchange),
			   .clkdiv		(clkdiv[7:0]),
			   .clkphase0		(clkphase0[15:0]),
			   .clkphase1		(clkphase1[15:0]));
   
endmodule // mio
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../common/hdl")
// End:



