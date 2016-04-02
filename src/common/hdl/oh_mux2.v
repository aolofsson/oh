module oh_mux2(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   in0, in1, sel0, sel1
   );

   parameter DW=1;
   
   //data inputs
   input [DW-1:0]  in0;
   input [DW-1:0]  in1;
   
   //select inputs
   input  sel0;
   input  sel1;

   output [DW-1:0] out;
   
   assign out[DW-1:0] = ({(DW){sel0}} & in0[DW-1:0] |
			 {(DW){sel1}} & in1[DW-1:0]);
   
			   
endmodule // oh_mux2

