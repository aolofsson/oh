module mrx_protocol (/*AUTOARG*/
   // Outputs
   fifo_access, fifo_packet,
   // Inputs
   rx_clk, nreset, datasize, lsbfirst, io_access, io_packet
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter  PW   = 104;               // packet width (core)
   parameter  NMIO = 8;                 // io packet width
   parameter  CW   = $clog2(2*PW/NMIO); // transfer count width
   
   //clock and reset
   input              rx_clk;        // rx clock
   input 	      nreset;        // async active low reset
   
   //config
   input [7:0] 	      datasize;      // dynamic width of output data
   input 	      lsbfirst;
   
   //16 bit interface
   input 	      io_access;     // access signal from IO
   input [2*NMIO-1:0] io_packet;     // data from IO 
   
   //wide input interface
   output 	      fifo_access;   // access for fifo
   output [PW-1:0]    fifo_packet;   // packet for fifo

   //#####################################################################
   //# BODY
   //#####################################################################

   //regs
   reg [2:0] 	   mrx_state;
   reg [CW-1:0]    mrx_count;   
   reg 		   fifo_access;
   wire 	   shift;
   wire 	   transfer_done;
   
   
   //##########################
   //# STATE MACHINE
   //##########################

   `define MRX_IDLE     3'b000
   `define MRX_BUSY     3'b001

   always @ (posedge rx_clk or negedge nreset)
     if(!nreset)
       mrx_state[2:0] <= `MRX_IDLE;
     else
       case (mrx_state[2:0])
	 `MRX_IDLE:  mrx_state[2:0] <= io_access  ? `MRX_BUSY : `MRX_IDLE;
	 `MRX_BUSY:  mrx_state[2:0] <= ~io_access ? `MRX_IDLE : `MRX_BUSY;
	 default: mrx_state[2:0] <= 'b0;	 
       endcase // case (mrx_state[2:0])

   //tx word counter
   always @ (posedge rx_clk)    
     if((mrx_state[2:0]==`MRX_IDLE) | transfer_done)
       mrx_count[CW-1:0] <= datasize[CW-1:0];
     else if(mrx_state[2:0]==`MRX_BUSY)
       mrx_count[CW-1:0] <= mrx_count[CW-1:0] - 1'b1;   
   
   assign transfer_done = (mrx_count[CW-1:0]==1'b1) & (mrx_state[2:0]==`MRX_BUSY);
   assign shift         = (mrx_state[2:0]==`MRX_BUSY);
   
   //pipeline access signal
   always @ (posedge rx_clk or negedge nreset)
     if(!nreset)
       fifo_access <= 'b0;
     else
       fifo_access <= transfer_done;
   
   //##########################
   //# SHIFT REGISTER
   //##########################

   oh_ser2par #(.PW(PW),
		.SW(2*NMIO))
   
   ser2par (// Outputs
	    .dout	(fifo_packet[PW-1:0]),
	    // Inputs
	    .clk	(rx_clk),
	    .din	(io_packet[2*NMIO-1:0]),
	    .lsbfirst	(lsbfirst),
	    .shift	(shift)
	    );
    
   
endmodule // mrx_protocol
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:







  
