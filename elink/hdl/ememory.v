/*64 bit wide byte addressable memory*/
module ememory(/*AUTOARG*/
   // Outputs
   wait_out, access_out, write_out, datamode_out, ctrlmode_out,
   dstaddr_out, data_out, srcaddr_out,
   // Inputs
   clk, reset, access_in, write_in, datamode_in, ctrlmode_in,
   dstaddr_in, data_in, srcaddr_in, wait_in
   );

   parameter DW  = 32;   
   parameter AW  = 32;   
   parameter MAW = 10;
   
   //Basic Interface
   input            clk;
   input 	    reset;  

   //incoming read/write
   input 	    access_in;
   input 	    write_in;   
   input [1:0] 	    datamode_in;
   input [3:0] 	    ctrlmode_in;
   input [AW-1:0]   dstaddr_in;
   input [DW-1:0]   data_in;   
   input [AW-1:0]   srcaddr_in;   
   output 	    wait_out;   //pushback
     
   //back to mesh (readback data)
   output 	    access_out;
   output 	    write_out;   
   output [1:0]     datamode_out;
   output [3:0]     ctrlmode_out;
   output [AW-1:0]  dstaddr_out;
   output [DW-1:0]  data_out;   
   output [AW-1:0]  srcaddr_out;   
   input 	    wait_in;   //pushback

   wire [MAW-1:0]   addr;
   wire [63:0]      din;
   wire [63:0] 	    dout;
   wire 	    en; 
   wire 	    mem_rd;
   wire 	    mem_wr;
   reg [7:0] 	    wen;

   //State
   reg 		    access_out;   
   reg 		    write_out;   
   reg [1:0] 	    datamode_out;
   reg [3:0] 	    ctrlmode_out;   
   reg [AW-1:0]     dstaddr_out;   
   reg [AW-1:0]     srcaddr_out;   
   reg 		    hilo_sel;
 
   //Access-in
   assign mem_rd = (access_in & ~write_in & ~wait_in);
   assign mem_wr = (access_in & write_in );
   
   assign en =  mem_rd | mem_wr;

   //Pushback Circuit (pass through problems?)
   assign wait_out = access_in & wait_in;
   
   //Address-in (shifted by three bits, 64 bit wide memory)
   assign addr[MAW-1:0] = dstaddr_in[MAW+2:3];     

   //Data-in (hardoded width)
   assign din[63:0] =(datamode_in[1:0]==2'b11) ? {srcaddr_in[31:0],data_in[31:0]}:
		                                 {data_in[31:0],data_in[31:0]};
   //Write mask
   always@*
     casez({write_in, datamode_in[1:0],dstaddr_in[2:0]})
       //Byte
       6'b100000 : wen[7:0] = 8'b00000001;
       6'b100001 : wen[7:0] = 8'b00000010;
       6'b100010 : wen[7:0] = 8'b00000100;
       6'b100011 : wen[7:0] = 8'b00001000;
       6'b100100 : wen[7:0] = 8'b00010000;
       6'b100101 : wen[7:0] = 8'b00100000;
       6'b100110 : wen[7:0] = 8'b01000000;
       6'b100111 : wen[7:0] = 8'b10000000;
       //Short
       6'b10100? : wen[7:0] = 8'b00000011;
       6'b10101? : wen[7:0] = 8'b00001100;
       6'b10110? : wen[7:0] = 8'b00110000;
       6'b10111? : wen[7:0] = 8'b11000000;
       //Word
       6'b1100?? : wen[7:0] = 8'b00001111;
       6'b1101?? : wen[7:0] = 8'b11110000;       
       //Double
       6'b111??? : wen[7:0] = 8'b11111111;
       default   : wen[7:0] = 8'b00000000;
     endcase // casez ({write, datamode_in[1:0],addr_in[2:0]})

   //Single ported memory
   defparam mem.DW=2*DW;//TODO: really fixed to 64 bits
   defparam mem.AW=MAW;		   
   memory_sp mem(
		 // Inputs
		 .clk	(clk),
		 .en	(en),
		 .wen	(wen[7:0]),
		 .addr	(addr[MAW-1:0]),
		 .din	(din[63:0]),
		 .dout	(dout[63:0])
		 );

   //Outgoing transaction     
   always @ (posedge  clk)
     access_out                    <= mem_rd;
                 
   //Other emesh signals "dataload"
   always @ (posedge clk)
     if(mem_rd)   
       begin
	  write_out           <= 1'b1;
          hilo_sel            <= dstaddr_in[2];
	  datamode_out[1:0]   <= datamode_in[1:0];
	  ctrlmode_out[3:0]   <= ctrlmode_in[3:0];                  
          srcaddr_out[AW-1:0] <= dout[63:32];	  
          dstaddr_out[AW-1:0] <= srcaddr_in[AW-1:0];
       end

   assign data_out[DW-1:0]     = hilo_sel ? dout[63:32] :
				             dout[31:0]; 
   
endmodule // emesh_memory
// Local Variables:
// verilog-library-directories:("." )
// End:


/*
 Copyright (C) 2014 Adapteva, Inc.
 Contributed by Andreas Olofsson <andreas@adapteva.com>
 
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


