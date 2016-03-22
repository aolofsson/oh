module oh_8b10b_encoder (/*AUTOARG*/
   // Outputs
   data_out,
   // Inputs
   clk, nreset, ksel, data_in
   );
         
   //#####################################################################
   //# INTERFACE
   //#####################################################################  

   input 	   clk;      //main clock
   input 	   nreset;   //async active low reset  
   input 	   ksel;     //select one of 12 K characters  
   input [7:0] 	   data_in;  //unencoded data input
   output [9:0]    data_out; //encoded data output

   //#####################################################################
   //# BODY
   //#####################################################################  

  
endmodule // oh_8b10b_encoder



