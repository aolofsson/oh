module fifo_full_block (/*AUTOARG*/
   // Outputs
   wr_fifo_full, wr_fifo_almost_full, wr_addr, wr_gray_pointer,
   // Inputs
   reset, wr_clk, wr_rd_gray_pointer, wr_write
   );

   parameter AW   = 2; // Number of bits to access all the entries 

   //##########
   //# INPUTS
   //##########
   input           reset;
   input           wr_clk;

   input [AW:0]    wr_rd_gray_pointer;//synced from read domain
   input           wr_write;
   
   //###########
   //# OUTPUTS
   //###########
   output           wr_fifo_full;
   output           wr_fifo_almost_full;
   
   output [AW-1:0]  wr_addr;
   output [AW:0]    wr_gray_pointer;//for read domain

   //#########
   //# REGS
   //#########
   reg [AW:0]      wr_gray_pointer;
   reg [AW:0]      wr_binary_pointer;
   reg             wr_fifo_full;

   //##########
   //# WIRES
   //##########
   wire            wr_fifo_full_next;
   wire [AW:0]     wr_gray_next;
   wire [AW:0]     wr_binary_next;
   
   wire 	   wr_fifo_almost_full_next;
   reg 		   wr_fifo_almost_full;
   
   //Counter States
   always @(posedge wr_clk or posedge reset)
     if(reset)
       begin
	  wr_binary_pointer[AW:0]     <= {(AW+1){1'b0}};
	  wr_gray_pointer[AW:0]       <= {(AW+1){1'b0}};
       end
     else if(wr_write)
       begin
	  wr_binary_pointer[AW:0]     <= wr_binary_next[AW:0];	  
	  wr_gray_pointer[AW:0]       <= wr_gray_next[AW:0];	  
       end

   //Write Address
   assign wr_addr[AW-1:0]       = wr_binary_pointer[AW-1:0];

   //Updating binary pointer
   assign wr_binary_next[AW:0]  = wr_binary_pointer[AW:0] + 
				  {{(AW){1'b0}},wr_write};

   //Gray Pointer Conversion (for more reliable synchronization)!
   assign wr_gray_next[AW:0]    = {1'b0,wr_binary_next[AW:1]} ^ 
				  wr_binary_next[AW:0];

   //FIFO full indication
   assign wr_fifo_full_next =
			 (wr_gray_next[AW-2:0] == wr_rd_gray_pointer[AW-2:0]) &
			 (wr_gray_next[AW]     ^  wr_rd_gray_pointer[AW])     &
			 (wr_gray_next[AW-1]   ^  wr_rd_gray_pointer[AW-1]);

 
   always @ (posedge wr_clk or posedge reset)
     if(reset)
       wr_fifo_full <= 1'b0;
     else
       wr_fifo_full <=wr_fifo_full_next;


   //FIFO almost full
   assign wr_fifo_almost_full_next =
			 (wr_gray_next[AW-3:0] == wr_rd_gray_pointer[AW-3:0]) &
			 (wr_gray_next[AW]     ^  wr_rd_gray_pointer[AW])     &
			 (wr_gray_next[AW-1]   ^  wr_rd_gray_pointer[AW-1])   &
			 (wr_gray_next[AW-2]   ^  wr_rd_gray_pointer[AW-2]);
  
   always @ (posedge wr_clk or posedge reset)
     if(reset)
       wr_fifo_almost_full <= 1'b0;
     else
       wr_fifo_almost_full <=wr_fifo_almost_full_next;

endmodule // fifo_full_block

   
