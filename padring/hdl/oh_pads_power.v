//#############################################################################
//# Function:  Core Power/Ground Pads                                         #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:   MIT (see LICENSE file in OH repository)                        # 
//#############################################################################

module oh_pads_power 
  #(parameter NVDD   =  1,   // Number of vdd pads
    parameter NVSS   =  1,   // Number of vss pads
    parameter DIR    = "NO"  // Side: "NO", "SO", "EA", "WE"
    )
   (
    inout vss, // core ground
    inout vdd, // pre-driver supply
    inout vddio, // io digital supply
    inout vssio, // io ground
    inout poc // power on control signal
    );

`ifdef CFG_ASIC   

   //#############################
   //# CORE VDD PADS
   //#############################
   genvar  i;   
   generate
      for(i=0;i<NVDD;i=i+1)
	begin : g00
	   asic_vddpad #(.DIR(DIR))	   
	   ivdd (.vdd    (vdd),
		 .vss    (vss),
		 .vddio  (vddio),
		 .vssio  (vssio),
		 .poc    (poc));
	end      
   endgenerate
   
   //#############################
   //# CORE ROUND PADS
   //############################# 

   generate
      for(i=0;i<NVSS;i=i+1)
	begin : g10
	   asic_vsspad #(.DIR(DIR))
	   ivss (
		 .vdd    (vdd),
		 .vss    (vss),
		 .vddio  (vddio),
		 .vssio  (vssio),
		 .poc    (poc));
	end      
   endgenerate

`endif
   
endmodule // oh_pads_power

// Local Variables:
// verilog-library-directories:("." "/home/aolofsson/models/verilog") 
// End:
