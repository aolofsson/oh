/* Parametrized model for xilinx async fifo*/
module fifo_async_model
   (/*AUTOARG*/
   // Outputs
   full, prog_full, almost_full, dout, empty, valid,
   // Inputs
   wr_rst, rd_rst, wr_clk, rd_clk, wr_en, din, rd_en
   );
   
   parameter DW    = 104;            //Fifo width 
   parameter DEPTH = 1;              //Fifo depth (entries)         
   parameter AW    = $clog2(DEPTH);  //FIFO address width (for model)

   //##########
   //# RESET/CLOCK
   //##########
   input           wr_rst;     //asynchronous reset
   input           rd_rst;     //asynchronous reset
   input           wr_clk;    //write clock   
   input           rd_clk;    //read clock   

   //##########
   //# FIFO WRITE
   //##########
   input           wr_en;   
   input  [DW-1:0] din;
   output          full;
   output 	   prog_full;
   output 	   almost_full;
   
   //###########
   //# FIFO READ
   //###########
   input 	   rd_en;
   output [DW-1:0] dout;
   output          empty;
   output          valid;
    
   //Wires
   wire [DW/8-1:0] wr_vec;
   wire [AW:0]	   wr_rd_gray_pointer;
   wire [AW:0] 	   rd_wr_gray_pointer;
   wire [AW:0] 	   wr_gray_pointer;
   wire [AW:0] 	   rd_gray_pointer;
   wire [AW-1:0]   rd_addr;
   wire [AW-1:0]   wr_addr;

   reg 		   valid;
   
   
   assign wr_vec[DW/8-1:0] = {(DW/8){wr_en}};


   //Valid data at output
   always @ (posedge rd_clk or posedge rd_rst)
     if(rd_rst)
       valid <=1'b0;
     else
       valid <= rd_en;
   
   memory_dp #(.DW(DW),.AW(AW)) memory_dp (
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
   fifo_empty_block #(.AW(AW)) fifo_empty_block(
						// Outputs
						.rd_fifo_empty	(empty),
						.rd_addr	(rd_addr[AW-1:0]),
						.rd_gray_pointer(rd_gray_pointer[AW:0]),
						// Inputs
						.reset		(rd_rst),
						.rd_clk		(rd_clk),
						.rd_wr_gray_pointer(rd_wr_gray_pointer[AW:0]),
						.rd_read	(rd_en));
   
   //Write circuit (and full indicator)
   fifo_full_block #(.AW(AW)) full_block (
					      // Outputs
					      .wr_fifo_almost_full(almost_full),
					      .wr_fifo_full	(full),				      
					      .wr_addr		(wr_addr[AW-1:0]),
					      .wr_gray_pointer	(wr_gray_pointer[AW:0]),
					      // Inputs
					      .reset		(wr_rst),
					      .wr_clk		(wr_clk),
					      .wr_rd_gray_pointer(wr_rd_gray_pointer[AW:0]),
					      .wr_write		(wr_en));
   

   //Half Full Indicator
   fifo_full_block #(.AW(AW-1)) half_full_block (
					      // Outputs
					      .wr_fifo_almost_full(),
					      .wr_fifo_full	(prog_full),			      
					      .wr_addr		(wr_addr[AW-2:0]),
					      .wr_gray_pointer	(),
					      // Inputs
					      .reset		(wr_rst),
					      .wr_clk		(wr_clk),
					      .wr_rd_gray_pointer(wr_rd_gray_pointer[AW-1:0]),
					      .wr_write		(wr_en));


   
   //Read pointer sync
   synchronizer #(.DW(AW+1)) rd2wr_sync (.out		(wr_rd_gray_pointer[AW:0]),
					 .in		(rd_gray_pointer[AW:0]),
                                         .reset		(wr_rst),
					 .clk		(wr_clk));
   
   //Write pointer sync
   synchronizer #(.DW(AW+1)) wr2rd_sync (.out		(rd_wr_gray_pointer[AW:0]),
					 .in		(wr_gray_pointer[AW:0]),
                                         .reset		(rd_rst),
					 .clk		(rd_clk));
   
      
endmodule // fifo_async
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

