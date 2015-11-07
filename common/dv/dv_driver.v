module dv_driver (/*AUTOARG*/
   // Outputs
   stim_access, stim_packet, stim_wait, stim_done,
   // Inputs
   clk, nreset, start, coreid, dut_access, dut_packet, dut_wait
   );

   //Parameters
   parameter PW       = 99;
   parameter N        = 1;
   parameter IDW      = 12;     //ID width
   parameter NAME     = "none"; // north, south etc
   parameter STIMS    = 1;      // number of stimulus
   
   //Control signals
   input		clk;
   input		nreset;
   input		start;       //starts test
   input [IDW-1:0] 	coreid;      //everything has a coreid! 
   
   //Inputs for monitoring
   input [N-1:0] 	dut_access;
   input [N*PW-1:0]	dut_packet;
   input [N-1:0] 	dut_wait;

   //Stimulus to drive
   output [N-1:0] 	stim_access;  
   output [N*PW-1:0] 	stim_packet;
   output [N-1:0] 	stim_wait;
   output 		stim_done;

   wire [N*32-1:0] 	stim_count;
   wire [N-1:0] 	stim_vec_done;  
   wire [N*IDW-1:0] 	coreid_array;
   reg [IDW-1:0] 	offset;
   
   assign stim_done = &(stim_vec_done[N-1:0]);
      
   //###########################################
   //STIMULUS
   //###########################################
   genvar 		i;
   generate
      for(i=0;i<N;i=i+1) begin : stim
	 if(i<STIMS) begin
	    //AT LEAST ONE STIMULUS
	    defparam stimulus.PW    = PW;
	    defparam stimulus.INDEX = i;
	    defparam stimulus.NAME  = NAME;	 
	    stimulus  stimulus (// Outputs
				.stim_access   (stim_access[0]),
				.stim_packet   (stim_packet[(i+1)*PW-1:i*PW]),
				.stim_count    (stim_count[(i+1)*32-1:i*32]),
				.stim_done     (stim_vec_done[i]),
				.stim_wait     (stim_wait[i]),
				// Inputs
				.clk	       (clk),
				.nreset	       (nreset),
				.start	       (start),
				.dut_wait      (dut_wait[i])
				);
	 end // if (i<STIMS)
	 else
	   begin
	      assign stim_access[i]               = 'b0;
	      assign stim_packet[(i+1)*PW-1:i*PW] = 'b0;
              assign stim_count[(i+1)*32-1:i*32]  = 'b0;
	      assign stim_vec_done[i]             = 'b1;
	      assign stim_wait[i]                 = 'b0;	      			
	   end
	    
      end // block: stim
   endgenerate
  
   //###########################################
   //MONITORS
   //###########################################
   
   //Increment coreID depending on counter and orientation of side block
   //TODO: parametrize 
   initial     
     begin
	#1
	  if(NAME=="north" | NAME=="south" )
	    offset=12'h001;   
	  else
	    offset=12'h040;   
     end
   
   genvar 		j;   
   generate
      for(j=0;j<N;j=j+1) begin : mon	 
	 assign coreid_array[(j+1)*IDW-1:j*IDW] = coreid[IDW-1:0] + j*offset;  	 
	 //MONITOR	 
	 emesh_monitor #(.PW(PW),
			 .NAME(NAME),
			 .IDW(IDW)
			 )	   	   
	 monitor (//inputs
				.clk		(clk),
				.nreset		(nreset),
				.dut_access	(dut_access[j]),
				.dut_packet	(dut_packet[(j+1)*PW-1:j*PW]),
				.coreid         (coreid_array[(j+1)*IDW-1:j*IDW]),
				.wait_in	(stim_wait[j])
				);
	 
      end // for (i=0;i<N;i=i+1)	 
   endgenerate
   
endmodule // dv_side


