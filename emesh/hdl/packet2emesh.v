/*
 * ---- E4 PACKET FORMAT (104 bits) ----
 * [0]       write bit
 * [2:1]     datamode
 * [6:3]     ctrlmode
 * [7]       reserved
 * [39:8]    f0 = dstaddr(lo)
 * [71:40]   f1 = data (lo)
 * [103:72]  f2 = srcaddr(lo) / data (hi)
 * 
 */

module packet2emesh(/*AUTOARG*/
   // Outputs
   write_in, datamode_in, ctrlmode_in, dstaddr_in, srcaddr_in,
   data_in,
   // Inputs
   packet_in
   );

   parameter AW     = 32;   
   parameter PW     = (2*AW+40); 

   //Input packet
   input [PW-1:0]   packet_in;

   //Emesh signal bundle 
   output 	     write_in;
   output [1:0]      datamode_in;
   output [4:0]      ctrlmode_in;
   output [AW-1:0]   dstaddr_in;
   output [AW-1:0]   srcaddr_in;
   output [AW-1:0]   data_in;

   generate
      if(AW==32 & PW==104)
	begin
	   assign write_in           = packet_in[0];   
	   assign datamode_in[1:0]   = packet_in[2:1];   
	   assign ctrlmode_in[4:0]   = {1'b0,packet_in[6:3]};   
	   assign dstaddr_in[31:0]   = packet_in[39:8]; 	 
	   assign srcaddr_in[31:0]   = packet_in[103:72];  
	   assign data_in[31:0]      = packet_in[71:40];  
	end
      else
	begin
	   initial
	     $display ("Only AW=32 and PW=104 is supported");
	end
   endgenerate
   
endmodule // packet2emesh




