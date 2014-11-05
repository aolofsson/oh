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
module debouncer (/*AUTOARG*/
   // Outputs
   clean_out,
   // Inputs
   clk, noisy_in
   );

   parameter N  = 20; //debouncer counter width
   

   input  clk;        //system clock
   input  noisy_in;   //bouncy input (convention says it goes low when button is pressed) 
   output clean_out;  //clean output (positive polarity)

 
   wire        expired;   
   wire        sync_in;
   reg [N-1:0] counter;
   wire        filtering;
   
   synchronizer #(1) synchronizer(.out		(sync_in),
			          .in		(noisy_in),
			          .clk		(clk),
			          .reset	(1'b0));
   
   //Counter that resets when sync_in is low
   always @ (posedge clk)
     if(sync_in)
       counter[N-1:0]={(N){1'b1}};
     else if(filtering)
       counter[N-1:0]=counter[N-1:0]-1'b1;

   assign filtering =|counter[N-1:0];
 
   assign clean_out = filtering | sync_in;
   

endmodule // debouncer
