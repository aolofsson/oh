module IDDR (/*AUTOARG*/
   // Outputs
   Q1, Q2,
   // Inputs
   C, CE, D, R, S
   );

   //Default parameters
    parameter DDR_CLK_EDGE        = "OPPOSITE_EDGE";    
    parameter INIT_Q1             = 1'b0;
    parameter INIT_Q2             = 1'b0;
    parameter [0:0] IS_C_INVERTED = 1'b0;
    parameter [0:0] IS_D_INVERTED = 1'b0;
    parameter SRTYPE              = "SYNC";

   localparam HOLDHACK            = 0.1;
      
   output   Q1;   // IDDR registered output (first) 
   output   Q2;   // IDDR registered output (second)    
   input    C;    // clock
   input    CE;   // clock enable, set to high to clock in data
   input    D;    // data input from IOB
   input    R;    // sync or async reset
   input    S;    // syn/async "set to 1"

   //trick for string comparison
   localparam [152:1] DDR_CLK_EDGE_REG = DDR_CLK_EDGE;

   reg 	    Q1_pos;
   reg 	    Q1_reg;

   reg 	    Q2_pos;
   reg 	    Q2_neg;
   
   always @ (posedge C)
     if(CE)
       Q1_pos <= #(HOLDHACK) D;

   always @ (posedge C)
     if(CE)
       Q1_reg <= #(HOLDHACK) Q1_pos;
         
   always @ (negedge C)
     if(CE)
       Q2_neg <= #(HOLDHACK) D;
   
   always @ (posedge C)
     if(CE)
      Q2_pos <= #(HOLDHACK) Q2_neg;

   //Select behavior based on parameters
   assign Q1 = (DDR_CLK_EDGE_REG == "SAME_EDGE_PIPELINED") ? Q1_reg :
	       (DDR_CLK_EDGE_REG == "SAME_EDGE")           ? Q1_pos :
	                                                     1'b0;
   
   assign Q2 = (DDR_CLK_EDGE_REG == "SAME_EDGE_PIPELINED") ? Q2_pos :
	       (DDR_CLK_EDGE_REG == "SAME_EDGE")           ? Q2_pos :
	                                                     1'b0;
            
endmodule // IDDR

