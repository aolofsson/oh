//#############################################################################
//# Function: Synchronous FIFO                                                #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_fifo_sync #(parameter DW        = 104,     //FIFO width
		      parameter DEPTH     = 32,      //FIFO depth
		      parameter REG       = 1,       //Register fifo output
		      parameter PROG_FULL = DEPTH-1, //prog_full threshold  
		      parameter AW = $clog2(DEPTH),  //rd_count width
		      parameter DUMPVAR = 1          // dump array
		      ) 
(
   input 	       clk, // clock
   input 	       nreset, //async reset
   input 	       clear, //clears reset (synchronous signal)
   input [DW-1:0]      din, // data to write
   input 	       wr_en, // write fifo
   input 	       rd_en, // read fifo
   output [DW-1:0]     dout, // output data (next cycle)
   output 	       full, // fifo full
   output 	       prog_full, // fifo is almost full
   output 	       empty, // fifo is empty  
   output reg [AW-1:0] rd_count     // valid entries in fifo
 );
   
   reg [AW:0]          wr_addr;
   reg [AW:0]          rd_addr;
   wire 	       fifo_read;
   wire 	       fifo_write;

   assign fifo_read   = rd_en & ~empty;
   assign fifo_write  = wr_en & ~full;
   assign prog_full   = (rd_count[AW-1:0] == PROG_FULL);
   assign ptr_match   = (wr_addr[AW-1:0] == rd_addr[AW-1:0]);
   assign full        = ptr_match & (wr_addr[AW]==!rd_addr[AW]);
   assign fifo_empty  = ptr_match & (wr_addr[AW]==rd_addr[AW]);
   
   always @ (posedge clk or negedge nreset) 
     if(~nreset) 
       begin	   
          wr_addr[AW:0]   <= 'd0;
          rd_addr[AW:0]   <= 'b0;
          rd_count[AW:0]  <= 'b0;
       end
     else if(clear) 
       begin	   
          wr_addr[AW:0]   <= 'd0;
          rd_addr[AW:0]   <= 'b0;
          rd_count[AW:0]  <= 'b0;
       end
     else if(fifo_write & fifo_read) 
       begin
	  wr_addr[AW:0] <= wr_addr[AW:0] + 'd1;
	  rd_addr[AW:0] <= rd_addr[AW:0] + 'd1;	      
       end 
     else if(fifo_write) 
       begin
	  wr_addr[AW:0]   <=  wr_addr[AW:0]   + 'd1;
	  rd_count[AW-1:0]<= rd_count[AW-1:0] + 'd1;	
       end 
     else if(fifo_read) 
       begin	      
          rd_addr[AW:0]   <= rd_addr[AW:0]  + 'd1;
          rd_count[AW-1:0]<= rd_count[AW-1:0] - 'd1;
       end

   //Empty register to account for RAM output register  
   generate
      if(REG)
	begin
	   reg empty_reg;	   
	   always @ (posedge clk)
	     empty_reg <= fifo_empty;
	   assign empty = empty_reg;
	end
      else
	assign empty = fifo_empty;
   endgenerate

   
   // GENERIC DUAL PORTED MEMORY
   oh_memory_dp 
     #(.DW(DW),
       .DEPTH(DEPTH),
       .DUMPVAR(DUMPVAR),
       .REG(REG))
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


`ifdef TARGET_SIM
   assign rd_error = rd_en & empty;
   assign wr_error = wr_en & full;
   
   always @ (posedge rd_error)
     #1 if(rd_error)
       $display ("ERROR: Reading empty FIFO in %m at ",$time);
   always @ (posedge wr_error)
     #1 if(wr_error)
       $display ("ERROR: Writing full FIFO in %m at ",$time);
  
`endif   			
   
endmodule // oh_fifo_sync
