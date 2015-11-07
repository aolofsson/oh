module IOBUFDS (O, IO, IOB, I, T);

`ifdef XIL_TIMING
    parameter LOC = "UNPLACED";
`endif // `ifdef XIL_TIMING
    parameter DIFF_TERM = "FALSE";
    parameter DQS_BIAS = "FALSE";
    parameter IBUF_LOW_PWR = "TRUE";
    parameter IOSTANDARD = "DEFAULT";
    parameter SLEW = "SLOW";

   localparam MODULE_NAME = "IOBUFDS";


    output O;
    inout  IO, IOB;
    input  I, T;

   assign O = IO & ~IOB;
   assign IO = T ? 1'bz : I;
   assign IOB = T ? 1'bz : ~I;
   
endmodule
