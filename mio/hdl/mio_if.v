`include "mio_regmap.vh"
module mio_if (/*AUTOARG*/
   // Outputs
   addrincr, access_out, packet_out, wait_out, rx_wait_out,
   tx_access_out, tx_packet_out,
   // Inputs
   clk, nreset, amode, emode, datasize, ctrlmode, dstaddr, wait_in,
   access_in, packet_in, rx_access_in, rx_packet_in, tx_wait_in
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter  AW  = 32;            // address width
   parameter  PW  = 2*AW +40;      // emesh packet width
   parameter  MPW = PW+8;          // mio packet width  
   
   // reset, clk, config
   input            clk;           // main core clock   
   input 	    nreset;        // async active low reset
   input 	    amode;         // auto address mode
   input 	    emode;         // emesh mode
   input [7:0] 	    datasize;      // datasize
   input [4:0] 	    ctrlmode;      // emesh ctrlmode
   input [AW-1:0]   dstaddr;       // destination address for amode
   output [3:0]     addrincr;      // increment address for amode
   
   // core interface
   output 	    access_out;    // pass through
   output [PW-1:0]  packet_out;    // packet for core from rx
   input 	    wait_in;       // pass through

   input 	    access_in;     // pass through
   input [PW-1:0]   packet_in;     // packet for tx from core
   output 	    wait_out;      // pass through

   
   // datapath interface (fifo)
   input 	    rx_access_in;  // pass through
   input [MPW-1:0]  rx_packet_in;  // packet from rx fifo
   output 	    rx_wait_out;   // pass through

   output 	    tx_access_out; // pass through
   output [MPW-1:0] tx_packet_out; // packet to tx fifo
   input 	    tx_wait_in;    // pass through
   
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


   // pass throughs
   assign rx_wait_out   = wait_in;
   assign access_out    = rx_access_in;
   assign tx_access_out = access_in;
   assign wait_out      = tx_wait_in;
   
   // adapter for PW-->MPW width (MPW>=PW)
   assign tx_packet_out[MPW-1:0] = packet_in[PW-1:0];

   //#################################################
   // TRANSACTION FOR CORE (FROM RX)
   //#################################################

   // parse packet
   packet2emesh pe2 (.packet_in		(rx_packet_in[PW-1:0]),
		     /*AUTOINST*/
		     // Outputs
		     .write_in		(write_in),
		     .datamode_in	(datamode_in[1:0]),
		     .ctrlmode_in	(ctrlmode_in[4:0]),
		     .dstaddr_in	(dstaddr_in[AW-1:0]),
		     .srcaddr_in	(srcaddr_in[AW-1:0]),
		     .data_in		(data_in[AW-1:0]));
      
   // datamode
   assign datamode[1:0] = (datasize[3:0]==4'd1) ? 2'b00 :
			  (datasize[3:0]==4'd2) ? 2'b01 :
			  (datasize[3:0]==4'd4) ? 2'b10 :
			                          2'b11;
   

   //#################################################
   // AUTOINCREMENT LOGIC ("AMODE")
   //#################################################

   //creating datamode based on data size
   assign addr_stride[3:0] = (datamode[1:0]==2'b00) ? 4'd1 :
		  	     (datamode[1:0]==2'b01) ? 4'd2 :
			     (datamode[1:0]==2'b10) ? 4'd4 :
			                            4'd8 ;


   // only update when in amode and no wait
   assign addr_update = amode & ~wait_in & access_out;

   // send address increment to mio_regs
   assign addrincr[3:0] = addr_update ? addr_stride[3:0] :
			                4'b0;
   
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
   assign data_out[AW-1:0]    = amode ? rx_packet_in[AW-1:0] :
                                        data_in[AW-1:0];

   assign srcaddr_out[AW-1:0] = amode ? 'b0 :
                                        srcaddr_in[AW-1:0];


   //Construct outgoing packet
   emesh2packet e2p (/*AUTOINST*/
		     // Outputs
		     .packet_out	(packet_out[PW-1:0]),
		     // Inputs
		     .write_out		(write_out),
		     .datamode_out	(datamode_out[1:0]),
		     .ctrlmode_out	(ctrlmode_out[4:0]),
		     .dstaddr_out	(dstaddr_out[AW-1:0]),
		     .data_out		(data_out[AW-1:0]),
		     .srcaddr_out	(srcaddr_out[AW-1:0]));
   
endmodule // mio_if

// Local Variables:
// verilog-library-directories:("." "../hdl" "../../../oh/emesh/hdl")
// End:



