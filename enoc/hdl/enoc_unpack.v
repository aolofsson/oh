/*******************************************************************************
 * Function:  Packet-->Memory Mapped Transaction Converter                                     
 * Author:    Andreas Olofsson                                                
 * License:   MIT (see LICENSE file in OH! repository)
 *
 * Documentation:
 * 
 * see ./enoc_pack.v
 * 
 ******************************************************************************/
module enoc_unpack
  #(parameter AW = 32,   // address width 
    parameter PW = 104)  // packet width
   (
    //Input packet
    input [PW-1:0]    packet_in,
    //Emesh signal bundle 
    output [3:0]      opcode_out,
    output [2:0]      size_out,//size of each transfer
    output [3:0]      len_out,//bust length(up to 16)
    output [7:0]      user_out, //user field
    output 	      local_out,//local address/remote address
    output 	      stop_out,//stop burst
    output [15:0]     cmd_out, // command
    output [AW-1:0]   dstaddr_out, // read/write target address
    output [AW-1:0]   srcaddr_out, // read return address
    output [2*AW-1:0] data_out     // write data
    );

   wire [15:0] cmd_out;

   //############################################
   // Command Decode (for write signal)
   //############################################
   
   enoc_decode enoc_decode (/*AUTOINST*/
			    // Outputs
			    .cmd_write		(cmd_write),
			    .cmd_write_start	(cmd_write_start),
			    .cmd_write_stop	(cmd_write_stop),
			    .cmd_write_multicast(cmd_write_multicast),
			    .cmd_read		(cmd_read),
			    .cmd_cas		(cmd_cas),
			    .cmd_atomic_add	(cmd_atomic_add),
			    .cmd_atomic_and	(cmd_atomic_and),
			    .cmd_atomic_or	(cmd_atomic_or),
			    .cmd_atomic_xor	(cmd_atomic_xor),
			    );

   
   generate
      //######################
      // 16-Bit ("lite/apb like")
      //######################
      if(AW==16) begin : aw16
	 if(PW==40) begin : p40
	    assign cmd_out[7:0]      = packet_in[7:0];
	    assign cmd_out[15:8]     = 8'b0;
	    assign dstaddr_out[15:0] = packet_in[23:8];
	    assign srcaddr_out[15:0] = packet_in[39:24];
	    assign data_out[31:0]    = {16'b0,packet_in[39:24]};
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
	if(PW==80) begin: p80
	   assign cmd_out[15:0]     = packet_in[15:0];
	   assign dstaddr_out[31:0] = packet_in[47:16];
	   assign srcaddr_out[31:0] = packet_in[79:48];
	   assign data_out[31:0]    = packet_in[79:48];
	   assign data_out[63:32]   = 32'b0;	
	end
	else if(PW==112) begin: p112
	   assign cmd_out[15:0]     = packet_in[15:0];
	   assign dstaddr_out[31:0] = packet_in[47:16];
	   assign srcaddr_out[31:0] = packet_in[79:48];
	   assign data_out[63:0]    = packet_in[111:48];
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
	 if(PW==144) begin: p144
	    assign cmd_out[15:0]      = packet_in[15:0];
	    assign dstaddr_out[31:0]  = packet_in[47:16];
	    assign srcaddr_out[63:0]  = packet_in[111:48];
	    assign data_out[127:0]    = packet_in[111:48];
	    assign dstaddr_out[63:32] = packet_in[143:112];
	    assign data_out[127:64]   = 64'b0;	
	 end
	 else if(PW==208) begin: p208
	    assign cmd_out[15:0]      = packet_in[15:0];
	    assign dstaddr_out[31:0]  = packet_in[47:16];
	    assign srcaddr_out[63:0]  = packet_in[111:48];
	    assign data_out[63:0]     = packet_in[111:48];
	    assign dstaddr_out[63:32] = packet_in[143:112];
	    assign data_out[127:64]   = packet_in[207:144];
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
	if(PW==272) begin: p272
	   assign cmd_out[15:0]       = packet_in[15:0];
	   assign dstaddr_out[31:0]   = packet_in[47:16];
	   assign srcaddr_out[63:0]   = packet_in[111:48];
	   assign data_out[63:0]      = packet_in[111:48];
	   assign dstaddr_out[63:32]  = packet_in[143:112];
	   assign data_out[127:64]    = packet_in[207:144];
	   assign srcaddr_out[127:64] = packet_in[207:144];
	   assign dstaddr_out[127:64] = packet_in[271:208];
	   assign data_out[255:128]   = 128'b0;	   
	 end
	else if(PW==400) begin: p400
	   assign cmd_out[15:0]       = packet_in[15:0];
	   assign dstaddr_out[31:0]   = packet_in[47:16];
	   assign srcaddr_out[63:0]   = packet_in[111:48];
	   assign data_out[63:0]      = packet_in[111:48];
	   assign dstaddr_out[63:32]  = packet_in[143:112];
	   assign data_out[127:64]    = packet_in[207:144];
	   assign srcaddr_out[127:64] = packet_in[207:144];
	   assign dstaddr_out[127:64] = packet_in[271:208];
	   assign data_out[255:128]   = packet_in[399:272];
	end
	else begin: perror
	   initial
	     $display ("Combo not supported (PW=%ds AW==%ds)", PW,AW);
	end
      end // block: aw128
   endgenerate  

   

output [15:0]     cmd_out, // command
endmodule // packet2emesh



