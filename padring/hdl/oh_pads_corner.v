//#############################################################################
//# Function: Corner Pads                                                     #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         # 
//#############################################################################

module oh_pads_corner
  (//feed through signals
   inout 	       vddio, // io supply
   inout 	       vssio, // io ground
   inout 	       vdd, // core supply
   inout 	       vss // common ground
   );

   asic_iocorner i0 (
     .vddio,
     .vssio,
     .vdd,
     .vss
   );
  
endmodule // oh_pads_corner

