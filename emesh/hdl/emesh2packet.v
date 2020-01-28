//#############################################################################
//# Function: Maps Emesh Signals to Packet                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################
module emesh2packet #(parameter AW = 32,   // address width 
		      parameter PW = 104)  // packet width
   (
    //Emesh signal bundle
    input 	    write_out, 
    input [1:0]     datamode_out,
    input [4:0]     ctrlmode_out,
    input [AW-1:0]  dstaddr_out,
    input [AW-1:0]  data_out, 
    input [AW-1:0]  srcaddr_out, 
    //Output packet
    output [PW-1:0] packet_out
    );
   
   // ---- FORMAT -----
   //
   // [0]  =write bit
   // [2:1]=datamode
   // [7:3]=ctrlmode
   // [39:8]=dstaddr(lo)
   //
   // ---- 32-BIT ADDRESS ----
   // [71:40]   data (lo)   | xxxx
   // [103:72]  srcaddr(lo) | data (hi)
   //
   // ---- 64-BIT ADDRESS ----
   // [71:40]   D0 | srcaddr(hi)
   // [103:72]  D1 | srcaddr(lo)
   // [135:104] dstaddr(hi)
   
   assign packet_out[0]       = write_out;   
   assign packet_out[2:1]     = datamode_out[1:0];
   assign packet_out[7:3]     = ctrlmode_out[4:0];
     
   generate   
     if(PW==136)
	begin : p136
	   assign packet_out[39:8]    = dstaddr_out[31:0];
	   assign packet_out[71:40]   = data_out[31:0];    // | srcaddr_out[63:32]
	   assign packet_out[103:72]  = srcaddr_out[31:0]; // (data_out[63:32])   
	   assign packet_out[135:104] = dstaddr_out[63:32];
	end
      else if(PW==104)
	begin : p104
	   assign packet_out[39:8]    = dstaddr_out[31:0];
	   assign packet_out[71:40]   = data_out[31:0];
	   assign packet_out[103:72]  = srcaddr_out[31:0];
	end
      else if(PW==72)
	begin : p72
	   assign packet_out[39:8]    = dstaddr_out[31:0];
	   assign packet_out[71:40]   = data_out[31:0];
	end
      else if(PW==40)
	begin : p40
	   assign packet_out[23:8]    = dstaddr_out[15:0];
	   assign packet_out[39:24]   = data_out[15:0];
	end
   endgenerate
   
endmodule // emesh2packet

