//#############################################################################
//# Purpose: SPI Master Transmit Fifo                                         #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

`include "spi_regmap.vh"
module spi_master_fifo #( parameter  DEPTH = 16,            // fifo entries
			  parameter  AW    = 32,            // address width
			  parameter  PW    = 104,           // input packet width   
			  parameter  SW    = 8,             // io packet width   
			  parameter  FAW   = $clog2(DEPTH), // fifo address width   
			  parameter  SRW   = $clog2(PW/SW), // serialization factor
			  parameter  TARGET = "GENERIC"     // XILINX,ALTERA,GENERIC,ASIC
			  )
   (
    //clk,reset, cfg
    input 	    clk, // clk
    input 	    nreset, // async active low reset
    input 	    spi_en, // spi enable   
    output 	    fifo_prog_full, // fifo full indicator for status
    // Incoming interface 
    input 	    access_in, // access by core
    input [PW-1:0]  packet_in, // packet from core
    output 	    wait_out, // pushback to core
    // IO interface
    input 	    fifo_read, // pull a byte to IO
    output 	    fifo_empty, // fifo is empty
    output [SW-1:0] fifo_dout // byte for IO
    );
   
   //###############
   //# LOCAL WIRES
   //###############
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

   packet2emesh #(.AW(AW),
		  .PW(PW))
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
      
   assign datasize[7:0] = (1<<datamode_in[1:0]);
   
   assign tx_write =  spi_en     & 
		      write_in   & 
		      access_in  &
		      ~fifo_wait &
		      (dstaddr_in[5:0]==`SPI_TX);
    
   wire fifo_wait;
   assign wait_out = fifo_wait; // & tx_write;

   //epiphany mode works in msb or lsb mode
   //data mode up to 64 bits works in lsb mode
   //for msb transfer, use byte writes only

   assign tx_data[PW-1:0] = {{(40){1'b0}},
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
	       .wait_out    (fifo_wait),
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

   // HACK: oh_fifo_sync is broken for XILINX target.
   generate
   if(TARGET=="XILINX") begin : gen_xilinx_fifo
     // HACK: Hardcoded DW/DEPTH to please XILINX target
     wire [103:0] fifo_dout_full;
     assign fifo_dout[SW-1:0] = fifo_dout_full[SW-1:0];

     wire [103:0] packet_in_full;
     assign packet_in_full[103:0] = {{(104-SW){1'b0}},fifo_din[SW-1:0]};

     //   oh_fifo_cdc  #(.DW(SW),
     //		  .DEPTH(DEPTH),
     //		  .TARGET(TARGET))
     oh_fifo_cdc  #(.DW(104),
		    .DEPTH(32),
		    .TARGET(TARGET))
     fifo  (// Outputs
	    .wait_out			(),
	    .access_out			(),
	    .packet_out			(fifo_dout_full[103:0]),
	    .prog_full			(fifo_prog_full),
	    .full				(fifo_full),
	    .empty			(fifo_empty),
	    // Inputs
	    .nreset			(nreset),
	    .clk_in			(clk),
	    .packet_in			(packet_in_full[103:0]),
	    .clk_out			(clk),
	    .access_in			(fifo_wr),
	    .wait_in			(~fifo_read));
   end // TARGET == "XILINX"
   else begin : gen_generic_fifo
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
   end  // TARGET != "XILINX"
   endgenerate

endmodule // spi_master_fifo

// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emesh/hdl")
// End:

