/* Detects the common aligned positive edge for a 
 * slow/fast clocks
 * 
 * NOTE: Assumes clocks are aligned and synchronous!
 *
 *    ___________             ___________
 * __/           \___________/           \  SLOWCLK
 *    __    __    __    __    __    __ 
 *  _/  \__/  \__/  \__/  \__/  \__/  \__/  FASTCLK
 *       ___________             _________   
 *    __/           \___________/           CLK45
 *             ___________             ___   
 *    ________/           \___________/     CLK135 
 * 
 * ____                    ______               
 *     \__________________/      \________  FIRSTEDGE 
 * 
 */

module edgealign (/*AUTOARG*/
   // Outputs
   firstedge,
   // Inputs
   fastclk, slowclk
   );
   
   input  fastclk;
   input  slowclk;
   output firstedge;

   reg 	  clk45;
   reg 	  clk135;
   reg 	  firstedge;

   always @ (negedge fastclk) 
     begin
	clk45     <= slowclk;
	clk135    <= clk45;
	firstedge <= ~clk45 & ~clk135;
     end

  //TODO: parametrized based on 1/N ratios?
   
endmodule // edgealign



