/*############################################################################
 * PROGRAMMABLE DELAY ELEMENT
 *
 * NOTE: NOT AVAILABLE IN HR BANKS!
 * 
 *############################################################################
 */

module ODELAYE2 (/*AUTOARG*/
   // Outputs
   CNTVALUEOUT, DATAOUT,
   // Inputs
   C, CE, CINVCTRL, CLKIN, CNTVALUEIN, INC, LD, LDPIPEEN, ODATAIN,
   REGRST
   );

    parameter CINVCTRL_SEL              = "FALSE";
    parameter DELAY_SRC                 = "ODATAIN";
    parameter HIGH_PERFORMANCE_MODE     = "FALSE";
    parameter [0:0] IS_C_INVERTED       = 1'b0;
    parameter [0:0] IS_ODATAIN_INVERTED = 1'b0;
    parameter ODELAY_TYPE               = "FIXED";
    parameter integer ODELAY_VALUE      = 0;
    parameter PIPE_SEL                  = "FALSE";
    parameter real REFCLK_FREQUENCY     = 200.0;
    parameter SIGNAL_PATTERN            = "DATA";

   input 	 C;           //clock for VARIABLE, VAR_LOAD,VAR_LOAD_PIPE mode
   input 	 REGRST;      //reset pipeline reg to all zeroes
   input 	 LD;          //loads programmed values depending on "mode"     
   input 	 CE;          //enable encrement/decrement function
   input 	 INC;         //increment/decrement tap delays
   input 	 CINVCTRL;    //dynamically inverts clock polarity
   input [4:0] 	 CNTVALUEIN;  //input value from FPGA logic
   input 	 CLKIN;       //clk from I/O clock mux??
   input 	 ODATAIN;     //data from OSERDESE2 output
   output 	 DATAOUT;     //delayed data to pin
   input 	 LDPIPEEN;    //enables pipeline reg??
   output [4:0]  CNTVALUEOUT; //current value for FPGA logic

   
   assign DATAOUT=ODATAIN;
      
endmodule // ODELAYE2
