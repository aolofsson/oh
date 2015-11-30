// # rising edge FF (output in_sl) follwowed by falling edge FF
// # has the following schematic representation:
// #
// #   posedge FF ->  negedge FF
// #       ||           ||
// #       \/           \/
// #    lat0-lat1 ->  lat1-lat0
// #              ||
// #              \/
// #    lat0-lat1 ->   lat0
// #       ||           ||
// #       \/           \/
// #  posedge FF  ->   lat0

module oh_lat0 (/*AUTOARG*/
   // Outputs
   out_sh,
   // Inputs
   in_sl, clk
   );

   parameter DW=99;

   input  [DW-1:0] in_sl; 
   input 	   clk;
   output [DW-1:0] out_sh;

   reg  [DW-1:0]   out_real_sh;

 
   /* verilator lint_off COMBDLY */
   // # Real lat0
   always @ (/*AUTOSENSE*/clk or in_sl)
     if (~clk)
       out_real_sh[DW-1:0] <= in_sl[DW-1:0];
   /* verilator lint_on COMBDLY */


`ifdef DV_FAKELAT
   // # negedge FF
   reg [DW-1:0]    out_dv_sh;
   always @ (negedge clk)
     out_dv_sh[DW-1:0] <= in_sl[DW-1:0];
   assign out_sh[DW-1:0] = out_dv_sh[DW-1:0];

   // #########################################
`else // !`ifdef DV_FAKELAT
   // #########################################
   assign out_sh[DW-1:0] = out_real_sh[DW-1:0];
   // #########################################
`endif // !`ifdef CFG_FAKELAT


endmodule // oh_lat0

