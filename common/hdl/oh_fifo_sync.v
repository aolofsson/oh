module oh_fifo_sync (/*AUTOARG*/
   // Outputs
   dout, full, prog_full, empty, count,
   // Inputs
   clk, nreset, din, wr_en, rd_en
   );
      
   //#####################################################################
   //# INTERFACE
   //#####################################################################
   parameter  DEPTH       = 4;
   parameter  DW          = 104;
   parameter  PROG_FULL   = DEPTH/2;
   parameter  AW          = $clog2(DEPTH);

   //clk/reset
   input 	   clk;          // clock
   input 	   nreset;       // active high async reset 

   //write port
   input [DW-1:0]  din;          // data to write
   input 	   wr_en;        // write fifo

   //read port
   input 	   rd_en;        // read fifo
   output [DW-1:0] dout;         // output data (next cycle)

   //Status    
   output 	   full;         // fifo full
   output 	   prog_full;    // fifo is almost full
   output 	   empty;        // fifo is empty  
   output [AW:0]   count;        // valid entries in fifo
  
   //#####################################################################
   //# BODY
   //#####################################################################
      
   reg [AW-1:0]  wr_addr;
   reg [AW-1:0]  rd_addr;
   reg [AW:0]    count;
   
   assign empty       = (count[AW:0]==0);   
   assign prog_full   = (count[AW:0] >=PROG_FULL);   
   assign full        = (count==DEPTH);
   
   always @ ( posedge clk or negedge nreset) 
     if(!nreset) 
       begin	   
          wr_addr[AW-1:0] <= 'd0;
          rd_addr[AW-1:0] <= 'b0;
          count[AW:0]     <= 'b0;
       end 
     else if(wr_en & rd_en) 
       begin
	  wr_addr[AW-1:0] <= wr_addr[AW-1:0] + 'd1;
	  rd_addr[AW-1:0] <= rd_addr[AW-1:0] + 'd1;	      
       end 
     else if(wr_en) 
       begin
	  wr_addr[AW-1:0] <= wr_addr[AW-1:0] + 'd1;
	  count[AW:0]     <= count[AW:0]  + 'd1;	
       end 
     else if(rd_en) 
       begin	      
          rd_addr[AW-1:0] <= rd_addr[AW-1:0] + 'd1;
          count[AW:0]     <= count[AW:0]  - 'd1;
       end
   
   // GENERIC DUAL PORTED MEMORY
   oh_memory_dp 
     #(.DW(DW),
       .AW(AW))
   mem (
	// read port
	.rd_dout	(dout[DW-1:0]),
	.rd_clk		(clk),
	.rd_en		(rd_en),
	.rd_addr	(rd_addr[AW-1:0]),
	// write port
	.wr_clk		(clk),
	.wr_en		(wr_en),
  	.wr_wem		({(DW){1'b1}}),
	.wr_addr	(wr_addr[AW-1:0]),
	.wr_din	        (din[DW-1:0])
	);

endmodule // fifo_sync

// Local Variables:
// verilog-library-directories:(".")
// End:
