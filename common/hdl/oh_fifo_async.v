//#############################################################################
//# Function: Parametrized asynchronous clock FIFO                            #
//#############################################################################
// Notes:                                                                     #
// Soft reference implementation always instantiated                          #
// Assumed to be optimized away in synthesis if needed                        #
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_fifo_async
  #(parameter DW       = 104,          // FIFO width
    parameter DEPTH    = 32,           // FIFO depth
    parameter REG      = 1,            // Register fifo output
    parameter AW       = $clog2(DEPTH),// rd_count width (derived)
    parameter PROGFULL = DEPTH-1,      // programmable almost full level
    parameter TYPE     = "soft",       // hard=name,soft=synthesizable
    parameter CONFIG   = "default",    // hard macro user config pass through
    parameter SHAPE    = "square"      // hard macro shape (square, tall, wide)
    )
   (

    //basic interface
    input 		rdclk, // read side clock
    input 		wrclk, // write side clock
    input 		nreset, //async reset
    input 		clear, //clear fifo (synchronous)
    //write port
    input 		write, // write fifo
    input [DW-1:0] 	din, // data to write
    output 		full, // fifo full
    output 		progfull, //programmable full level
    //read port
    input 		read, // read fifo
    output [DW-1:0] 	dout, // output data (next cycle)
    output 		empty, // fifo is empty
    output reg [AW-1:0] rdcount, // valid entries in fifo
    // BIST interface
    input 		bist_en, // bist enable
    input 		bist_we, // write enable global signal
    input [DW-1:0] 	bist_wem, // write enable vector
    input [AW-1:0] 	bist_addr, // address
    input [DW-1:0] 	bist_din, // data input
    input [DW-1:0] 	bist_dout, // data input
    // Power/repair (hard macro only)
    input 		shutdown, // shutdown signal
    input 		vss, // ground signal
    input 		vdd, // memory array power
    input 		vddio, // periphery/io power
    input [7:0] 	memconfig, // generic memory config
    input [7:0] 	memrepair // repair vector
    );

   //local wires and registers
   wire [AW-1:0]   wr_count;  // valid entries in fifo
   reg [AW:0] 	   wr_addr;       // extra bit for wraparound comparison
   reg [AW:0] 	   wr_addr_ahead; // extra bit for wraparound comparison
   reg [AW:0] 	   rd_addr;


   //#####################################
   //# Select between hard and soft logic
   //#####################################

   generate
      if(TYPE=="soft") begin: gen_soft

	 assign dout[DW-1:0] = soft_dout[DW-1:0];
	 assign dout[DW-1:0] = soft_dout[DW-1:0]


      endgenerate

   //###########################
   //# Full/empty indicators
   //###########################

   // uses one extra bit for compare to track wraparound pointers
   // careful clock synchronization done using gray codes
   // could get rid of gray2bin for rd_addr_sync...

   // fifo indicators
   assign soft_empty =  (rd_addr_gray[AW:0] == wr_addr_gray_sync[AW:0]);

   // fifo full
   assign soft_full  =  (wr_addr[AW-1:0] == rd_addr_sync[AW-1:0]) &
			(wr_addr[AW]     != rd_addr_sync[AW]);


   // programmable full
   assign soft_progfull = (wr_addr_ahead[AW-1:0] == rd_addr_sync[AW-1:0]) &
			  (wr_addr_ahead[AW]     != rd_addr_sync[AW]);


   //###########################
   //# Reset synchronizers
   //###########################

   oh_rsync wr_rsync (.nrst_out (wr_nreset),
		      .clk      (wrclk),
		      .nrst_in	(nreset));

   oh_rsync rd_rsync (.nrst_out (rd_nreset),
		      .clk      (rdclk),
		      .nrst_in	(nreset));


   //###########################
   //# Write side address counter
   //###########################

   always @ ( posedge wr_clk or negedge wr_nreset)
     if(!wr_nreset)
       wr_addr[AW:0]  <= 'b0;
     else if(wr_en)
       wr_addr[AW:0]  <= wr_addr[AW:0]  + 'd1;

   //address lookahead for prog_full indicator
   always @ (posedge wr_clk or negedge wr_nreset)
     if(!wr_nreset)
       wr_addr_ahead[AW:0] <= 'b0;
     else if(~prog_full)
       wr_addr_ahead[AW:0] <= wr_addr[AW:0]  + PROG_FULL;

   //###########################
   //# Synchronize to read clk
   //###########################

   // convert to gray code (only one bit can toggle)
   oh_bin2gray #(.DW(AW+1))
   wr_b2g (.out    (wr_addr_gray[AW:0]),
	   .in	   (wr_addr[AW:0]));

   // synchronize to read clock
   oh_dsync wr_sync[AW:0] (.dout (wr_addr_gray_sync[AW:0]),
			   .clk  (rdclk),
			   .nreset(rd_nreset),
			   .din  (wr_addr_gray[AW:0]));

   //###########################
   //#read side address counter
   //###########################

   always @ ( posedge rd_clk or negedge rd_nreset)
     if(!rd_nreset)
       rd_addr[AW:0] <= 'd0;
     else if(read)
       rd_addr[AW:0] <= rd_addr[AW:0] + 'd1;

   //###########################
   //# Synchronize to write clk
   //###########################

   //covert to gray (can't have multiple bits toggling)
   oh_bin2gray #(.DW(AW+1))
   rd_b2g (.out   (rd_addr_gray[AW:0]),
	   .in	  (rd_addr[AW:0]));

   //synchronize to wr clock
   oh_dsync  rd_sync[AW:0] (.dout   (rd_addr_gray_sync[AW:0]),
			    .clk    (wrclk),
			    .nreset (wr_nreset),
			    .din    (rd_addr_gray[AW:0]));

   //convert back to binary (for ease of use, rd_count)
   oh_gray2bin #(.DW(AW+1))
   rd_g2b (.out (rd_addr_sync[AW:0]),
	   .in (rd_addr_gray_sync[AW:0]));



	 //###########################
	 //# Full/empty indicators
	 //###########################

	 // uses one extra bit for compare to track wraparound pointers
   // careful clock synchronization done using gray codes
   // could get rid of gray2bin for rd_addr_sync...

   // fifo indicators
   assign empty    =  (rd_addr_gray[AW:0] == wr_addr_gray_sync[AW:0]);

   // fifo full
   assign full     =  (wr_addr[AW-1:0] == rd_addr_sync[AW-1:0]) &
		      (wr_addr[AW]     != rd_addr_sync[AW]);


   // programmable full
   assign prog_full = (wr_addr_ahead[AW-1:0] == rd_addr_sync[AW-1:0]) &
		      (wr_addr_ahead[AW]     != rd_addr_sync[AW]);

	 //asiclib
      end
      else:
	//asiclib
   endgenerate

endmodule // oh_fifo_async
// Local Variables:
// verilog-library-directories:("." "../fpga/" "../dv")
// End:
