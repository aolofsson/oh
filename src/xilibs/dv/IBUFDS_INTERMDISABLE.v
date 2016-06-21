
module IBUFDS_INTERMDISABLE (O, I, IB, IBUFDISABLE, INTERMDISABLE);

`ifdef XIL_TIMING
  parameter LOC = "UNPLACED";
`endif // `ifdef XIL_TIMING
  parameter DIFF_TERM = "FALSE";
  parameter DQS_BIAS = "FALSE";
  parameter IBUF_LOW_PWR = "TRUE";
  parameter IOSTANDARD = "DEFAULT";
  parameter SIM_DEVICE = "7SERIES";
  parameter USE_IBUFDISABLE = "TRUE";

  localparam MODULE_NAME = "IBUFDS_INTERMDISABLE";


    output O;

    input  I;
    input  IB;
    input  IBUFDISABLE;
    input  INTERMDISABLE;

endmodule // IBUFDS_INTERMDISABLE
