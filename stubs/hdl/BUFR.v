module BUFR (/*AUTOARG*/
   // Outputs
   O,
   // Inputs
   I, CE, CLR
   );

   parameter BUFR_DIVIDE=4;
   parameter SIM_DEVICE=0;

   input I;
   input CE;
   input CLR;
   output O;

  
   //assign O=I & CE & ~CLR;

   //TODO: need to paraemtrize this!!!   
   clock_divider clock_divider (
				// Outputs
				.clkout		(O),
				.clkout90	(),
				// Inputs
				.clkin		(I),
				.divcfg		(4'b0010),//div4
				.reset		(CLR)
				);
   
   
endmodule // IBUFDS
// Local Variables:
// verilog-library-directories:("../../common/hdl")
// End:
