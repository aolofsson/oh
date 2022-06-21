/*******************************************************************************
 * Function:  Memory Mapped Transaction --> Packet Converter
 * Author:    Andreas Olofsson
 * License:   MIT (see LICENSE file in OH! repository)
 *
 * Documentation:
 *
 * The following table shows the field mapping for different AW's:
 *
 *  | Packet  | AW16    | AW32     | AW64   | AW128   |
 *  |---------|---------|----------|--------|---------|
 *  | 15:0    | DA,CMD  | CMD      | CMD    | CMD     |
 *  | 47:16   | D/SA,DA | DA0      | DA0    | DA0     |
 *  | 79:48   | ****    | D0/SA0   | D0/SA0 | D0/SA0  |
 *  | 111:80  | ****    | D1/0     | D1/SA1 | D1/SA1  |
 *  |---------|---------|----------|--------|---------|
 *  | 143:112 | ****    | ***      | DA1    | DA1     |
 *  |---------|---------|----------|--------|---------|
 *  | 167:144 | ****    | ***      | D2     | D2/SA2  |
 *  | 207:176 | ***     | ****     | D3     | D3/SA3  |
 *  | 239:208 | ****    | ****     | ****   | DA2     |
 *  | 271:240 | ****    | ****     | ****   | DA3     |
 *  |---------|---------|----------|--------|---------|
 *  | 303:272 | ****    | ****     | ***    | D4      |
 *  | 335:304 | ****    | ****     | ****   | D5      |
 *  | 367:336 | ****    | ****     | ****   | D6      |
 *  | 399:368 | ****    | ****     | ****   | D7      |
 *
 * The following list shows the widths supported for each AW
 *
 *  |Packet         | AW16  | AW32   | AW64   | AW128  |
 *  |---------------|-------|--------|--------|--------|
 *  |minimum        | 40    | 72+8   | 136+8  | 264+8  |
 *  |double/atomics | --    | 104+8  | 200+8  | 392+8  |
 *
 * The command field has the following options:
 *
 *
 *  | Command[15:0]   | 15:11     | 10:8      | 7:4      | 3:0  |
 *  |-----------------|-----------|-----------|----------|------|
 *  | WRITE-START     | USER[7:3] | SIZE[2:0] | LEN[3:0] | 0000 |
 *  | WRITE-STOP      | USER[7:3] | SIZE[2:0] | LEN[3:0] | 0001 |
 *  | WRITE-MULTICAST | USER[7:3] | SIZE[2:0] | LEN[3:0] | 0010 |
 *  | TBD             | USER[7:3] | SIZE[2:0] | LEN[3:0] | 0011 |
 *  | TBD             | USER[7:3] | SIZE[2:0] | LEN[3:0] | 0100 |
 *  | TBD             | USER[7:3] | SIZE[2:0] | LEN[3:0] | 0101 |
 *  | TBD             | USER[7:3] | SIZE[2:0] | LEN[3:0] | 0110 |
 *  | TBD             | USER[7:3] | SIZE[2:0] | LEN[3:0] | 0111 |
 *  |-----------------|-----------|-----------|----------|------|
 *  | READ            | USER[7:3] | SIZE[2:0] | LEN[3:0] | 1000 |
 *  | TBD             | USER[7:3] | SIZE[2:0] | LEN[3:0] | 1010 |
 *  | TBD             | USER[7:3] | SIZE[2:0] | LEN[3:0] | 1010 |
 *  | CAS             | USER[7:3] | SIZE[2:0] | LEN[3:0] | 1011 |
 *  | ATOMIC-ADD      | USER[7:3] | SIZE[2:0] | LEN[3:0] | 1100 |
 *  | ATOMIC-AND      | USER[7:3] | SIZE[2:0] | LEN[3:0] | 1101 |
 *  | ATOMIC-OR       | USER[7:3] | SIZE[2:0] | LEN[3:0] | 1110 |
 *  | ATOMIC-XOR      | USER[7:3] | SIZE[2:0] | LEN[3:0] | 1111 |
 *
 * SIZE DECODE:
 * 000=8b
 * 001=16b
 * 010=32b
 * 011=64b
 * 100=128b
 * 101=256b
 * 110=512b
 * 111=1024b
 *
 * LENGTH DECODE:
 * 0000=1 beat (single transaction)
 * 0001=2 beat
 * ...
 * 1111=16 beats
 *
 * AW32/AW64/AW128 formats are compatible
 * AW16 format is a standalone format not compatible with any other
 * All transactions are LSB aligned
 * No return address for AW16 (point to point)
 *
 ******************************************************************************/
