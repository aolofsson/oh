//#############################################################################
//# Function: Synchronous FIFO                                                #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_fifo_sync #(parameter DW        = 104,      //FIFO width
		      parameter DEPTH     = 32,       //FIFO depth
		      parameter PROG_FULL = (DEPTH/2),//prog_full threshold  
		      parameter AW = $clog2(DEPTH)    //rd_count width
		      ) 
(
   input 	       clk, // clock
   input 	       nreset, // active high async reset 
   input [DW-1:0]      din, // data to write
   input 	       wr_en, // write fifo
   input 	       rd_en, // read fifo
   output [DW-1:0]     dout, // output data (next cycle)
   output 	       full, // fifo full
   output 	       prog_full, // fifo is almost full
   output 	       empty, // fifo is empty  
   output reg [AW-1:0] rd_count     // valid entries in fifo
 );
   
   reg [AW-1:0]        wr_addr;
   reg [AW-1:0]        rd_addr;
   wire 	       fifo_read;
   wire 	       fifo_write;
   
   assign empty       = (rd_count[AW-1:0] == 0);   
   assign prog_full   = (rd_count[AW-1:0] >= PROG_FULL);   
   assign full        = (rd_count[AW-1:0] == (DEPTH-1));
   assign fifo_read   = rd_en & ~empty;
   assign fifo_write  = wr_en & ~full;
   
   always @ ( posedge clk or negedge nreset) 
     if(!nreset) 
       begin	   
          wr_addr[AW-1:0]   <= 'd0;
          rd_addr[AW-1:0]   <= 'b0;
          rd_count[AW-1:0]  <= 'b0;
       end 
     else if(fifo_write & fifo_read) 
       begin
	  wr_addr[AW-1:0] <= wr_addr[AW-1:0] + 'd1;
	  rd_addr[AW-1:0] <= rd_addr[AW-1:0] + 'd1;	      
       end 
     else if(fifo_write) 
       begin
	  wr_addr[AW-1:0] <= wr_addr[AW-1:0]  + 'd1;
	  rd_count[AW-1:0]<= rd_count[AW-1:0] + 'd1;	
       end 
     else if(fifo_read) 
       begin	      
          rd_addr[AW-1:0] <= rd_addr[AW-1:0]  + 'd1;
          rd_count[AW-1:0]<= rd_count[AW-1:0] - 'd1;
       end
   
   // GENERIC DUAL PORTED MEMORY
   oh_memory_dp 
     #(.DW(DW),
       .DEPTH(DEPTH))
   mem (// read port
	.rd_dout	(dout[DW-1:0]),
	.rd_clk		(clk),
	.rd_en		(fifo_read),
	.rd_addr	(rd_addr[AW-1:0]),
	// write port
	.wr_clk		(clk),
	.wr_en		(fifo_write),
  	.wr_wem		({(DW){1'b1}}),
	.wr_addr	(wr_addr[AW-1:0]),
	.wr_din	        (din[DW-1:0]));

endmodule // oh_fifo_sync
