// A stimulus file provides inputs signals to the design under test (DUT).
// This stimulus module is designed to be compatible with verilog simulators,
// emulators, and FPGA prototyping. This is akin to a simple test vector generator
// No looping supported!
//
// Memory format: 
// b0       = valid,
// b1-15    = wait time
// b16-bxxx = packet
//
// Test Process:
// 1. Zero out memory (or write program)
// 2. Set go signal
//
module stimulus #( parameter PW       = 32,       // Memory width=PW+
		   parameter MAW      = 15,       // Memory address width
		   parameter INIT     = 1,        // 1=init from memh file
		   parameter FILENAME = "NONAME"  // Name of memh file
		   )
   (   
       //Inputs
       input 	       nreset, // Async negative edge reset
       input 	       ext_clk,// External clock for write path  
       input 	       ext_access, // Valid packet for memory
       input [PW-1:0]  ext_packet, // Packet for memory
       input 	       ext_start, // Start driving stimulus      
       //DUT Drive port
       input 	       dut_clk, // DUT side clock
       input 	       dut_wait, // DUT stall signal
       output 	       stim_access, // Access signal  
       output [PW-1:0] stim_packet, // Packet
       output 	       stim_done // Stimulus program done
       );

   localparam MD       = 1<<MAW;  // Memory depth

   
   //Registers
   reg [PW+16-1:0]     ram[MD-1:0];
   reg [MAW-1:0]       wr_addr;
   reg [MAW-1:0]       rd_addr;
   reg [255:0] 	       memhfile;
   
   //#################################
   // Init memory if configured
   //#################################
   generate
      if(INIT)
	initial
	  begin
	     $display("Initializing SRAM from %s", FILENAME);	
	     $readmemh(FILENAME, ram);
	  end
   endgenerate
   
   //#################################
   // Write port state machine
   //#################################

   always @ (posedge ext_clk or negedge nreset)
     if(!nreset)
       begin	  	
	  wr_addr[MAW-1:0]      <= 'b0;	   	  
       end
     else if(ext_access)
       begin
	  ram[wr_addr[MAW-1:0]] <= ext_packet[PW-1:0];
	  wr_addr[MAW-1:0]      <= wr_addr[MAW-1:0] + 1;
       end

   //Synchronize start signal to rd_clk
   oh_dsync oh_dsync(.clk	(ext_clk),
		     .din	(ext_start),
		     .dout	(dut_start));
      
   //#################################
   // Read port state machine
   //#################################
   //1. Start on dut_start
   //2. After thar update rd state machine on all not wait
   always @ (posedge rd_clk or negedge nreset)
     if(!nreset)
       begin	  	
	  rd_addr[MAW-1:0]    <= 'b0;
	  rd_en               <= 'b0;
       end
     else if(ext_start) //read first cycle
       rd_en               <=1'b1;
     else if(rd_en & ~dut_wait)
       rd_addr[MAW-1:0]    <= rd_addr[MAW-1:0]+1'b1;
     else if(ext_
	     rd_addr[MAW-1:0]    <= 'b0;

  
       end
     else if((state[1:0]==`IDLE))//not started
       begin
	  state[1:0] <= `GO;//going
       end
     else if(~dut_wait)
       if((wait_counter[15:0]==0) & (stim_count < stim_end) & (state[1:0]==`GO))//going
	 begin
	    wait_counter[15:0]   <= stimarray[stim_addr];//first 15 bits
	    mem_data[PW+16-1:0]  <= stimarray[stim_addr];//FIX: used 2D indexiing?
	    mem_access           <= 1'b1;	  
	    stim_addr[MAW-1:0]   <= stim_addr[MAW-1:0] + 1'b1; 
	    stim_count           <= stim_count + 1'b1; 
       end         
       else if((wait_counter[15:0]==0) & (stim_count == stim_end) & (state[1:0]==`GO)) //not waiting and done
	 begin
	    state[1:0]          <= `DONE;//gone
	    mem_access          <= 1'b0;	  
	 end
       else if(wait_counter>0)
	 begin
	    mem_access          <= 1'b0;	  
	    wait_counter[15:0]  <= wait_counter[15:0] - 1'b1;
	 end
	    
   //Use to finish simulation
   assign stim_done           = ~dut_wait & (state[1:0]==`DONE);
   
   //Removing delay value
	    always @ (posedge clk or negedge nreset)
     if(~nreset)
       begin
	  mem_access_reg <= 'b0;
	  mem_packet_reg <= 'b0;	  
	  stim_packet    <= 'b0;	  
	  stim_access    <= 'b0;	  
       end
     else if(~dut_wait)
       begin
	  mem_access_reg <= mem_access;
	  mem_packet_reg <= mem_data[PW+16-1:16];	  
	  stim_packet    <= mem_packet_reg;
	  stim_access    <= mem_access_reg;
       end

   
   
   
endmodule // stimulus


