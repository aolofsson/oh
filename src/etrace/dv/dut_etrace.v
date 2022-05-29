module dut(/*AUTOARG*/
   // Outputs
   dut_active, wait_out, access_out, packet_out,
   // Inputs
   clk, nreset, vdd, vss, access_in, packet_in, wait_in
   );

   parameter AW    = 32;
   parameter DW    = 32;
   parameter CW    = 2; 
   parameter IDW   = 12;
   parameter M_IDW = 6;
   parameter S_IDW = 12;
   parameter PW    = 104;     
   parameter N     = 1;
   parameter ID    = 12'h810;
   
   //#######################################
   //# CLOCK AND RESET
   //#######################################
   input            clk;
   input            nreset;
   input [N*N-1:0]  vdd;
   input 	    vss;
   output 	    dut_active;
   
   //#######################################
   //#EMESH INTERFACE 
   //#######################################
   
   //Stimulus Driven Transaction
   input [N-1:0]     access_in;
   input [N*PW-1:0]  packet_in;
   output [N-1:0]    wait_out;

   //DUT driven transactoin
   output [N-1:0]    access_out;
   output [N*PW-1:0] packet_out;
   input [N-1:0]     wait_in;


   //TODO: finish readback
   wire [DW-1:0]     mi_dout;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [3:0]		mi_ctrlmode;		// From e2p of packet2emesh.v
   wire [DW-1:0]	mi_data;		// From e2p of packet2emesh.v
   wire [1:0]		mi_datamode;		// From e2p of packet2emesh.v
   wire [AW-1:0]	mi_dstaddr;		// From e2p of packet2emesh.v
   wire [AW-1:0]	mi_srcaddr;		// From e2p of packet2emesh.v
   wire			mi_write;		// From e2p of packet2emesh.v
   // End of automatics
   
   assign dut_active         = 1'b1;
   assign access_out         = 'b0;
   assign wait_out           = 'b0;
   assign packet_out[PW-1:0] = 'b0;
   
   
   /*packet2emesh AUTO_TEMPLATE (//Stimulus
                            .\(.*\)_out(mi_\1[]),
                             );
    */

   //CONFIG INTERFACE
   packet2emesh e2p (/*AUTOINST*/
		     // Outputs
		     .write_out		(mi_write),		 // Templated
		     .datamode_out	(mi_datamode[1:0]),	 // Templated
		     .ctrlmode_out	(mi_ctrlmode[3:0]),	 // Templated
		     .data_out		(mi_data[DW-1:0]),	 // Templated
		     .dstaddr_out	(mi_dstaddr[AW-1:0]),	 // Templated
		     .srcaddr_out	(mi_srcaddr[AW-1:0]),	 // Templated
		     // Inputs
		     .packet_in		(packet_in[PW-1:0]));

   //TRACE
   etrace #(.ID(ID))
   etrace ( // Outputs
	    .mi_dout		(mi_dout[DW-1:0]),
	    // Inputs
	    .mi_en		(access_in),
	    .mi_we		(mi_write),
	    .mi_addr		(mi_dstaddr[AW-1:0]),
	    .mi_clk		(clk),
	    .mi_din		(mi_data[DW-1:0]),
	    .trace_clk		(clk),
	    .trace_trigger	(1'b1), 
	    .trace_vector	(mi_srcaddr[AW-1:0]),
	    .nreset		(nreset));
     
endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/dv" "../../emesh/hdl")
// End:

