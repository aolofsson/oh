

module IBUFDS_DIFF_OUT (O, OB, I, IB);

    parameter DIFF_TERM = "FALSE";
    parameter DQS_BIAS = "FALSE";
    parameter IBUF_LOW_PWR = "TRUE";
    parameter IOSTANDARD = "DEFAULT";
`ifdef XIL_TIMING
    parameter LOC = " UNPLACED";
`endif
    output O, OB;

    input  I, IB;


endmodule
