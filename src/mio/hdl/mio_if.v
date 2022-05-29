`include "mio_regmap.vh"
module mio_if (/*AUTOARG*/
   // Outputs
   access_out, packet_out, rx_wait_out,
   // Inputs
   clk, nreset, amode, emode, lsbfirst, ctrlmode, dstaddr, wait_in,
   rx_access_in, rx_packet_in
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter  AW  = 32;            // address width
   parameter  PW  = 104;           // emesh packet width
   parameter  MPW = 128;           // mio packet width  (> PW) 
   
   // reset, clk, config
   input            clk;           // main core clock   
   input 	    nreset;        // async active low reset
   input 	    emode;         // emesh mode
   input [4:0] 	    ctrlmode;      // emode ctrlmode
   input 	    amode;         // auto address mode
   input [AW-1:0]   dstaddr;       // amode destination address
   input [1:0] 	    datamode;      // amode datamode
   //    
   // core interface
   output 	    access_out;    // pass through
   output [PW-1:0]  packet_out;    // packet for core from rx
   input 	    wait_in;       // pass through
   
   // datapath interface (fifo)
   input 	    rx_access_in;  // pass through
   input [MPW-1:0]  rx_packet_in;  // packet from rx fifo
   output 	    rx_wait_out;   // pass through

   //#####################################################################
   //# BODY
   //#####################################################################
   wire [4:0] 	   ctrlmode_out;
   wire [AW-1:0]   data_out;	
   wire [1:0] 	   datamode_out;
   wire [AW-1:0]   dstaddr_out;	
   wire [AW-1:0]   srcaddr_out;	
   wire 	   write_out;	
   wire [1:0] 	   datamode;
   wire [3:0] 	   addr_stride;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From pe2 of packet2emesh.v
   wire [AW-1:0]	data_in;		// From pe2 of packet2emesh.v
   wire [1:0]		datamode_in;		// From pe2 of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From pe2 of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From pe2 of packet2emesh.v
   wire			write_in;		// From pe2 of packet2emesh.v
   // End of automatics
   /*AUTOINPUT*/

   wire [3:0] 		datasize;
   
   
 
   //#################################################
   // TRANSACTION FOR CORE (FROM RX)
   //#################################################

   // parse packet
   packet2emesh #(.AW(AW),
		  .PW(PW))
   pe2 (.packet_in		(rx_packet_in[PW-1:0]),
	/*AUTOINST*/
	// Outputs
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[4:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]));
      
   // datamode
   assign datamode[1:0] = (datasize[3:0]==4'd1) ? 2'b00 :
			  (datasize[3:0]==4'd2) ? 2'b01 :
			  (datasize[3:0]==4'd4) ? 2'b10 :
			                          2'b11;
   
   //#################################################
   // TRANSACTION FOR CORE (FROM RX)
   //#################################################

   // write only for amode (streaming data)
   assign write_out           = amode ? 1'b1 :  
			                write_in;

   // translate datasize to datamode
   assign datamode_out[1:0]   = amode ? datamode[1:0] :
			                datamode_in[1:0];
   
   // ctrlmode from register in amode
   assign ctrlmode_out[4:0]   = amode ? ctrlmode[4:0] :
			                ctrlmode_in[4:0];
   
   // address from 
   assign dstaddr_out[AW-1:0] = amode ? dstaddr[AW-1:0] :
                                        dstaddr_in[AW-1:0];
   
   // data in first 64 bits for amode
   
   assign data_out[AW-1:0]    = amode ? rx_packet_in[31:0] :
                                        data_in[AW-1:0];

   assign srcaddr_out[AW-1:0] = amode ? rx_packet_in[63:32] :
                                        srcaddr_in[AW-1:0];

   //Construct outgoing packet
   emesh2packet #(.AW(AW),
		  .PW(PW))
   e2p (/*AUTOINST*/
	// Outputs
	.packet_out			(packet_out[PW-1:0]),
	// Inputs
	.write_out			(write_out),
	.datamode_out			(datamode_out[1:0]),
	.ctrlmode_out			(ctrlmode_out[4:0]),
	.dstaddr_out			(dstaddr_out[AW-1:0]),
	.data_out			(data_out[AW-1:0]),
	.srcaddr_out			(srcaddr_out[AW-1:0]));
   
endmodule // mio_if

// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl")
// End:



