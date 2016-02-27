module mio (/*AUTOARG*/
   // Outputs
   tx_access, tx_packet, rx_wait, wait_out, access_out, packet_out,
   // Inputs
   clk, io_clk, nreset, datasize, tx_wait, rx_clk, rx_access,
   rx_packet, access_in, packet_in, wait_in
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter PW    = `CFG_MIOPW;       // data width (core)
   parameter MIOW  = `CFG_MIOW;        // Mini IO width
   localparam CW   = $clog2(2*PW/MIOW);// transfer count width
   

   // reset, clk
   input              clk;         // main core clock   
   input              io_clk;      // clock for TX
   input              nreset;      // async active low reset
   input [CW-1:0]     datasize;    // size of data transmitted

   // tx interface
   output 	      tx_access;   // access signal for IO
   output [MIOW-1:0]  tx_packet;   // packet for IO
   input 	      tx_wait;     // pushback from IO

   // rx interface
   input 	      rx_clk;      // rx clock
   input 	      rx_access;   // rx access
   input [MIOW-1:0]   rx_packet;   // rx packet
   output 	      rx_wait;     // pushback from IO

   // core interface
   input 	      access_in;   // fifo data valid
   input [PW-1:0]     packet_in;   // fifo packet  
   output 	      wait_out;    // wait pushback for fifo
   output 	      access_out;  // fifo data valid
   output [PW-1:0]    packet_out;  // fifo packet
   input 	      wait_in;     // wait pushback for fifo
   
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   /*AUTOWIRE*/
      
   mtx #(.MIOW(MIOW),
	 .PW(PW))
   mtx (/*AUTOINST*/
	// Outputs
	.wait_out			(wait_out),
	.tx_access			(tx_access),
	.tx_packet			(tx_packet[MIOW-1:0]),
	// Inputs
	.clk				(clk),
	.io_clk				(io_clk),
	.nreset				(nreset),
	.access_in			(access_in),
	.packet_in			(packet_in[PW-1:0]),
	.datasize			(datasize[CW-1:0]),
	.tx_wait			(tx_wait));
   
   mrx #(.MIOW(MIOW),
	 .PW(PW))
   mrx (/*AUTOINST*/
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
	.rx_packet			(rx_packet[MIOW-1:0]),
	.wait_in			(wait_in));
      
endmodule // mio


