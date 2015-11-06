module packet2emesh(/*AUTOARG*/
   // Outputs
   write_out, datamode_out, ctrlmode_out, data_out, dstaddr_out,
   srcaddr_out,
   // Inputs
   packet_in
   );

   parameter PW      = 104;   //packet width
   parameter DW      = 32;    //data width
   parameter AW      = 32;    //addess width

   //Input packet
   input [PW-1:0]   packet_in;

   //Emesh signal bundle 
   output 	        write_out;
   output [1:0] 	datamode_out;
   output [3:0] 	ctrlmode_out;
   output [DW-1:0] 	data_out; //TODO: fix to make relative to PW
   output [AW-1:0]      dstaddr_out;
   output [AW-1:0]      srcaddr_out;
      
   assign write_out             = packet_in[0];   
   assign datamode_out[1:0]     = packet_in[2:1];   
   assign ctrlmode_out[3:0]     = packet_in[6:3];   
   assign dstaddr_out[31:0]     = packet_in[39:8]; 	 
   assign srcaddr_out[31:0]     = packet_in[103:72];  
   assign data_out[31:0]        = packet_in[71:40];  
      
endmodule // packet2emesh

