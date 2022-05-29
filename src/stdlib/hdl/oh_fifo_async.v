//#############################################################################
//# Function: Parametrized FIFO                                               #
//#############################################################################
// Notes:                                                                     #
// Soft reference implementation always instantiated                          #
// Assumed to be optimized away in synthesis if needed                        #
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_fifo_async
  #(parameter N        = 32,           // FIFO width
    parameter DEPTH    = 32,           // FIFO depth
    parameter REG      = 1,            // Register fifo output
    parameter AW       = $clog2(DEPTH),// rd_count width (derived)
    parameter SYNCPIPE = 2,            // depth of synchronization pipeline
    parameter SYN      = "TRUE",       // synthesizable
    parameter TYPE     = "DEFAULT",    // implementation type
    parameter PROGFULL = DEPTH-1,      // programmable almost full level
    parameter SHAPE    = "SQUARE"      // hard macro shape (square, tall, wide)
    )
   (//nreset
    input 	    nreset,
    //write port
    input 	    wr_clk,
    input [N-1:0]  wr_din, // data to write
    input 	    wr_en, // write fifo
    output 	    wr_full, // fifo full
    output 	    wr_almost_full, //one entry left
    output 	    wr_prog_full, //programmable full level
    output [AW-1:0] wr_count, // pessimistic report of entries from wr side
    //read port
    input 	    rd_clk,
    output [N-1:0] rd_dout, // output data (next cycle)
    input 	    rd_en, // read fifo
    output 	    rd_empty, // fifo is empty
    output [AW-1:0] rd_count, // pessimistic report of entries from rd side
    // BIST interface
    input 	    bist_en, // bist enable
    input 	    bist_we, // write enable global signal
    input [N-1:0]  bist_wem, // write enable vector
    input [AW-1:0]  bist_addr, // address
    input [N-1:0]  bist_din, // data input
    input [N-1:0]  bist_dout, // data input
    // Power/repair (hard macro only)
    input 	    shutdown, // shutdown signal
    input 	    vss, // ground signal
    input 	    vdd, // memory array power
    input 	    vddio, // periphery/io power
    input [7:0]     memconfig, // generic memory config
    input [7:0]     memrepair // repair vector
    );

   //local wires
   reg [AW:0] 		wr_addr;       // extra bit for wraparound comparison
   reg [AW:0] 		rd_addr;
   wire [AW:0] 		wr_addr_gray;
   wire [AW:0] 		wr_addr_gray_sync;
   wire [AW:0] 		rd_addr_gray;
   wire [AW:0] 		rd_addr_gray_sync;
   wire [AW:0] 		rd_addr_sync;
   wire 		fifo_write;
   wire 		rd_nreset;
   wire 		wr_nreset;



   //###########################
   //# Reset synchronizers
   //###########################

   oh_rsync #(.SYN(SYN),
	      .SYNCPIPE(SYNCPIPE))
   wr_rsync (.nrst_out (wr_nreset),
	     .clk      (wr_clk),
	     .nrst_in  (nreset));

   oh_rsync #(.SYN(SYN),
	      .SYNCPIPE(SYNCPIPE))
   rd_rsync (.nrst_out (rd_nreset),
	     .clk      (rd_clk),
	     .nrst_in  (nreset));

   //###########################
   //# Write side address counter
   //###########################

   assign fifo_write = wr_en & ~wr_full;

   always @ ( posedge wr_clk or negedge wr_nreset)
     if(!wr_nreset)
       wr_addr[AW:0]  <= 'b0;
     else if(fifo_write)
       wr_addr[AW:0]  <= wr_addr[AW:0]  + 'd1;

   //###########################
   //# Read side address counter
   //###########################

   always @ ( posedge rd_clk or negedge rd_nreset)
     if(!rd_nreset)
       rd_addr[AW:0] <= 'd0;
     else if(rd_en)
       rd_addr[AW:0] <= rd_addr[AW:0] + 'd1;

   //############################################
   //# Synchronizaztion logic for async FIFO
   //############################################

   //###########################
   //# WRITE --> READ
   //###########################
   // convert to gray code (only one bit can toggle)
   oh_bin2gray #(.N(AW+1))
   wr_bin2gray (.out    (wr_addr_gray[AW:0]),
		.in	(wr_addr[AW:0]));

   // synchronize to read clock
   oh_dsync #(.SYN(SYN),
	      .SYNCPIPE(SYNCPIPE))
   wr_sync[AW:0] (.dout   (wr_addr_gray_sync[AW:0]),
		  .clk    (rd_clk),
		  .nreset (rd_nreset),
		  .din    (wr_addr_gray[AW:0]));

   //###########################
   //# READ ---> WRITE
   //###########################

   oh_bin2gray #(.N(AW+1))
   rd_bin2gray (.out   (rd_addr_gray[AW:0]),
		.in    (rd_addr[AW:0]));

   //synchronize to wr clock
   oh_dsync  #(.SYN(SYN),
	       .SYNCPIPE(SYNCPIPE))
   rd_sync[AW:0] (.dout   (rd_addr_gray_sync[AW:0]),
		  .clk    (wr_clk),
		  .nreset (wr_nreset),
		  .din    (rd_addr_gray[AW:0]));

   //###########################
   //# Full/empty indicators
   //###########################

   // fifo indicators
   assign rd_empty =  (rd_addr_gray[AW:0] == wr_addr_gray_sync[AW:0]);

   // fifo full
   assign wr_full  =  (wr_addr[AW-1:0] == rd_addr_sync[AW-1:0]) &
		      (wr_addr[AW]     != rd_addr_sync[AW]);

   //###########################
   //# Memory Array
   //###########################

   oh_memory_dp #(.N(N),
		  .DEPTH(DEPTH),
		  .REG(REG),
		  .SYN(SYN),
		  .SHAPE(SHAPE))
   oh_memory_dp(.wr_wem			({(N){1'b1}}),
		.wr_en                  (fifo_write),
		/*AUTOINST*/
		// Outputs
		.rd_dout		(rd_dout[N-1:0]),
		// Inputs
		.wr_clk			(wr_clk),
		.wr_addr		(wr_addr[AW-1:0]),
		.wr_din			(wr_din[N-1:0]),
		.rd_clk			(rd_clk),
		.rd_en			(rd_en),
		.rd_addr		(rd_addr[AW-1:0]),
		.bist_en		(bist_en),
		.bist_we		(bist_we),
		.bist_wem		(bist_wem[N-1:0]),
		.bist_addr		(bist_addr[AW-1:0]),
		.bist_din		(bist_din[N-1:0]),
		.shutdown		(shutdown),
		.vss			(vss),
		.vdd			(vdd),
		.vddio			(vddio),
		.memconfig		(memconfig[7:0]),
		.memrepair		(memrepair[7:0]));

endmodule // oh_fifo_async
// Local Variables:
// verilog-library-directories:("." "../fpga/" "../dv")
// End:
