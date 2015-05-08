/*###########################################################################
 *#Clock buffer with built in divider
 *########################################################################### 
 *
 * Division ratios: 1,2,3,4,5,6,7,8, and bypass division ratings
 * 
 * BUFRs can drive:
 * -I/O logic
 * -logic resources
 * 
 * BUFRs can be driven by:
 * -SRCCs and MRCCs in the same clock region
 * -MRCCs in an adjacent clock region using BUFMRs
 * -MMCMs clock outputs 0-3 driving the HPC in the same clock region
 * -MMCMs clock outputs 0-3
 * -General interconnect 
 * 
 * Input to Output Delay (Zynq7010/7020): 1.04/0.80/0.64 (-1/-2/-3 grade) 
 * 
 */ 

module BUFR (/*AUTOARG*/
   // Outputs
   O,
   // Inputs
   I, CE, CLR
   );

   parameter BUFR_DIVIDE=4;
   parameter SIM_DEVICE=0;

   input I;   //clock input
   input CE;  //async output clock enable
   input CLR; //async clear for divider logic
   output O;  //clock output

   //assign O=I & CE & ~CLR;

   //TODO: need to paraemtrize this!!!   
   clock_divider clock_divider (
				// Outputs
				.clkout		(O),
				// Inputs
				.clkin		(I),
				.divcfg		(4'b0010),//div4
				.reset		(CLR)
				);
   
   
endmodule // IBUFDS
// Local Variables:
// verilog-library-directories:("../../common/hdl")
// End:
