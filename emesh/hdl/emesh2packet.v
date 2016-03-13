/*
 * ---- 32-BIT ADDRESS ----
 * [1]       write bit
 * [2:1]     datamode
 * [6:3]     ctrlmode
 * [7]       RESERVED
 * [39:8]    f0 = dstaddr(lo)
 * [71:40]   f1 = data (lo)
 * [103:72]  f2 = srcaddr(lo) /  data (hi)
 * 
 * ---- 64-BIT ADDRESS ----
 * [0]       write bit
 * [2:1]     datamode
 * [7:3]     ctrlmode
 * [39:8]    f0 = dstaddr(lo)
 * [71:40]   f1 = D0
 * [103:72]  f2 = D1 | srcaddr(lo)
 * [135:104] f3 = D2 | srcaddr(hi)
 * [167:136] f4 = D3 | dstaddr(hi)
 * 
 */
module emesh2packet(/*AUTOARG*/
   // Outputs
   packet_out,
   // Inputs
   write_out, datamode_out, ctrlmode_out, dstaddr_out, data_out,
   srcaddr_out
   );
   parameter AW   = 32;   
   parameter PW   = 2*AW+40; 
   
   //Emesh signal bundle
   input 	    write_out;   
   input [1:0] 	    datamode_out;
   input [4:0] 	    ctrlmode_out;
   input [AW-1:0]   dstaddr_out;
   input [AW-1:0]   data_out;   
   input [AW-1:0]   srcaddr_out;   
   
   //Output packet
   output [PW-1:0]  packet_out;

   assign packet_out[0]       = write_out;   
   assign packet_out[2:1]     = datamode_out[1:0];
   assign packet_out[7:3]     = ctrlmode_out[4:0];
     
   generate   
      if(AW==64)
	begin : packet64
	   assign packet_out[39:8]    = dstaddr_out[31:0];
	   assign packet_out[71:40]   = data_out[31:0];
	   assign packet_out[103:72]  = srcaddr_out[31:0];   
	   assign packet_out[135:104] = srcaddr_out[63:32];
	   assign packet_out[167:136] = dstaddr_out[63:32];
	end
      else if(AW==32)
	begin : packet32
	   assign packet_out[39:8]    = dstaddr_out[31:0];
	   assign packet_out[71:40]   = data_out[31:0];
	   assign packet_out[103:72]  = srcaddr_out[31:0];
	end
      else if(AW==16)
	begin : packet16
	   assign packet_out[23:8]    = dstaddr_out[15:0];
	   assign packet_out[39:24]   = data_out[15:0];
	   assign packet_out[55:40]   = srcaddr_out[15:0];
	end
     
   endgenerate
   
endmodule // emesh2packet

