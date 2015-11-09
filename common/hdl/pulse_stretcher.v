/*
 * This module stretches a pulse by DW+1 clock cycles
 * Can be useful for synchronous clock transfers from fast to slow.
 * 
 */
module pulse_stretcher (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, in
   );

   parameter DW = 1;
   
   input clk;
   input in;
   output out;

   reg [DW-1:0] wide_pulse;
   
   
   always @ (posedge clk)
     wide_pulse[DW-1:0] <= {wide_pulse[DW-2:0],in};

   assign out = (|{wide_pulse[DW-1:0],in});
   
endmodule // pulse_stretcher

  
