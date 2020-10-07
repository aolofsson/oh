/*******************************************************************************
 * Function:  Memory Mapped Transaction to Packet Converter                                     
 * Author:    Andreas Olofsson                                                
 * License:   MIT (see LICENSE file in OH! repository)
 *
 * Documentation:
 * 
 * The following table shows the field mapping for different AW's:
 * 
 *  Packet    | AW16        | AW32     | AW64      | AW128    |
 *  --------------------------------------------------------
 *  [7:0]     | CMDL        | CMDL     | CMDL      | CMDL     |
 *  [39:8]    | D0/SA0,DA   | DA0      | DA0       | DA0      |
 *  [71:40]   | ****        | D0/SA0   | (D0/SA0)  | (D0/SA0) |
 *  [103:72]  | ****        | D1/SA1   | (D1/SA1)  | (D1/SA1) |
 *  [135:104] | ****        | ***,CMDH | DA1       | DA1      |
 *  [167:136] | ****        | ***,CMDH | D2/CMDH   | D2/SA2   |
 *  [199:168] | ***         | ****     | D3        | D3/SA3   |
 *  [231:200] | ****        | ***,CMDH | ***,CMDH  | DA2      |
 *  [263:232] | ****        | ****     | ****      | DA3      |
 *  [295:264] | ****        | ***,CMDH | ***,CMDH  | D4/CMDH  |
 *  [327:296] | ****        | ****     | ****      | D5       |
 *  [359:328] | ****        | ****     | ****      | D6       |
 *  [391:360] | ****        | ****     | ****      | D7       |
 *  [399:392] | ****        | ***,CMDH | ***,CMDH  | CMDH     |
 * 
 * The following list shows the widths supported for each AW
 * 
 *  Packet         | AW16  | AW32   | AW64   | AW128  |
 *  --------------------------------------------------
 *  minimum        | 40    | 72+8   | 136+8  | 264+8  |
 *  double/atomics | --    | 104+8  | 200+8  | 392+8  |
 * 
 * This module is a pass through signal mappig module (no logic).
 * Basic commands at bits [7:0] for all address widths
 * D0 is passed in the srcaddr inputs on write commands
 * 
 ******************************************************************************/
