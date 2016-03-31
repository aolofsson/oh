module oh_pwr_gate (/*AUTOARG*/);

   input  npower;   // active low power on
   input  vdd;      // input supply
   output vddg;     // gated supply

`ifdef TARGET_SIM
   assign vddg = ((vdd===1'b1) && (npower===1'b0)) ? 1'b1 : 1'bX; 		  
`else
`endif
      
endmodule // oh_pwr_gate
