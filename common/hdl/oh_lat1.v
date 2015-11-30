// # falling edge FF (output in_sh) follwowed by rising edge FF
// # has the following schematic representation:
// #
// #   negedge FF ->  posedge FF
// #       ||           ||
// #       \/           \/
// #    lat1-lat0 ->  lat0-lat1
// #              ||
// #              \/
// #    lat1-lat0 ->   lat1
// #       ||           ||
// #       \/           \/
// #  negedge FF  ->   lat1
module oh_lat1 (/*AUTOARG*/
   // Outputs
   out_sl,
   // Inputs
   in_sh, clk, lat_clk
   );

   parameter DW=99;

   input  [DW-1:0] in_sh; 
   input 	   clk;
   input 	   lat_clk;
   output [DW-1:0] out_sl;

   // # lat_clk is created in the following way:
   // #  1. clk_en -> lat0 -> clk_en_sh
   // #  2. lat_clk = clk_en_sh & clk 

   reg  [DW-1:0]    out_real_sl;
   wire [DW-1:0]    out_sl;

   /* verilator lint_off COMBDLY */
   // # Real lat1
   always @ (/*AUTOSENSE*/in_sh or lat_clk)
	if (lat_clk)
	  out_real_sl[DW-1:0] <= in_sh[DW-1:0];
   /* verilator lint_on COMBDLY */

`ifdef DV_FAKELAT
   // # posedge FF
   reg [DW-1:0]    out_dv_sl;
   always @ (posedge clk)
     out_dv_sl[DW-1:0] <= in_sh[DW-1:0];
   assign out_sl[DW-1:0] = out_dv_sl[DW-1:0];

`else 
   assign out_sl[DW-1:0] = out_real_sl[DW-1:0];
`endif // !`ifdef CFG_FAKELAT

endmodule // lat1

