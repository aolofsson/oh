//#############################################################################
//# Function: Synchronous FIFO                                                #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_fifo_sync
  #(parameter N        = 8,            // FIFO width
    parameter DEPTH    = 4,            // FIFO depth
    parameter REG      = 1,            // Register fifo output
    parameter SYN      = "TRUE",       // synthesizable
    parameter TYPE     = "DEFAULT",    // implementation type
    parameter SHAPE    = "SQUARE",     // hard macro shape (square, tall, wide),
    parameter PROGFULL = DEPTH-1,      // programmable almost full level
    parameter AW       = $clog2(DEPTH) // count width (derived)
    )
   (
    //basic interface
    input 		clk, // clock
    input 		nreset, //async reset
    input 		clear, //clear fifo statemachine (sync)
    //write port
    input [N-1:0] 	wr_din, // data to write
    input 		wr_en, // write fifo
    output 		wr_full, // fifo full
    output 		wr_almost_full, //one entry left
    output 		wr_prog_full, //programmable full level
    output reg [AW-1:0] wr_count, // pessimistic report of entries from wr side
    //read port
    output [N-1:0] 	rd_dout, // output data (next cycle)
    input 		rd_en, // read fifo
    output 		rd_empty, // fifo is empty
    // BIST interface
    input 		bist_en, // bist enable
    input 		bist_we, // write enable global signal
    input [N-1:0] 	bist_wem, // write enable vector
    input [AW-1:0] 	bist_addr, // address
    input [N-1:0] 	bist_din, // data input
    input [N-1:0] 	bist_dout, // data input
    // Power/repair (hard macro only)
    input 		shutdown, // shutdown signal
    input 		vss, // ground signal
    input 		vdd, // memory array power
    input 		vddio, // periphery/io power
    input [7:0] 	memconfig, // generic memory config
    input [7:0] 	memrepair // repair vector
    );

   //############################
   //local wires
   //############################
   reg [AW:0]          wr_addr;
   reg [AW:0]          rd_addr;
   reg 		       empty_reg;
   wire 	       fifo_read;
   wire 	       fifo_write;
   wire 	       ptr_match;
   wire 	       fifo_empty;

   //#########################################################
   // FIFO Control
   //#########################################################

   assign fifo_read      = rd_en & ~rd_empty;
   assign fifo_write     = wr_en & ~wr_full;
   assign wr_almost_full = (wr_count[AW-1:0] == PROGFULL);
   assign ptr_match      = (wr_addr[AW-1:0] == rd_addr[AW-1:0]);
   assign wr_full        = ptr_match & (wr_addr[AW]==!rd_addr[AW]);
   assign rd_empty       = ptr_match & (wr_addr[AW]==rd_addr[AW]);

   always @ (posedge clk or negedge nreset)
     if(~nreset)
       begin
          wr_addr[AW:0]    <= 'd0;
          rd_addr[AW:0]    <= 'b0;
          wr_count[AW-1:0] <= 'b0;
       end
     else if(clear)
       begin
          wr_addr[AW:0]    <= 'd0;
          rd_addr[AW:0]    <= 'b0;
          wr_count[AW-1:0] <= 'b0;
       end
     else if(fifo_write & fifo_read)
       begin
	  wr_addr[AW:0] <= wr_addr[AW:0] + 'd1;
	  rd_addr[AW:0] <= rd_addr[AW:0] + 'd1;
       end
     else if(fifo_write)
       begin
	  wr_addr[AW:0]    <= wr_addr[AW:0] + 'd1;
	  wr_count[AW-1:0] <= wr_count[AW-1:0] + 'd1;
       end
     else if(fifo_read)
       begin
          rd_addr[AW:0]    <= rd_addr[AW:0] + 'd1;
          wr_count[AW-1:0] <= wr_count[AW-1:0] - 'd1;
       end

   //Pipeline register to account for RAM output register
   always @ (posedge clk)
     empty_reg <= fifo_empty;

   assign empty = (REG==1) ? empty_reg : fifo_empty;

   //###########################
   //# Memory Array
   //###########################

   oh_dpram #(.N(N),
		  .DEPTH(DEPTH),
		  .REG(REG),
		  .SYN(SYN),
		  .TYPE(TYPE),
		  .SHAPE(SHAPE))
   oh_dpram(.wr_wem			({(N){1'b1}}),
	    .wr_clk			(clk),
	    .rd_clk			(clk),
	    /*AUTOINST*/
	    // Outputs
	    .rd_dout			(rd_dout[N-1:0]),
	    // Inputs
	    .wr_en			(wr_en),
	    .wr_addr			(wr_addr[AW-1:0]),
	    .wr_din			(wr_din[N-1:0]),
	    .rd_en			(rd_en),
	    .rd_addr			(rd_addr[AW-1:0]),
	    .bist_en			(bist_en),
	    .bist_we			(bist_we),
	    .bist_wem			(bist_wem[N-1:0]),
	    .bist_addr			(bist_addr[AW-1:0]),
	    .bist_din			(bist_din[N-1:0]),
	    .shutdown			(shutdown),
	    .vss			(vss),
	    .vdd			(vdd),
	    .vddio			(vddio),
	    .memconfig			(memconfig[7:0]),
	    .memrepair			(memrepair[7:0]));

endmodule // oh_fifo_sync
