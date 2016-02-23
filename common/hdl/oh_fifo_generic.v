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
   parameter DEPTH     = 1;              // FIFO depth (entries)         
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
   output [AW-1:0] rd_count;// fifo count on rd side
   output [AW-1:0] wr_count;// fifo count on wr side

   //#####################################################################
   //# BODY
   //#####################################################################
   
   reg [AW-1:0]    wr_addr;
   reg [AW-1:0]    rd_addr;
   reg [AW-1:0]    rd_count;
   reg [AW-1:0]    wr_count;

   // fifo indicators
   assign empty     = (rd_count[AW-1:0] == 'b0);
   assign full      = (wr_count[AW-1:0] == DEPTH);
   assign prog_full = (wr_count[AW-1:0] >= PROG_FULL);   

   // write side state machine
   always @ ( posedge wr_clk or negedge nreset) 
     if(!nreset) 
       begin	   
          wr_addr[AW-1:0]   <= 'd0;
	  wr_count[AW-1:0]  <= 'd0;
       end 
     else if(wr_en & rd_en_sync) 
	  wr_addr[AW-1:0] <= wr_addr[AW-1:0] + 'd1;
     else if(wr_en) 
       begin
	  wr_addr[AW-1:0] <= wr_addr[AW-1:0]  + 'd1;
	  wr_count[AW-1:0]<= wr_count[AW-1:0] + 'd1;	
       end
     else if(rd_en_sync) 
       wr_count[AW-1:0]<= wr_count[AW-1:0] - 'd1;	

   // read side state machine
   always @ ( posedge rd_clk or negedge nreset) 
     if(!nreset) 
       begin	   
          rd_addr[AW-1:0]   <= 'd0;
	  rd_count[AW-1:0]  <= 'd0;
       end 
     else if(rd_en & wr_en_sync) 
       rd_addr[AW-1:0] <= rd_addr[AW-1:0] + 'd1;
     else if(rd_en) 
       begin
	  rd_addr[AW-1:0] <= rd_addr[AW-1:0]  + 'd1;
	  rd_count[AW-1:0] <= rd_count[AW-1:0] - 'd1;	
       end
     else if(wr_en_sync) 
       rd_count[AW-1:0] <= rd_count[AW-1:0] + 'd1;	
         
   // clock domain synchronizers
   oh_dsync wr_sync(.dout (wr_en_sync),
		    .clk  (rd_clk),
		    .din  (wr_en));
   
   oh_dsync rd_sync(.dout (rd_en_sync),
		    .clk  (wr_clk),
		    .din  (rd_en));
   
   // dual ported memory (1rd, 1 wr)
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
		    

