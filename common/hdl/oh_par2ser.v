
//convert parallel vector to serial stream
module oh_par2ser (/*AUTOARG*/
   // Inputs
   clk, din, load, dout
   );

   //###############################################################
   //# Interface
   //###############################################################

   input           clk;       //sampling clock   
   input [DW-1:0]  din;       //parallel data
   input 	   load;      //load parallel data   
   output 	   dout;      //serial output data  

   parameter DW   = 64;       //width of converter
   parameter TYPE = "LSB";    //LSB, transfer din[0] first
                              //MSB, transfer dinb[DW-1] first

   //###############################################################
   //# BODY
   //###############################################################

   reg [DW-1:0]    shiftreg;
   
   generate
      if(TYPE=="MSB")
	begin
	   assign dout = shiftreg[DW-1];	   

	   always @ (posedge clk)
	     if(load)
	       shiftreg[DW-1:0] = din[DW-1:0];	   
	     else		 
	       shiftreg[DW-1:0] = {shiftreg[DW-2:0],1'b0};
	  
	end
      else
	begin
	   assign dout = shiftreg[0];	   

	   always @ (posedge clk)
	     if(load)
	       shiftreg[DW-1:0] = din[DW-1:0];		
	     else		 
	       shiftreg[DW-1:0] = {1'b0,shiftreg[DW-1:1]};
	end
   endgenerate   
endmodule // oh_par2ser






