
module IBUFDS_INTERMDISABLE_INT (O, I, IB, IBUFDISABLE, INTERMDISABLE);

`ifdef XIL_TIMING
  parameter LOC = "UNPLACED";
`endif // `ifdef XIL_TIMING
  parameter DIFF_TERM = "FALSE";
  parameter DQS_BIAS = "FALSE";
  parameter IBUF_LOW_PWR = "TRUE";
  parameter IOSTANDARD = "DEFAULT";
  parameter USE_IBUFDISABLE = "TRUE";

  localparam MODULE_NAME = "IBUFDS_INTERMDISABLE_INT";


    output O;

    input  I;
    input  IB;
    input  IBUFDISABLE;
    input  INTERMDISABLE;

 
endmodule
