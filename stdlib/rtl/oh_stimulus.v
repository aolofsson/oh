//#############################################################################
//# Function: Multimode Stimulus Driver                                       #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_stimulus
  #( parameter PW       = 80,        // stimulus packet width
     parameter CW       = 16,        // bit[0]=valid, [CW-1:1]=timestamp
     parameter DEPTH    = 8192,      // Memory depth
     parameter TARGET   = "DEFAULT", // pass through variable for hard macro
     parameter FILENAME = "NONE"     // Simulus hexfile for $readmemh
     )
   (
    // control
    input 	    nreset, // async reset
    input [1:0]     mode, // 0=load,1=go,2=rng,3=bypass
    input [PW-1:0]  seed, // seed for random stimulus
    // external interface
    input 	    ext_clk,// External clock for write path
    input 	    ext_valid, // Valid packet for memory
    input [PW-1:0]  ext_packet, // Packet for memory
    // dut feedback
    input 	    dut_clk, // DUT side clock
    input 	    dut_ready, // DUT ready signal
    // stimulus outputs
    output 	    stim_valid, // Packet valid
    output [PW-1:0] stim_packet, // packet to DUT
    output 	    stim_done // Signals that stimulus is done
    );

   // memory parameters
   localparam MAW = $clog2(DEPTH); // Memory address width

   // state machine parameters
   localparam STIM_IDLE   = 2'b00;
   localparam STIM_ACTIVE = 2'b01;
   localparam STIM_PAUSE  = 2'b10;
   localparam STIM_DONE   = 2'b11;

   // state machine parameters
   localparam MODE_LOAD  = 2'b00;
   localparam MODE_READ  = 2'b01;
   localparam MODE_RNG   = 2'b10;
   localparam MODE_BP    = 2'b11;

   // Local values
   reg [1:0] 	      rd_state;
   reg [MAW-1:0]      wr_addr;
   reg [MAW-1:0]      rd_addr;
   reg [1:0] 	      sync_pipe;
   reg 		      mem_read;
   reg [CW:0] 	      rd_delay;
   wire 	      dut_start;
   wire 	      valid_packet;
   wire [PW-1:0]      mem_data;
   wire [PW-1:0]      rng_data;

   //#################################
   // Mode mux
   //#################################

   assign stim_valid = (mode[1:0]==MODE_READ) ? mem_valid :
		       (mode[1:0]==MODE_BP)   ? ext_valid :
		       (mode[1:0]==MODE_RNG)  ? 1'b1      :
		                                1'b0;

   assign stim_packet = (mode[1:0]==MODE_READ) ? mem_data   :
		        (mode[1:0]==MODE_BP)   ? ext_packet :
		        (mode[1:0]==MODE_RNG)  ? rng_data   :
		                                {(PW){1'b0}};

   assign stim_done = (mode[1:0]==MODE_READ) ? mem_done  : 1'b0;

   //#################################
   // Random Number Generator
   //#################################

   oh_random #(.N(PW))
   oh_random(//outputs
	     .out	(rng_data[PW-1:0]),
	     .mask	({(PW){1'b1}}),
	     .taps	({(PW){1'b1}}),
	     .entaps	(1'b0),
	     .en	(stim_valid),
	     .seed      (seed),
	     /*AUTOINST*/
	     // Inputs
	     .clk			(clk),
	     .nreset			(nreset));

   //#################################
   // Init memory if configured
   //#################################
   generate
      if(!(FILENAME=="NONE"))
	initial
	  begin
	     $display("Driving stimulus from %s", FILENAME);
	     $readmemh(FILENAME, ram.ram);
	  end
   endgenerate

   //#################################
   // Memory write port state machine
   //#################################

   always @ (posedge ext_clk or negedge nreset)
     if(!nreset)
       wr_addr[MAW-1:0] <= 'b0;
     else if(ext_valid & (mode[1:0]==MODE_LOAD))
       wr_addr[MAW-1:0] <= wr_addr[MAW-1:0] + 1;

   //Synchronize mode to dut_clk domain
   always @ (posedge dut_clk or negedge nreset)
     if(!nreset)
       sync_pipe[1:0] <= 'b0;
     else
       sync_pipe[1:0] <= {sync_pipe[0],(mode[1:0]==MODE_READ)};

   assign dut_start = sync_pipe[1];

   //#################################
   // Memory read port state machine
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
			       ~valid_packet ? STIM_DONE  :
                                               STIM_ACTIVE;
	      rd_addr[MAW-1:0] <= rd_addr[MAW-1:0] + 1'b1;
	      rd_delay         <= (CW > 1) ? mem_data[CW-1:1] : 'b0;
	   end
	 STIM_PAUSE :
	   begin
	      rd_state[1:0] <= (|rd_delay) ? STIM_PAUSE : STIM_ACTIVE;
	      rd_delay      <= rd_delay - 1'b1;
	   end
       endcase // case (rd_state[1:0])

   // pipeline to match sram pipeline
   always @ (posedge dut_clk)
     mem_read <= (rd_state==STIM_ACTIVE); //mem-cycle adjust

   //  output drivesrs
   assign valid_packet = (CW==0) | mem_data[0];
   assign mem_done     = (rd_state[1:0] == STIM_DONE);
   assign mem_valid    = valid_packet & mem_read & ~stim_done;

   //#################################
   // Stimulus Dual Port RAM
   //#################################

   oh_dpram #(.N(PW),
	      .DEPTH(DEPTH),
	      .TARGET(TARGET))
   ram(
       // write port
       .wr_clk		(ext_clk),
       .wr_en		(ext_valid),
       .wr_wem		({(PW){1'b1}}),
       .wr_addr		(wr_addr[MAW-1:0]),
       .wr_din		(ext_packet[PW-1:0]),
       // read port
       .rd_dout		(mem_data[PW-1:0]),
       // Inputs
       .rd_clk		(dut_clk),
       .rd_en		(1'b1),
       .rd_addr		(rd_addr[MAW-1:0]),
       // disable asic signals
       .bist_en		(1'b0),
       .bist_we		(1'b0),
       .bist_wem	({(PW){1'b0}}),
       .bist_addr	({(MAW){1'b0}}),
       .bist_din	({(PW){1'b0}}),
       .memconfig	(8'b0),
       .memrepair	(8'b0),
       .vss		(1'b0),
       .vdd		(1'b1),
       .vddio		(1'b1),
       .shutdown	(1'b0));

endmodule // oh_stimulus
