module etx_remap (/*AUTOARG*/
   // Outputs
   emesh_access_out, emesh_packet_out,
   // Inputs
   clk, reset, emesh_access_in, emesh_packet_in, remap_en,
   remap_bypass, emesh_wait_in
   );

   parameter AW = 32;
   parameter DW = 32;
   parameter PW = 104;
   parameter ID = 12'h808;
   
   //Clock/reset
   input clk;
   input reset;

   //Input from arbiter
   input          emesh_access_in;
   input [PW-1:0] emesh_packet_in;
   input 	  remap_en;             //enable tx remap (static)
   input 	  remap_bypass;         //dynamic control (read request)
   
   //Output to TX IO   
   output 	   emesh_access_out;
   output [PW-1:0] emesh_packet_out;
   input 	   emesh_wait_in;

   wire [31:0] 	   addr_in;
   wire [31:0] 	   addr_remap;
   wire [31:0] 	   addr_out;

   reg 		   emesh_access_out;
   reg [PW-1:0]    emesh_packet_out;
   
   assign addr_in[31:0]   =  emesh_packet_in[39:8];

   assign addr_remap[31:0] = {addr_in[28:17],
                             {(4){addr_in[16]}},
			     addr_in[15:0]
			     };
   			     
   assign addr_out[31:0] = (remap_en & ~remap_bypass) ? addr_remap[31:0] :
                	                                addr_in[31:0];
        		
   always @ (posedge clk)     
     if(~emesh_wait_in)//pipeline stall
       begin
	  emesh_access_out         <= emesh_access_in;
	  emesh_packet_out[PW-1:0] <= {emesh_packet_in[PW-1:40],
				       addr_out[31:0],
				       emesh_packet_in[7:0]
				       };	
       end
   
endmodule // etx_mux

