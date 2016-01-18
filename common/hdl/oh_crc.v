module oh_crc (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, nreset, en, in
   );
       
   //###############################################################
   //# Interface
   //###############################################################

   parameter DW   = 64;
   parameter TYPE = "CRC1";
  
   input           clk;
   input           nreset;   
   input 	   en;   
   input [DW-1:0]  in;
   output [DW-1:0] out;
   
		 		    
endmodule // oh_crc



 
