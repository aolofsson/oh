module oh_bitreverse (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   in
   );

   parameter DW = 64;      // width operation

   input [DW-1:0]  in;     // data input
   output [DW-1:0] out;    // bit reversed output
   
   reg [DW-1:0]    out;        
   integer 	   i;
   
   always @*
     for (i=0;i<DW;i=i+1)
       out[i]=in[DW-1-i];   
   
endmodule // oh_bitreverse






