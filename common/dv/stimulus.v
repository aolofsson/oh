// A stimulus file provides inputs signals to the design under test (DUT).
// This stimulus module is designed to be compatible with verilog simulators,
// emulators, and FPGA prototyping. This is akin to a simple test vector generator
// No looping supported!
//
// Memory format: 
// b0      = valid,
// b1-7    = wait time
// b8-bxxx = packet
//
// Test Process:
// 1. Zero out memory (or write program)
// 2. Set go signal
//
module stimulus #( parameter DW       = 32,    // Memory width=DW+
		   parameter MAW      = 15,    // Memory address width
		   parameter HEXFILE = "NONE"  // Name of hex file
		   )
   (   
       //Asynchronous Stimulus Reset
       input 	       nreset,
       input 	       ext_start, // Start driving stimulus
       input 	       use_timestamps,//b1-7 used for timestamps
       input 	       ignore_valid,//b0 valid bit ignored 
       //External Load port
       input 	       ext_clk,// External clock for write path  
       input 	       ext_access, // Valid packet for memory
       input [DW-1:0]  ext_packet, // Packet for memory
       //DUT Drive port
       input 	       dut_clk, // DUT side clock
       input 	       dut_wait, // DUT stall signal
       output 	       stim_access, // Access signal  
       output [DW-1:0] stim_packet, // Packet
       output 	       stim_done // Stimulus program done
       );

   localparam MD       = 1<<MAW;  // Memory depth
   
   //Registers
   reg [DW-1:0]        ram[0:MD-1];
   reg [1:0] 	       rd_state;   
   reg [MAW-1:0]       wr_addr;
   reg [MAW-1:0]       rd_addr;
   reg [255:0] 	       memhfile;
   reg [1:0] 	       sync_pipe;
   reg [6:0] 	       rd_delay;
   reg [DW-1:0]        stim_packet;
   reg 		       stim_read;

   //#################################
   // Init memory if configured
   //#################################
   generate
      if(!(HEXFILE=="NONE"))
	initial
	  begin
	     $display("Initializing STIMULUS from %s", HEXFILE);	
	     $readmemh(HEXFILE, ram);
	  end
   endgenerate
   
   //#################################
   // Write port state machine
   //#################################

   always @ (posedge ext_clk or negedge nreset)
     if(!nreset)
       wr_addr[MAW-1:0] <= 'b0;	   	  
     else if(ext_access)
       wr_addr[MAW-1:0]   <= wr_addr[MAW-1:0] + 1;
   
   //Synchronize ext_start to dut_clk domain   
   always @ (posedge dut_clk or negedge nreset)		 
     if(!nreset)
       sync_pipe[1:0] <= 1'b0;
     else
       sync_pipe[1:0] <= {sync_pipe[0],ext_start};	      	      
   assign dut_start = sync_pipe[1];
   
   //#################################
   // Read port state machine
   //#################################
   //1. Start on dut_start
   //2. After thar update rd state machine on all not stall and not wait
   //3. Set end state on special end packet

`define STIM_IDLE   2'b00
`define STIM_ACTIVE 2'b01  
`define STIM_PAUSE  2'b10
`define STIM_DONE   2'b11
   
   always @ (posedge dut_clk or negedge nreset)
     if(!nreset)
       begin
	  rd_state[1:0]     <= `STIM_IDLE;
	  rd_addr[MAW-1:0]  <= 'b0;
	  rd_delay[6:0]     <= 'b0;
       end
     else if(~dut_wait)
       case (rd_state[1:0])
	 `STIM_IDLE : 
	   rd_state[1:0]       <= dut_start ? `STIM_ACTIVE : `STIM_IDLE;
	 `STIM_ACTIVE :
	   begin
	      rd_state[1:0]    <= (|rd_delay[6:0]) ? `STIM_PAUSE :
			          ~stim_valid      ? `STIM_DONE  :
	                      		             `STIM_ACTIVE;
	      rd_addr[MAW-1:0] <= rd_addr[MAW-1:0] + 1'b1;
	      rd_delay[6:0]    <= {(7){use_timestamps}} & stim_packet[7:1];
	   end
	 `STIM_PAUSE :
	   begin
	      rd_state[1:0]    <= (|rd_delay[6:0]) ? `STIM_PAUSE : `STIM_ACTIVE;
	      rd_delay[6:0]    <= rd_delay[6:0] - 1'b1;
	   end
       endcase // case (rd_state[1:0])
   
   //Output Driver
   assign stim_done           = (rd_state[1:0] == `STIM_DONE);
   assign stim_valid          = ignore_valid | stim_packet[0];
      
   //#################################
   // RAM
   //#################################

   //write port
   always @(posedge ext_clk)    
     if(ext_access)
       ram[wr_addr[MAW-1:0]] <= ext_packet[DW-1:0];

   //read port
   always @ (posedge dut_clk)
     begin
	stim_packet[DW-1:0] <= ram[rd_addr[MAW-1:0]];
	stim_read           <= (rd_state==`STIM_ACTIVE); //mem-cycle adjust
     end

   //Shut off access immediately, but pipeline delay by one cycle
   assign stim_access = stim_valid & stim_read & ~stim_done;
      
endmodule // stimulus

  
