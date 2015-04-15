// ###############################################################
// # FUNCTION: Synchronous clock divider that divides by integer
// ############################################################### 

module clock_divider(/*AUTOARG*/
   // Outputs
   clkout, clkout90,
   // Inputs
   clkin, divcfg, reset
   );

   input       clkin;    // Input clock
   input [3:0] divcfg;   // Divide factor
   input       reset;    // Counter init

   output      clkout;   // Divided clock phase aligned with clkin 
   output      clkout90; // Divided clock with 90deg phase shift with clkout


   reg        clkout_reg;
   reg [7:0]  counter;   
   reg [7:0]  divcfg_dec;

   wire       div2_sel;
   wire       div1_sel;   
   wire       posedge_match;
   wire       negedge_match;  
   wire       posedge90_match;
   wire       negedge90_match; 
   
   wire       clkout90_div2_in;
   wire       clkout90_div4_in;
   
   reg 	      clkout90_div4;
   reg 	      clkout90_div2;

   // ###################
   // # Decode divcfg
   // ###################

   always @ (divcfg[3:0])
     casez (divcfg[3:0])
	  4'b0111 : divcfg_dec[7:0] = 8'b00000010;  // Divide by 2
	  4'b0110 : divcfg_dec[7:0] = 8'b00000100;  // Divide by 4
	  4'b0101 : divcfg_dec[7:0] = 8'b00001000;  // Divide by 8
	  4'b0100 : divcfg_dec[7:0] = 8'b00010000;  // Divide by 16
	  4'b0011 : divcfg_dec[7:0] = 8'b00100000;  // Divide by 32
          4'b0010 : divcfg_dec[7:0] = 8'b01000000;  // Divide by 64
          4'b0001 : divcfg_dec[7:0] = 8'b10000000;  // Divide by 128
	  default : divcfg_dec[7:0] = 8'b0000000;   // others
	endcase
   
   //Divide by two special case
   assign div2_sel = divcfg[3:0]==4'b0111;
   assign div1_sel = divcfg[3:0]==4'b1000;//TODO: may change
    
   always @ (posedge clkin or posedge reset)
     if(reset)
       counter[7:0] <= 8'b000001;
     else      
       if(posedge_match)
	 counter[7:0] <= 8'b000001;// Self resetting
       else
	 counter[7:0] <= (counter[7:0] + 8'b000001);
   
   assign posedge_match    = (counter[7:0]==divcfg_dec[7:0]);
   assign negedge_match    = (counter[7:0]=={1'b0,divcfg_dec[7:1]}); 
   assign posedge90_match  = (counter[7:0]==({2'b00,divcfg_dec[7:2]}));
   assign negedge90_match  = (counter[7:0]==({2'b00,divcfg_dec[7:2]} + 
					     {1'b0,divcfg_dec[7:1]})); 
			      
   always @ (posedge clkin)
     if(posedge_match)
       clkout_reg <= 1'b1;
     else if(negedge_match)
       clkout_reg <= 1'b0;
  
   assign clkout    = div1_sel ? clkin : clkout_reg;
 
   assign clkout90_div4_in = posedge90_match ? 1'b1 :
                             negedge90_match ? 1'b0 :
			                       clkout90_div4;
    
   assign clkout90_div2_in = negedge_match ? 1'b1 :
                             posedge_match ? 1'b0 :
			                     clkout90_div2;
   
    
   always @ (posedge clkin)
     clkout90_div4 <= clkout90_div4_in;

   always @ (negedge clkin)
     clkout90_div2 <= clkout90_div2_in;
     
   assign clkout90  = div2_sel ? clkout90_div2 : clkout90_div4;
      
endmodule // clock_divider
    
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
