//#############################################################################
//# Function: Padring Generator                                               #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module oh_padring
  #(parameter TYPE       = "SOFT",// asic cell type selector
    parameter NO_DOMAINS =  1,    // total domains
    parameter NO_GPIO    =  8,    // total IO signal pads
    parameter NO_VDDIO   =  8,    // total IO supply pads
    parameter NO_VSSIO   =  8,    // total IO ground pads
    parameter NO_VDD     =  8,    // total core supply pads
    parameter NO_VSS     =  8,    // total core ground pads
    parameter SO_DOMAINS =  1,    // ...
    parameter SO_GPIO    =  8,
    parameter SO_VDDIO   =  8,
    parameter SO_VSSIO   =  8,
    parameter SO_VDD     =  8,
    parameter SO_VSS     =  8,
    parameter EA_DOMAINS =  1,
    parameter EA_GPIO    =  8,
    parameter EA_VDDIO   =  8,
    parameter EA_VSSIO   =  8,
    parameter EA_VDD     =  8,
    parameter EA_VSS     =  8,
    parameter WE_DOMAINS =  1,
    parameter WE_GPIO    =  8,
    parameter WE_VDDIO   =  8,
    parameter WE_VSSIO   =  8,
    parameter WE_VDD     =  8,
    parameter WE_VSS     =  8,
    parameter ENABLE_CUT = 1,
    parameter ENABLE_POC  = 1,
    parameter TECH_CFG_WIDTH = 16,
    parameter TECH_RING_WIDTH = 8
    )
   (
    //CONTINUOUS GROUND
    inout 		   vss,

    inout 		   vdd,
    //NORTH
    inout [NO_DOMAINS-1:0] no_vddio,
    inout [NO_DOMAINS-1:0] no_vssio,
    inout [NO_GPIO-1:0]    no_pad, // pad
    output [NO_GPIO-1:0]   no_din, // data from pad
    input [NO_GPIO-1:0]  no_dout, // data to pad
    input [NO_GPIO*8-1:0]  no_cfg, // config
    input [NO_GPIO-1:0]    no_ie, // input enable
    input [NO_GPIO-1:0]    no_oen, // output enable (bar)
    input [NO_GPIO*TECH_CFG_WIDTH-1:0] no_tech_cfg,
    //SOUTH
    inout [SO_DOMAINS-1:0] so_vddio,
    inout [SO_DOMAINS-1:0] so_vssio,
    inout [SO_GPIO-1:0]    so_pad, // pad
    output [SO_GPIO-1:0]   so_din, // data from pad
    input [SO_GPIO-1:0]  so_dout, // data to pad
    input [SO_GPIO*8-1:0]  so_cfg, // config
    input [SO_GPIO-1:0]    so_ie, // input enable
    input [SO_GPIO-1:0]    so_oen, // output enable (bar)
    input [SO_GPIO*TECH_CFG_WIDTH-1:0] so_tech_cfg,
    //EAST
    inout [EA_DOMAINS-1:0] ea_vddio,
    inout [EA_DOMAINS-1:0] ea_vssio,
    inout [EA_GPIO-1:0]    ea_pad, // pad
    output [EA_GPIO-1:0]   ea_din, // data from pad
    input [EA_GPIO-1:0]  ea_dout, // data to pad
    input [EA_GPIO*8-1:0]  ea_cfg, // config
    input [EA_GPIO-1:0]    ea_ie, // input enable
    input [EA_GPIO-1:0]    ea_oen, // output enable (bar)
    input [EA_GPIO*TECH_CFG_WIDTH-1:0] ea_tech_cfg,
    //WEST
    inout [WE_DOMAINS-1:0] we_vddio,
    inout [WE_DOMAINS-1:0] we_vssio,
    inout [WE_GPIO-1:0]    we_pad, // pad
    output [WE_GPIO-1:0]   we_din, // data from pad
    input [WE_GPIO-1:0]  we_dout, // data to pad
    input [WE_GPIO*8-1:0]  we_cfg, // config
    input [WE_GPIO-1:0]    we_ie, // input enable
    input [WE_GPIO-1:0]    we_oen, // output enable (bar)
    input [WE_GPIO*TECH_CFG_WIDTH-1:0] we_tech_cfg
    );


   //Local wires
   wire [NO_DOMAINS-1:0]   no_poc;
   wire [SO_DOMAINS-1:0]   so_poc;
   wire [WE_DOMAINS-1:0]   we_poc;
   wire [EA_DOMAINS-1:0]   ea_poc;

   wire [TECH_RING_WIDTH-1:0] ring;

   generate
      genvar 		  i;

      //#############################
      // NORTH
      //#############################

      for(i=0;i<NO_DOMAINS;i=i+1)
        begin: no_pads
           oh_pads_domain #(.DIR("NO"),
                            .TYPE(TYPE),
                            .NGPIO(NO_GPIO),
                            .NVDDIO(NO_VDDIO),
                            .NVSSIO(NO_VSSIO),
                            .NVDD(NO_VDD),
                            .NVSS(NO_VSS),
                            .POC(ENABLE_POC),
                            .LEFTCUT(ENABLE_CUT),
                            .RIGHTCUT(ENABLE_CUT),
                            .TECH_CFG_WIDTH(TECH_CFG_WIDTH))
           i0 (.vdd     (vdd),
               .vss     (vss),
               // Outputs
               .din     (no_din[NO_GPIO-1:0]),
               // Inouts
               .pad     (no_pad[NO_GPIO-1:0]),
               .vddio   (no_vddio[i]),
               .vssio	(no_vssio[i]),
               .poc	(no_poc[i]),
               .ring(ring),
               // Inputs
               .dout	(no_dout[NO_GPIO-1:0]),
               .oen	(no_oen[NO_GPIO-1:0]),
               .ie	(no_ie[NO_GPIO-1:0]),
               .cfg	(no_cfg[NO_GPIO*8-1:0]),
               .tech_cfg(no_tech_cfg));
        end

      //#############################
      // SOUTH
      //#############################

      for(i=0;i<SO_DOMAINS;i=i+1)
        begin: so_pads
           oh_pads_domain #(.DIR("SO"),
                            .TYPE(TYPE),
                            .NGPIO(SO_GPIO),
                            .NVDDIO(SO_VDDIO),
                            .NVSSIO(SO_VSSIO),
                            .NVDD(SO_VDD),
                            .NVSS(SO_VSS),
                            .POC(ENABLE_POC),
                            .LEFTCUT(ENABLE_CUT),
                            .RIGHTCUT(ENABLE_CUT),
                            .TECH_CFG_WIDTH(TECH_CFG_WIDTH))
           i0 (.vdd     (vdd),
               .vss     (vss),
               // Outputs
               .din     (so_din[SO_GPIO-1:0]),
               // Inouts
               .pad     (so_pad[SO_GPIO-1:0]),
               .vddio   (so_vddio[i]),
               .vssio	(so_vssio[i]),
               .poc	(so_poc[i]),
               .ring(ring),
               // Inputs
               .dout	(so_dout[SO_GPIO-1:0]),
               .oen	(so_oen[SO_GPIO-1:0]),
               .ie	(so_ie[SO_GPIO-1:0]),
               .cfg	(so_cfg[SO_GPIO*8-1:0]),
               .tech_cfg(so_tech_cfg));
        end


      //#############################
      // EAST
      //#############################

      for(i=0;i<EA_DOMAINS;i=i+1)
        begin: ea_pads
           oh_pads_domain #(.DIR("EO"),
                            .TYPE(TYPE),
                            .NGPIO(EA_GPIO),
                            .NVDDIO(EA_VDDIO),
                            .NVSSIO(EA_VSSIO),
                            .NVDD(EA_VDD),
                            .NVSS(EA_VSS),
                            .POC(ENABLE_POC),
                            .LEFTCUT(ENABLE_CUT),
                            .RIGHTCUT(ENABLE_CUT),
                            .TECH_CFG_WIDTH(TECH_CFG_WIDTH))
           i0 (.vdd     (vdd),
               .vss     (vss),
               // Outputs
               .din     (ea_din[EA_GPIO-1:0]),
               // Inouts
               .pad     (ea_pad[EA_GPIO-1:0]),
               .vddio   (ea_vddio[i]),
               .vssio	(ea_vssio[i]),
               .poc	(ea_poc[i]),
               .ring(ring),
               // Inputs
               .dout	(ea_dout[EA_GPIO-1:0]),
               .oen	(ea_oen[EA_GPIO-1:0]),
               .ie	(ea_ie[EA_GPIO-1:0]),
               .cfg	(ea_cfg[EA_GPIO*8-1:0]),
               .tech_cfg(ea_tech_cfg));

        end

      //#############################
      // WEST
      //#############################

      for(i=0;i<WE_DOMAINS;i=i+1)
        begin: we_pads
           oh_pads_domain #(.DIR("WE"),
                            .TYPE(TYPE),
                            .NGPIO(WE_GPIO),
                            .NVDDIO(WE_VDDIO),
                            .NVSSIO(WE_VSSIO),
                            .NVDD(WE_VDD),
                            .NVSS(WE_VSS),
                            .POC(ENABLE_POC),
                            .LEFTCUT(ENABLE_CUT),
                            .RIGHTCUT(ENABLE_CUT),
                            .TECH_CFG_WIDTH(TECH_CFG_WIDTH))

           i0 (.vdd     (vdd),
               .vss     (vss),
               // Outputs
               .din     (we_din[WE_GPIO-1:0]),
               // Inouts
               .pad     (we_pad[WE_GPIO-1:0]),
               .vddio   (we_vddio[i]),
               .vssio	(we_vssio[i]),
               .poc	(we_poc[i]),
               .ring(ring),
               // Inputs
               .dout	(we_dout[WE_GPIO-1:0]),
               .oen	(we_oen[WE_GPIO-1:0]),
               .ie	(we_ie[WE_GPIO-1:0]),
               .cfg	(we_cfg[WE_GPIO*8-1:0]),
               .tech_cfg(we_tech_cfg));

        end

   endgenerate

endmodule // oh_padring
