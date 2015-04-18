module ereset (/*AUTOARG*/
   // Outputs
   reset, chip_resetb,
   // Inputs
   hard_reset, soft_reset
   );

   //inputs
   input 	hard_reset;        // hardware reset from external block
   input 	soft_reset;        // soft reset drive by register (level)

   //outputs
   output 	reset;             //reset for elink
   output       chip_resetb;       //reset for epiphany
 
   //Reset for link logic
   assign reset    = hard_reset | soft_reset;

   //May become more sophisticated later..
   //(for example, for epiphany reset, you might want to include some
   //some hard coded logic to avoid reset edge errata)
   //also, for multi chip boards, since the coordinates are sampled on
   //the rising edge of chip_resetb it may be beneficial to have one
   //reset per chip and to stagger the 

   assign chip_resetb =  ~(hard_reset | soft_reset); 
   
endmodule // ereset

/*
 Copyright (C) 2014 Adapteva, Inc.
 
 Contributed by Andreas Olofsson <andreas@adapteva.com>
 Contributed by Fred Huettig <fred@adapteva.com>
 Contributed by Roman Trogan <roman@adapteva.com>

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

