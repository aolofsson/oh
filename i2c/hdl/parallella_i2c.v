/*
  File: parallella_i2c
 
  This file is part of the Parallella FPGA Reference Design.

  Copyright (C) 2013-2015 Adapteva, Inc.
  Contributed by Fred Huettig

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

// Implements I2C from the Zynq PS

module parallella_i2c
  (/*AUTOARG*/
   // Outputs
   I2C_SDA_I, I2C_SCL_I,
   // Inouts
   I2C_SDA, I2C_SCL,
   // Inputs
   I2C_SDA_O, I2C_SDA_T, I2C_SCL_O, I2C_SCL_T
   );
   
   input  I2C_SDA_O;
   input  I2C_SDA_T;
   output I2C_SDA_I;

   input  I2C_SCL_O;
   input  I2C_SCL_T;
   output I2C_SCL_I;

   inout  I2C_SDA;
   inout  I2C_SCL;
   

`ifdef  PORTABLE
   
   wire   I2C_SDA = I2C_SDA_T ? 1'bZ : I2C_SDA_O;
   wire   I2C_SDA_I = I2C_SDA;
   
   wire   I2C_SCL = I2C_SCL_T ? 1'bZ : I2C_SCL_O;
   wire   I2C_SCL_I = I2C_SCL;
   
`else

  
   IOBUF #(
      .DRIVE(8), // Specify the output drive strength
      .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
   ) IOBUF_sda (
      .O(I2C_SDA_I),     // Buffer output
      .IO(I2C_SDA),   // Buffer inout port (connect directly to top-level port)
      .I(I2C_SDA_O),     // Buffer input
      .T(I2C_SDA_T)      // 3-state enable input, high=input, low=output
   );
    
    IOBUF #(
       .DRIVE(8), // Specify the output drive strength
       .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
       .IOSTANDARD("DEFAULT"), // Specify the I/O standard
       .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_inst (
       .O(I2C_SCL_I),     // Buffer output
       .IO(I2C_SCL),   // Buffer inout port (connect directly to top-level port)
       .I(I2C_SCL_O),     // Buffer input
       .T(I2C_SCL_T)      // 3-state enable input, high=input, low=output
    );
   
`endif
   
endmodule // parallella_i2c


