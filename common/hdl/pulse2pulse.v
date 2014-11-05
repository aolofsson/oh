/*
  Copyright (C) 2013 Adapteva, Inc.
  Contributed by Andreas Olofsson <support@adapteva.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program (see the file COPYING).  If not, see
  <http://www.gnu.org/licenses/>.
*/
module pulse2pulse(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   inclk, outclk, in, reset
   );

   
   //clocks
   input  inclk; 
   input  outclk;  

   
   input  in;   
   output out;

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
				  .out			(insync),
				  // Inputs
				  .in			(intoggle),
				  .clk			(outclk),
				  .reset		(reset));
   
   
   //toogle to pulse
   toggle2pulse toggle2pulse(
			     // Outputs
			     .out		(out),
			     // Inputs
			     .clk		(outclk),
			     .in		(insync),
			     .reset		(reset));
   

   
endmodule // pulse2pulse



