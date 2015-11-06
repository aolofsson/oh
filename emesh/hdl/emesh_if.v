//WARNING: Pass through logic
module emesh_if (/*AUTOARG*/
   // Outputs
   c2e_cmesh_wait_out, e2c_cmesh_access_out, e2c_cmesh_packet_out,
   c2e_rmesh_wait_out, e2c_rmesh_access_out, e2c_rmesh_packet_out,
   c2e_xmesh_wait_out, e2c_xmesh_access_out, e2c_xmesh_packet_out,
   e2c_emesh_wait_out, c2e_emesh_access_out, c2e_emesh_packet_out,
   // Inputs
   c2e_cmesh_access_in, c2e_cmesh_packet_in, e2c_cmesh_wait_in,
   c2e_rmesh_access_in, c2e_rmesh_packet_in, e2c_rmesh_wait_in,
   c2e_xmesh_access_in, c2e_xmesh_packet_in, e2c_xmesh_wait_in,
   e2c_emesh_access_in, e2c_emesh_packet_in, c2e_emesh_wait_in
   );

   parameter PW = 99;  

   //##Cmesh##    
   //core-->io
   input 	  c2e_cmesh_access_in;
   input [PW-1:0] c2e_cmesh_packet_in;
   output 	  c2e_cmesh_wait_out;
   //io-->core
   output 	   e2c_cmesh_access_out;
   output [PW-1:0] e2c_cmesh_packet_out;
   input 	   e2c_cmesh_wait_in;
      
   //##Rmesh## 
   //core-->io
   input 	   c2e_rmesh_access_in;
   input [PW-1:0]  c2e_rmesh_packet_in;
   output 	   c2e_rmesh_wait_out;
   //io-->core
   output 	   e2c_rmesh_access_out;
   output [PW-1:0] e2c_rmesh_packet_out;
   input 	   e2c_rmesh_wait_in;
   
   //##Xmesh## 

   //core-->io
   input 	   c2e_xmesh_access_in;
   input [PW-1:0]  c2e_xmesh_packet_in;
   output 	   c2e_xmesh_wait_out;
   
   //io-->core
   output 	   e2c_xmesh_access_out;
   output [PW-1:0] e2c_xmesh_packet_out;
   input 	   e2c_xmesh_wait_in;
   
   //##Emesh##

   //io-->core
   input 	   e2c_emesh_access_in;
   input [PW-1:0]  e2c_emesh_packet_in;
   output 	   e2c_emesh_wait_out;
   
   //core-->io
   output 	   c2e_emesh_access_out;
   output [PW-1:0] c2e_emesh_packet_out;
   input 	   c2e_emesh_wait_in;
   
   
   //local wires
   wire 	   e2c_emesh_write;
  
   //#####################################################
   //# EXTERNAL 2 CORE (E2C)
   //#####################################################
      
   //Access signals
   assign e2c_cmesh_access_out = e2c_emesh_access_in & e2c_emesh_packet_in[0];
   
   assign e2c_rmesh_access_out = e2c_emesh_access_in & ~e2c_emesh_packet_in[0];

   assign e2c_xmesh_access_out = 1'b0;
      
   //Distribute emesh to xmesh,cmesh, rmesh
   assign e2c_cmesh_packet_out[PW-1:0] = e2c_emesh_packet_in[PW-1:0];	 
   assign e2c_rmesh_packet_out[PW-1:0] = e2c_emesh_packet_in[PW-1:0];	 
   assign e2c_xmesh_packet_out[PW-1:0] = e2c_emesh_packet_in[PW-1:0];

   //Pushback from core logic
   assign e2c_emesh_wait_out = e2c_cmesh_wait_in |
			       e2c_rmesh_wait_in |
			       e2c_xmesh_wait_in;
  	 	 
   //#####################################################
   //# CORE 2 EXTERNAL (C2E) 
   //#####################################################

   //Access aggregration 
   assign c2e_emesh_access_out = c2e_cmesh_access_in |
				 c2e_rmesh_access_in |
				 c2e_xmesh_access_in;
   
   //Simple priority decode (watch out for deadlock!)
   assign c2e_emesh_packet_out[PW-1:0] = c2e_cmesh_access_in ? c2e_cmesh_packet_in[PW-1:0] :
					 c2e_rmesh_access_in ? c2e_rmesh_packet_in[PW-1:0] :
					                       c2e_xmesh_packet_in[PW-1:0];
   
				
   //Wait pushback (for all, don't want loopback paths)

   assign c2e_cmesh_wait_out = c2e_emesh_wait_in;
   

   assign c2e_rmesh_wait_out = c2e_emesh_wait_in;
				

   assign c2e_xmesh_wait_out = c2e_emesh_wait_in;
   
   				     
endmodule // emesh_if


