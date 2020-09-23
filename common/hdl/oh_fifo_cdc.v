//#############################################################################
//# Function: Clock domain crossing FIFO                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_fifo_cdc # (parameter DW        = 104,      //FIFO width
		      parameter DEPTH     = 32,       //FIFO depth (entries)
		      parameter TARGET    = "GENERIC" //XILINX,ALTERA,GENERIC
		      )
   (
    input 	    nreset, // async active low reset
    //Write Side
    input 	    clk_in, // write clock
    input 	    valid_in, // write valid
    input [DW-1:0]  packet_in, // write packet
    output 	    wait_out, // write pushback
    //Read Side
    input 	    clk_out, //read clock
    output reg 	    valid_out, //read valid
    output [DW-1:0] packet_out, //read packet
    input 	    wait_in, // read pushback
    //Status
    output 	    prog_full, // fifo is half full
    output 	    full, // fifo is full
    output 	    empty // fifo is empty
    );
   
   // local wires
   wire 	   wr_en;
   wire 	   rd_en;
      
   // parametric async fifo
   oh_fifo_async  #(.TARGET(TARGET),
		    .DW(DW),
		    .DEPTH(DEPTH))
   fifo (.prog_full (prog_full),
	 .full	    (full),
	 .rd_count  (),
	 .nreset    (nreset),
	 .dout	    (packet_out[DW-1:0]),
	 .empty	    (empty),
	 .wr_clk    (clk_in),
	 .rd_clk    (clk_out),
	 .wr_en	    (wr_en),
	 .din	    (packet_in[DW-1:0]),
	 .rd_en	    (rd_en));

   // FIFO control logic
   assign wr_en    = valid_in;
   assign rd_en    = ~empty & ~wait_in;
   assign wait_out = prog_full;


   //async asser, sync deassert of reset
   oh_rsync sync_reset(.nrst_out  (nreset_out),
                       .clk       (clk_out),
                       .nrst_in   (nreset));
   
   //align valid signal with FIFO read delay
   always @ (posedge clk_out or negedge nreset_out)
     if(!nreset_out)
       valid_out <= 1'b0;   
     else if(~wait_in)
       valid_out <= rd_en;
   
endmodule // oh_fifo_cdc

