module etx_remap (/*AUTOARG*/
   // Outputs
   emesh_access_out, emesh_packet_out,
   // Inputs
   nreset, clk, emesh_access_in, emesh_packet_in, remap_en,
   remap_bypass, etx_rd_wait, etx_wr_wait
   );

   parameter AW = 32;
   parameter DW = 32;
   parameter PW = 104;
   
   //Clock and reset
   input          nreset;
   input 	  clk;

   //Input from arbiter
   input          emesh_access_in;
   input [PW-1:0] emesh_packet_in;
   input 	  remap_en;             //enable tx remap (static)
   input 	  remap_bypass;         //dynamic control (read request)
   
   //Output to TX IO   
   output 	   emesh_access_out;
   output [PW-1:0] emesh_packet_out;

   //Wait signals from protocol block
   input 	   etx_rd_wait;
   input 	   etx_wr_wait;

   wire [31:0] 	   addr_in;
   wire [31:0] 	   addr_remap;
   wire [31:0] 	   addr_out;
   wire 	   write_in;
   
   reg 		   emesh_access_out;
   reg [PW-1:0]    emesh_packet_out;

   packet2emesh p2e (// Outputs
		     .write_out		(write_in),
		     .datamode_out	(),
		     .ctrlmode_out	(),
		     .data_out		(),
		     .dstaddr_out	(addr_in[31:0]),
		     .srcaddr_out	(),
		     // Inputs
		     .packet_in		(emesh_packet_in[PW-1:0]));
         
   assign addr_remap[31:0] = {addr_in[29:18],//ID
			      addr_in[17:16],//SPECIAL GROUP
                             {(2){(|addr_in[17:16])}},//ZERO IF NOT SPECIAL
			     addr_in[15:0]
			     };
   			     

   assign addr_out[31:0] = (remap_en & ~remap_bypass) ? addr_remap[31:0] :
                	                                addr_in[31:0];
        		

   //stall read/write access appropriately
   always @ (posedge clk)
     if(~nreset)
       begin
	  emesh_access_out <= 1'b0;
	  emesh_packet_out[PW-1:0] <= {(PW){1'b0}};
       end
     else if(~(etx_wr_wait | etx_rd_wait))
       begin
	  emesh_access_out         <= emesh_access_in;
	  emesh_packet_out[PW-1:0] <= {emesh_packet_in[PW-1:40],
				       addr_out[31:0],
				       emesh_packet_in[7:0]
				       };	
       end
   
endmodule // etx_remap


// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl")
// End:
