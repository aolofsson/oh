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
 *  | Command[15:0]   | 15:8  | 7        | 6:4         | 3:0   |
 *  |-----------------|-------|----------|-------------|-------|
 *  | WRITE-SINGLE    | CTRL  | NEAR/FAR | SIZE[2:0]   | 0000  |
 *  | WRITE-IRQ       | CTRL  | NEAR/FAR | SIZE[2:0]   | 0001  |
 *  | WRITE-START     | LEN   | NEAR/FAR | SIZE[2:0]   | 0010  |
 *  | WRITE-STREAM    | CTRL  | STOP     | CTRL        | 0011  |
 *  | WRITE-MULTICAST |       | NEAR/FAR | SIZE[2:0]   | 0100  |
 *  | WRITE-IO        |       | NEAR/FAR | 64,DIR[1:0] | 0101  |
 *  | TBD             |       | NEAR/FAR | SIZE[2:0]   | 0110  |
 *  | TBD             |       | NEAR/FAR | SIZE[2:0]   | 0111  |
 *  |-----------------|-------|----------|-------------|-------|
 *  | READ            | CH    | NEAR/FAR | SIZE[2:0]   | 1000  |
 *  | ATOMIC-OP       | CH    | NEAR/FAR | SIZE[2:0]   | 1001  |
 *  | CAS             | CH    | NEAR/FAR | SIZE[2:0]   | 1010  |
 *  | READ-IO         | CH    | NEAR/FAR | 64,DIR[1:0] | 1011  |
 *  | TBD             | CH    | NEAR/FAR | SIZE[2:0]   | 1101  |
 *  | TBD             | CH    | NEAR/FAR | SIZE[2:0]   | 1110  |
 *  | TBD             | CH    | NEAR/FAR | SIZE[2:0]   | 1111  |
 *  | TBD             | CH    | NEAR/FAR | SIZE[2:0]   | 1111  |
 * 
 * SIZE DECODE:
 * 000=8b
 * 001=16b
 * 010=32b
 * 011=64b
 * 100=128b
 * 1xx=reserved
 * 
 * DIR DECODE:
 * 00=north
 * 01=east
 * 10=west
 * 11=south
 * 
 * Basic commands at bits [7:0] for all address widths
 * AW32/AW64/AW128 formats are compatible
 * AW16 format is a standalone format not compatible with any other
 * CMD[3] indicates
 * Near/Far indicates whether to enable AW or AW/2 packet width
 * All transactions are LSB aligned  
 * No return address for AW16 (point to point)
 * 
 ******************************************************************************/
module emesh2packet 
  #(parameter AW = 64,
    parameter PW = 144)
   (
    //Emesh signal bundle
    input [15:0]     cmd_out, //cmd[15:8] can be optionally set to zero
    input [AW-1:0]   dstaddr_out, //destination address
    input [AW-1:0]   srcaddr_out, //source address (for reads)
    input [2*AW-1:0] data_out, //data
    //Output packet
    output [PW-1:0]  packet_out
    );
   
   //Selector for src/data field
   assign write  = cmd_out[3];

   generate
      //############################
      // 16-Bit ("lite/apb like")
      //############################
      if(AW==16) begin : aw16
	 if(PW==40) begin : p40
	    assign packet_out[7:0]   = cmd_out[7:0];
	    assign packet_out[23:8]  = dstaddr_out[15:0];
	    assign packet_out[39:24] = write ? data_out[15:0]:
				               srcaddr_out[15:0];
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
	    assign packet_out[47:16]  = dstaddr_out[31:0];
	    assign packet_out[79:48]  = write ? data_out[31:0] : 
					        srcaddr_out[31:0];
	 end
	 else if(PW==112) begin: p112
	    assign packet_out[15:0]    = cmd_out[15:0];
	    assign packet_out[47:16]   = dstaddr_out[31:0];
	    assign packet_out[79:48]   = write ? data_out[31:0] : 
					         srcaddr_out[31:0];
	    assign packet_out[111:80]  = data_out[63:32];
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
	    assign packet_out[47:16]   = dstaddr_out[31:0];
	    assign packet_out[111:48]  = write ? data_out[63:0] : 
					         srcaddr_out[63:0];
	    assign packet_out[143:112] = dstaddr_out[63:32];
	 end
	 else if(PW==208) begin: p208
	    assign packet_out[15:0]    = cmd_out[15:0];
	    assign packet_out[47:16]   = dstaddr_out[31:0];
	    assign packet_out[111:48]  = write ? data_out[63:0] : 
					         srcaddr_out[63:0];
	    assign packet_out[143:112] = dstaddr_out[63:32];
	    assign packet_out[207:144] = data_out[127:64];
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
	    assign packet_out[47:16]   = dstaddr_out[31:0];
	    assign packet_out[111:48]  = write ? data_out[63:0] : 
					         srcaddr_out[63:0];
	    assign packet_out[143:112] = dstaddr_out[63:32];
	    assign packet_out[207:144] = write ? data_out[127:64] : 
					         srcaddr_out[127:64];
	    assign packet_out[271:208] = dstaddr_out[127:64];
	 end
	 else if(PW==400) begin: p400
	    assign packet_out[15:0]    = cmd_out[15:0];
	    assign packet_out[47:16]   = dstaddr_out[31:0];
	    assign packet_out[111:48]  = write ? data_out[63:0] : 
					         srcaddr_out[63:0];
	    assign packet_out[143:112] = dstaddr_out[63:32];
	    assign packet_out[207:144] = write ? data_out[127:64] : 
					         srcaddr_out[127:64];
	    assign packet_out[271:208] = dstaddr_out[127:64];
	    assign packet_out[399:272] = data_out[255:128];
	 end
	 else begin: perror
	    initial
	      $display ("Combo not supported (PW=%ds AW==%ds)", PW,AW);
	 end
      end // block: aw128
   endgenerate  
endmodule // emesh2packet

