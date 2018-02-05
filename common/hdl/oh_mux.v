//#########################################################################
//# GENERIC "ONE HOT" N:1 MUX
//# See also oh_mux2.v, oh_mux3.v, etc
//#########################################################################
module oh_mux (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   sel, in
   );
   
   //#####################################################################
   //# INTERFACE
   //#####################################################################
   parameter DW      = 32; // width of data inputs
   parameter N       = 99; 

   input [N-1:0]    sel;  // select vector
   input [N*DW-1:0] in;   // concatenated input {..,in1[DW-1:0],in0[DW-1:0]
   output [DW-1:0]  out;  // output
   
   //#####################################################################
   //# BODY
   //#####################################################################
   reg [DW-1:0]     out;
   
   //parametrized mux
   integer 	    i;   
   always @*
     begin
	out[DW-1:0] = 'b0;
	for(i=0;i<N;i=i+1)
	  out[DW-1:0] = out[DW-1:0] | {(DW){sel[i]}} & in[((i+1)*DW-1)-:DW];
     end

endmodule // oh_mux


