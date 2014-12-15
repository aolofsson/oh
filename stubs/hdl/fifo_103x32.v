module fifo_103x32(/*AUTOARG*/
   // Outputs
   dout, empty, full, prog_full,
   // Inputs
   din, rd_clk, rd_en, rst, wr_clk, wr_en
   );

   input  [102:0] din;
   output [102:0] dout;
   output 	  empty;
   output 	  full;
   output 	  prog_full;
   input 	  rd_clk;
   input 	  rd_en;
   input 	  rst;
   input 	  wr_clk;
   input 	  wr_en;

   assign dout = 103'b0;
   assign empty = 1'b0;
   assign full = 1'b0;
   assign prog_full = 1'b0;
  
endmodule // fifo_103x32



  