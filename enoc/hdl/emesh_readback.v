module emesh_readback (/*AUTOARG*/
   // Outputs
   ready_out, access_out, packet_out,
   // Inputs
   nreset, clk, access_in, packet_in, read_data, ready_in
   );
   parameter  AW  = 32;    // address width
   parameter  PW  = 104;   // packet width   
   
   //clk, reset
   input           nreset;      // asynchronous active low reset
   input 	   clk;         // clock
   
   // input transaction
   input 	   access_in;   // register access
   input [PW-1:0]  packet_in;   // data/address
   output 	   ready_out;    // pushback from mesh

   // register/memory data (already pipelined)
   input [63:0]    read_data;   // data from register/memorye

   // output transaction
   output 	   access_out;  // register access
   output [PW-1:0] packet_out;  // data/address
   input 	   ready_in;     // pushback from mesh

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [12:0]		ctrlmode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	data_in;		// From p2e of packet2emesh.v
   wire [1:0]		datamode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From p2e of packet2emesh.v
   wire			write_in;		// From p2e of packet2emesh.v
   // End of automatics

   reg [1:0] 		datamode_out;
   reg [4:0] 		ctrlmode_out;
   reg [AW-1:0] 	dstaddr_out; 	
   wire [AW-1:0] 	data_out;
   wire [AW-1:0] 	srcaddr_out;
   reg 			access_out;
   
   //########################################
   //# Parse packet
   //#######################################  

   enoc_unpack #(.AW(AW),
		 .PW(PW))
   p2e (/*AUTOINST*/
	// Outputs
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[12:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]),
	// Inputs
	.packet_in			(packet_in[PW-1:0]));
      
   //########################################
   //# Pipeline
   //#######################################   

   //access
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       access_out <= 1'b0;
     else if(ready_in)
       access_out <= access_in & ~write_in;

   //packet
   always @ (posedge clk)
     if(ready_in & access_in & ~write_in)
       begin	  
	  datamode_out[1:0]   <= datamode_in[1:0];
	  ctrlmode_out[4:0]   <= ctrlmode_in[4:0];
	  dstaddr_out[AW-1:0] <= srcaddr_in[AW-1:0]; 
       end

   assign data_out[AW-1:0]    = read_data[31:0];
   assign srcaddr_out[AW-1:0] = read_data[63:32];
   
   //ready signal
   assign ready_out = ready_in;
   
   //########################################
   //# Convert to Packet
   //#######################################  
     
   enoc_pack #(.AW(AW),
	       .PW(PW))
   e2p (.write_out   (1'b1),
	/*AUTOINST*/
	// Outputs
	.packet_out			(packet_out[PW-1:0]),
	// Inputs
	.datamode_out			(datamode_out[1:0]),
	.ctrlmode_out			(ctrlmode_out[12:0]),
	.dstaddr_out			(dstaddr_out[AW-1:0]),
	.data_out			(data_out[AW-1:0]),
	.srcaddr_out			(srcaddr_out[AW-1:0]));
   
   
endmodule // emesh_readback

// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:
