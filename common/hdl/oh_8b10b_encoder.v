module oh_8b10b_enc (/*AUTOARG*/
   // Outputs
   data_out,
   // Inputs
   clk, nreset, data_in
   );
         
   //#####################################################################
   //# INTERFACE
   //#####################################################################
   
   //clk/reset
   input 	   clk;   
   input 	   nreset;

   //Data
   input 	   data_in[7:0];
   output 	   data_out[9:0];

   

   
  
endmodule // oh_8b10b_enc

