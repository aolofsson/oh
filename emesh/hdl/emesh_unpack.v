/*******************************************************************************
 * Function:  Packet-->Memory Mapped Transaction Converter
 * Author:    Andreas Olofsson
 * License:   MIT (see LICENSE file in OH! repository)
 *
 * Documentation:
 *
 * see ./emesh_pack.v for packet formatting
 *
 ******************************************************************************/
module emesh_unpack
  #(parameter AW = 32,   // address width
    parameter PW = 104)  // packet width
   (
    //Input packet
    input [PW-1:0]    packet_in,
    //Write
    output 	      cmd_write,//start write
    output 	      cmd_write_stop,//stop burst
    //Read
    output 	      cmd_read,
    //Atomic read/write
    output 	      cmd_atomic_add,
    output 	      cmd_atomic_and,
    output 	      cmd_atomic_or,
    output 	      cmd_atomic_xor,
    output 	      cmd_cas,
    //Command Fields
    output [3:0]      cmd_opcode,//raw opcode
    output [3:0]      cmd_length,//bust length(up to 16)
    output [2:0]      cmd_size,//size of each transfer
    output [7:0]      cmd_user, //user field
    //Address/Data
    output [AW-1:0]   dstaddr, // read/write target address
    output [AW-1:0]   srcaddr, // read return address
    output [2*AW-1:0] data     // write data
    );

   wire [15:0] cmd;

   //############################################
   // Command Decode
   //############################################

   emesh_decode emesh_decode (//Input
			      .cmd_in		(cmd[15:0]),
			      // Outputs
			      .cmd_write	(cmd_write),
			      .cmd_write_stop	(cmd_write_stop),
			      .cmd_read		(cmd_read),
			      .cmd_cas		(cmd_cas),
			      .cmd_atomic_add	(cmd_atomic_add),
			      .cmd_atomic_and	(cmd_atomic_and),
			      .cmd_atomic_or	(cmd_atomic_or),
			      .cmd_atomic_xor	(cmd_atomic_xor),
			      .cmd_opcode	(cmd_opcode[3:0]),
			      .cmd_user		(cmd_user[7:0]),
			      .cmd_length	(cmd_length[3:0]),
			      .cmd_size		(cmd_size[2:0]));
   generate
      //######################
      // 16-Bit ("lite/apb like")
      //######################
      if(AW==16) begin : aw16
	 if(PW==40) begin : p40
	    assign cmd[7:0]      = packet_in[7:0];
	    assign cmd[15:8]     = 8'b0;
	    assign dstaddr[15:0] = packet_in[23:8];
	    assign srcaddr[15:0] = packet_in[39:24];
	    assign data[31:0]    = {16'b0,packet_in[39:24]};
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
	   assign cmd[15:0]     = packet_in[15:0];
	   assign dstaddr[31:0] = packet_in[47:16];
	   assign srcaddr[31:0] = packet_in[79:48];
	   assign data[31:0]    = packet_in[79:48];
	   assign data[63:32]   = 32'b0;
	end
	else if(PW==112) begin: p112
	   assign cmd[15:0]     = packet_in[15:0];
	   assign dstaddr[31:0] = packet_in[47:16];
	   assign srcaddr[31:0] = packet_in[79:48];
	   assign data[63:0]    = packet_in[111:48];
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
	    assign cmd[15:0]      = packet_in[15:0];
	    assign dstaddr[31:0]  = packet_in[47:16];
	    assign srcaddr[63:0]  = packet_in[111:48];
	    assign data[127:0]    = packet_in[111:48];
	    assign dstaddr[63:32] = packet_in[143:112];
	    assign data[127:64]   = 64'b0;
	 end
	 else if(PW==208) begin: p208
	    assign cmd[15:0]      = packet_in[15:0];
	    assign dstaddr[31:0]  = packet_in[47:16];
	    assign srcaddr[63:0]  = packet_in[111:48];
	    assign data[63:0]     = packet_in[111:48];
	    assign dstaddr[63:32] = packet_in[143:112];
	    assign data[127:64]   = packet_in[207:144];
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
	   assign cmd[15:0]       = packet_in[15:0];
	   assign dstaddr[31:0]   = packet_in[47:16];
	   assign srcaddr[63:0]   = packet_in[111:48];
	   assign data[63:0]      = packet_in[111:48];
	   assign dstaddr[63:32]  = packet_in[143:112];
	   assign data[127:64]    = packet_in[207:144];
	   assign srcaddr[127:64] = packet_in[207:144];
	   assign dstaddr[127:64] = packet_in[271:208];
	   assign data[255:128]   = 128'b0;
	 end
	else if(PW==400) begin: p400
	   assign cmd[15:0]       = packet_in[15:0];
	   assign dstaddr[31:0]   = packet_in[47:16];
	   assign srcaddr[63:0]   = packet_in[111:48];
	   assign data[63:0]      = packet_in[111:48];
	   assign dstaddr[63:32]  = packet_in[143:112];
	   assign data[127:64]    = packet_in[207:144];
	   assign srcaddr[127:64] = packet_in[207:144];
	   assign dstaddr[127:64] = packet_in[271:208];
	   assign data[255:128]   = packet_in[399:272];
	end
	else begin: perror
	   initial
	     $display ("Combo not supported (PW=%ds AW==%ds)", PW,AW);
	end
      end // block: aw128
   endgenerate

endmodule // enoc_unpack
