//#################################################################
//# MUXES BETWEEN PACKETS
//#################################################################
module emesh_arbiter (/*AUTOARG*/
   // Outputs
   wait_out, packet_out, wait_in,
   // Inputs
   access_in, packet_in, access_out
   );

   parameter PW      = 99;
   parameter N       = 99; 
   parameter CFG     = "STATIC"; //Arbitration configuration
                                 //"STATIC" fixed priority, [0] has highest priority
                                 //"DYNAMIC" round robin
   //Incoming transaction
   input [N-1:0]    access_in;
   input [N*PW-1:0] packet_in;
   output [N-1:0]   wait_out;

   //Outgoing transaction
   input 	    access_out;
   output [PW-1:0]   packet_out;
   output 	    wait_in;

   wire [N-1:0]     grants;
   reg [PW-1:0]     packet_out;

   //Keep static for now
   generate
      if(CFG=="STATIC")		
	oh_arbiter_static arbiter(// Outputs
				  .grants   (grants[N-1:0]),
				  // Inputs
				  .requests (access_in[N-1:0])
				  );      
   endgenerate
   

   //######################################
   //# ACCESS SIGNAL
   //######################################
   assign access_out = |(access_in[N-1:0]);

   //######################################
   //# PUSHBACK
   //######################################
   assign wait_out = access_in[N-1:0] & ~grants[N-1:0];

   //######################################
   //# DATA MUX
   //######################################
   
   integer   i;
   
   always @*
     begin
	packet_out[PW-1:0] = 'b0;
	for(i=0;i<N;i=i+1)
	  packet_out[PW-1:0] |= {(PW){grants[i]}} & packet_in[PW-1:0];
     end

endmodule // emesh_mux

// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:


