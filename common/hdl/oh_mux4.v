module oh_mux4(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   in0, in1, in2, in3, sel0, sel1, sel2, sel3
   );

   parameter DW=99;
  
   //data inputs
   input [DW-1:0]  in0;
   input [DW-1:0]  in1;
   input [DW-1:0]  in2;
   input [DW-1:0]  in3;
   
   //select inputs
   input           sel0;
   input           sel1;
   input 	   sel2;
   input 	   sel3;

   output [DW-1:0] out;

   wire 	   error;
   
  
   assign out[DW-1:0] = ({(DW){sel0}} & in0[DW-1:0] |
			 {(DW){sel1}} & in1[DW-1:0] |
			 {(DW){sel2}} & in2[DW-1:0] |
			 {(DW){sel3}} & in3[DW-1:0]);
   

   assign error = (sel0 | sel1 | sel2 | sel3) &
   		  ~(sel0 ^ sel1 ^ sel2 ^ sel3);

   always @ (posedge error)
     $display ("ERROR at in oh_mux4 %m at ",$time);
   			
endmodule // oh_mux4

