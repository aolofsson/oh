/* Model for xilinx async fifo*/
module fifo_async_104x32 
   (/*AUTOARG*/
   // Outputs
   full, prog_full, almost_full, dout, empty, valid,
   // Inputs
   wr_rst, rd_rst, wr_clk, rd_clk, wr_en, din, rd_en
   );
   
   parameter DW     = 104;//104 wide
   parameter DEPTH  = 16; //
   
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

   defparam fifo_model.DW=104;   
   defparam fifo_model.DEPTH=32;   

   fifo_async_model fifo_model (/*AUTOINST*/
				// Outputs
				.full		(full),
				.prog_full	(prog_full),
				.almost_full	(almost_full),
				.dout		(dout[DW-1:0]),
				.empty		(empty),
				.valid		(valid),
				// Inputs
				.wr_rst		(wr_rst),
				.rd_rst		(rd_rst),
				.wr_clk		(wr_clk),
				.rd_clk		(rd_clk),
				.wr_en		(wr_en),
				.din		(din[DW-1:0]),
				.rd_en		(rd_en));
      
      
endmodule // fifo_async
// Local Variables:
// verilog-library-directories:("." "../../memory/hdl")
// End:
