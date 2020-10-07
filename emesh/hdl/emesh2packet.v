/*******************************************************************************
 * Function:  Memory Mapped Transaction to Packet Converter                                     
 * Author:    Andreas Olofsson                                                
 * License:   MIT (see LICENSE file in OH! repository)
 *
 * Documentation:
 * 
 * The following table shows the field mapping for different AW's:
 * 
 *  Packet    | AW16     | AW32     | AW64      | AW128    |
 *  --------------------------------------------------------
 *  [7:0]     | CMDL     | CMDL     | CMDL      | CMDL     |
 *  [39:8]    | D/SA,DA  | DA0      | DA0       | DA0      |
 *  [71:40]   | ***,CMDH | D0/SA0   | (D0/SA0)  | (D0/SA0) |
 *  [103:72]  | ****     | D1/SA1   | (D1/SA1)  | (D1/SA1) |
 *  [135:104] | ****     | ***,CMDH | DA1       | DA1      |
 *  [167:136] | ****     | ***,CMDH | D2/CMDH   | D2/SA2   |
 *  [199:168] | ***      | ****     | D3        | D3/SA3   |
 *  [231:200] | ****     | ***,CMDH | ***,CMDH  | DA2      |
 *  [263:232] | ****     | ****     | ****      | DA3      |
 *  [295:264] | ****     | ***,CMDH | ***,CMDH  | D4/CMDH  |
 *  [327:296] | ****     | ****     | ****      | D5       |
 *  [359:328] | ****     | ****     | ****      | D6       |
 *  [391:360] | ****     | ****     | ****      | D7       |
 *  [399:392] | ****     | ***,CMDH | ***,CMDH  | CMDH     |
 * 
 * The following list shows the widths supported for each AW
 * 
 *  Packet       |  AW16  | AW32   | AW64   | AW128  |
 *  --------------------------------------------------
 *  minimum      | 40+8   | 72+8   | 136+8  | 264+8  |
 *  double write | 56+8   | 104+8  | 200+8  | 392+8  |
 * 
 * This module is a pass through signal mappig module (no logic).
 * Basic commands at bits [7:0] for all address widths
 * 
 ******************************************************************************/
module emesh2packet #(parameter AW = 64,  // address width (128/64/32/16)
		      parameter PW = 144) // packet width (72/104/144/272)
   (
    //Emesh signal bundle
    input [15:0]    cmd_out, 
    input [AW-1:0]  dstaddr_out,
    input [AW-1:0]  data_out, 
    input [AW-1:0]  srcaddr_out, 
    //Output packet
    output [PW-1:0] packet_out
    );
   
   //All formats have 8bit command vector
   assign packet_out[7:0]    = cmd_out[7:0];   
   assign packet_out[39:8]   = dstaddr_out[31:0];
   assign packet_out[71:40]  = data_out[31:0];


   //AW=16  (pw=40/48)
   //AW=32  (pw=72/80/104/112)
   //AW=64  (pw=136/144)
   //AW=128 (pw=272)
   
   generate
      if(PW==72) begin: p72
      end
      else
	begin
	   
	end
      //######################
      // 16-Bit
      //######################

      //######################
      // 32-Bit
      //######################
      if(AW==32) begin : aw32
	 if(PW==104) begin: p104
	    assign packet_out[103:72]  = srcaddr_out[31:0];
	 end
	 else if(PW==112) begin: p112
	    assign packet_out[103:72]  = srcaddr_out[31:0];
	    assign packet_out[111:104] = cmd_out[15:8];
	 end
      end // block: aw32
      //######################
      // 64-Bit
      //######################
      else if(AW==64) begin : aw64
	 if(PW==136) begin: p136
	    assign packet_out[103:72]  = srcaddr_out[31:0]; // (data_out[63:32])   
	    assign packet_out[135:104] = dstaddr_out[63:32];
	 end
	 if(PW==144) begin: p144
	    assign packet_out[103:72]  = srcaddr_out[31:0]; // (data_out[63:32])   
	    assign packet_out[135:104] = dstaddr_out[63:32];
	    assign packet_out[143:136] = cmd_out[15:8];
	 end
      end // block: aw64
      //######################
      // 128-Bit
      //######################
      else if(AW==128) begin : aw128
	 if(PW==272) begin: p272
	    assign packet_out[103:72]  = srcaddr_out[31:0]; // (data_out[63:32])   
	    assign packet_out[135:104] = dstaddr_out[63:32];
	    
	    assign packet_out[271:264] = cmd_out[15:8];
	 end
      end
   endgenerate
   
   
endmodule // emesh2packet

