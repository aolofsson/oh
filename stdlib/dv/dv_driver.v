/* verilator lint_off STMTDLY */
module dv_driver #( parameter  N     = 1,      // "N" packets wide
		    parameter  AW    = 32,     // address width
		    parameter  PW    = 104,    // packet width (derived)
		    parameter  IDW   = 12,     // id width
		    parameter  NAME  = "none", // north, south etc
		    parameter  STIMS = 1,      // number of stimulus
		    parameter  MAW   = 16      // 64KB memory address width
		    )
   (
    //control signals
    input 	      clkin,
    input 	      clkout,
    input 	      nreset,
    input 	      start, //starts test
    input [IDW-1:0]   coreid, //everything has a coreid! 
    //inputs for monitoring
    input [N-1:0]     dut_access,
    input [N*PW-1:0]  dut_packet,
    input [N-1:0]     dut_wait,
    //stimulus to drive
    output [N-1:0]    stim_access, 
    output [N*PW-1:0] stim_packet,
    output [N-1:0]    stim_wait,
    output 	      stim_done
    );

  //#############
  //LOCAL WIRES
  //#############
   reg [IDW-1:0] 	offset;
   wire [N*32-1:0] 	stim_count;
   wire [N-1:0] 	stim_vec_done;  
   wire [N*IDW-1:0] 	coreid_array;
   wire [N*PW-1:0] 	mem_packet_out;	
   wire [N-1:0] 	mem_access_out;
   wire [N-1:0] 	mem_wait_out;   
   /*AUTOWIRE*/   

   //###########################################
   //STIMULUS
   //###########################################

   assign stim_done = &(stim_vec_done[N-1:0]);
   
   genvar 		i;
   generate
      for(i=0;i<N;i=i+1) begin : stim
	 if(i<STIMS) begin
	    stimulus  #(.PW(PW),
			.INDEX(i),
			.NAME(NAME))
	    stimulus (// Outputs
				.stim_access   (stim_access[0]),
				.stim_packet   (stim_packet[(i+1)*PW-1:i*PW]),
				.stim_count    (stim_count[(i+1)*32-1:i*32]),
				.stim_done     (stim_vec_done[i]),
				.stim_wait     (stim_wait[i]),
				// Inputs
				.clk	       (clkin),
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
   //MONITORS (USE CLK2)
   //###########################################
   
   //Increment coreID depending on counter and orientation of side block
   //TODO: parametrize 
   initial     
     begin
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
				.clk		(clkout),
				.nreset		(nreset),
				.dut_access	(dut_access[j]),
				.dut_packet	(dut_packet[(j+1)*PW-1:j*PW]),
				.coreid         (coreid_array[(j+1)*IDW-1:j*IDW]),
				.wait_in	(stim_wait[j])
				);
	 
      end // for (i=0;i<N;i=i+1)	 
   endgenerate

   //###########################################
   //MEMORY
   //###########################################
   genvar k;
   generate
      for(j=0;j<N;j=j+1) begin : mem	 
	 ememory #(.NAME(NAME),
		   .IDW(IDW),
		   .PW(PW),
		   .AW(AW)
		   )
	 ememory(// Outputs
		 .wait_out		(mem_wait_out[j]),
		 .access_out		(mem_access_out[j]),
		 .packet_out		(mem_packet_out[(j+1)*PW-1:j*PW]),
		 // Inputs
		 .clk			(clkout),
		 .nreset		(nreset),
		 .coreid		(coreid[IDW-1:0]),
		 .access_in		(dut_access[j]),
		 .packet_in		(dut_packet[(j+1)*PW-1:j*PW]),
		 .wait_in		(dut_wait[j])
		 );
      end	 
	 
   endgenerate
   
   //###########################################
   //MUX BETWEEN STIMULUS AND MEMORY
   //###########################################
   //stimulus has higher priority
   //TODO: Implement
   
endmodule // dv_driver

// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl")
// End:

