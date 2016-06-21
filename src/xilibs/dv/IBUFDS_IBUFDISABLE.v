

module IBUFDS_IBUFDISABLE (O, I, IB, IBUFDISABLE);

`ifdef XIL_TIMING
  parameter LOC = "UNPLACED";
`endif // `ifdef XIL_TIMING
  parameter DIFF_TERM = "FALSE";
  parameter DQS_BIAS = "FALSE";
  parameter IBUF_LOW_PWR = "TRUE";
  parameter IOSTANDARD = "DEFAULT";
  parameter SIM_DEVICE = "7SERIES";
  parameter USE_IBUFDISABLE = "TRUE";

  localparam MODULE_NAME = "IBUFDS_IBUFDISABLE";


    output O;

    input  I;
    input  IB;
    input  IBUFDISABLE;
   
endmodule
