//##########################################################################
//#
//# - DW is fixed per design
//# - size of packet being fed should be programmable
//# - data is transmitted LSB first!
//#
//#
//##########################################################################
module ctx_protocol (/*AUTOARG*/
   // Outputs
   fifo_wait, io_access, io_packet,
   // Inputs
   clk, nreset, datasize, fifo_access, fifo_packet, tx_wait
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter  PW   = 104;              // packet width (core)
   parameter  IOW  = 16;               // io packet width
   localparam CW   = $clog2(2*PW/IOW); // transfer count width
   
   //clock and reset
   input              clk;     // core clock
   input              nreset;     // async active low reset
   
   //config
   input [CW-1:0]     datasize;   // dynamic width of input data

   //wide input interface
   input 	      fifo_access;  // data valid
   input [PW-1:0]     fifo_packet;  // wide data
   output 	      fifo_wait;    // wait pushback
   
   //io interface (16 bits SDR)
   output    	      io_access;  // access signal for io
   output [2*IOW-1:0] io_packet;  // data for IO
   input 	      tx_wait;    // pushback (from io)

   //regs
   reg [2:0] 	      ctx_state;
   reg [PW-1:0]       ctx_data;
   reg [CW-1:0]       ctx_count;
   
   //##########################
   //# STATE MACHINE
   //##########################
   `define CTX_IDLE    3'b000
   `define CTX_BUSY    3'b001
   
   assign start_transfer =  (fifo_access & ~tx_wait);
   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       ctx_state[2:0] <= `CTX_IDLE;
     else
       case (ctx_state[2:0])
	 `CTX_IDLE: ctx_state[2:0] <= start_transfer ? `CTX_BUSY : `CTX_IDLE;
	 `CTX_BUSY: ctx_state[2:0] <= transfer_done  ? `CTX_IDLE  : `CTX_BUSY;
	 default: ctx_state[2:0] <= 'b0;	 
       endcase // case (ctx_state[2:0])

   always @ (posedge clk)
     if(ctx_state[2:0]==`CTX_BUSY)
       ctx_count[CW-1:0] <= ctx_count[CW-1:0] - 1'b1;
     else
       ctx_count[CW-1:0] <= datasize[CW-1:0];

   assign transfer_done = ~(|ctx_count[CW-1:0]) & (ctx_state[2:0]==`CTX_BUSY) ;

   assign io_access = (ctx_state[2:0]==`CTX_BUSY);
      
   //##########################
   //# DATA SHIFT REGISTER
   //##########################
   
   always @ (posedge clk)
     if(ctx_state[2:0]==`CTX_BUSY)
       ctx_data[PW-1:0]  <= {ctx_data[PW-2*IOW-1:0],{(2*IOW){1'b0}}};
     else if(start_transfer)
       ctx_data[PW-1:0]  <= fifo_packet[PW-1:0];
   
   assign io_packet[2*IOW-1:0] = ctx_data[PW-1:PW-2*IOW];
        
   //##########################
   //# WAIT SIGNAL
   //##########################

   assign fifo_wait = tx_wait |
		      (ctx_state[2:0]==`CTX_BUSY);
 
endmodule // ctx_protocol




  
