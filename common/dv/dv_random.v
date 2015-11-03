module dv_ctrl(/*AUTOARG*/
   // Outputs
   nreset, clk, start,
   // Inputs
   stim_done, test_done
   );
 
   parameter N          = 5000;

   input        nreset;  // async active low reset
   input        clk;     // main clock
   input [15:0] 
   
   output [N-1:0] stim_done; //stimulus is done  
   input 	  test_done; //test is done
   
   //signal declarations
   reg 	  nreset = 1'b0;
   reg 	  clk    = 1'b0;
   reg 	  start  = 1'b0;

   //init
   initial
     begin	
	#(CLK_PERIOD*10)
	  nreset   = 'b1;
	#(CLK_PERIOD*100)
	  start  = 'b1;
     end


   //finish circuitry
   always @*
     if(stim_done & test_done)
       begin
	  #(TIMEOUT) $finish;	  
       end
	   
   //Clock generator
   always
     #(CLK_PHASE) clk = ~clk;
   
   //Waveform dump
   //Better solution?
`ifdef NOVCD
`else
   initial
     begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, dv_top);
     end
`endif
   
endmodule // dv_init

/*
  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Andreas Olofsson <andreas@adapteva.com>
 
   This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.This program is distributed in the hope 
  that it will be useful,but WITHOUT ANY WARRANTY; without even the implied 
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details. You should have received a copy 
  of the GNU General Public License along with this program (see the file 
  COPYING).  If not, see <http://www.gnu.org/licenses/>.
*/
