module ereset (/*AUTOARG*/
   // Outputs
   etx_reset, erx_reset, sys_reset,
   // Inputs
   reset, sys_clk, tx_lclk_div4, rx_lclk_div4
   );

   // reset inputs
   input   reset;           // POR | ~elink_en (with appropriate delays..)
   
   //synchronization clocks
   input   sys_clk;        // system clock
   input   tx_lclk_div4;   // slow clock for TX
   input   rx_lclk_div4;   // slow clock for RX

   //synchronous reset outputs
   output  etx_reset;      // reset for TX slow logic
   output  erx_reset;      // reset for RX slow logic
   output  sys_reset;     // reset for system FIFOs

   wire    erx_resetb;
   wire    etx_resetb;
   wire    sys_resetb;
   
   
   //erx reset synchronizer
   /*
    
    synchronizer sync_erx (.out	 (erx_resetb),
			  .in	 (1'b1),
			  .clk	 (rx_lclk_div4),
			  .reset (reset)
			  );
    */
    
   //etx reset synchronizer
   synchronizer sync_etx (.out	 (etx_resetb),
			  .in	 (1'b1),
			  .clk	 (tx_lclk_div4),
			  .reset (reset)
			  );

   //system reset synchronizer
    synchronizer sync_sys (.out	 (sys_resetb),
			  .in	 (1'b1),
			  .clk	 (sys_clk),
			  .reset (reset)
			   );

   assign etx_reset =~etx_resetb;
   assign sys_reset =~sys_resetb;
   assign erx_reset = reset;     //async reset! can't guarantee rx clock
   
endmodule // ereset
// Local Variables:
// verilog-library-directories:("." "../../common/hdl/")
// End:
/*
 Copyright (C) 2015 Adapteva, Inc.
 
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

