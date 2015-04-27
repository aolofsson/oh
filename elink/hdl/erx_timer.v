module erx_timer (/*AUTOARG*/
   // Outputs
   timeout,
   // Inputs
   clk, reset, timer_cfg, stop_count, start_count
   );

   parameter DW = 32;
   parameter AW = 32;
   
   input          clk;
   input 	  reset;   
   input [1:0] 	  timer_cfg; //masks MSB of each byte (all zero is off) 
   input 	  stop_count; 
   input 	  start_count;
   
   output 	  timeout;

   reg [31:0] 	  timeout_reg;
   reg 		  do_count;
   wire 	  timer_en;
   wire 	  start_count_sync;
   


   //Synchronize the start count
   synchronizer #(.DW(1)) sync(
			       // Outputs
			       .out		(start_count_sync),
			       // Inputs
			       .in		(start_count),
			       .clk		(clk),
			       .reset		(reset)
			       );
   
   
   assign timer_en = |(timer_cfg[1:0]);
   
  
   always @ (posedge clk or posedge reset)
     if(reset)
       begin
	  do_count <=1'b0;	  
	  timeout_reg[31:0] <= 32'hffffffff;
       end
     else if(start_count_sync & timer_en)
       begin
	  do_count <=1'b1;	  
	  timeout_reg[31:0] <= (timer_cfg[1:0]==2'b01) ? 32'h000000ff :
			       (timer_cfg[1:0]==2'b10) ? 32'h0000ffff :
			                                 32'hffffffff;
       end
     else if(stop_count)
       begin
	  do_count <=1'b0;
       end
     else if(timer_expired)
       begin
	  do_count <=1'b0;
	  timeout_reg[31:0] <= 32'hffffffff;
       end
     else if(do_count)
       begin
	  timeout_reg[31:0] <= timeout_reg[31:0]-1'b1;	  
       end
   
	     
   assign timer_expired = ~(|timeout_reg[31:0]);
   
   assign timeout = timer_en & timer_expired;
   
endmodule // erx_timeout
// Local Variables:
// verilog-library-directories:("." "../../common/hdl" )
// End:
