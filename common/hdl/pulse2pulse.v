module pulse2pulse(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   inclk, outclk, in, reset
   );

   input  in;      //input pulse (one clock cycle)
   input  inclk;   //input clock
   output out;     //one cycle wide pulse
   input  outclk;      


   //reset
   input  reset;

   wire   intoggle;
   wire   insync;
   
   
   //pulse to toggle
   pulse2toggle    pulse2toggle(
				// Outputs
				.out		(intoggle),
				// Inputs
				.clk		(inclk),
				.in		(in),
				.reset		(reset));
   
   //metastability synchronizer
   synchronizer #(1) synchronizer(
				  // Outputs
				  .out		(insync),
				  // Inputs
				  .in		(intoggle),
				  .clk		(outclk),
				  .reset	(reset));
   
   
   //toogle to pulse
   toggle2pulse toggle2pulse(
			     // Outputs
			     .out		(out),
			     // Inputs
			     .clk		(outclk),
			     .in		(insync),
			     .reset		(reset));
   

   
endmodule // pulse2pulse

