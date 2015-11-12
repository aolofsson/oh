/*
 * module that reads in a memh file and outputs it on stim_packet vector
 * NOTE: MSB of vector is the left most character 
 * 
 * NOTE: wait comes in one next cycle, this block adjusts for that!
 * 
 */ 
 
module stimulus (/*AUTOARG*/
   // Outputs
   stim_access, stim_packet, stim_count, stim_done, stim_wait,
   // Inputs
   clk, nreset, start, dut_wait
   );

   //stimulus 
   parameter PW     = 99;            //size of packet
   parameter MAW    = 15;    
   parameter MD     = 1<<MAW;         //limit test to 1K transactions
   parameter INDEX  = 1;
   parameter NAME   = "not_declared";
   
   //Inputs
   input           clk;
   input           nreset;
   input           start;
   input           dut_wait;
   
   //outputs
   output          stim_access;   
   output [PW-1:0] stim_packet;   
   output [31:0]   stim_count;
   output 	   stim_done;   
   output 	   stim_wait;   

   //variables
   reg 		   mem_access;
   reg [PW+16-1:0] stimarray[MD-1:0];
   reg [PW+16-1:0] mem_data;
   reg [MAW-1:0]   stim_addr;
   reg [1:0] 	   state;
   reg [31:0] 	   stim_count;
   reg [15:0]      wait_counter;
   reg [PW-1:0]    stim_packet_reg;
   reg 		   stim_access_reg;
   
   //Read in stimulus
   integer 	   i,j;

   reg [255:0] 	   testfile;
   integer 	   fd;
   reg [128*8:0]   str;
   reg [31:0] 	   stim_end;
   
   //Read Stimulus
   initial begin
      $sformat(testfile[255:0],"%0s_%0d%s",NAME,INDEX,".memh");
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
     else if((wait_counter[15:0]==0) & (stim_count < stim_end) & (state[1:0]==`GO) & ~dut_wait)//going
       begin
	  wait_counter[15:0]   <= stimarray[stim_addr];//first 15 bits
	  mem_data[PW+16-1:0]  <= stimarray[stim_addr];//FIX: used 2D indexiing?
	  mem_access           <= 1'b1;	  
	  stim_addr[MAW-1:0]   <= stim_addr[MAW-1:0] + 1'b1; 
	  stim_count           <= stim_count + 1'b1; 
       end         
     else if((wait_counter[15:0]==0) & (stim_count == stim_end) & (state[1:0]==`GO) & ~dut_wait) //not waiting and done
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
	  stim_packet_reg <= 'b0;	  
	  stim_access_reg <= 'b0;	  
       end
     else if(~dut_wait)
       begin
	  stim_packet_reg <= mem_data[PW+16-1:16];
	  stim_access_reg <= mem_access;	  
       end

   assign stim_packet = dut_wait ? stim_packet_reg : mem_data[PW+16-1:16];
   //assign stim_access = dut_wait ? stim_access_reg : mem_access;
   assign stim_access = dut_wait ? 1'b0 : mem_access;
   
   //TODO: Implement
   //lfsr?
   //seed from command line?
   //walk through the waits:0,1,2,3,4,5,6,7,8,16,32,64,128 cycles
   //randomize where you start in state machine
   assign stim_wait = 1'b0;
   
endmodule // stimulus


