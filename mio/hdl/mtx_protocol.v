//#######################################################################
//#
//# - DW is fixed per design
//# - size of packet being fed should be programmable
//# - data is transmitted MSB first!
//# - how to set up rx/tx protocol (other system channel??)
//#######################################################################
module mtx_protocol (/*AUTOARG*/
   // Outputs
   fifo_wait, io_access, io_packet,
   // Inputs
   clk, nreset, datasize, fifo_access, fifo_packet, tx_wait
   );

   //####################################################################
   //# INTERFACE
   //####################################################################

   //parameters
   parameter  PW   = 104;              // packet width (core)
   parameter  MIOW = 16;               // io packet width
   localparam CW   = $clog2(2*PW/MIOW); // transfer count width
   
   //clock and reset
   input               clk;            // core clock
   input               nreset;         // async active low reset
   
   //config
   input [CW-1:0]      datasize;       // dynamic width of input data

   //wide input interface
   input 	       fifo_access;    // data valid
   input [PW-1:0]      fifo_packet;    // wide data
   output 	       fifo_wait;      // wait pushback
   
   //io interface (16 bits SDR)
   output    	       io_access;      // access signal for io
   output [2*MIOW-1:0] io_packet;      // data for IO
   input 	       tx_wait;        // pushback (from io)

   //regs
   reg [2:0] 	       mtx_state;
   reg [PW-1:0]        mtx_data;
   reg [CW-1:0]        mtx_count;
   
   //##########################
   //# STATE MACHINE
   //##########################
   `define MTX_IDLE    3'b000
   `define MTX_BUSY    3'b001
   
   assign start_transfer =  (fifo_access & ~tx_wait);
   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       mtx_state[2:0] <= `MTX_IDLE;
     else
       case (mtx_state[2:0])
	 `MTX_IDLE: mtx_state[2:0] <= start_transfer ? `MTX_BUSY : `MTX_IDLE;
	 `MTX_BUSY: mtx_state[2:0] <= transfer_done  ? `MTX_IDLE  : `MTX_BUSY;
	 default: mtx_state[2:0] <= 'b0;	 
       endcase // case (mtx_state[2:0])

   always @ (posedge clk)
     if(mtx_state[2:0]==`MTX_BUSY)
       mtx_count[CW-1:0] <= mtx_count[CW-1:0] - 1'b1;
     else
       mtx_count[CW-1:0] <= datasize[CW-1:0];

   assign transfer_done = ~(|mtx_count[CW-1:0]) & (mtx_state[2:0]==`MTX_BUSY) ;

   assign io_access = (mtx_state[2:0]==`MTX_BUSY);
      
   //##########################
   //# DATA SHIFT REGISTER
   //##########################
   
   always @ (posedge clk)
     if(mtx_state[2:0]==`MTX_BUSY)
       mtx_data[PW-1:0]  <= {mtx_data[PW-2*MIOW-1:0],{(2*MIOW){1'b0}}};
     else if(start_transfer)
       mtx_data[PW-1:0]  <= fifo_packet[PW-1:0];
   
   assign io_packet[2*MIOW-1:0] = mtx_data[PW-1:PW-2*MIOW];
        
   //##########################
   //# WAIT SIGNAL
   //##########################

   assign fifo_wait = tx_wait |
		      (mtx_state[2:0]==`MTX_BUSY);
 
endmodule // mtx_protocol




  
