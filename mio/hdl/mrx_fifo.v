//#############################################################################
//# Purpose: MIO Receive Synchronization FIFO                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################
module mrx_fifo # ( parameter PW         = 104,        // fifo width
		    parameter AW         = 32,         // fifo width
		    parameter FIFO_DEPTH = 16,         // fifo depth  
		    parameter TARGET     = "GENERIC"   // fifo target
		    )
   (// reset, clk, cfg
    input 	    clk, // main core clock   
    input 	    nreset, // async active low reset
    input 	    emode, // emesh mode
    input [4:0]     ctrlmode, // emode ctrlmode
    input 	    amode, // auto address mode
    input [AW-1:0]  dstaddr, // amode destination address
    input [1:0]     datamode, // amode datamode
    // IO interface
    input 	    io_access,// fifo write
    input [7:0]     io_valid, // fifo byte valid
    input [63:0]    io_packet, // fifo packet
    output 	    rx_wait,
    input 	    rx_clk,
    // transaction for mesh
    output 	    access_out, // fifo data valid
    output [PW-1:0] packet_out, // fifo packet
    input 	    wait_in     // wait pushback for fifo
    );
   reg [191:0] 	    emode_shiftreg;
   reg 		    emode_access;
   reg [2:0] 	    emode_valid;
   wire [2:0] 	    emode_select;
   wire [2:0] 	    emode_next;   
   wire [71:0] 	    fifo_packet;
   wire [63:0] 	    fifo_data;
   wire [7:0] 	    fifo_valid;
   wire 	    fifo_access;
   wire [191:0]     mux_data;
   wire  	    amode_write;
   wire [1:0] 	    amode_datamode;
   wire [4:0] 	    amode_ctrlmode;
   wire [AW-1:0]    amode_dstaddr;
   wire [AW-1:0]    amode_srcaddr;
   wire [AW-1:0]    amode_data;
   wire [PW-1:0]    emode_packet;
   wire 	    emode_done;
   wire 	    emode_active;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [PW-1:0]	amode_packet;		// From e2p_amode of emesh2packet.v
   // End of automatics
   
   //########################################################
   //# FIFO 
   //#######################################################   
   
   oh_fifo_cdc  #(.TARGET(TARGET),
		  .DW(72),
		  .DEPTH(FIFO_DEPTH))
   fifo  (// Outputs
	  .wait_out			(rx_wait),
	  .access_out			(fifo_access),
	  .packet_out			(fifo_packet[71:0]),
	  .prog_full			(),
	  .full				(),
	  .empty			(),
	  // Inputs
	  .nreset			(nreset),
	  .clk_in			(rx_clk),
	  .access_in			(io_access),
	  .packet_in			({io_packet[63:0],io_valid[7:0]}),
	  .clk_out			(clk),
	  .wait_in			(wait_in));

   assign fifo_data[63:0] = fifo_packet[71:8];
   assign fifo_valid[7:0] = fifo_packet[7:0];   

   //########################################################
   //# AMODE
   //#######################################################   

   assign amode_write           = 1'b1;
   assign amode_datamode[1:0]   = 2'b11;   
   assign amode_ctrlmode[4:0]   = ctrlmode[4:0];     
   assign amode_dstaddr[AW-1:0] = dstaddr[AW-1:0];
   assign amode_data[AW-1:0]    = fifo_data[31:0];
   assign amode_srcaddr[AW-1:0] = fifo_data[63:32];
      
   //########################################################
   //# EMODE
   //#######################################################   

   assign emode_done   = fifo_access & (~&fifo_valid[7:0]);
   assign emode_active = |emode_select[2:0];
   assign emode_next[2:0] = {emode_valid[1:0],emode_valid[2]};
   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       emode_valid[2:0] <= 3'b001;
     else if(~emode)
       emode_valid[2:0] <= 3'b001;
     else if(emode & fifo_access) 
       emode_valid[2:0] <= emode_next[2:0];   

   //Packet buffer
   assign mux_data[191:0] = {(3){fifo_data[63:0]}};
   
   assign emode_select[2:0] = {(3){fifo_access}} & emode_valid[2:0];
  
   integer 	      i;   
   always @ (posedge clk)
     for (i=0;i<3;i=i+1)
       emode_shiftreg[i*64+:64] <= emode_select[i] ? mux_data[i*64+:64] : emode_shiftreg[i*64+:64];

   assign emode_packet[PW-1:0] = emode_shiftreg[PW-1:0];
   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       emode_access <= 1'b0;
     else
       emode_access <= emode_done;
   
   //########################################################
   //# Transaction for Emesh
   //#######################################################   

   assign access_out         = amode ? fifo_access :
			               emode_access;
   			
   assign packet_out[PW-1:0] = amode ? amode_packet[PW-1:0] :
			               emode_packet[PW-1:0];
   
   
   /*emesh2packet AUTO_TEMPLATE (.\(.*\)_out (@"(substring vl-cell-name 4)"_\1[]),
    
    );
    */
   
   emesh2packet #(.AW(AW),
		  .PW(PW))
   e2p_amode (/*AUTOINST*/
	      // Outputs
	      .packet_out		(amode_packet[PW-1:0]),	 // Templated
	      // Inputs
	      .write_out		(amode_write),		 // Templated
	      .datamode_out		(amode_datamode[1:0]),	 // Templated
	      .ctrlmode_out		(amode_ctrlmode[4:0]),	 // Templated
	      .dstaddr_out		(amode_dstaddr[AW-1:0]), // Templated
	      .data_out			(amode_data[AW-1:0]),	 // Templated
	      .srcaddr_out		(amode_srcaddr[AW-1:0])); // Templated
     
endmodule // mrx_fifo

// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emesh/hdl")
// End:
