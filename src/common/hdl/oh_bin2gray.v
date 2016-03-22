module oh_bin2gray (/*AUTOARG*/
   // Outputs
   gray,
   // Inputs
   bin
   );

   //###############################################################
   //# Interface
   //###############################################################
   input [DW-1:0]  bin;       //binary encoded input
   output [DW-1:0] gray;      //gray encoded output

   parameter DW = 64;         //width of converter

   //###############################################################
   //# BODY
   //###############################################################
   reg [DW-1:0]    gray;
   integer 	   i;   
  
   always @*
     begin
	gray[DW-1] = bin[DW-1];   
	for (i=0; i<(DW-1); i=i+1)
	  gray[i] = bin[i] ^ bin[i+1];	      
     end
endmodule // oh_bin2gray


