//#########################################################################
//# SYNCHRONOUS EDGE DETECTOR
//#########################################################################
module oh_edgedetect (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, cfg, in
   );
   
   //#####################################################################
   //# INTERFACE
   //#####################################################################
   parameter DW      = 32;  // Width of vector

   input            clk;    // clk
   input [1:0] 	    cfg;    // 00=off, 01=posedge, 10=negedge,11=any   
   input [DW-1:0]   in;     // input data
   output [DW-1:0]  out;    // output
   
   //#####################################################################
   //# BODY
   //#####################################################################
   reg [DW-1:0]     shadow_reg;
   wire [DW-1:0]    data_noedge;
   wire [DW-1:0]    data_posedge;
   wire [DW-1:0]    data_negedge;
   wire [DW-1:0]    data_anyedge;
   
   
   
   always @ (posedge clk)    
     shadow_reg[DW-1:0] <= in[DW-1:0];

   assign data_noedge[DW-1:0]  =  {(DW){1'b0}};
   assign data_posedge[DW-1:0] =  shadow_reg[DW-1:0] & ~in[DW-1:0];
   assign data_negedge[DW-1:0] = ~shadow_reg[DW-1:0] & in[DW-1:0];
   assign data_anyedge[DW-1:0] =  shadow_reg[DW-1:0] ^ in[DW-1:0];
   
   oh_mux4 #(.DW(DW))
   mux4 (.out (out[DW-1:0]),
         .in0 (data_noedge[DW-1:0]),  .sel0 (cfg==2'b00),
	 .in1 (data_posedge[DW-1:0]), .sel1 (cfg==2'b01),
	 .in2 (data_negedge[DW-1:0]), .sel2 (cfg==2'b10),
	 .in3 (data_anyedge[DW-1:0]), .sel3 (cfg==2'b11)
	 );

endmodule // oh_edgedetect



