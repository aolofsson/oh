//#############################################################################
//# Function: Aligns positive edge of slow clock to fast clock                #
//#           !!!Assumes clocks are aligned and synchronous!!!                #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################
/*
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
 */
module oh_edgealign (/*AUTOARG*/
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
   
endmodule // oh_edgealign




