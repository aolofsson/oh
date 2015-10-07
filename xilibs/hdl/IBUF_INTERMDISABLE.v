
module IBUF_INTERMDISABLE (O, I, IBUFDISABLE, INTERMDISABLE);

    parameter IBUF_LOW_PWR = "TRUE";
    parameter IOSTANDARD = "DEFAULT";
    parameter SIM_DEVICE = "7SERIES";
    parameter USE_IBUFDISABLE = "TRUE";
`ifdef XIL_TIMING
    parameter LOC = "UNPLACED";
`endif // `ifdef XIL_TIMING
    
    output O;

    input  I;
    input  IBUFDISABLE;
    input  INTERMDISABLE;

endmodule
