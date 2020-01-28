module IOBUFDSE3 #(
`ifdef XIL_TIMING
  parameter LOC = "UNPLACED",
`endif
  parameter DIFF_TERM = "FALSE",
  parameter DQS_BIAS = "FALSE",
  parameter IBUF_LOW_PWR = "TRUE",
  parameter IOSTANDARD = "DEFAULT",
  parameter integer SIM_INPUT_BUFFER_OFFSET = 0,
  parameter USE_IBUFDISABLE = "FALSE"
)(
  output O,

  inout IO,
  inout IOB,

  input DCITERMDISABLE,
  input I,
  input IBUFDISABLE,
  input [3:0] OSC,
  input [1:0] OSC_EN,
  input T
);
  
// define constants
  localparam MODULE_NAME = "IOBUFDSE3";
  localparam in_delay    = 0;
  localparam out_delay   = 0;
  localparam inclk_delay    = 0;
  localparam outclk_delay   = 0;

// Parameter encodings and registers
  localparam DIFF_TERM_FALSE = 0;
  localparam DIFF_TERM_TRUE = 1;
  localparam DQS_BIAS_FALSE = 0;
  localparam DQS_BIAS_TRUE = 1;
  localparam IBUF_LOW_PWR_FALSE = 1;
  localparam IBUF_LOW_PWR_TRUE = 0;
  localparam USE_IBUFDISABLE_FALSE = 0;
  localparam USE_IBUFDISABLE_TRUE = 1;

// include dynamic registers - XILINX test only
  reg trig_attr = 1'b0;
  localparam [40:1] DIFF_TERM_REG = DIFF_TERM;
  localparam [40:1] DQS_BIAS_REG = DQS_BIAS;
  localparam [40:1] IBUF_LOW_PWR_REG = IBUF_LOW_PWR;
  localparam integer SIM_INPUT_BUFFER_OFFSET_REG = SIM_INPUT_BUFFER_OFFSET;
  localparam [40:1] USE_IBUFDISABLE_REG = USE_IBUFDISABLE;


endmodule
