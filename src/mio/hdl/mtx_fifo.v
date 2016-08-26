//#############################################################################
//# Purpose: MIO Transmit FIFO                                                #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################
module mtx_fifo # ( parameter PW         = 136,           // packet width
		    parameter AW         = 64,            // address width
		    parameter FIFO_DEPTH = 16,            // fifo depth  
		    parameter TARGET     = "GENERIC"      // fifo target
		    )
   (// reset, clk, cfg
    input 	   clk, // main core clock   
    input 	   io_clk, // clock for tx logic
    input 	   nreset, // async active low reset
    input 	   tx_en,// transmit enable
    input 	   emode,// emesh transaction mode
    // Data from mesh
    input 	   access_in, // fifo data valid
    input [PW-1:0] packet_in, // fifo packet  
    output 	   wait_out, // wait pushback for fifo    
    // Data for IO logic
    output [63:0]  io_packet, // packet for IO
    output [7:0]   io_valid, // byte valids for IO
    input 	   io_wait // pushback from IO
    );
   
   //local wires
   reg [1:0] 	   emesh_cycle;
   reg [191:0] 	   packet_buffer;   
   wire 	   fifo_access_out;
   wire [71:0] 	   fifo_packet_out;
   wire 	   fifo_access_in;
   wire [71:0] 	   fifo_packet_in;
   wire [63:0] 	   data_wide;
   wire [7:0] 	   valid;
   wire 	   emesh_wait;
   wire [63:0] 	   fifo_data_in;
   wire 	   fifo_wait;
   
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	data_in;		// From p2e of packet2emesh.v
   wire [1:0]		datamode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From p2e of packet2emesh.v
   wire			write_in;		// From p2e of packet2emesh.v
   // End of automatics
   
   //######################
   //# FIFO INPUT LOGIC
   //######################

   packet2emesh #(.AW(AW),
		  .PW(PW))
   p2e (.packet_in		(packet_in[PW-1:0]),
	/*AUTOINST*/
	// Outputs
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[4:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]));

   // create 64 bit data vector (related to packet packing)
   assign data_wide[63:0]    =  {srcaddr_in[31:0],data_in[31:0]};

   // create a dummy wide packet to avoid warnings
   always @ (posedge clk)
     if(~wait_out & access_in)
       packet_buffer[191:0] <= packet_in[PW-1:0];
    
   // Emesh write pipeline (note! fifo_wait means half full!)
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       emesh_cycle[1:0] <= 'b0;
     else if(emesh_cycle[0] && (AW==64))      // 2nd stall for 64bit
       emesh_cycle[1:0] <= 2'b10;
     else if(emode & access_in & ~fifo_wait)  // 1 stall for emesh
       emesh_cycle[1:0] <= 2'b01;
     else
       emesh_cycle[1:0] <= 2'b00;

   // valid bits depending on type of transaction
   assign valid[7:0] = (emesh_cycle[0] && (AW==32))       ? 8'h3F : //48 bits
		       (emesh_cycle[1] && (AW==64))       ? 8'h03 : //16 bits
         	       (~emode & datamode_in[1:0]==2'b00) ? 8'h01 : //double
        	       (~emode & datamode_in[1:0]==2'b01) ? 8'h03 : //word
         	       (~emode & datamode_in[1:0]==2'b10) ? 8'h0F : //short	 
                                                            8'hFF;  //default
			   
   // folding data for fifo
   assign fifo_data_in[63:0] = ~emode          ? data_wide[63:0]       :
                                emesh_cycle[0] ? packet_buffer[127:64]   :
      		                emesh_cycle[1] ? packet_buffer[191:128]  :
		                                  packet_in[63:0];

   assign fifo_packet_in[71:0] = {fifo_data_in[63:0], valid[7:0]};
   
   // fifo access
   assign fifo_access_in = access_in | (|emesh_cycle[1:0]);

   // pushback wait while emesh transaction is active or while fifo is half-full
   assign wait_out = fifo_wait  | (|emesh_cycle[1:0]);
      
   //########################################################
   //# FIFO 
   //#######################################################   

   oh_fifo_cdc  #(.TARGET(TARGET),
		  .DW(72),
		  .DEPTH(FIFO_DEPTH))
   fifo  (.clk_in			(clk),
	  .clk_out			(io_clk),
	  .wait_in			(io_wait),
	  .prog_full			(),
	  .full				(),
	  .empty			(), 
	  .wait_out			(fifo_wait),
	  .access_in			(fifo_access_in),
	  .packet_in			(fifo_packet_in[71:0]),
	  .access_out			(fifo_access_out),
	  .packet_out			(fifo_packet_out[71:0]),
	  .nreset			(nreset));

   //########################################################
   //# FIFO OUTPUT LOGIC
   //#######################################################

   assign io_valid[7:0]    = {{(8){fifo_access_out}} & fifo_packet_out[7:0]};
   assign io_packet[63:0] = fifo_packet_out[71:8];
   
endmodule // mtx
// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emesh/hdl")
// End:

