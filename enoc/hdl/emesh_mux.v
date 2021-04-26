module emesh_mux (/*AUTOARG*/
   // Outputs
   ready_out, access_out, packet_out,
   // Inputs
   access_in, packet_in, ready_in
   );
   
   //#####################################################################
   //# PARAMETERS
   //#####################################################################
   parameter AW      = 32;
   parameter PW      = 2 * AW + 40;   
   parameter N       = 99; 
   parameter CFG     = "STATIC"; //Arbitration configuration
                                 //"STATIC" fixed priority
                                 //"DYNAMIC" round robin priority

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //Incoming transaction
   input [N-1:0]    access_in;
   input [N*PW-1:0] packet_in;
   output [N-1:0]   ready_out;

   //Outgoing transaction
   output 	    access_out;
   output [PW-1:0]  packet_out;
   input 	    ready_in;
   
   //#####################################################################
   //# BODY
   //#####################################################################
   
   //local variables
   wire [N-1:0]     grants;
   reg [PW-1:0]     packet_out;
   integer 	    i;
   
   //arbiter
   generate
      if(CFG=="STATIC")		
	begin : arbiter_static
	   oh_arbiter #(.N(N))
	   arbiter(// Outputs
		   .grants   (grants[N-1:0]),
		   // Inputs
		   .requests (access_in[N-1:0])
		   );      
	end
      else if (CFG=="DYNAMIC")
	begin : arbiter_dynamic
`ifdef TARGET_SIM
	   initial
	     $display("ROUND ROBIN ARBITER NOT IMPLEMENTED\n");	   
`endif
	end
   endgenerate
   
   //access signal
   assign access_out = |(access_in[N-1:0]);

   //raise ready signals 
   assign ready_out[N-1:0] = ~(access_in[N-1:0] & ~grants[N-1:0]) & {(N){ready_in}});

   //parametrized mux
   always @*
     begin
	packet_out[PW-1:0] = 'b0;
	for(i=0;i<N;i=i+1)
	  packet_out[PW-1:0] = packet_out[PW-1:0] | {(PW){grants[i]}} & packet_in[((i+1)*PW-1)-:PW];
     end

endmodule // mesh_mux

// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:


