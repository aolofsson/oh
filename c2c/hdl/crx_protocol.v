//##########################################################################
//#
//# - DW is fixed per design
//# - size of packet being fed should be programmable
//# - data is transmitted LSB first!
//#
//#
//##########################################################################
module crx_protocol (/*AUTOARG*/
   // Outputs
   fifo_access, fifo_packet,
   // Inputs
   clk, nreset, datasize, io_access, io_packet
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter  PW   = 104;              // packet width (core)
   parameter  IOW  = 16;               // io packet width
   localparam CW   = $clog2(2*PW/IOW); // transfer count width
   
   //clock and reset
   input             clk;               // core clock
   input             nreset;            // async active low reset
   
   //config
   input [CW-1:0]    datasize;          // dynamic width of output data

   //16 bit interface
   input 	     io_access;    // access signal from IO
   input [2*IOW-1:0] io_packet;    // data from IO 

   //wide input interface
   output 	     fifo_access;   // access for fifo
   output [PW-1:0]   fifo_packet;   // packet for fifo

   //regs
   reg [2:0] 	     crx_state;
   reg [CW-1:0]      crx_count;   
   reg [PW-1:0]      fifo_packet;
   reg 		     fifo_access;
   
   //##########################
   //# STATE MACHINE
   //##########################
   `define CRX_IDLE     3'b000
   `define CRX_BUSY     3'b001

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       crx_state[2:0] <= `CRX_IDLE;
     else
       case (crx_state[2:0])
	 `CRX_IDLE:  crx_state[2:0] <= io_access      ? `CRX_BUSY : `CRX_IDLE;
	 `CRX_BUSY:  crx_state[2:0] <= transfer_done  ? `CRX_IDLE : `CRX_BUSY;
	 default: crx_state[2:0] <= 'b0;	 
       endcase // case (crx_state[2:0])

   //shift data
   always @ (posedge clk)    
     if(crx_state[2:0]==`CRX_BUSY)
       crx_count[CW-1:0] <= crx_count[CW-1:0] - 1'b1;
     else 
       crx_count[CW-1:0] <= datasize[CW-1:0];
   
   assign transfer_done = ~(|crx_count[CW-1:0]) & (crx_state[2:0]==`CRX_BUSY);

   //pipeline access signal
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       fifo_access <= 'b0;
     else
       fifo_access <= transfer_done;
   
   //create a wide parallel packet
   always @ (posedge clk)
     if ((crx_state[2:0]==`CRX_BUSY) & ~transfer_done)
       fifo_packet[PW-1:0] <= {fifo_packet[PW-2*IOW-1:0],io_packet[2*IOW-1:0]};
 
endmodule // crx_protocol





  
