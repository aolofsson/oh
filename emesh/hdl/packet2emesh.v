//#############################################################################
//# Function: Maps Packet to Emesh Signals                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################
module packet2emesh #(parameter AW = 32,   // address width 
		      parameter PW = 104)  // packet width
   (
    //Input packet
    input [PW-1:0]  packet_in,
    //Emesh signal bundle 
    output 	    write_in,   // write signal
    output [1:0]    datamode_in,// datasize
    output [4:0]    ctrlmode_in,// ctrlmode
    output [AW-1:0] dstaddr_in, // read/write address
    output [AW-1:0] srcaddr_in, // return address for reads
    output [AW-1:0] data_in // data
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
   
   generate
      if(PW==104)
	begin : p104
	   assign write_in           = packet_in[0];   
	   assign datamode_in[1:0]   = packet_in[2:1];   
	   assign ctrlmode_in[4:0]   = {1'b0,packet_in[6:3]};   
	   assign dstaddr_in[31:0]   = packet_in[39:8]; 	 
	   assign srcaddr_in[31:0]   = packet_in[103:72];  
	   assign data_in[31:0]      = packet_in[71:40]; 
	end
      else if(PW==136)
	begin : p136
	   assign write_in           = packet_in[0];
	   assign datamode_in[1:0]   = packet_in[2:1];  
	   assign ctrlmode_in[4:0]   = packet_in[7:3];
	   assign dstaddr_in[63:0]   = {packet_in[135:104],packet_in[39:8]}; 
	   assign srcaddr_in[63:0]   = {packet_in[71:40],packet_in[135:72]};
	   assign data_in[63:0]      = packet_in[103:40];
	end
      else if(PW==72)
	begin : p72
	   assign write_in           = packet_in[0];
	   assign datamode_in[1:0]   = packet_in[2:1];  
	   assign ctrlmode_in[4:0]   = packet_in[7:3];
	   assign dstaddr_in[31:0]   = packet_in[39:8]; 
	   assign data_in[31:0]      = packet_in[71:40];
	end
      else if(PW==40)
	begin : p40
	   assign write_in           = packet_in[0];
	   assign datamode_in[1:0]   = packet_in[2:1];  
	   assign ctrlmode_in[4:0]   = packet_in[7:3];
	   assign dstaddr_in[15:0]   = packet_in[23:8]; 
	   assign data_in[15:0]      = packet_in[39:24];
	end
      else
	begin : unknown
`ifdef TARGET_SIM
	   initial
	     $display ("packet width=%ds not supported",  PW);
`endif
	end
   endgenerate
   
endmodule // packet2emesh



