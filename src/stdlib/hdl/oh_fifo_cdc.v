//#############################################################################
//# Function: Clock domain crossing FIFO                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_fifo_cdc
  #(parameter N     = 32,           // FIFO width
    parameter DEPTH = 32,           // FIFO depth
    parameter SYN   = "TRUE",       // true=synthesizable
    parameter TYPE  = "DEFAULT",    // true=synthesizable
    parameter AW    = $clog2(DEPTH) // rd_count width (derived)
    )
   (
    input 	   nreset,     // async active low reset
    //Write Side
    input 	   clk_in,     // write clock
    input 	   valid_in,   // write valid
    input [N-1:0]  packet_in,  // write packet
    output 	   ready_out,  // write pushback
    //Read Side
    input 	   clk_out,    // read clock
    output reg 	   valid_out,  // read valid
    output [N-1:0] packet_out, // read packet
    input 	   ready_in,   // read pushback
    //Status
    output 	   prog_full, // fifo is half full
    output 	   full,      // fifo is full
    output 	   empty      // fifo is empty
    );

   // FIFO control logic
   assign wr_en    = valid_in;
   assign rd_en    = ~empty & ready_in;
   assign ready_out = ~(wr_almost_full | wr_full | wr_prog_full);

   //async asser, sync deassert of reset
   oh_rsync #(.SYN(SYN),
	      .TYPE(TYPE))
   sync_reset(.nrst_out  (nreset_out),
              .clk       (clk_out),
              .nrst_in   (nreset));

   //align valid signal with FIFO read delay
   always @ (posedge clk_out or negedge nreset_out)
     if(!nreset_out)
       valid_out <= 1'b0;
     else if(ready_in)
       valid_out <= rd_en;

   // parametric async fifo
   oh_fifo_async  #(.SYN(SYN),
		    .N(N),
		    .DEPTH(DEPTH))
   oh_fifo_async (
		  .rd_clk		(clk_out),
		  .rd_dout		(packet_out[N-1:0]),
		  .wr_clk		(clk_in),
		  .wr_din		(packet_in[N-1:0]),
		  .memconfig		(8'b0),
		  .memrepair		(8'b0),
		  .shutdown             (1'b0),
		  .vddio                (1'b1),
		  .vdd                  (1'b0),
		  .vss                  (1'b0),
		  .bist_en		(bist_en),
		  .bist_we		(bist_we),
		  .bist_wem		({(N){1'b0}}),
		  .bist_addr		({(AW){1'b0}}),
		  .bist_din		({(N){1'b0}}),
		  .bist_dout		(),
		  .wr_count		(),
		  .rd_count		(),
		  /*AUTOINST*/
		  // Outputs
		  .wr_full		(wr_full),
		  .wr_almost_full	(wr_almost_full),
		  .wr_prog_full		(wr_prog_full),
		  .rd_empty		(rd_empty),
		  // Inputs
		  .nreset		(nreset),
		  .wr_en		(wr_en),
		  .rd_en		(rd_en));

endmodule // oh_fifo_cdc
// Local Variables:
// verilog-library-directories:("." "../fpga/" "../dv")
// End:
