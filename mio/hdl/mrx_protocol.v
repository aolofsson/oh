//##########################################################################
//#
//# - DW is fixed per design
//# - size of packet being fed should be programmable
//# - data is transmitted LSB first!
//#
//#
//##########################################################################
module mrx_protocol (/*AUTOARG*/
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
   parameter  MIOW  = 16;               // io packet width
   localparam CW   = $clog2(2*PW/MIOW); // transfer count width
   
   //clock and reset
   input              clk;               // core clock
   input              nreset;            // async active low reset
   
   //config
   input [CW-1:0]     datasize;          // dynamic width of output data

   //16 bit interface
   input 	      io_access;    // access signal from IO
   input [2*MIOW-1:0] io_packet;    // data from IO 

   //wide input interface
   output 	      fifo_access;   // access for fifo
   output [PW-1:0]    fifo_packet;   // packet for fifo

   //regs
   reg [2:0] 	      mrx_state;
   reg [CW-1:0]       mrx_count;   
   reg [PW-1:0]       fifo_packet;
   reg 		      fifo_access;
   
   //##########################
   //# STATE MACHINE
   //##########################
   `define MRX_IDLE     3'b000
   `define MRX_BUSY     3'b001

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       mrx_state[2:0] <= `MRX_IDLE;
     else
       case (mrx_state[2:0])
	 `MRX_IDLE:  mrx_state[2:0] <= io_access  ? `MRX_BUSY : `MRX_IDLE;
	 `MRX_BUSY:  mrx_state[2:0] <= ~io_access ? `MRX_IDLE : `MRX_BUSY;
	 default: mrx_state[2:0] <= 'b0;	 
       endcase // case (mrx_state[2:0])

   //shift data
   always @ (posedge clk)    
     if((mrx_state[2:0]==`MRX_IDLE) | transfer_done)
       mrx_count[CW-1:0] <= datasize[CW-1:0];
     else if(mrx_state[2:0]==`MRX_BUSY)
       mrx_count[CW-1:0] <= mrx_count[CW-1:0] - 1'b1;   
   
   assign transfer_done = ~(|mrx_count[CW-1:0]) & (mrx_state[2:0]==`MRX_BUSY);

   //pipeline access signal
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       fifo_access <= 'b0;
     else
       fifo_access <= transfer_done;
   
   //create a wide parallel packet
   always @ (posedge clk)
     if ((mrx_state[2:0]==`MRX_BUSY))
       fifo_packet[PW-1:0] <= {fifo_packet[PW-2*MIOW-1:0],io_packet[2*MIOW-1:0]};
 
endmodule // mrx_protocol






  
