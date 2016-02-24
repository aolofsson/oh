 //#####################################################################
//# Asynchronous FIFO based on article by Clifford Cummings, "Simulation and Synthesis Techniques for Asynchronous FIFO Design", SNUG 2002
//#
//# Modifications: Using binary comparisons for simplicity. This may cost
//# a few more gates, but the the clarity is worth it. 
//#####################################################################
module oh_fifo_generic
   (/*AUTOARG*/
   // Outputs
   dout, empty, full, prog_full, rd_count, wr_count,
   // Inputs
   nreset, wr_clk, wr_en, din, rd_clk, rd_en
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################
   
   // parameters
   parameter DW        = 104;            // FIFO width 
   parameter DEPTH     = 16;             // FIFO depth (entries)         
   parameter PROG_FULL = DEPTH/2;        // FIFO full threshold 
   parameter AW        = $clog2(DEPTH);  // FIFO address width (for model)

   // common reset
   input           nreset;       // asynch active low reset

   // fifo write
   input           wr_clk;       // write clock   
   input           wr_en;        // write enable
   input  [DW-1:0] din;          // write data
   
   // fifo read
   input           rd_clk;       // read clock   
   input 	   rd_en;        // read enable
   output [DW-1:0] dout;         // read data

   // status
   output          empty;        // fifo is empty
   output          full;         // fifo is full
   output 	   prog_full;    // fifo is "half empty"
   output [AW-1:0] rd_count;     // NOT IMPLEMENTED 
   output [AW-1:0] wr_count;     // NOT IMPLEMENTED

   //#####################################################################
   //# BODY
   //#####################################################################
   
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

   //###########################
   //# Full/empty indicators
   //###########################

   // uses on extra bit for compare to track wraparound pointers 
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
   //#write side state machine
   //###########################

   always @ ( posedge wr_clk or negedge nreset) 
     if(!nreset) 
       wr_addr[AW:0]  <= 'b0;
     else if(wr_en) 
       wr_addr[AW:0]  <= wr_addr[AW:0]  + 'd1;

   //address for prog_full indicator
   always @ (posedge wr_clk)
     if(~nreset)
       wr_addr_ahead[AW:0] <= 'b0;   
     else if(~prog_full)
       wr_addr_ahead[AW:0] <= wr_addr[AW:0]  + PROG_FULL;
   
   oh_bin2gray #(.DW(AW+1))
   wr_b2g (.gray   (wr_addr_gray[AW:0]),
	   .bin	   (wr_addr[AW:0]));
   
   oh_dsync  #(.DW(AW+1))
   wr_sync(.dout (wr_addr_gray_sync[AW:0]),
	   .clk  (rd_clk),
	   .din  (wr_addr_gray[AW:0]));
   
   //###########################
   //#read side state machine
   //###########################

   always @ ( posedge rd_clk or negedge nreset) 
     if(!nreset) 
       rd_addr[AW:0] <= 'd0;   
     else if(rd_en) 
       rd_addr[AW:0] <= rd_addr[AW:0] + 'd1;
   
   oh_bin2gray #(.DW(AW+1))
   rd_b2g (.gray  (rd_addr_gray[AW:0]),
	   .bin	  (rd_addr[AW:0]));
   
   oh_dsync  #(.DW(AW+1))
   rd_sync(.dout (rd_addr_gray_sync[AW:0]),
	   .clk  (rd_clk),
	   .din  (rd_addr_gray[AW:0]));

   oh_gray2bin #(.DW(AW+1))
   rd_g2b (.bin  (rd_addr_sync[AW:0]),
	   .gray (rd_addr_gray_sync[AW:0]));
   

   //###########################
   //#dual ported memory
   //###########################
   oh_memory_dp  #(.DW(DW),
		   .AW(AW))
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
		    

