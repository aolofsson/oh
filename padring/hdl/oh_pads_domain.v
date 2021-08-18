//#############################################################################
//# Function:  A Padring IO Domain                                            #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:   MIT (see LICENSE file in OH repository)                        #
//#############################################################################

module oh_pads_domain
  #(parameter TYPE     = "SOFT",// asic cell type selector
    parameter DIR      = "NO",  // "NO", "SO", "EA", "WE"
    parameter NGPIO    =  8,    // total IO signal pads
    parameter NVDDIO   =  8,    // total IO supply pads
    parameter NVSSIO   =  8,    // total IO ground pads
    parameter NVDD     =  8,    // total core supply pads
    parameter NVSS     =  8,    // total core ground pads
    parameter POC      =  1,    // 1 = place poc cell
    parameter LEFTCUT  =  1,    // 1 = place cut on left (seen from center)
    parameter RIGHTCUT =  1,    // 1 = place cut on right (seen from center
    parameter TECH_CFG_WIDTH = 16,
    parameter TECH_RING_WIDTH = 8
    )
   (//pad
    inout [NGPIO-1:0] 	pad, // pad
    //feed through signals
    inout 		vddio, // io supply
    inout 		vssio, // io ground
    inout 		vdd, // core supply
    inout 		vss, // common ground
    inout 		poc, // power-on-ctrl

    inout [TECH_RING_WIDTH-1:0] ring,

    //core facing signals
    input [NGPIO-1:0] 	dout, // data to drive to pad
    output [NGPIO-1:0] 	din, // data from pad
    input [NGPIO-1:0] 	oen, // output enable (bar)
    input [NGPIO-1:0] 	ie, // input enable
    input [NGPIO*8-1:0] cfg, // io config
    input [NGPIO*TECH_CFG_WIDTH-1:0] tech_cfg // technology-specific config
    );

   generate
      genvar 		i;

      //#####################
      //# IO BUFFERS
      //#####################

      for(i=0;i<NGPIO;i=i+1)
	begin : padio
	   asic_iobuf #(.DIR(DIR),
			.TYPE(TYPE))
	   i0 (// data to core
	       .din    (din[i]),
	       // data from core
	       .dout   (dout[i]),
	       //tristate controls
	       .ie     (ie[i]),
	       .oen    (oen[i]),
	       // config signals
	       .cfg    (cfg[i*8+:8]),
	       // padring signals
	       .poc    (poc),
	       .vdd    (vdd),
	       .vss    (vss),
	       .vddio  (vddio),
	       .vssio  (vssio),
	       .pad    (pad[i]),

	       .ring(ring),

	       .tech_cfg(tech_cfg[i*TECH_CFG_WIDTH+:TECH_CFG_WIDTH]));
	end

      //######################
      //# IO SUPPLY PINS
      //######################

      for(i=0;i<NVDDIO;i=i+1)
	begin : padvddio
	   asic_iovddio #(.DIR(DIR),
			.TYPE(TYPE))
	   i0 (.vdd     (vdd),
	       .vss     (vss),
	       .vddio   (vddio),
	       .vssio   (vssio),
	       .ring(ring),
	       .poc     (poc));
	end

      //######################
      //# IO GROUND PINS
      //######################

      for(i=0;i<NVSSIO;i=i+1)
	begin: padvssio
	   asic_iovssio #(.DIR(DIR),
			.TYPE(TYPE))
	   i0 (.vdd     (vdd),
	       .vss     (vss),
	       .vddio   (vddio),
	       .vssio   (vssio),
	       .ring(ring),
	       .poc     (poc));
	end

      //######################
      //# CORE SUPPLY PINS
      //######################
      for(i=0;i<NVDD;i=i+1)
	begin: padvdd
	   asic_iovdd #(.DIR(DIR),
			.TYPE(TYPE))
	   i0 (.vdd     (vdd),
	       .vss     (vss),
	       .vddio   (vddio),
	       .vssio   (vssio),
	       .ring(ring),
	       .poc     (poc));
	end

      //######################
      //# CORE GROUND PINS
      //######################
      for(i=0;i<NVSS;i=i+1)
	begin: padvss
	   asic_iovss #(.DIR(DIR),
			.TYPE(TYPE))
	   i0 (.vdd     (vdd),
	       .vss     (vss),
	       .vddio   (vddio),
	       .vssio   (vssio),
	       .ring(ring),
	       .poc     (poc));
	end

      //######################
      //# CUT CELLS
      //######################
      if (LEFTCUT==1)
	begin: padcutleft
	   asic_iocut #(.DIR(DIR),
			.TYPE(TYPE))
	   i0 (.vdd     (vdd),
	       .vss     (vss),
	       .vddio   (vddio),
	       .vssio   (vssio),
	       .poc     (poc));
	end

      if (RIGHTCUT==1)
	begin: padcutright
	   asic_iocut #(.DIR(DIR),
			.TYPE(TYPE))
	   i0 (.vdd     (vdd),
	       .vss     (vss),
	       .vddio   (vddio),
	       .vssio   (vssio),
	       .poc     (poc));
	end

      //######################
      //# POWER ON CONTROL
      //######################
      if (POC==1)
	begin: padpoc
	   asic_iopoc #(.DIR(DIR),
			.TYPE(TYPE))
	   i0 (.vdd     (vdd),
	       .vss     (vss),
	       .vddio   (vddio),
	       .vssio   (vssio),
	       .poc     (poc));
	end

   endgenerate

endmodule
// Local Variables:
// verilog-library-directories:("." )
// End:



