/* Simple combinatorial priority arbiter
 * (lowest position has highest priority)
 *
 */

module arbiter_priority(/*AUTOARG*/
   // Outputs
   grant, await,
   // Inputs
   request
   );
   
   parameter ARW=99;
       
   input  [ARW-1:0] request;  //request vector
   output [ARW-1:0] grant;    //grant (one hot)
   output [ARW-1:0] await;    //grant mask
   
   genvar j;
   assign await[0]   = 1'b0;   
   generate for (j=ARW-1; j>=1; j=j-1) begin : gen_arbiter     
      assign await[j] = |request[j-1:0];
   end
   endgenerate

   //grant circuit
   assign grant[ARW-1:0] = request[ARW-1:0] & ~await[ARW-1:0];

   
endmodule // arbiter_priority

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
