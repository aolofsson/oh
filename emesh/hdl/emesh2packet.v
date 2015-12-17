/*

 * ---- E4 PACKET FORMAT (104 bits) ----
 * [1]       write bit
 * [2:1]     datamode
 * [6:3]     ctrlmode
 * [7]       reserved
 * [39:8]    f0 = dstaddr(lo)
 * [71:40]   f1 = data (lo)
 * [103:72]  f2 = srcaddr(lo) /  data (hi)
 * 
 */
module emesh2packet(/*AUTOARG*/
   // Outputs
   packet_out,
   // Inputs
   write_out, datamode_out, ctrlmode_out, dstaddr_out, data_out,
   srcaddr_out
   );
   parameter AW      = 32;   
   localparam PW     = (2*AW+40); 

   
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
      if(AW==32 & PW==104)
	begin	  
	   assign packet_out[39:8]    = dstaddr_out[AW-1:0];
	   assign packet_out[71:40]   = data_out[AW-1:0];
	   assign packet_out[103:72]  = srcaddr_out[AW-1:0];
	end 
      else
	begin
	   initial
	     $display ("Only AW=32 and PW=104 is supported");
	end
   endgenerate
endmodule // emesh2packet

