module oh_binary_decode (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   in
   );

   parameter  N  = 32;         // one hot bit width
   localparam NB = $clog2(N);  // encoded bit width
   
   input [NB-1:0] in;   
   output [N-1:0]  out;
   
   
   integer 	  i;      
   reg [N-1:0] 	  out;  

   always @*
     for(i=0;i<N;i=i+1)
       out[i]=(in[NB-1:0]==i);
   
endmodule // oh_binary_decode




