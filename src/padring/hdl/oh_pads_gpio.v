//#############################################################################
//# Function: GPIO Pads                                                       #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         # 
//#############################################################################
//#
//#  IO BUFFER CONFIG
//#  0    = pull_enable (1=enable)
//#  1    = pull_select (1=pull up)
//#  2    = slew limiter
//#  3    = shmitt trigger enable
//#  4    = ds[0]
//#  5    = ds[1]
//#  6    = ds[2]
//#  7    = ds[3]
//#
//#############################################################################

module oh_pads_gpio 
  #(parameter NGPIO  =  8,   // total IO signal pads
    parameter NVDDIO =  8,   // total IO supply pads
    parameter NVSSIO =  8,   // total IO ground pads
    parameter DIR    = "NO"  // "NO", "SO", "EA", "WE"
    )
   (//pad
    inout [NGPIO-1:0] 	pad, // pad
    //feed through signals
    inout 		vddio, // io supply
    inout 		vssio, // io ground
    inout 		vdd, // core supply
    inout 		vss, // common ground
    inout 		poc, // power-on-ctrl
    //core facing signals
    input [NGPIO-1:0] 	dout, // data to drive to pad
    output [NGPIO-1:0] 	din, // data from pad
    input [NGPIO-1:0] 	oen, // output enable (bar)
    input [NGPIO-1:0] 	ie, // input enable
    input [NGPIO*8-1:0] cfg // io config
    );
   
   //########################################################
   //# GPIO PINS
   //########################################################
   
   genvar 	     i;   
   generate
      for(i=0;i<NGPIO;i=i+1)
	begin : g00
`ifdef CFG_ASIC
	   asic_iobuf #(.DIR(DIR))
	   dpad (// Outputs
		 .out	   (din[i]),
		 // Inouts
		 .poc	  (poc),
		 .vdd	  (vdd),
		 .vss	  (vss),
		 .vddio   (vddio),
		 .vssio   (vssio),
		 .pad	  (pad[i]),
		 // Inputs
		 .pe	  (cfg[8*i]),
		 .ie	  (ie[i]),
		 .i	  (dout[i]),
		 .oen	  (oen[i]),
		 .ps	  (cfg[8*i+1]),
		 .sl	  (cfg[8*i+2]),
		 .ds      (cfg[(8*i+4)+:4]));
`else
	   assign din[i] = pad[i] & ie[i];
	   assign pad[i] = ~oen ? dout[i] : 1'bz;
`endif
	end	   
   endgenerate
   
   //########################################################
   //# IO SUPPLY PINS
   //########################################################
`ifdef CFG_ASIC
   generate
      for(i=0;i<NVDDIO;i=i+1) 
	begin : g10
	   //VDDIO
	   asic_iosupply #(.DIR(DIR))
	   ivddio (.vdd     (vdd),
		   .vss     (vss),
		   .vddio   (vddio),
		   .vssio   (vssio),
		   .poc     (poc));
	end      
   endgenerate
`endif

   //########################################################
   //# IO GROUND PINS
   //########################################################

`ifdef CFG_ASIC   
   generate
      for(i=0;i<NVSSIO;i=i+1) 
	begin : g10
	   //VSSIO
	   asic_ioground #(.DIR(DIR))
	   ivssio (.vdd     (vdd),
		   .vss     (vss),
		   .vddio   (vddio),
		   .vssio   (vssio),
		   .poc     (poc));
	end
   endgenerate
`endif
   
endmodule // io_pads_gpio
// Local Variables:
// verilog-library-directories:("." ) 
// End:



