`timescale 1ns/1ps
module dv_ctrl(/*AUTOARG*/
   // Outputs
   nreset, clk, start,
   // Inputs
   dut_active, stim_done, test_done
   );

   parameter CLK_PERIOD = 10;
   parameter CLK_PHASE  = CLK_PERIOD/2;
   parameter TIMEOUT    = 10000;

   output nreset;     // async active low reset
   output clk;        // main clock
   output start;      // start test (level)

   input  dut_active; // reset sequence is done
   input  stim_done;  //stimulus is done  
   input  test_done;  //test is done
   
   //signal declarations
   reg 	  nreset = 1'b0;
   reg 	  clk    = 1'b0;


   reg 	  start;   
   //init
   initial
     begin	
	#(CLK_PERIOD*20)   //hold reset for 20 cycles
	  nreset   = 'b1;
     end

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       start = 1'b0;
     else if(dut_active)       
       start = 1'b1;

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

   parameter REFCLK_FREQUENCY = 200.00;   
   parameter real tap = 1 / (32 * 2 * (REFCLK_FREQUENCY/1000));


   reg [3:0] 	  myreg=4'b0101;
   
   reg [7:0] 	  clkdel;

   always @ (clk)
     begin
	clkdel[0] <= #(tap*5) clk;
	clkdel[1] <= #(tap*myreg) clk;
	clkdel[2] <= #(tap*15) clk;
	clkdel[3] <= #(tap*20) clk;
	clkdel[4] <= #(tap*25) clk;
	clkdel[5] <= #(tap*30) clk;	
     end
              
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
