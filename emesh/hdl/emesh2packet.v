/*Converts an emesh bundle into a 104 bit packet*/
module emesh2packet(/*AUTOARG*/
   // Outputs
   packet_out,
   // Inputs
   write_in, datamode_in, ctrlmode_in, dstaddr_in, data_in,
   srcaddr_in
   );

   parameter AW=32;
   parameter DW=32;
   parameter PW=104;
   
   //Emesh signal bundle
   input 	    write_in;   
   input [1:0] 	    datamode_in;
   input [3:0] 	    ctrlmode_in;
   input [AW-1:0]   dstaddr_in;
   input [DW-1:0]   data_in;   
   input [AW-1:0]   srcaddr_in;   
   
   //Output packet
   output [PW-1:0]  packet_out;

   assign packet_out[0]       = write_in;   
   assign packet_out[2:1]     = datamode_in[1:0];
   assign packet_out[7:3]     = {1'b0,ctrlmode_in[3:0]};
   assign packet_out[39:8]    = dstaddr_in[AW-1:0];
   assign packet_out[71:40]   = data_in[AW-1:0];
   assign packet_out[103:72]  = srcaddr_in[AW-1:0];
     
endmodule // emesh2packet
