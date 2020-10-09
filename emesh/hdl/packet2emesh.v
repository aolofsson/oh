/*******************************************************************************
 * Function:  Packet-->Memory Mapped Transaction Converter                                     
 * Author:    Andreas Olofsson                                                
 * License:   MIT (see LICENSE file in OH! repository)
 *
 * Documentation:
 * 
 * see ./emesh2packet.v
 * 
 ******************************************************************************/
module packet2emesh 
  #(parameter AW = 32,   // address width 
    parameter PW = 104)  // packet width
   (
    //Input packet
    input [PW-1:0]    packet_in,
    //Emesh signal bundle 
    output [15:0]     cmd_in, // command
    output [AW-1:0]   dstaddr_in, // read/write target address
    output [AW-1:0]   srcaddr_in, // read return address
    output [2*AW-1:0] data_in     // write data
    );

   //Command always situated in lowest byte
   assign cmd_in[7:0] = packet_in[7:0];
   
   generate
      //######################
      // 16-Bit
      //######################
      if(AW==16) begin : aw16
	 if(PW==40) begin : p40
	    assign dstaddr_in[15:0] = packet_in[23:8];
	    assign srcaddr_in[15:0] = packet_in[39:24];
	    assign data_in[15:0]    = {16'b0,packet_in[39:24]};
	 end
	 else begin: perror
	    initial
	      $display ("Combo not supported (PW=%ds AW==%ds)", PW,AW);
	 end
      end // block: aw16
      //######################
      // 32-Bit
      //######################
      if(AW==32) begin : aw32
	 if(PW==72) begin: p72
	    assign dstaddr_in[31:0] = packet_in[39:8];
	    assign srcaddr_in[31:0] = packet_in[71:40];
	    assign data_in[63:0]    = {32'b0,packet_in[71:40]};
	 end
	 else if(PW==80) begin: p80
	    assign dstaddr_in[31:0] = packet_in[39:8];
	    assign srcaddr_in[31:0] = packet_in[71:40];
	    assign data_in[63:0]    = {32'b0,packet_in[71:40]};
	    assign cmd_in[15:8]     = packet_in[79:72];
	 end
	 else if(PW==104) begin: p104
	    assign dstaddr_in[31:0] = packet_in[39:8];
	    assign srcaddr_in[31:0] = packet_in[103:72];
	    assign data_in[63:0]    = packet_in[103:40];
	 end
	 else if(PW==112) begin: p112
	    assign dstaddr_in[31:0] = packet_in[39:8];
	    assign srcaddr_in[31:0] = packet_in[103:72];
	    assign data_in[63:0]    = packet_in[103:40];
	    assign cmd_in[15:8]     = packet_in[111:104];
	 end
	 else begin: perror
	    initial
	      $display ("Combo not supported (PW=%ds AW==%ds)", PW,AW);
	 end
      end // block: aw32
      //######################
      // 64-Bit
      //######################
      if(AW==64) begin : aw64
	 if(PW==136) begin: p136
	    assign dstaddr_in[31:0]  = packet_in[39:8];
	    assign dstaddr_in[63:32] = packet_in[135:104];
	    assign srcaddr_in[31:0]  = packet_in[103:72];
	    assign srcaddr_in[63:32] = packet_in[71:40];
	    assign data_in[127:0]    = {64'b0,packet_in[103:40]};
	 end
	 else if(PW==144) begin: p144
	    assign dstaddr_in[31:0]  = packet_in[39:8];
	    assign dstaddr_in[63:32] = packet_in[135:104];
	    assign srcaddr_in[31:0]  = packet_in[103:72];
	    assign srcaddr_in[63:32] = packet_in[71:40];
	    assign data_in[127:0]    = {64'b0,packet_in[103:40]};
	    assign cmd_in[15:8]      = packet_in[143:136];
	 end
	 else if(PW==200) begin: p200
	    assign dstaddr_in[31:0]  = packet_in[39:8];
	    assign dstaddr_in[63:32] = packet_in[135:104];
	    assign srcaddr_in[31:0]  = packet_in[103:72];
	    assign srcaddr_in[63:32] = packet_in[71:40];
	    assign data_in[63:0]     = packet_in[103:40];
	    assign data_in[127:64]   = packet_in[199:136];
	 end
	 else if(PW==208) begin: p208
	    assign dstaddr_in[31:0]  = packet_in[39:8];
	    assign dstaddr_in[63:32] = packet_in[135:104];
	    assign srcaddr_in[31:0]  = packet_in[103:72];
	    assign srcaddr_in[63:32] = packet_in[71:40];
	    assign data_in[63:0]     = packet_in[103:40];
	    assign data_in[127:64]   = packet_in[199:136];
	    assign cmd_in[15:8]      = packet_in[207:200];
	 end
	 else begin: perror
	    initial
	      $display ("Combo not supported (PW=%ds AW==%ds)", PW,AW);
	 end
      end // block: aw64
      //######################
      // 128-Bit
      //######################
      if(AW==128) begin : aw128
	 if(PW==264) begin: p264
	    assign dstaddr_in[31:0]   = packet_in[39:8];
	    assign dstaddr_in[63:32]  = packet_in[135:104];
	    assign dstaddr_in[127:64] = packet_in[263:200];
	    assign srcaddr_in[31:0]   = packet_in[103:72];
	    assign srcaddr_in[63:32]  = packet_in[71:40];
	    assign srcaddr_in[127:64] = packet_in[199:136];
	    assign data_in[63:0]      = packet_in[103:40];
	    assign data_in[127:64]    = packet_in[199:136];
	    assign data_in[255:128]   = 128'b0;
	 end
	 else if(PW==272) begin: p272
	    assign dstaddr_in[31:0]   = packet_in[39:8];
	    assign dstaddr_in[63:32]  = packet_in[135:104];
	    assign dstaddr_in[127:64] = packet_in[263:200];
	    assign srcaddr_in[31:0]   = packet_in[103:72];
	    assign srcaddr_in[63:32]  = packet_in[71:40];
	    assign srcaddr_in[127:64] = packet_in[199:136];
	    assign data_in[63:0]      = packet_in[103:40];
	    assign data_in[127:64]    = packet_in[199:136];
	    assign data_in[255:128]   = 128'b0;
	    assign cmd_in[15:8]       = packet_in[271:264];
	 end
	 else if(PW==392) begin: p392
	    assign dstaddr_in[31:0]   = packet_in[39:8];
	    assign dstaddr_in[63:32]  = packet_in[135:104];
	    assign dstaddr_in[127:64] = packet_in[263:200];
	    assign srcaddr_in[31:0]   = packet_in[103:72];
	    assign srcaddr_in[63:32]  = packet_in[71:40];
	    assign srcaddr_in[127:64] = packet_in[199:136];
	    assign data_in[63:0]      = packet_in[103:40];
	    assign data_in[127:64]    = packet_in[199:136];
	    assign data_in[255:128]   = packet_in[391:264];
	 end
	 else if(PW==400) begin: p400
	    assign dstaddr_in[31:0]   = packet_in[39:8];
	    assign dstaddr_in[63:32]  = packet_in[135:104];
	    assign dstaddr_in[127:64] = packet_in[263:200];
	    assign srcaddr_in[31:0]   = packet_in[103:72];
	    assign srcaddr_in[63:32]  = packet_in[71:40];
	    assign srcaddr_in[127:64] = packet_in[199:136];
	    assign data_in[63:0]      = packet_in[103:40];
	    assign data_in[127:64]    = packet_in[199:136];
	    assign data_in[255:128]   = packet_in[391:264];
	    assign cmd_in[15:8]       = packet_in[399:392];
	 end
	 else begin: perror
	    initial
	      $display ("Combo not supported (PW=%ds AW==%ds)", PW,AW);
	 end
      end // block: aw128
   endgenerate  

endmodule // packet2emesh



