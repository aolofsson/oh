//#############################################################################
//# Function: Generic Async FIFO                                              #
//# Based on article by Clifford Cummings,                                    #
//  "Simulation and Synthesis Techniques for Asynchronous FIFO Design"        #
//# (SNUG2002)                                                                #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_fifo_generic #(parameter DW        = 104,      // FIFO width
			 parameter DEPTH     = 32,       // FIFO depth (entries)
			 parameter PROG_FULL = (DEPTH/2),// full threshold   
			 parameter AW = $clog2(DEPTH)    // read count width
			 )
   (
    input 	    nreset, // asynch active low reset for wr_clk
    input 	    wr_clk, // write clock   
    input 	    wr_en, // write enable
    input [DW-1:0]  din, // write data
    input 	    rd_clk, // read clock   
    input 	    rd_en, // read enable
    output [DW-1:0] dout, // read data
    output 	    empty, // fifo is empty
    output 	    full, // fifo is full
    output 	    prog_full, // fifo is "half empty"
    output [AW-1:0] rd_count, // NOT IMPLEMENTED 
    output [AW-1:0] wr_count // NOT IMPLEMENTED
    );

   //regs 
   reg [AW:0]    wr_addr;       // extra bit for wraparound comparison
   reg [AW:0] 	 wr_addr_ahead; // extra bit for wraparound comparison   
   reg [AW:0] 	 rd_addr;  
   wire [AW:0] 	 rd_addr_gray;
   wire [AW:0] 	 wr_addr_gray;
   wire [AW:0] 	 rd_addr_gray_sync;
   wire [AW:0] 	 wr_addr_gray_sync;
   wire [AW:0] 	 rd_addr_sync;
   wire [AW:0] 	 wr_addr_sync;
   wire 	 wr_nreset;
   wire 	 rd_nreset;
   
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

   //###########################
   //# Reset synchronizers
   //###########################

   oh_rsync wr_rsync (.nrst_out (wr_nreset),
	     .clk      (wr_clk), 
	     .nrst_in	(nreset));

   oh_rsync rd_rsync (.nrst_out (rd_nreset),
	     .clk      (rd_clk), 
	     .nrst_in	(nreset));
   
   //###########################
   //#write side address counter
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
			   .clk  (rd_clk),
			   .nreset(rd_nreset),
			   .din  (wr_addr_gray[AW:0]));
   
   //###########################
   //#read side address counter
   //###########################

   always @ ( posedge rd_clk or negedge rd_nreset) 
     if(!rd_nreset) 
       rd_addr[AW:0] <= 'd0;   
     else if(rd_en) 
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
			    .clk    (wr_clk),
			    .nreset (wr_nreset),
			    .din    (rd_addr_gray[AW:0]));
   
   //convert back to binary (for ease of use, rd_count)
   oh_gray2bin #(.DW(AW+1))
   rd_g2b (.out (rd_addr_sync[AW:0]),
	   .in (rd_addr_gray_sync[AW:0]));
   
   //###########################
   //#dual ported memory
   //###########################
   oh_memory_dp  #(.DW(DW),
		   .DEPTH(DEPTH))
   fifo_mem(// Outputs
	    .rd_dout	(dout[DW-1:0]),
	    // Inputs
	    .wr_clk	(wr_clk),
	    .wr_en	(wr_en),
	    .wr_wem	({(DW){1'b1}}),
	    .wr_addr	(wr_addr[AW-1:0]),
	    .wr_din	(din[DW-1:0]),
	    .rd_clk	(rd_clk),
	    .rd_en	(rd_en),
	    .rd_addr	(rd_addr[AW-1:0]));
   
endmodule // oh_fifo_generic
		    

