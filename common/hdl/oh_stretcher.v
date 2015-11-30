/*
 * This module stretches a pulse by DW+1 clock cycles
 * Can be useful for synchronous clock transfers from fast to slow.
 * The block has one cycle latency 
 * 
 * in 
 * clk
 * out
 * 
 */
module oh_stretcher (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, in, nrst
   );

   parameter CYCLES = 4;
   
   input  clk;
   input  in; 
   input  nrst;   
   output out;

   reg [CYCLES-1:0] valid;
      
   always @ (posedge clk)
     if(!nrst)       
       valid[CYCLES-1:0] <='b0;   
     else if(in)
       valid[CYCLES-1:0] <={(CYCLES){1'b1}};   
     else
       valid[CYCLES-1:0] <={valid[CYCLES-2:0],1'b0};

   assign out = valid[CYCLES-1];
   
endmodule // oh_stretcher


  
