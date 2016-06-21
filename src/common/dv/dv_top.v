`timescale 1ns/1ps
module dv_top();
   
   //static variables
   parameter N   = 1;
   parameter IDW = 12;
   parameter AW  = 32;   
   parameter PW  = 2*AW+40;

   //local variables
   integer r;   

   wire [IDW-1:0]   dv_coreid;
   wire [N*N-1:0]   vdd;
   wire 	    vss;
   wire 	    clkout;
   wire 	    dut_active;
   wire [N-1:0]     dut_wait;
   wire [N-1:0]     dut_access;
   wire [N*PW-1:0]  dut_packet;
   
  
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			clk1;			// From dv_ctrl of dv_ctrl.v
   wire			clk2;			// From dv_ctrl of dv_ctrl.v
   wire			nreset;			// From dv_ctrl of dv_ctrl.v
   wire			start;			// From dv_ctrl of dv_ctrl.v
   wire [N-1:0]		stim_access;		// From dv_driver of dv_driver.v
   wire			stim_done;		// From dv_driver of dv_driver.v
   wire [N*PW-1:0]	stim_packet;		// From dv_driver of dv_driver.v
   wire [N-1:0]		stim_wait;		// From dv_driver of dv_driver.v
   // End of automatics
   /*AUTOINPUT*/
   /*AUTOUTPUT*/

   //####################################################
   //COREID
   //####################################################
    
   assign dv_coreid[IDW-1:0] = 12'h000;
     
   //############################################################
   // SIMULATION CONTROL
   // -reset & clok generation
   // -dumps stimulus
   //############################################################

   dv_ctrl dv_ctrl (.test_done		(1'b1),   //optimize later
		    /*AUTOINST*/
		    // Outputs
		    .nreset		(nreset),
		    .clk1		(clk1),
		    .clk2		(clk2),
		    .start		(start),
		    .vdd		(vdd),
		    .vss		(vss),
		    // Inputs
		    .dut_active		(dut_active),
		    .stim_done		(stim_done));
   
   //#############################################################
   // DEVICE UNDER TEST
   // -create your own module named dut to include at compile time 
   //#############################################################   
      
   dut #(.PW(PW), 
	  .N(N)
	  ) 
   dut (// Outputs
	.dut_active	(dut_active),
	.clkout		(clkout),
	.wait_out	(dut_wait[N-1:0]),
	.access_out	(dut_access[N-1:0]),
	.packet_out	(dut_packet[N*PW-1:0]),
	// Inputs
	.clk1		(clk1),
	.clk2		(clk2),
	.nreset		(nreset),
	.vdd		(vdd[N*N-1:0]),
	.vss	        (vss),
	.access_in	(stim_access[N-1:0]),
	.packet_in	(stim_packet[N*PW-1:0]),
	.wait_in	(stim_wait[N-1:0]));
   
   //##############################
   //# STIMULUS + MONITORS
   //##############################
   /*dv_driver AUTO_TEMPLATE(
    .name         (@"(substring vl-cell-name  0 2)"_name[]),
    .coreid	  (@"(substring vl-cell-name  0 2)"_coreid[IDW-1:0]),
            );
    */
   
   dv_driver #(.AW(AW), 
	       .N(N), 
	       .NAME("test"),
	       .IDW(IDW)
	     ) 
   dv_driver (.coreid			(dv_coreid[IDW-1:0]),
	      .clkin			(clk1),
	      /*AUTOINST*/
	      // Outputs
	      .stim_access		(stim_access[N-1:0]),
	      .stim_packet		(stim_packet[N*PW-1:0]),
	      .stim_wait		(stim_wait[N-1:0]),
	      .stim_done		(stim_done),
	      // Inputs
	      .clkout			(clkout),
	      .nreset			(nreset),
	      .start			(start),
	      .dut_access		(dut_access[N-1:0]),
	      .dut_packet		(dut_packet[N*PW-1:0]),
	      .dut_wait			(dut_wait[N-1:0]));
     
endmodule // dv_top

// Local Variables:
// verilog-library-directories:("." "../hdl" "../dv" "../../common/dv" )
// End:


