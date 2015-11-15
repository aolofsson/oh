/* Detects the common aligned positive edge for a 
 * slow/fast clocks. The circuit uses the negedge of the fast clock
 * to sample the slow clock. Output is positive edge sampled.
 * 
 * NOTE: Assumes clocks are aligned and synchronous!
 *
 *    ___________             ___________
 * __/           \___________/           \   SLOWCLK
 *    __    __    __    __    __    __ 
 *  _/  \__/  \__/  \__/  \__/  \__/  \__/   FASTCLK
 *        ___________              _________   
 *    ___/ 1     1   \_0_____0____/          CLK45
 *           ____________              ___   
 *    ______/    1     1 \___0____0___/      CLK90 
 * 
 * ____                  ______               
 *     \________________/      \________     FIRSTEDGE 
 * 
 *                      
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
   reg 	  clk90;
   reg 	  firstedge;

   always @ (negedge fastclk) 
     clk45     <= slowclk;

   always @ (posedge fastclk) 
     begin
	clk90     <= clk45;
	firstedge <= ~clk45 & clk90;
     end
   
  //TODO: parametrized based on 1/N ratios?
   
endmodule // edgealign



