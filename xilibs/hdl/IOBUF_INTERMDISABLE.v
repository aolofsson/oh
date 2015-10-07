
module IOBUF_INTERMDISABLE (O, IO, I, IBUFDISABLE, INTERMDISABLE, T);

    parameter integer DRIVE = 12;
    parameter IBUF_LOW_PWR = "TRUE";
    parameter IOSTANDARD = "DEFAULT";
    parameter SIM_DEVICE = "7SERIES";
    parameter SLEW = "SLOW";
    parameter USE_IBUFDISABLE = "TRUE";
`ifdef XIL_TIMING
    parameter LOC = "UNPLACED";
`endif // `ifdef XIL_TIMING

    output O;
    inout  IO;
    input  I;
    input  IBUFDISABLE;
    input  INTERMDISABLE;
    input  T;

endmodule
