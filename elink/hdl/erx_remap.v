module erx_remap (/*AUTOARG*/
   // Outputs
   emesh_access_out, emesh_packet_out,
   // Inputs
   clk, emesh_access_in, emesh_packet_in, remap_mode, remap_sel,
   remap_pattern, remap_base
   );

   parameter AW = 32;
   parameter DW = 32;
   parameter PW = 104;
   parameter ID = 12'h808;
   
   //Clock/reset
   input          clk;
   
   //Input from arbiter
   input          emesh_access_in;
   input [PW-1:0] emesh_packet_in;
   
   //Configuration
   input [1:0] 	  remap_mode;    //00=none,01=static,02=continuity
   input [11:0]   remap_sel;     //number of bits to remap
   input [11:0]   remap_pattern; //static pattern to map to
   input [31:0]   remap_base;    //remap offset
   
   //Output to TX IO   
   output 	   emesh_access_out;
   output [PW-1:0] emesh_packet_out;

   wire [31:0] 	   static_remap;
   wire [31:0] 	   dynamic_remap;
   wire [31:0] 	   remap_mux;
   wire [31:0] 	   addr_in;
   wire [31:0] 	   addr_out;
   wire 	   remap_en;
   
   reg 		   emesh_access_out;
   reg [PW-1:0]    emesh_packet_out;

   //TODO:FIX!??
   parameter[5:0]  colid = ID[5:0];
   
   //parsing packet
   assign addr_in[31:0]  =  emesh_packet_in[39:8];
 
   
   //simple static remap
   assign static_remap[31:20] = (remap_sel[11:0] & remap_pattern[11:0]) |
			        (~remap_sel[11:0] & addr_in[31:20]);

   assign static_remap[19:0]  = addr_in[19:0];
    
   //more complex compresssed map
   assign dynamic_remap[31:0] = addr_in[31:0]    //input
			     - (colid << 20)     //subtracing elink (start at 0)
			     + remap_base[31:0]  //adding back base
                             - (addr_in[31:26]<<$clog2(colid));
     			     
   //Static, dynamic, or no remap
   assign remap_mux[31:0]  = (addr_in[31:20]==ID)     ? addr_in[31:0] : //for write to mailbox
			     (remap_mode[1:0]==2'b00) ? addr_in[31:0] :
			     (remap_mode[1:0]==2'b01) ? static_remap[31:0] :
	  		                                dynamic_remap[31:0];

   //Access pipeline
   always @ (posedge clk)
       emesh_access_out <= emesh_access_in;

   //Packet Remapping
   always @ (posedge clk)    
       emesh_packet_out[PW-1:0] <= {emesh_packet_in[103:40],
                                    remap_mux[31:0],
                                    emesh_packet_in[7:0]
				    };
   
endmodule // etx_mux