module emesh_pack
  #(parameter AW = 64,
    parameter PW = 144)
   (
    //Command Inputs
    input [3:0]      opcode_in,
    input [3:0]      length_in,//burst length(1-16)
    input [2:0]      size_in,//size of each transfer
    input [7:3]      user_in, //user control field
    //Address/Data
    input [AW-1:0]   dstaddr_in, //destination address
    input [AW-1:0]   srcaddr_in, //source address (for reads)
    input [2*AW-1:0] data_in, //data
    //Output packet
    output [PW-1:0]  packet_out
    );

   //############################################
   // Command Field
   //############################################
   wire [15:0] 	     cmd_out;

   assign cmd_out[3:0]   = opcode_in[3:0];
   assign cmd_out[7:4]   = length_in[3:0];
   assign cmd_out[10:8]  = size_in[2:0];
   assign cmd_out[15:11] = user_in[7:3];

   //Decode (only write indicator needed)
   emesh_decode enoc_decode (//Inputs
			    .cmd_in		(cmd_out[15:0]),
			    // Outputs
			    .cmd_write		(cmd_write),
			    .cmd_write_stop	(),
			    .cmd_read		(),
			    .cmd_atomic_add	(),
			    .cmd_atomic_and	(),
			    .cmd_atomic_or	(),
			    .cmd_atomic_xor	(),
			    .cmd_cas		(),
			    .cmd_opcode		(),
			    .cmd_length		(),
			    .cmd_size		(),
			    .cmd_user		());

   generate
      //############################
      // 16-Bit ("lite/apb like")
      //############################
      if(AW==16) begin : aw16
	 if(PW==40) begin : p40
	    assign packet_out[7:0]   = cmd_out[7:0];
	    assign packet_out[23:8]  = dstaddr_in[15:0];
	    assign packet_out[39:24] = cmd_write ? data_in[15:0]:
				                   srcaddr_in[15:0];
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
	    assign packet_out[15:0]   = cmd_out[15:0];
	    assign packet_out[47:16]  = dstaddr_in[31:0];
	    assign packet_out[79:48]  = cmd_write ? data_in[31:0] :
					            srcaddr_in[31:0];
	 end
	 else if(PW==112) begin: p112
	    assign packet_out[15:0]    = cmd_out[15:0];
	    assign packet_out[47:16]   = dstaddr_in[31:0];
	    assign packet_out[79:48]   = cmd_write ? data_in[31:0] :
					             srcaddr_in[31:0];
	    assign packet_out[111:80]  = data_in[63:32];
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
	    assign packet_out[15:0]    = cmd_out[15:0];
	    assign packet_out[47:16]   = dstaddr_in[31:0];
	    assign packet_out[111:48]  = cmd_write ? data_in[63:0] :
					             srcaddr_in[63:0];
	    assign packet_out[143:112] = dstaddr_in[63:32];
	 end
	 else if(PW==208) begin: p208
	    assign packet_out[15:0]    = cmd_out[15:0];
	    assign packet_out[47:16]   = dstaddr_in[31:0];
	    assign packet_out[111:48]  = cmd_write ? data_in[63:0] :
					             srcaddr_in[63:0];
	    assign packet_out[143:112] = dstaddr_in[63:32];
	    assign packet_out[207:144] = data_in[127:64];
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
	    assign packet_out[15:0]    = cmd_out[15:0];
	    assign packet_out[47:16]   = dstaddr_in[31:0];
	    assign packet_out[111:48]  = cmd_write ? data_in[63:0] :
					             srcaddr_in[63:0];
	    assign packet_out[143:112] = dstaddr_in[63:32];
	    assign packet_out[207:144] = cmd_write ? data_in[127:64] :
					             srcaddr_in[127:64];
	    assign packet_out[271:208] = dstaddr_in[127:64];
	 end
	 else if(PW==400) begin: p400
	    assign packet_out[15:0]    = cmd_out[15:0];
	    assign packet_out[47:16]   = dstaddr_in[31:0];
	    assign packet_out[111:48]  = cmd_write ? data_in[63:0] :
					             srcaddr_in[63:0];
	    assign packet_out[143:112] = dstaddr_in[63:32];
	    assign packet_out[207:144] = cmd_write ? data_in[127:64] :
					             srcaddr_in[127:64];
	    assign packet_out[271:208] = dstaddr_in[127:64];
	    assign packet_out[399:272] = data_in[255:128];
	 end
	 else begin: perror
	    initial
	      $display ("Combo not supported (PW=%ds AW==%ds)", PW,AW);
	 end
      end // block: aw128
   endgenerate
endmodule // emesh_pack
