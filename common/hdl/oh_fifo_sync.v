module oh_fifo_sync (/*AUTOARG*/
   // Outputs
   dout, empty, full, almost_full, count,
   // Inputs
   clk, nreset, din, wr_en, rd_en
   );
      
   //#####################################################################
   //# PARAMETERS
   //#####################################################################
   parameter DEPTH       = 4;
   parameter DW          = 104;
   parameter ALMOST_FULL = DEPTH-1;

   localparam AW         = $clog2(DEPTH);
      
   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //clk/reset
   input 	   clk;   
   input 	   nreset;   

   //write port
   input [DW-1:0]  din;   
   input 	   wr_en;   

   //Read port
   input 	   rd_en;   
   output [DW-1:0] dout;

   //Status   
   output 	   empty;   
   output 	   full;
   output 	   almost_full;
   output [AW:0]   count;
  
   //#####################################################################
   //# BODY
   //#####################################################################
      
   reg [AW-1:0]  wr_addr;
   reg [AW-1:0]  rd_addr;
   reg [AW:0]    count;
   
   assign empty       = (count[AW:0]==0);   
   assign almost_full = (count[AW:0] >=ALMOST_FULL);   
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
	  count[AW:0]     <= count[AW:0]     + 'd1;	
       end 
     else if(rd_en) 
       begin	      
          rd_addr[AW-1:0] <= rd_addr[AW-1:0] + 'd1;
          count[AW:0]     <= count[AW:0]     - 'd1;
       end
   
   // GENERIC DUAL PORTED MEMORY
   defparam mem.DW=DW;
   defparam mem.AW=AW;   
   oh_memory_dp 
     #(.DW(DW),
       .AW(AW))
   mem (
	// read port
	.rd_dout	(dout[DW-1:0]),
	.rd_clk		(clk),
	.rd_en		(rd_en),
	.rd_addr	(rd_addr[AW-1:0])
	// write port
	.wr_clk		(clk),
	.wr_en		(wr_en),
  	.wr_wem		({(DW){1'b1}}),
	.wr_addr	(wr_addr[AW-1:0]),
	.wr_din	        (din[DW-1:0]),
	);

endmodule // fifo_sync

// Local Variables:
// verilog-library-directories:(".")
// End:
