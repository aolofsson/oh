
//convert serial stream to parallel
module oh_ser2par (/*AUTOARG*/
   // Inputs
   clk, din, dout
   );

   //###############################################################
   //# Interface
   //###############################################################

   input           clk;       //sampling clock
   input           din;       //serial data
   output [DW-1:0] dout;      //parallel data  

   parameter  DW  = 64;      //width of converter
   parameter TYPE = "MSB";   //MSB first or LSB first

   //###############################################################
   //# BODY
   //###############################################################
   reg [DW-1:0]    dout;
   generate
      if(TYPE=="MSB")
	begin
	   always @ (posedge clk)
	     dout[DW-1:0] = {dout[DW-2:0],din};
	end
      else
	begin
	   always @ (posedge clk)
	     dout[DW-1:0] = {din,dout[DW-1:1]};
	end
   endgenerate
   
endmodule // oh_ser2par

