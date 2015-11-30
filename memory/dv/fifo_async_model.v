/* Parametrized fifo model*/
/* UGLY hacks, needs to be cleaned up!!!*/

module oh_fifo_async_model
   (/*AUTOARG*/
   // Outputs
   full, prog_full, dout, empty, valid,
   // Inputs
   rst, wr_clk, rd_clk, wr_en, din, rd_en
   );
   
   parameter DW    = 104;            //Fifo width 
   parameter DEPTH = 1;              //Fifo depth (entries)         
   parameter AW    = $clog2(DEPTH);  //FIFO address width (for model)

   //##########
   //# RESET/CLOCK
   //##########
   input           rst;       //asynchronous reset
   input           wr_clk;    //write clock   
   input           rd_clk;    //read clock   

   //##########
   //# FIFO WRITE
   //##########
   input           wr_en;   
   input  [DW-1:0] din;
   output          full;
   output 	   prog_full;
   
   //###########
   //# FIFO READ
   //###########
   input 	   rd_en;
   output [DW-1:0] dout;
   output          empty;
   output          valid;
    
   //Wires
   wire [DW/8-1:0] wr_vec;
   wire [AW:0]	   rd_gray_pointer_sync;
   wire [AW:0] 	   wr_gray_pointer_sync;
   wire [AW:0] 	   wr_gray_pointer;
   wire [AW:0] 	   rd_gray_pointer;
   wire [AW-1:0]   rd_addr;
   wire [AW-1:0]   wr_addr;

   reg 		   valid;
   
   
   assign wr_vec[DW/8-1:0] = {(DW/8){wr_en}};


   //Valid data at output
   always @ (posedge rd_clk or posedge rst)
     if(rst)
       valid <=1'b0;
     else
       valid <= rd_en;
   
   oh_memory_dp #(.DW(DW),.AW(AW)) memory_dp (
					   // Outputs
					   .rd_data	(dout[DW-1:0]),
					   // Inputs
					   .wr_clk	(wr_clk),
					   .wr_en	(wr_vec[DW/8-1:0]),
					   .wr_addr	(wr_addr[AW-1:0]),
					   .wr_data	(din[DW-1:0]),
					   .rd_clk	(rd_clk),
					   .rd_en	(rd_en),
					   .rd_addr	(rd_addr[AW-1:0]));

   //Read State Machine
   oh_fifo_empty_block #(.AW(AW)) fifo_empty_block(
						// Outputs
						.rd_fifo_empty	(empty),
                                                .rd_gray_pointer(rd_gray_pointer[AW:0]),	
						// Inputs
						.rd_addr	(rd_addr[AW-1:0]),
						.reset		(rst),
						.rd_clk		(rd_clk),
						.rd_wr_gray_pointer(wr_gray_pointer_sync[AW:0]),
						.rd_read	(rd_en));
   
   //Write circuit (and full indicator)
   oh_fifo_full_block #(.AW(AW)) full_block (
					      // Outputs
					      .wr_fifo_almost_full(),
					      .wr_fifo_full	(full),				      
					      .wr_gray_pointer	(wr_gray_pointer[AW:0]),
					      // Inputs
					      .wr_addr		(wr_addr[AW-1:0]),
					      .reset		(rst),
					      .wr_clk		(wr_clk),
					      .wr_rd_gray_pointer(rd_gray_pointer_sync[AW:0]),
					      .wr_write		(wr_en)
					  );
   

   //Half Full Indicator
   wire [AW-1:0]   hack_addr;
   
   assign hack_addr = wr_addr[AW-1:0]+AW/4;
   
   oh_fifo_full_block #(.AW(AW)) half_full_block (
					      // Outputs
					      .wr_fifo_almost_full(),
					      .wr_fifo_full	(prog_full),			      
					      .wr_gray_pointer	(),
					      // Inputs
					      .wr_addr		(hack_addr[AW-1:0]),//hack for now, need to move to better model
					      .reset		(rst),
					      .wr_clk		(wr_clk),
					      .wr_rd_gray_pointer(rd_gray_pointer_sync[AW:0]),
					      .wr_write		(wr_en));


   
   //Read pointer sync
   oh_dsync #(.DW(AW+1)) rd2wr_sync (.dout		(rd_gray_pointer_sync[AW:0]),
				     .din		(rd_gray_pointer[AW:0]),
				     .clk		(wr_clk));
   
   //Write pointer sync
   oh_dsync #(.DW(AW+1)) wr2rd_sync (.dout		(wr_gray_pointer_sync[AW:0]),
				     .din		(wr_gray_pointer[AW:0]),
				     .clk		(rd_clk));
   
      
endmodule // fifo_async
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:



