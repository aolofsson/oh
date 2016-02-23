module oh_iddr (/*AUTOARG*/
   // Outputs
   q1, q2,
   // Inputs
   clk, ce, din
   );

   //#########################################################
   //# INTERFACE
   //#########################################################

   //parameters
   parameter DW            = 32;
   parameter DDR_CLK_EDGE  = ""; //"OPPOSITE EDGE", "SAME EDGE", "SAME EDGE PIPELINE"
   localparam HOLDHACK     = 0.1;
      
   input 	    clk;    // clock
   input 	    ce;     // clock enable, set to high to clock in data
   input [DW-1:0]   din;    // data input 

   output [DW-1:0]  q1;     // iddr registered output (first) 
   output [DW-1:0]  q2;     // iddr registered output (second)    
  
   //#########################################################
   //# BODY
   //#########################################################

   //trick for string comparison?
   localparam [152:1] DDR_CLK_EDGE_REG = DDR_CLK_EDGE;

   reg [DW-1:0]     q1_pos;
   reg [DW-1:0]     q1_reg;

   reg [DW-1:0]     q2_pos;
   reg [DW-1:0]     q2_neg;
   
   always @ (posedge clk)
     if(ce)
       q1_pos[DW-1:0] <= #(HOLDHACK) din[DW-1:0];

   always @ (posedge clk)
     if(ce)
       q1_reg[DW-1:0] <= #(HOLDHACK) q1_pos[DW-1:0];
         
   always @ (negedge clk)
     if(ce)
       q2_neg[DW-1:0] <= #(HOLDHACK) din[DW-1:0];
   
   always @ (posedge clk)
     if(ce)
       q2_pos[DW-1:0] <= #(HOLDHACK) q2_neg[DW-1:0];

   //Select behavior based on parameters
   assign q1[DW-1:0] = (DDR_CLK_EDGE_REG == "SAME_EDGE_PIPELINED") ? q1_reg[DW-1:0] :
		       (DDR_CLK_EDGE_REG == "SAME_EDGE")           ? q1_pos[DW-1:0] :
	                                                             'b0;
   
   assign q2[DW-1:0] = (DDR_CLK_EDGE_REG == "SAME_EDGE_PIPELINED") ? q2_pos[DW-1:0] :
		       (DDR_CLK_EDGE_REG == "SAME_EDGE")           ? q2_pos[DW-1:0] :
	                                                             'b0;
            
endmodule // oh_iddr


