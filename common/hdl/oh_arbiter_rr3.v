//#############################################################################
//# Function: 3 port clocked round-robin arbiter                              #
//#############################################################################
//# Author:   Ola Jeppsson                                                    #
//# SPDX-License-Identifier:     MIT                                          #
//#############################################################################

module oh_arbiter_rr3(/*AUTOARG*/
   // Outputs
   grants,
   // Inputs
   clk, nreset, requests
   );

   parameter		CW = 4;    //counter width

   input		clk;       //clock
   input		nreset;    //negative reset

   input  [2:0]		requests;  //request vector
   output [2:0]		grants;    //grant (one hot)

   // Regs
   reg  [1:0]		state;
   reg  [CW-1:0]	counter;

   // Wires
   wire  [2:0]		grants;
   wire			next;

   always @(posedge clk or negedge nreset)
     if (!nreset)
       counter <= {(CW){1'b0}};
     else
       counter <= counter[CW-1:0] + 1'b1;

   /* TOKEN STATE MACHINE */
`define R0 2'b00 /* Favour requests[0] */
`define R1 2'b01 /* Favour requests[1] */
`define R2 2'b10 /* Favour requests[2] */

   assign next = nreset & ~(|(counter[CW-1:0]));

   always @(posedge next or negedge nreset)
     if (!nreset)
	 state[1:0]  <= `R2;
     else
       case (state[1:0])
	 `R2:		state[1:0]  <= `R0;
	 `R1:		state[1:0]  <= `R2;
	 default:	state[1:0]  <= `R1;
       endcase

   /* NOTE: We always grant access, even when there are no requests.
    * oh_fifo_cdc deasserts its access_out when wait_in is high. */
   assign grants[2:0] = state[1:0] == `R2 ?
			  (requests[2] ? 3'b100 :
			   requests[0] ? 3'b001 :
			   requests[1] ? 3'b010 : 3'b100)
		      : state[1:0] == `R1 ?
			  (requests[1] ? 3'b010 :
			   requests[2] ? 3'b100 :
			   requests[0] ? 3'b001 : 3'b010)
		      :
			  (requests[0] ? 3'b001 :
			   requests[1] ? 3'b010 :
			   requests[2] ? 3'b100 : 3'b001);

endmodule // oh_arbiter_rr3

// Local Variables:
// verilog-library-directories:(".")
// End:
