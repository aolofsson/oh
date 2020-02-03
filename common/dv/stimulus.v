// A stimulus file provides inputs signals to the design under test (DUT).
// This stimulus module is designed to be compatible with verilog simulators,
// emulators, and FPGA prototyping.
//
// Memory format: 
// b0      =valid,
// b1-15   =wait time
// b16=bxxx=packet
//
`timescale 1ns/1ps //TODO: Find a better place for this!
module stimulus (/*AUTOARG*/
   // Outputs
   stim_access, stim_packet, stim_count, stim_done, stim_wait,
   // Inputs
   clk, nreset, start, dut_wait
   );

   //stimulus 
   parameter PW     = 32;         //Memory width=PW+
   parameter MAW    = 15;         //Memory address width
   parameter MD     = 1<<MAW;     //Memory depth
   parameter MEMH   = 1;          //1=read from memh file
   parameter NAME   = "NONAME";   //
   parameter WAIT   = 0;

   
   
   //Inputs
   input           clk;               // single clock
   input           nreset;            // async negative edge reset
   input           start;             // Start driving stimulus ("ready/go/por")
      
   //DUT Transaction
   input           dut_wait;
   output          stim_access;   
   output [PW-1:0] stim_packet;   
   output [31:0]   stim_count;
   output 	   stim_done;   
   output 	   stim_wait;   

   //External Write Path
   input           dut_wait;
   output          stim_access;   
   output [PW-1:0] stim_packet;   
   output [31:0]   stim_count;
   output 	   stim_done;   
   output 	   stim_wait;   


   
   //##############################
   //Dual Ported Stimulus Memory
   //##############################


   
   //variables
   reg 		   mem_access;
   reg [PW+16-1:0] mem_data;
   reg [PW+16-1:0] stimarray[MD-1:0];
   reg [MAW-1:0]   stim_addr;
   reg [1:0] 	   state;
   reg [31:0] 	   stim_count;
   reg [15:0]      wait_counter;
   reg [PW-1:0]    stim_packet;
   reg 		   stim_access;
   reg [PW-1:0]    mem_packet_reg;
   reg 		   mem_access_reg;
   
   //Read in stimulus
   integer 	   i,j;

   reg [255:0] 	   testfile;
   integer 	   fd;
   reg [128*8:0]   str;
   reg [31:0] 	   stim_end;
   wire 	   stall_random;
   
   //Read Stimulus
   initial begin
      $sformat(testfile[255:0],"%0s_%0d%s",NAME,INDEX,".emf");
      fd = $fopen(testfile, "r");
      if(!fd)
	begin
	   $display("could not open the file %0s\n", testfile);
	   $finish;
	end
      //Read stimulus from file      
      j=0;      
      while ($fgets(str, fd)) begin 
	 if ($sscanf(str,"%h", stimarray[j]))
	   begin
	      //$display("%0s %0d data=%0h", testfile, j, stimarray[j]);
	      j=j+1;
	   end	 
      end
      stim_end[31:0]=j;      
   end

   
`define IDLE  2'b00
`define DONE  2'b10
`define GO    2'b01
   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       begin	  	
	  state[1:0]          <= `IDLE;
	  mem_access          <= 1'b0;	  
	  mem_data            <= 'd0;
	  stim_count          <= 0;
	  stim_addr[MAW-1:0]  <= 'b0;	   	  
	  wait_counter        <= 'b0;
       end
     else if(start & (state[1:0]==`IDLE))//not started
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
   //assign stim_packet[PW-1:0] = mem_data[PW+16-1:  
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

   //assign stim_packet = dut_wait ? stim_packet_reg : mem_data[PW+16-1:16];
   //assign stim_access = dut_wait ? stim_access_reg : mem_access;
   //assign stim_access = dut_wait ? 1'b0 : mem_access;
   
   //TODO: Implement
   assign stim_wait = stall_random;

   //Random wait generator
   //TODO: make this a module
   
   generate
      if(WAIT)
	begin	   
	   reg [15:0] stall_counter;  
	   always @ (posedge clk or negedge nreset)
	     if(!nreset)
	       stall_counter[15:0] <= 'b0;   
	     else
	       stall_counter[15:0] <= stall_counter+1'b1;         
	   assign stall_random      = (|stall_counter[6:0]);//(|wait_counter[3:0]);//1'b0;
	end
      else
	begin
	   assign stall_random = 1'b0;
	end // else: !if(WAIT)
   endgenerate
   
   
endmodule // stimulus


