// A stimulus file provides inputs signals to the design under test (DUT).
// This stimulus module is designed to be compatible with verilog simulators,
// emulators, and FPGA prototyping. This is akin to a simple test vector generator
//
// Test Process:
// 1. Zero out memory (or write program)
// 2. Set go signal
// 3. Drive out all valid packets sequentially

module stimulus
  #(parameter DW        = 64,      // Stimulus packet width
    parameter DEPTH     = 1024,    // Memory depth
    parameter CW        = 0,       // bit[0]=valid, [CW-1:1]=timestamp
    parameter MW        = DW + CW, // Memory width (derived)
    parameter FILENAME  = "NONE"   // Simulus hexfile for $readmemh
    )
   (
    // External stimulus load port
    input 	    nreset, // async reset
    input 	    ext_start, // Start driving stimulus
    input 	    ext_clk,// External clock for write path
    input 	    ext_access, // Valid packet for memory
    input [MW-1:0]  ext_packet, // Packet for memory
    // DUT drive port
    input 	    dut_clk, // DUT side clock
    input 	    dut_ready, // DUT ready signal
    output 	    stim_valid, // Packet valid
    output [DW-1:0] stim_packet, // Packet data
    output 	    stim_done // Signals that stimulus is done
    );

   // memory parameters
   parameter MAW = $clog2(DEPTH); // Memory address width

   // state machine parameters
   localparam STIM_IDLE    = 2'b00;
   localparam STIM_ACTIVE  = 2'b01;
   localparam STIM_PAUSE   = 2'b10;
   localparam STIM_DONE    = 2'b11;

   // Local values
   reg [MW-1:0]       ram[0:DEPTH-1];
   reg [1:0] 	      rd_state;
   reg [MAW-1:0]      wr_addr;
   reg [MAW-1:0]      rd_addr;
   reg [1:0] 	      sync_pipe;
   reg 		      mem_read;
   reg [MW-1:0]       mem_data;
   reg [CW:0] 	      rd_delay;
   wire 	      dut_start;
   wire 	      valid_packet;

   //#################################
   // Init memory if configured
   //#################################
   generate
      if(!(FILENAME=="NONE"))
	initial
	  begin
	     $display("Driving stimulus from %s", FILENAME);
	     $readmemh(FILENAME, ram);
	  end
   endgenerate

   //#################################
   // Write port state machine
   //#################################

   always @ (posedge ext_clk or negedge nreset)
     if(!nreset)
       wr_addr[MAW-1:0] <= 'b0;
     else if(ext_access)
       wr_addr[MAW-1:0] <= wr_addr[MAW-1:0] + 1;

   //Synchronize ext_start to dut_clk domain
   always @ (posedge dut_clk or negedge nreset)
     if(!nreset)
       sync_pipe[1:0] <= 'b0;
     else
       sync_pipe[1:0] <= {sync_pipe[0],ext_start};

   assign dut_start = sync_pipe[1];

   //#################################
   // Read port state machine
   //#################################
   //1. Start on dut_start
   //2. Drive stimulus while dut is ready
   //3. Set end state on special end packet (bit 0)

   always @ (posedge dut_clk or negedge nreset)
     if(!nreset)
       begin
	  rd_state[1:0]      <= STIM_IDLE;
	  rd_addr[MAW-1:0]   <= 'b0;
	  rd_delay           <= 'b0;
       end
     else if(dut_ready)
       case (rd_state[1:0])
	 STIM_IDLE :
	   rd_state[1:0] <= dut_start ? STIM_ACTIVE : STIM_IDLE;
	 STIM_ACTIVE :
	   begin
	      rd_state[1:0] <= (|rd_delay) ? STIM_PAUSE :
			       ~stim_valid ? STIM_DONE  :
	                                     STIM_ACTIVE;
	      rd_addr[MAW-1:0] <= rd_addr[MAW-1:0] + 1'b1;
	      rd_delay         <= (CW > 1) ? mem_data[CW:1] : 'b0;
	   end
	 STIM_PAUSE :
	   begin
	      rd_state[1:0] <= (|rd_delay) ? STIM_PAUSE : STIM_ACTIVE;
	      rd_delay      <= rd_delay - 1'b1;
	   end
       endcase // case (rd_state[1:0])

   //Output Driver
   assign stim_done    = (rd_state[1:0] == STIM_DONE);
   assign valid_packet = (CW==0) | mem_data[0];

   //#################################
   // RAM
   //#################################

   //write port
   always @(posedge ext_clk)
     if(ext_access)
       ram[wr_addr[MAW-1:0]] <= ext_packet[MW-1:0];

   //read port
   always @ (posedge dut_clk)
     begin
	mem_data[MW-1:0] <= ram[rd_addr[MAW-1:0]];
	mem_read         <= (rd_state==STIM_ACTIVE); //mem-cycle adjust
     end

   //Shut off access immediately, but pipeline delay by one cycle
   assign stim_valid          = valid_packet & mem_read & ~stim_done;
   assign stim_packet[DW-1:0] = mem_data[MW-1:CW];

endmodule // stimulus