module emesh2packet #(parameter AW = 64,
		      parameter PW = 144)
   (
    //Emesh signal bundle
    input [15:0]    cmd_out,     //cmd[15:8] can be optionally set to zero
    input [AW-1:0]  dstaddr_out, //destination address
    input [AW-1:0]  srcaddr_out, //source address/lower data
    input [AW-1:0]  data_out,    //upper data (optional)
    //Output packet
    output [PW-1:0] packet_out
    );
   
   //######################
   // PACKET COMMANDS
   //######################
   assign packet_out[7:0]    = cmd_out[7:0];   

   generate
      //######################
      // 16-Bit
      //######################
      if(AW==16) begin : aw16
	 if(PW==40) begin : p40
	    assign packet_out[23:8]  = dstaddr_out[15:0];
	    assign packet_out[39:24] = srcaddr_out[15:0];
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
	    assign packet_out[39:8]   = dstaddr_out[31:0];
	    assign packet_out[71:40]  = srcaddr_out[31:0];
	 end
	 else if(PW==80) begin: p80
	    assign packet_out[39:8]   = dstaddr_out[31:0];
	    assign packet_out[71:40]  = srcaddr_out[31:0];
	    assign packet_out[79:72]  = cmd_out[15:8];
	 end
	 else if(PW==104) begin: p104
	    assign packet_out[39:8]    = dstaddr_out[31:0];
	    assign packet_out[71:40]   = srcaddr_out[31:0];
	    assign packet_out[103:72]  = data_out[31:0];
	 end
	 else if(PW==112) begin: p112
	    assign packet_out[39:8]    = dstaddr_out[31:0];
	    assign packet_out[71:40]   = srcaddr_out[31:0];
	    assign packet_out[103:72]  = data_out[31:0];
	    assign packet_out[111:104] = cmd_out[15:8];
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
	    assign packet_out[39:8]    = dstaddr_out[31:0];
	    assign packet_out[71:40]   = srcaddr_out[31:0];
	    assign packet_out[103:72]  = srcaddr_out[63:32];
	    assign packet_out[135:104] = dstaddr_out[63:32];
	 end
	 else if(PW==144) begin: p144
	    assign packet_out[39:8]    = dstaddr_out[31:0];
	    assign packet_out[71:40]   = srcaddr_out[31:0];
	    assign packet_out[103:72]  = srcaddr_out[63:32];
	    assign packet_out[135:104] = dstaddr_out[63:32];
	    assign packet_out[143:136] = cmd_out[15:8];
	 end
	 else if(PW==200) begin: p200
	    assign packet_out[39:8]    = dstaddr_out[31:0];
	    assign packet_out[71:40]   = srcaddr_out[31:0];
	    assign packet_out[103:72]  = srcaddr_out[63:32];
	    assign packet_out[135:104] = dstaddr_out[63:32];
	    assign packet_out[199:136] = data_out[63:0];
	 end
	 else if(PW==208) begin: p208
	    assign packet_out[39:8]    = dstaddr_out[31:0];
	    assign packet_out[71:40]   = srcaddr_out[31:0];
	    assign packet_out[103:72]  = srcaddr_out[63:32];
	    assign packet_out[135:104] = dstaddr_out[63:32];
	    assign packet_out[199:136] = data_out[63:0];
	    assign packet_out[207:200] = cmd_out[15:8];
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
	    assign packet_out[39:8]    = dstaddr_out[31:0];
	    assign packet_out[71:40]   = srcaddr_out[31:0];
	    assign packet_out[103:72]  = srcaddr_out[63:32];
	    assign packet_out[135:104] = dstaddr_out[63:32];
	    assign packet_out[199:136] = srcaddr_out[127:64];
	    assign packet_out[263:200] = dstaddr_out[127:64];
	 end
	 else if(PW==272) begin: p272
	    assign packet_out[39:8]    = dstaddr_out[31:0];
	    assign packet_out[71:40]   = srcaddr_out[31:0];
	    assign packet_out[103:72]  = srcaddr_out[63:32];
	    assign packet_out[135:104] = dstaddr_out[63:32];
	    assign packet_out[199:136] = srcaddr_out[127:64];
	    assign packet_out[263:200] = dstaddr_out[127:64];
	    assign packet_out[271:264] = cmd_out[15:8];
	 end
	 else if(PW==392) begin: p392
	    assign packet_out[39:8]    = dstaddr_out[31:0];
	    assign packet_out[71:40]   = srcaddr_out[31:0];
	    assign packet_out[103:72]  = srcaddr_out[63:32];
	    assign packet_out[135:104] = dstaddr_out[63:32];
	    assign packet_out[199:136] = srcaddr_out[127:64];
	    assign packet_out[263:200] = dstaddr_out[127:64];
	    assign packet_out[391:264] = data_out[127:0];
	 end
	 else if(PW==400) begin: p400
	     assign packet_out[39:8]    = dstaddr_out[31:0];
	    assign packet_out[71:40]   = srcaddr_out[31:0];
	    assign packet_out[103:72]  = srcaddr_out[63:32];
	    assign packet_out[135:104] = dstaddr_out[63:32];
	    assign packet_out[199:136] = srcaddr_out[127:64];
	    assign packet_out[263:200] = dstaddr_out[127:64];
	    assign packet_out[391:264] = data_out[127:0];
	    assign packet_out[399:392] = cmd_out[15:8];
	 end
	 else begin: perror
	    initial
	      $display ("Combo not supported (PW=%ds AW==%ds)", PW,AW);
	 end
      end // block: aw128
   endgenerate  
endmodule // emesh2packet

