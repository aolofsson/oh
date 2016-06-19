
module IBUFDS_GTE2 (
    O,
    ODIV2,

    CEB,
    I,
    IB
    );
`ifdef XIL_TIMING
    parameter LOC = "UNPLACED";
`endif
    parameter CLKCM_CFG = "TRUE";
    parameter CLKRCV_TRST = "TRUE";
    parameter [1:0] CLKSWING_CFG = 2'b11;

    output O;
    output ODIV2;

    input CEB;
    input I;
    input IB;



endmodule
