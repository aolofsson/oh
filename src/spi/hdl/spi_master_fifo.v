`include "spi_regmap.vh"
module spi_master_fifo (/*AUTOARG*/
   // Outputs
   fifo_prog_full, wait_out, fifo_empty, fifo_dout,
   // Inputs
   clk, nreset, spi_en, emode, access_in, packet_in, fifo_read
   );
   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter  DEPTH = 16;            // fifo entries
   parameter  AW    = 32;            // architecture address width
   parameter  SW    = 8;             // output packet width   
   localparam PW    = 2*AW+40;       // input packet width   
   localparam FAW   = $clog2(DEPTH); // fifo address width   
   localparam SRW   = $clog2(PW/SW); // serializer cycle count width
   
   //clk,reset, cfg
   input            clk;            // clk
   input 	    nreset;         // async active low reset
   input 	    spi_en;         // spi enable   
   input  	    emode;          // epiphany transfer mode
   output 	    fifo_prog_full; // fifo full indicator for status
   
   // Incoming interface 
   input            access_in;      // access by core
   input [PW-1:0]   packet_in;      // packet from core
   output 	    wait_out;       // pushback to core
   
   // IO interface
   input 	    fifo_read;      // pull a byte to IO
   output 	    fifo_empty;     // fifo is empty
   output [SW-1:0]  fifo_dout;      // byte for IO

   //##################################
   //# BODY
   //##################################

   wire [7:0] 	    datasize;
   wire [PW-1:0]    tx_data;
   wire [SW-1:0]    fifo_din;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	data_in;		// From p2e of packet2emesh.v
   wire [1:0]		datamode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From p2e of packet2emesh.v
   wire			write_in;		// From p2e of packet2emesh.v
   // End of automatics
   
   //##################################
   //# DECODE
   //###################################

   packet2emesh #(.AW(AW))
   p2e (/*AUTOINST*/
	// Outputs
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[4:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]),
	// Inputs
	.packet_in			(packet_in[PW-1:0]));
   
   
   assign datasize[7:0] = emode ? (PW/SW-1'b1) :
			  ((1<<datamode_in[1:0]));
   

   assign tx_write =  spi_en &
		      write_in & 
		      access_in &
		      (dstaddr_in[5:0]==`SPI_TX);
     
   //epiphany mode works in msb or lsb mode
   //data mode up to 64 bits works in lsb mode
   //for msb transfer, use byte writes only

   assign tx_data[PW-1:0] = emode ? packet_in[PW-1:0] :
			    {{(40){1'b0}},
			     srcaddr_in[AW-1:0], 
			     data_in[AW-1:0]};
   
   //##################################
   //# FIFO PACKET WRITE
   //##################################

   oh_par2ser #(.PW(PW),
		.SW(SW))

   oh_par2ser (// Outputs
	       .dout	    (fifo_din[SW-1:0]),
	       .access_out  (fifo_wr),
	       .wait_out    (wait_out),
	       // Inputs
	       .clk	    (clk),
	       .nreset	    (nreset),
	       .din	    (tx_data[PW-1:0]),
	       .shift	    (1'b1),
	       .datasize    (datasize[7:0]),
	       .load	    (tx_write),
	       .lsbfirst    (1'b1),
	       .fill	    (1'b0),
	       .wait_in	    (fifo_prog_full)
	       );
      
   //##################################
   //# FIFO
   //###################################

   oh_fifo_sync #(.DEPTH(DEPTH),
		  .DW(SW))   
   fifo(// Outputs
	.dout		(fifo_dout[7:0]),
	.full		(fifo_full),
	.prog_full	(fifo_prog_full),
	.empty		(fifo_empty),
	.rd_count	(),
	// Inputs
	.clk		(clk),
	.nreset		(nreset),
	.din		(fifo_din[7:0]),
	.wr_en		(fifo_wr),
	.rd_en		(fifo_read));

endmodule // spi_master_fifo

// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emesh/hdl")
// End:

