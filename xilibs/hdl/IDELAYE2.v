/* verilator lint_off WIDTH */
module IDELAYE2 (/*AUTOARG*/
   // Outputs
   CNTVALUEOUT, DATAOUT,
   // Inputs
   C, CE, CINVCTRL, CNTVALUEIN, DATAIN, IDATAIN, INC, LD, LDPIPEEN,
   REGRST
   );

   parameter         CINVCTRL_SEL = "FALSE";          // Enable clock inversion
   parameter         DELAY_SRC = "IDATAIN";           // Delay input 
   parameter         HIGH_PERFORMANCE_MODE  = "FALSE";// Reduced jitter
   parameter         IDELAY_TYPE  = "FIXED";          // Type of delay line
   parameter integer IDELAY_VALUE = 0;                // Input delay tap setting
   parameter [0:0]   IS_C_INVERTED = 1'b0;            // 
   parameter [0:0]   IS_DATAIN_INVERTED = 1'b0;       //
   parameter [0:0]   IS_IDATAIN_INVERTED = 1'b0;      //
   parameter         PIPE_SEL = "FALSE";              // Select pipelined mode
   parameter real    REFCLK_FREQUENCY = 200.0;        // Ref clock frequency
   parameter         SIGNAL_PATTERN    = "DATA";      // Input signal type

`ifdef XIL_TIMING
    parameter LOC = "UNPLACED";
    parameter integer SIM_DELAY_D = 0;
    localparam DELAY_D = (IDELAY_TYPE == "VARIABLE") ? SIM_DELAY_D : 0;
`endif // ifdef XIL_TIMING

`ifndef XIL_TIMING
    integer DELAY_D=0;
`endif // ifndef XIL_TIMING

   output [4:0] CNTVALUEOUT; // count value for monitoring tap value
   output 	DATAOUT;     // delayed data
   input 	C;           // clock input for variable mode
   input 	CE;          // enable increment/decrement function
   input 	CINVCTRL;    // dynamically inverts clock polarity
   input [4:0] 	CNTVALUEIN;  // counter value for tap delay
   input 	DATAIN;      // data input from FGPA logic
   input 	IDATAIN;     // data input from IBUF
   input 	INC;         // increment tap delay
   input 	LD;          // loads the delay primitive
   input 	LDPIPEEN;    // enables the pipeline register delay 
   input 	REGRST;      // reset for pipeline register

   
   parameter real tap = 1 / (32 * 2 * (REFCLK_FREQUENCY/1000));
     
   reg [4:0] idelay_reg=5'b0;
   reg 	     DATAOUT;
   
   always @ (posedge C)
     if(LD)   
       begin
	  idelay_reg[4:0] <= CNTVALUEIN[4:0];  
       end
   
   //Variable delay
   always @ (IDATAIN)
     DATAOUT <= #(idelay_reg * tap) IDATAIN;

   
   //not modeled
   assign CNTVALUEOUT=5'b0;
   		  
endmodule // IDELAYE2



