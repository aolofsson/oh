module c2c (/*AUTOARG*/
   // Outputs
   tx_access, tx_packet, tx_clk, wait_out, rx_wait, access_out,
   packet_out,
   // Inputs
   clk, io_clk, nreset, divcfg, tx_wait, access_in, packet_in,
   datasize, rx_clk, rx_access, rx_packet, wait_in
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter PW    = `C2C_PW;         // data width (core)
   parameter IOW   = `C2C_IOW;        // IO data width
   localparam CW   = $clog2(2*PW/IOW);// transfer count width
   
   // reset, clk
   input              clk;         // main core clock   
   input              io_clk;      // clock for TX
   input              nreset;      // async active low reset
   input [3:0] 	      divcfg;	   // tx clock divider config

   ////////////////
   // tx interface
   output 	      tx_access;   // access signal for IO
   output [IOW-1:0]   tx_packet;   // packet for IO
   output 	      tx_clk;      // clock for IO
   input 	      tx_wait;     // pushback from IO

   input 	      access_in;   // fifo data valid
   input [PW-1:0]     packet_in;   // fifo packet
   input [CW-1:0]     datasize;    // size of data transmitted
   output 	      wait_out;    // wait pushback for fifo

   ////////////////
   // rx interface
   input 	      rx_clk;      // rx clock
   input 	      rx_access;   // rx access
   input [IOW-1:0]    rx_packet;   // rx packet
   output 	      rx_wait;     // pushback from IO

   output 	      access_out;  // fifo data valid
   output [PW-1:0]    packet_out;  // fifo packet
   input 	      wait_in;     // wait pushback for fifo
   
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   /*AUTOWIRE*/
      
   ctx #(.IOW(IOW),
	 .PW(PW))
   ctx (/*AUTOINST*/
	// Outputs
	.wait_out			(wait_out),
	.tx_clk				(tx_clk),
	.tx_access			(tx_access),
	.tx_packet			(tx_packet[IOW-1:0]),
	// Inputs
	.clk				(clk),
	.io_clk				(io_clk),
	.nreset				(nreset),
	.divcfg				(divcfg[3:0]),
	.access_in			(access_in),
	.packet_in			(packet_in[PW-1:0]),
	.datasize			(datasize[CW-1:0]),
	.tx_wait			(tx_wait));
   
   crx #(.IOW(IOW),
	 .PW(PW))
   crx (/*AUTOINST*/
	// Outputs
	.rx_wait			(rx_wait),
	.access_out			(access_out),
	.packet_out			(packet_out[PW-1:0]),
	// Inputs
	.clk				(clk),
	.nreset				(nreset),
	.datasize			(datasize[CW-1:0]),
	.rx_clk				(rx_clk),
	.rx_access			(rx_access),
	.rx_packet			(rx_packet[IOW-1:0]),
	.wait_in			(wait_in));
      
endmodule // c2c
