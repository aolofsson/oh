`define CFG_FAKECLK   1      /*stupid verilator doesn't get clock gating*/
`define CFG_MDW       32     /*Width of mesh network*/
`define CFG_DW        32     /*Width of datapath*/
`define CFG_AW        32     /*Width of address space*/
`define CFG_LW        8      /*Link port width*/
`define CFG_NW        13     /*Number of bytes in the transmission*/


module e16_arbiter_priority(/*AUTOARG*/
   // Outputs
   grant, arb_wait,
   // Inputs
   clk, clk_en, reset, hold, request
   );
   
   parameter ARW=99;
   
   input            clk;
   input            clk_en;
   input            reset;

   input            hold;      
   input  [ARW-1:0] request;

   output [ARW-1:0] grant;
   output [ARW-1:0] arb_wait;


   //wires
   wire [ARW-1:0] grant_mask;
   wire [ARW-1:0] request_mask;
   
   //regs
   reg [ARW-1:0]  grant_hold;

   //hold circuit
   always @ (posedge clk or posedge reset)
     if(reset)
       grant_hold[ARW-1:0] <= {(ARW){1'b0}};
     else if(clk_en)       
       grant_hold[ARW-1:0] <= grant[ARW-1:0] & {(ARW){hold}};

   //request blocking based on held previous requests
   genvar i;
   generate              
      for(i=0;i<ARW-1;i=i+1) begin : gen_block
         assign request_mask[i]=request[i] & ~(|grant_hold[ARW-1:i+1]);	 
      end
      assign request_mask[ARW-1]=request[ARW-1];//awlays on, loses on priority 
   endgenerate
   
   genvar j;
   assign grant_mask[0]   = 1'b0;   
   generate for (j=ARW-1; j>=1; j=j-1) begin : gen_arbiter     
      assign grant_mask[j] = |request_mask[j-1:0];
   end
   endgenerate
        
   //grant circuit
   assign grant[ARW-1:0] = request_mask[ARW-1:0] & ~grant_mask[ARW-1:0];

   //wait circuit  
   assign arb_wait[ARW-1:0] = request[ARW-1:0] & ({(ARW){hold}} | ~grant[ARW-1:0]);


   //makes sure we hold request one cycle after wait is gone!!!
   // synthesis translate_off
   always @*
     if((|(grant_hold[ARW-1:0] & ~request[ARW-1:0])) & ~reset  & $time> 0)
       begin
	  $display("ERROR>>Request not held steady in cell %m at time %0d", $time);
       end
   // synthesis translate_on
   
endmodule // arbiter_priority

   
     
module e16_arbiter_roundrobin(/*AUTOARG*/
   // Outputs
   grants,
   // Inputs
   clk, clk_en, reset, en_rotate, requests
   );

   /************************************************************/
   /*PARAMETERS                                                */
   /************************************************************/   
   parameter ARW  = 5;


   /************************************************************/
   /*BASIC INTERFACE                                           */
   /****I*******************************************************/
   input            clk;
   input            clk_en;  //2nd level manual clock gater   
   input            reset;

   /************************************************************/
   /*ARBITRATION INTERFACE                                     */
   /****I*******************************************************/
   input            en_rotate;//enable mask rotation, makes arbiter more flexible
                              //in mesh there should be a way to control freq of rotation 

   input  [ARW-1:0] requests; 
   output [ARW-1:0] grants;   

   //loop variable
   integer m;    

   //Masks
   reg  [ARW-1:0]   request_mask; //rotating mask


   //Wires
   reg [2*ARW-1:0]  grants_rotate_buffer;   
   reg [ARW-1:0]    grants;         //output grants      
   wire [ARW-1:0]   shifted_requests[ARW-1:0];
   wire [ARW-1:0]   shifted_grants[ARW-1:0];
   wire [2*ARW-1:0] requests_rotate_buffer;
   
   /********************************************************************/
   /*Rotating Mask Pointer On Every Clock Cycle                        */
   /********************************************************************/
   //request vector[7:0]-->regular
   //hold vector[7:0]   -->sets the priority to the request when it wins
   //                      there can be multiple bits set
   //                      the only one active is the one where the
   //                      mask is currently located.
   //                      en_rotate=~(hold_vec[7:0] & requeste_mask[7:0])

   //every request should also be able to send a "start/stop" signal
   //instead of having an en_rotate signal, we have
   //if then en-rotate signal is low
  
   always @ ( posedge clk or posedge reset)
     if(reset)
       request_mask[ARW-1:0] <= {{(ARW-1){1'b0}},1'b1};   
     else if(clk_en)
       if(en_rotate)
	 request_mask[ARW-1:0] <= {request_mask[ARW-2:0],request_mask[ARW-1]};
   
   /********************************************************************/
   /*Creating Shifted Request Vectors                                  */
   /********************************************************************/
   assign requests_rotate_buffer[2*ARW-1:0]={requests[ARW-1:0],requests[ARW-1:0]};

   genvar i;
   generate
      for (i=0;i<ARW;i=i+1) begin: gen_requests	
	 assign shifted_requests[i]=requests_rotate_buffer[ARW-1+i:i];      
      end
   endgenerate

   /********************************************************************/
   /*Priority Encoders For Each Vector                                 */
   /********************************************************************/
   //Priority Encoders For Each Vector   
   genvar k;   
   generate
      for (k=0;k<ARW;k=k+1) begin: gen_arbiter
	   e16_arbiter_priority #(.ARW(ARW)) simple_arbiter(
                                                        .clk       (clk),
					                .clk_en    (clk_en),
					                .reset     (reset),                                     
					                .hold      (1'b0),				 
					                .request   (shifted_requests[k]),                         
                                                        .arb_wait  (),
					                .grant     (shifted_grants[k])
					                );      
      end
   endgenerate   

   /********************************************************************/
   /*One Hot Mux                                                       */
   /********************************************************************/
   //Note that grants have to be rotate back to their right positiona again.
   always @*
     begin	
	grants[ARW-1:0]      = {(ARW){1'b0}};
	for(m=0;m<ARW;m=m+1)
	  begin
	     grants_rotate_buffer[2*ARW-1:0]={shifted_grants[m],shifted_grants[m]};	
	     grants[ARW-1:0]                =grants[ARW-1:0] |
	                                     ({(ARW){request_mask[m]}} & 
					      grants_rotate_buffer[2*ARW-1-m-:ARW]
					      );
	  end
     end
     
   /********************************************************************/
   /*Checkers                                                          */
   /********************************************************************/
/*
   
   // synthesis translate_off
   always @*     
     begin
	if((|(grants[ARW-1:0]&~requests[ARW-1:0])) & $time>0)
	  $display("ERROR>>Grant granted with out request in cell %m at time %0d",$time);
	if((~(|grants[ARW-1:0]) & (|requests[ARW-1:0])) & $time>0)
	  $display("ERROR>>Zero granted when there was a request in cell %m at time %0d",$time);	
     end   
   // synthesis translate_on
*/
   	    
endmodule // arbiter_roundrobin
// ###############################################################
// # FUNCTION: Synchronous clock divider that divides by integer
// #  NOTE:     Combinatorial output becomes new clock
// ############################################################### 

module e16_clock_divider(/*AUTOARG*/
   // Outputs
   clk_out, clk_out90,
   // Inputs
   clk_in, reset, div_cfg
   );


   input       clk_in;    // Input clock
   input       reset;
   input [3:0] div_cfg;   // Divide factor
   
   output      clk_out;   // Divided clock phase aligned with clk_in 
   output      clk_out90; // Divided clock with 90deg phase shift with clk_out


   reg        clk_out_reg;
   //reg        clk_out90_reg;
   //reg        clk90_div2_reg;
   reg [5:0]  counter;   
   reg [5:0]  div_cfg_dec;

   wire div2_sel;   
   wire posedge_match;
   wire negedge_match;  
   wire posedge90_match;
   wire negedge90_match; 
    
   wire clk_out90_div2;
   wire clk_out90_div4;
   wire clk_out90_div2_in;
   wire clk_out90_div4_in;
   // ###################
   // # Decode div_cfg
   // ###################

   always @ (div_cfg[3:0])
     begin
	casez (div_cfg[3:0])
	  4'b0000 : div_cfg_dec[5:0] = 6'b000010;  // Divide by 2
	  4'b0001 : div_cfg_dec[5:0] = 6'b000100;  // Divide by 4
	  4'b0010 : div_cfg_dec[5:0] = 6'b001000;  // Divide by 8
	  4'b0011 : div_cfg_dec[5:0] = 6'b010000;  // Divide by 16
	  4'b01?? : div_cfg_dec[5:0] = 6'b100000;  // A lof of different ratios
          4'b1??? : div_cfg_dec[5:0] = 6'b100000;  // Divide by 32
	  default : div_cfg_dec[5:0] = 6'b000000;
	endcase // casez (div_cfg[3:0])
     end // always @ (div_cfg[3:0])

   assign div2_sel = div_cfg[3:0]==4'b0;
    

   //Counter For Generating Toggling Edges
   //always @ (posedge clk_in or posedge reset)
   //if(reset)
   //counter[5:0] <= 6'b000001;// Reset value

   always @ (posedge clk_in or posedge reset)
     if (reset)
       counter[5:0] <= 6'b000001;   
     else if(posedge_match)
       counter[5:0] <= 6'b000001;// Self resetting
     else
       counter[5:0] <= (counter[5:0]+6'b000001);
   
   assign posedge_match    = (counter[5:0]==div_cfg_dec[5:0]);
   assign negedge_match    = (counter[5:0]=={1'b0,div_cfg_dec[5:1]}); 
   assign posedge90_match  = (counter[5:0]==({2'b00,div_cfg_dec[5:2]}));
   assign negedge90_match  = (counter[5:0]==({2'b00,div_cfg_dec[5:2]}+{1'b0,div_cfg_dec[5:1]})); 
			      
   //Divided clock
   //always @ (posedge clk_in or posedge reset)
   //if(reset)
   //clk_out_reg <= 1'b0;   
   always @ (posedge clk_in)
     if(posedge_match)
       clk_out_reg <= 1'b1;
     else if(negedge_match)
       clk_out_reg <= 1'b0;
  
   assign clk_out    = clk_out_reg;

   /**********************************************************************/
   /*Divide by 2 Clock
   /**********************************************************************/
   //always @ (posedge clk_in or posedge reset)     
   //if(reset)
   //clk_out90_reg <= 1'b0;   
   //always @ (posedge clk_in)     
   //  if(posedge90_match)
   //    clk_out90_reg <= 1'b1;
   //  else if(negedge90_match)
   //    clk_out90_reg <= 1'b0;

   assign clk_out90_div4_in = posedge90_match ? 1'b1 :
                              negedge90_match ? 1'b0 :
			                        clk_out90_div4;

   DFFQX4A12TR clk90_flop     (.CK(clk_in), 
			       .D(clk_out90_div4_in), 
			       .Q(clk_out90_div4) 
			       );
   
   //always @ (negedge clk_in)
   //  if(negedge_match)
   //    clk90_div2_reg <= 1'b1;
   //  else if(posedge_match)
   //    clk90_div2_reg <= 1'b0;

   assign clk_out90_div2_in = negedge_match ? 1'b1 :
                              posedge_match ? 1'b0 :
			                      clk_out90_div2;
   
  
   
   DFFNQX3A12TR clk90_div2_flop (.CKN(clk_in), 
	 			 .D(clk_out90_div2_in), 
				 .Q(clk_out90_div2) 
				);
   

   //assign clk_out90  = div2_sel ? clk90_div2_reg : clk_out90_reg;
   MX2X4A12TR clk90_mux2      (.A(clk_out90_div4), 
			       .B(clk_out90_div2), 
			       .S0(div2_sel),
			       .Y(clk_out90)
			       );


   
   
endmodule // clock_divider



     
module e16_mesh_interface(/*AUTOARG*/
   // Outputs
   wait_out, access_out, write_out, datamode_out, ctrlmode_out,
   data_out, dstaddr_out, srcaddr_out, access_reg, write_reg,
   datamode_reg, ctrlmode_reg, data_reg, dstaddr_reg, srcaddr_reg,
   // Inputs
   clk, clk_en, reset, wait_in, access_in, write_in, datamode_in,
   ctrlmode_in, data_in, dstaddr_in, srcaddr_in, wait_int, access,
   write, datamode, ctrlmode, data, dstaddr, srcaddr
   );

   parameter DW = `CFG_DW;
   parameter AW = `CFG_AW;
   
   //###########
   //# INPUTS
   //###########
   input            clk;
   input            clk_en;  //2nd level manual clock gater   
   input 	    reset;  

   //# from the mesh
   input 	    wait_in;
   input 	    access_in;
   input 	    write_in;
   input [1:0]      datamode_in;
   input [3:0]      ctrlmode_in;   		    
   input [DW-1:0]   data_in;
   input [AW-1:0]   dstaddr_in;
   input [AW-1:0]   srcaddr_in;   

   //# from the internal control
   input 	    wait_int;
   input 	    access;
   input 	    write;
   input [1:0]      datamode;
   input [3:0]      ctrlmode;   		    
   input [DW-1:0]   data;
   input [AW-1:0]   dstaddr;
   input [AW-1:0]   srcaddr;   

   //###########
   //# OUTPUTS
   //###########

   //# to the mesh
   output 	    wait_out;
   output 	    access_out;
   output 	    write_out;
   output [1:0]     datamode_out;
   output [3:0]     ctrlmode_out;   		    
   output [DW-1:0]  data_out;
   output [AW-1:0]  dstaddr_out;
   output [AW-1:0]  srcaddr_out;  

   //# to the internal control
   output 	    access_reg;
   output 	    write_reg;
   output [1:0]     datamode_reg;
   output [3:0]     ctrlmode_reg;   		    
   output [DW-1:0]  data_reg;
   output [AW-1:0]  dstaddr_reg;
   output [AW-1:0]  srcaddr_reg;  

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#########
   //# REGS
   //#########
   reg          wait_out;
   reg 		access_out;
   reg 		write_out;
   reg [1:0] 	datamode_out;
   reg [3:0] 	ctrlmode_out;   		    
   reg [DW-1:0] data_out;
   reg [AW-1:0] dstaddr_out;
   reg [AW-1:0] srcaddr_out;  

   reg 		access_reg;
   reg 		write_reg;
   reg [1:0] 	datamode_reg;
   reg [3:0] 	ctrlmode_reg;   		    
   reg [DW-1:0] data_reg;
   reg [AW-1:0] dstaddr_reg;
   reg [AW-1:0] srcaddr_reg;  

   //#########
   //# WIRES
   //#########

   //##########################
   //# mesh input busses
   //##########################

   always @ (posedge clk or posedge reset)
     if(reset)
       access_reg <= 1'b0;
     else if(clk_en)
       if(~wait_int)
	 access_reg <= access_in;
      
   always @ (posedge clk)
     if(clk_en)
       if(~wait_int & access_in)
	 begin
	    write_reg           <= write_in;
	    datamode_reg[1:0]   <= datamode_in[1:0];
	    ctrlmode_reg[3:0]   <= ctrlmode_in[3:0];
	    data_reg[DW-1:0]    <= data_in[DW-1:0];
	    dstaddr_reg[AW-1:0] <= dstaddr_in[AW-1:0];
	    srcaddr_reg[AW-1:0] <= srcaddr_in[AW-1:0];
	 end

   //##########################
   //# mesh output busses  
   //##########################

   always @ (posedge clk or posedge reset)
     if(reset)
       access_out <= 1'b0;
     else if(clk_en)
       if(!wait_in)
	 access_out <= access;

   always @ (posedge clk)
     if (clk_en)
       if(!wait_in & access)
	 begin
	    srcaddr_out[AW-1:0] <= srcaddr[AW-1:0];
	    data_out[DW-1:0]    <= data[DW-1:0];
	    write_out           <= write;
	    datamode_out[1:0]   <= datamode[1:0]; 
	    dstaddr_out[AW-1:0] <= dstaddr[AW-1:0];
	    ctrlmode_out[3:0]   <= ctrlmode[3:0];
	 end
 
   //#####################
   //# Wait out control
   //#####################
   always @ (posedge clk or posedge reset)
     if(reset)
       wait_out <= 1'b0;
     else if(clk_en)
       wait_out <= wait_int;
   
endmodule // mesh_interface



module e16_mux7(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   in0, in1, in2, in3, in4, in5, in6, sel0, sel1, sel2, sel3, sel4,
   sel5, sel6
   );

   parameter DW=99;
   

   //data inputs
   input [DW-1:0]  in0;
   input [DW-1:0]  in1;
   input [DW-1:0]  in2;
   input [DW-1:0]  in3;
   input [DW-1:0]  in4;
   input [DW-1:0]  in5;
   input [DW-1:0]  in6;
   
   //select inputs
   input 	   sel0;
   input 	   sel1;
   input 	   sel2;
   input 	   sel3;
   input 	   sel4;
   input 	   sel5;
   input 	   sel6;


   output [DW-1:0] out;
   
  
   assign out[DW-1:0] = ({(DW){sel0}} & in0[DW-1:0] |
			 {(DW){sel1}} & in1[DW-1:0] |
			 {(DW){sel2}} & in2[DW-1:0] |
			 {(DW){sel3}} & in3[DW-1:0] |
			 {(DW){sel4}} & in4[DW-1:0] |
			 {(DW){sel5}} & in5[DW-1:0] |
			 {(DW){sel6}} & in6[DW-1:0]);
   

   // synthesis translate_off
   always @*
     if((sel0+sel1+sel2+sel3+sel4+sel5+sel6>1) & $time>0)
       $display("ERROR>>Arbitration failure in cell %m");
   // synthesis translate_on
   
   
endmodule // mux7

module e16_pulse2pulse(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   inclk, outclk, in, reset
   );

   
   //clocks
   input  inclk; 
   input  outclk;  

   
   input  in;   
   output out;

   //reset
   input  reset;  //do we need this???



   wire   intoggle;
   wire   insync;
   
   
   //pulse to toggle
   pulse2toggle    pulse2toggle(
				// Outputs
				.out		(intoggle),
				// Inputs
				.clk		(inclk),
				.in		(in),
				.reset		(reset));
   
   //metastability synchronizer
   synchronizer #(1) synchronizer(
				  // Outputs
				  .out			(insync),
				  // Inputs
				  .in			(intoggle),
				  .clk			(outclk),
				  .reset		(reset));
   
   
   //toogle to pulse
   toggle2pulse toggle2pulse(
			     // Outputs
			     .out		(out),
			     // Inputs
			     .clk		(outclk),
			     .in		(insync),
			     .reset		(reset));
   

   
endmodule // pulse2pulse



module e16_pulse2toggle(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, in, reset
   );

   
   //clocks
   input  clk; 
   
   input  in;   
   output out;

   //reset
   input  reset;  //do we need this???


   reg 	  out;
   wire   toggle;
   
   //if input goes high, toggle output
   //note1: input can only be high for one clock cycle
   //note2: be careful with clock gating

   assign toggle = in ? ~out :
		         out;
   

   always @ (posedge clk or posedge reset)
     if(reset)
       out <= 1'b0;
     else
       out <= toggle;
   
endmodule // pulse2toggle




module e16_synchronizer #(parameter DW=32) (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   in, clk, reset
   );


   //Input Side   
   input  [DW-1:0] in;   
   input           clk;      
   input           reset;//asynchronous signal
   
   
   //Output Side
   output [DW-1:0] out;

   reg [DW-1:0] sync_reg0;
   reg [DW-1:0] sync_reg1;
   reg [DW-1:0] out;
     
   //Synchronization between clock domain
   //We use two flip-flops for metastability improvement
   always @ (posedge clk or posedge reset)
     if(reset)
       begin
	  sync_reg0[DW-1:0] <= {(DW){1'b0}};
	  sync_reg1[DW-1:0] <= {(DW){1'b0}};
	  out[DW-1:0]       <= {(DW){1'b0}};
       end
     else
       begin
	  sync_reg0[DW-1:0] <= in[DW-1:0];
	  sync_reg1[DW-1:0] <= sync_reg0[DW-1:0];
	  out[DW-1:0]       <= sync_reg1[DW-1:0];
       end
   


   
   
     

endmodule // clock_synchronizer

//goes high for one clock cycle on every input transition
module e16_toggle2pulse(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, in, reset
   );

   
   //clocks
   input  clk; 
   
   input  in;   
   output out;

   //reset
   input  reset;
   reg 	  out_reg;
         
   always @ (posedge clk or posedge reset)
     if(reset)
       out_reg <= 1'b0;
     else
       out_reg <= in;
      
   assign out = in ^ out_reg;

endmodule 





module elink_e16 (/*AUTOARG*/
   // Outputs
   rxi_rd_wait, rxi_wr_wait, txo_data, txo_lclk, txo_frame,
   c0_mesh_access_out, c0_mesh_write_out, c0_mesh_dstaddr_out,
   c0_mesh_srcaddr_out, c0_mesh_data_out, c0_mesh_datamode_out,
   c0_mesh_ctrlmode_out, c0_emesh_wait_out, c0_mesh_wait_out,
   // Inputs
   reset, c0_clk_in, c1_clk_in, c2_clk_in, c3_clk_in, rxi_data,
   rxi_lclk, rxi_frame, txo_rd_wait, txo_wr_wait, c0_mesh_access_in,
   c0_mesh_write_in, c0_mesh_dstaddr_in, c0_mesh_srcaddr_in,
   c0_mesh_data_in, c0_mesh_datamode_in, c0_mesh_ctrlmode_in,
   c0_mesh_wait_in
   );
   
   parameter DW   = `CFG_DW  ;//data width  
   parameter AW   = `CFG_AW  ;//address width
   parameter LW   = `CFG_LW  ;//lvds tranceiver pairs per side

 
   
   //Reset/core clock
   input             reset; 
   input 	     c0_clk_in;
   input 	     c1_clk_in;
   input 	     c2_clk_in;
   input 	     c3_clk_in;
   

   // # IO Signals
   input   [LW-1:0]  rxi_data;      // Byte word
   input             rxi_lclk;      // receive clock (adjusted)
   input             rxi_frame;     // indicates new transmission
   input             txo_rd_wait;   // wait indicator on read transactions   
   input             txo_wr_wait;   // wait indicator on write transactions  
   output 	     rxi_rd_wait;   // wait indicator on read transaction  
   output 	     rxi_wr_wait;   // wait indicator on write transaction  
   output  [LW-1:0]  txo_data;      // Byte word
   output            txo_lclk;      // transmit clock
   output            txo_frame;     // indicates new transmission 

   

   // # MESH 
   // # core0 (external corners and multicast)
   input 	    c0_mesh_access_in;  // access control from the mesh
   input 	    c0_mesh_write_in;   // write control from the mesh
   input [AW-1:0]   c0_mesh_dstaddr_in; // destination address from the mesh
   input [AW-1:0]   c0_mesh_srcaddr_in; // source address from the mesh
   input [DW-1:0]   c0_mesh_data_in;    // data from the mesh
   input [1:0] 	    c0_mesh_datamode_in;// data mode from the mesh 
   input [3:0] 	    c0_mesh_ctrlmode_in;// ctrl mode from the mesh
   input 	    c0_mesh_wait_in;   // wait



   // ##############
   // # Outputs
   // ##############

   
   // # MESH (write transactions internal and external corners)
   // # core0 
   output 	     c0_mesh_access_out;  // access control to the mesh
   output 	     c0_mesh_write_out;   // write control to the mesh
   output [AW-1:0]   c0_mesh_dstaddr_out; // destination address to the mesh
   output [AW-1:0]   c0_mesh_srcaddr_out; // source address to the mesh
   output [DW-1:0]   c0_mesh_data_out;    // data to the mesh
   output [1:0]      c0_mesh_datamode_out;// data mode to the mesh 
   output [3:0]      c0_mesh_ctrlmode_out;// ctrl mode to the mesh
  

   // # Waits
   output 	     c0_emesh_wait_out; // wait to the emesh   
   output 	     c0_mesh_wait_out;  // wait to the mesh 


   //TODO: NOTRE FIXED COORDINATE
   wire [3:0] 	     ext_yid_k=4'h8;   
   wire [3:0] 	     ext_xid_k=4'h2;   
   wire 	     vertical_k=1'b1; // specifies if block is vertical or horizontal
   wire [3:0] 	     who_am_i=4'b0100;   // (north,east,south,west)
   wire 	     cfg_extcomp_dis=1'b0;// Disable external coordinates comparison

   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			c0_emesh_frame_out;	// From link_port of link_port.v
   wire [2*LW-1:0]	c0_emesh_tran_out;	// From link_port of link_port.v
   wire			c0_rdmesh_frame_out;	// From link_port of link_port.v
   wire [2*LW-1:0]	c0_rdmesh_tran_out;	// From link_port of link_port.v
   wire			c0_rdmesh_wait_out;	// From link_port of link_port.v
   wire			c1_emesh_wait_out;	// From link_port of link_port.v
   wire			c1_rdmesh_frame_out;	// From link_port of link_port.v
   wire [2*LW-1:0]	c1_rdmesh_tran_out;	// From link_port of link_port.v
   wire			c1_rdmesh_wait_out;	// From link_port of link_port.v
   wire			c2_emesh_wait_out;	// From link_port of link_port.v
   wire			c2_rdmesh_frame_out;	// From link_port of link_port.v
   wire [2*LW-1:0]	c2_rdmesh_tran_out;	// From link_port of link_port.v
   wire			c2_rdmesh_wait_out;	// From link_port of link_port.v
   wire			c3_emesh_frame_out;	// From link_port of link_port.v
   wire [2*LW-1:0]	c3_emesh_tran_out;	// From link_port of link_port.v
   wire			c3_emesh_wait_out;	// From link_port of link_port.v
   wire			c3_mesh_access_out;	// From link_port of link_port.v
   wire [3:0]		c3_mesh_ctrlmode_out;	// From link_port of link_port.v
   wire [DW-1:0]	c3_mesh_data_out;	// From link_port of link_port.v
   wire [1:0]		c3_mesh_datamode_out;	// From link_port of link_port.v
   wire [AW-1:0]	c3_mesh_dstaddr_out;	// From link_port of link_port.v
   wire [AW-1:0]	c3_mesh_srcaddr_out;	// From link_port of link_port.v
   wire			c3_mesh_wait_out;	// From link_port of link_port.v
   wire			c3_mesh_write_out;	// From link_port of link_port.v
   wire			c3_rdmesh_frame_out;	// From link_port of link_port.v
   wire [2*LW-1:0]	c3_rdmesh_tran_out;	// From link_port of link_port.v
   wire			c3_rdmesh_wait_out;	// From link_port of link_port.v
   // End of automatics

   /* link_port AUTO_TEMPLATE  (.\(.*\)_rdmesh_tran_in (16'b0),
                                .\(.*\)_rdmesh_frame_in (1'b0),
                                .\(.*\)_emesh_tran_in (16'b0),
                                .\(.*\)_emesh_frame_in (1'b0),
    );
    */
   

   wire		c0_emesh_wait_in=1'b0;
   wire		c0_rdmesh_wait_in=1'b0;
   wire		c1_rdmesh_wait_in=1'b0;
   wire		c2_rdmesh_wait_in=1'b0;
   wire		c3_emesh_wait_in=1'b0;
   wire		c3_mesh_wait_in=1'b0;
   wire		c3_rdmesh_wait_in=1'b0;
   wire [5:0] 	txo_cfg_reg=6'b0;
   

   link_port link_port (.c3_mesh_access_in(1'b0),
			.c3_mesh_write_in(1'b0),
			.c3_mesh_dstaddr_in(32'b0),
			.c3_mesh_srcaddr_in(32'b0),
			.c3_mesh_data_in(32'b0),
			.c3_mesh_datamode_in(2'b0),
			.c3_mesh_ctrlmode_in(4'b0),
			/*AUTOINST*/
			// Outputs
			.rxi_rd_wait	(rxi_rd_wait),
			.rxi_wr_wait	(rxi_wr_wait),
			.txo_data	(txo_data[LW-1:0]),
			.txo_lclk	(txo_lclk),
			.txo_frame	(txo_frame),
			.c0_emesh_frame_out(c0_emesh_frame_out),
			.c0_emesh_tran_out(c0_emesh_tran_out[2*LW-1:0]),
			.c3_emesh_frame_out(c3_emesh_frame_out),
			.c3_emesh_tran_out(c3_emesh_tran_out[2*LW-1:0]),
			.c0_rdmesh_frame_out(c0_rdmesh_frame_out),
			.c0_rdmesh_tran_out(c0_rdmesh_tran_out[2*LW-1:0]),
			.c1_rdmesh_frame_out(c1_rdmesh_frame_out),
			.c1_rdmesh_tran_out(c1_rdmesh_tran_out[2*LW-1:0]),
			.c2_rdmesh_frame_out(c2_rdmesh_frame_out),
			.c2_rdmesh_tran_out(c2_rdmesh_tran_out[2*LW-1:0]),
			.c3_rdmesh_frame_out(c3_rdmesh_frame_out),
			.c3_rdmesh_tran_out(c3_rdmesh_tran_out[2*LW-1:0]),
			.c0_mesh_access_out(c0_mesh_access_out),
			.c0_mesh_write_out(c0_mesh_write_out),
			.c0_mesh_dstaddr_out(c0_mesh_dstaddr_out[AW-1:0]),
			.c0_mesh_srcaddr_out(c0_mesh_srcaddr_out[AW-1:0]),
			.c0_mesh_data_out(c0_mesh_data_out[DW-1:0]),
			.c0_mesh_datamode_out(c0_mesh_datamode_out[1:0]),
			.c0_mesh_ctrlmode_out(c0_mesh_ctrlmode_out[3:0]),
			.c3_mesh_access_out(c3_mesh_access_out),
			.c3_mesh_write_out(c3_mesh_write_out),
			.c3_mesh_dstaddr_out(c3_mesh_dstaddr_out[AW-1:0]),
			.c3_mesh_srcaddr_out(c3_mesh_srcaddr_out[AW-1:0]),
			.c3_mesh_data_out(c3_mesh_data_out[DW-1:0]),
			.c3_mesh_datamode_out(c3_mesh_datamode_out[1:0]),
			.c3_mesh_ctrlmode_out(c3_mesh_ctrlmode_out[3:0]),
			.c0_emesh_wait_out(c0_emesh_wait_out),
			.c1_emesh_wait_out(c1_emesh_wait_out),
			.c2_emesh_wait_out(c2_emesh_wait_out),
			.c3_emesh_wait_out(c3_emesh_wait_out),
			.c0_rdmesh_wait_out(c0_rdmesh_wait_out),
			.c1_rdmesh_wait_out(c1_rdmesh_wait_out),
			.c2_rdmesh_wait_out(c2_rdmesh_wait_out),
			.c3_rdmesh_wait_out(c3_rdmesh_wait_out),
			.c0_mesh_wait_out(c0_mesh_wait_out),
			.c3_mesh_wait_out(c3_mesh_wait_out),
			// Inputs
			.reset		(reset),
			.ext_yid_k	(ext_yid_k[3:0]),
			.ext_xid_k	(ext_xid_k[3:0]),
			.txo_cfg_reg	(txo_cfg_reg[5:0]),
			.vertical_k	(vertical_k),
			.who_am_i	(who_am_i[3:0]),
			.cfg_extcomp_dis(cfg_extcomp_dis),
			.rxi_data	(rxi_data[LW-1:0]),
			.rxi_lclk	(rxi_lclk),
			.rxi_frame	(rxi_frame),
			.txo_rd_wait	(txo_rd_wait),
			.txo_wr_wait	(txo_wr_wait),
			.c0_clk_in	(c0_clk_in),
			.c1_clk_in	(c1_clk_in),
			.c2_clk_in	(c2_clk_in),
			.c3_clk_in	(c3_clk_in),
			.c0_emesh_tran_in(16'b0),		 // Templated
			.c0_emesh_frame_in(1'b0),		 // Templated
			.c1_emesh_tran_in(16'b0),		 // Templated
			.c1_emesh_frame_in(1'b0),		 // Templated
			.c2_emesh_tran_in(16'b0),		 // Templated
			.c2_emesh_frame_in(1'b0),		 // Templated
			.c3_emesh_tran_in(16'b0),		 // Templated
			.c3_emesh_frame_in(1'b0),		 // Templated
			.c0_rdmesh_tran_in(16'b0),		 // Templated
			.c0_rdmesh_frame_in(1'b0),		 // Templated
			.c1_rdmesh_tran_in(16'b0),		 // Templated
			.c1_rdmesh_frame_in(1'b0),		 // Templated
			.c2_rdmesh_tran_in(16'b0),		 // Templated
			.c2_rdmesh_frame_in(1'b0),		 // Templated
			.c3_rdmesh_tran_in(16'b0),		 // Templated
			.c3_rdmesh_frame_in(1'b0),		 // Templated
			.c0_mesh_access_in(c0_mesh_access_in),
			.c0_mesh_write_in(c0_mesh_write_in),
			.c0_mesh_dstaddr_in(c0_mesh_dstaddr_in[AW-1:0]),
			.c0_mesh_srcaddr_in(c0_mesh_srcaddr_in[AW-1:0]),
			.c0_mesh_data_in(c0_mesh_data_in[DW-1:0]),
			.c0_mesh_datamode_in(c0_mesh_datamode_in[1:0]),
			.c0_mesh_ctrlmode_in(c0_mesh_ctrlmode_in[3:0]),
			.c0_emesh_wait_in(c0_emesh_wait_in),
			.c3_emesh_wait_in(c3_emesh_wait_in),
			.c0_mesh_wait_in(c0_mesh_wait_in),
			.c3_mesh_wait_in(c3_mesh_wait_in),
			.c0_rdmesh_wait_in(c0_rdmesh_wait_in),
			.c1_rdmesh_wait_in(c1_rdmesh_wait_in),
			.c2_rdmesh_wait_in(c2_rdmesh_wait_in),
			.c3_rdmesh_wait_in(c3_rdmesh_wait_in));
      
endmodule // elink_e16

module link_port(/*AUTOARG*/
   // Outputs
   rxi_rd_wait, rxi_wr_wait, txo_data, txo_lclk, txo_frame,
   c0_emesh_frame_out, c0_emesh_tran_out, c3_emesh_frame_out,
   c3_emesh_tran_out, c0_rdmesh_frame_out, c0_rdmesh_tran_out,
   c1_rdmesh_frame_out, c1_rdmesh_tran_out, c2_rdmesh_frame_out,
   c2_rdmesh_tran_out, c3_rdmesh_frame_out, c3_rdmesh_tran_out,
   c0_mesh_access_out, c0_mesh_write_out, c0_mesh_dstaddr_out,
   c0_mesh_srcaddr_out, c0_mesh_data_out, c0_mesh_datamode_out,
   c0_mesh_ctrlmode_out, c3_mesh_access_out, c3_mesh_write_out,
   c3_mesh_dstaddr_out, c3_mesh_srcaddr_out, c3_mesh_data_out,
   c3_mesh_datamode_out, c3_mesh_ctrlmode_out, c0_emesh_wait_out,
   c1_emesh_wait_out, c2_emesh_wait_out, c3_emesh_wait_out,
   c0_rdmesh_wait_out, c1_rdmesh_wait_out, c2_rdmesh_wait_out,
   c3_rdmesh_wait_out, c0_mesh_wait_out, c3_mesh_wait_out,
   // Inputs
   reset, ext_yid_k, ext_xid_k, txo_cfg_reg, vertical_k, who_am_i,
   cfg_extcomp_dis, rxi_data, rxi_lclk, rxi_frame, txo_rd_wait,
   txo_wr_wait, c0_clk_in, c1_clk_in, c2_clk_in, c3_clk_in,
   c0_emesh_tran_in, c0_emesh_frame_in, c1_emesh_tran_in,
   c1_emesh_frame_in, c2_emesh_tran_in, c2_emesh_frame_in,
   c3_emesh_tran_in, c3_emesh_frame_in, c0_rdmesh_tran_in,
   c0_rdmesh_frame_in, c1_rdmesh_tran_in, c1_rdmesh_frame_in,
   c2_rdmesh_tran_in, c2_rdmesh_frame_in, c3_rdmesh_tran_in,
   c3_rdmesh_frame_in, c0_mesh_access_in, c0_mesh_write_in,
   c0_mesh_dstaddr_in, c0_mesh_srcaddr_in, c0_mesh_data_in,
   c0_mesh_datamode_in, c0_mesh_ctrlmode_in, c3_mesh_access_in,
   c3_mesh_write_in, c3_mesh_dstaddr_in, c3_mesh_srcaddr_in,
   c3_mesh_data_in, c3_mesh_datamode_in, c3_mesh_ctrlmode_in,
   c0_emesh_wait_in, c3_emesh_wait_in, c0_mesh_wait_in,
   c3_mesh_wait_in, c0_rdmesh_wait_in, c1_rdmesh_wait_in,
   c2_rdmesh_wait_in, c3_rdmesh_wait_in
   );

   parameter DW   = `CFG_DW  ;//data width  
   parameter AW   = `CFG_AW  ;//address width
   parameter LW   = `CFG_LW  ;//lvds tranceiver pairs per side

   // #########
   // # Inputs
   // #########
   
   input             reset;     //reset input
   input [3:0] 	     ext_yid_k; //external y-id 
   input [3:0] 	     ext_xid_k; //external x-id

   input [5:0] 	     txo_cfg_reg;// Link configuration register
   input             vertical_k; // specifies if block is vertical or horizontal
   input [3:0] 	     who_am_i;   // specifies what link is that (north,east,south,west)
   input 	     cfg_extcomp_dis;// Disable external coordinates comparison
                                     // Every input transaction is received by the chip
   // # Vertical_k usage:
   // # West/East link port is "vertical", i.e. sends transactions to the cores
   // # horizontally, according to the row_k[2:0] index
   // # North/South link port is "horizontal", i.e. sends transactions to the cores
   // # vertically, according to the col_k[2:0] index
   // # In order to distinguish between West/East and North/South,
   // # vertical_k index is used.

   // # Receiver
   input   [LW-1:0]  rxi_data;        // Byte word
   input             rxi_lclk;        // receive clock (adjusted to the frame/data)
   input             rxi_frame;       // indicates new transmission

   // # Transmitter
   input             txo_rd_wait;     // wait indicator on read transactions   
   input             txo_wr_wait;     // wait indicator on write transactions  

   // # Clocks
   input 	    c0_clk_in;         // clock of the core  
   input 	    c1_clk_in;         // clock of the core  
   input 	    c2_clk_in;         // clock of the core  
   input 	    c3_clk_in;         // clock of the core  

   // # EMESH
   input [2*LW-1:0] c0_emesh_tran_in;  // serialized transaction
   input 	    c0_emesh_frame_in; // transaction frame
   input [2*LW-1:0] c1_emesh_tran_in;  // serialized transaction
   input 	    c1_emesh_frame_in; // transaction frame
   input [2*LW-1:0] c2_emesh_tran_in;  // serialized transaction
   input 	    c2_emesh_frame_in; // transaction frame
   input [2*LW-1:0] c3_emesh_tran_in;  // serialized transaction
   input 	    c3_emesh_frame_in; // transaction frame
   // # RDMESH
   input [2*LW-1:0] c0_rdmesh_tran_in;  // serialized transaction
   input 	    c0_rdmesh_frame_in; // transaction frame
   input [2*LW-1:0] c1_rdmesh_tran_in;  // serialized transaction
   input 	    c1_rdmesh_frame_in; // transaction frame
   input [2*LW-1:0] c2_rdmesh_tran_in;  // serialized transaction
   input 	    c2_rdmesh_frame_in; // transaction frame
   input [2*LW-1:0] c3_rdmesh_tran_in;  // serialized transaction
   input 	    c3_rdmesh_frame_in; // transaction frame
   // # MESH 
   // # core0 (external corners and multicast)
   input 	    c0_mesh_access_in;  // access control from the mesh
   input 	    c0_mesh_write_in;   // write control from the mesh
   input [AW-1:0]   c0_mesh_dstaddr_in; // destination address from the mesh
   input [AW-1:0]   c0_mesh_srcaddr_in; // source address from the mesh
   input [DW-1:0]   c0_mesh_data_in;    // data from the mesh
   input [1:0] 	    c0_mesh_datamode_in;// data mode from the mesh 
   input [3:0] 	    c0_mesh_ctrlmode_in;// ctrl mode from the mesh
   // # core3 (external corners only)
   input 	    c3_mesh_access_in;  // access control from the mesh
   input 	    c3_mesh_write_in;   // write control from the mesh
   input [AW-1:0]   c3_mesh_dstaddr_in; // destination address from the mesh
   input [AW-1:0]   c3_mesh_srcaddr_in; // source address from the mesh
   input [DW-1:0]   c3_mesh_data_in;    // data from the mesh
   input [1:0] 	    c3_mesh_datamode_in;// data mode from the mesh 
   input [3:0] 	    c3_mesh_ctrlmode_in;// ctrl mode from the mesh

   //# Waits
   input 	    c0_emesh_wait_in;  // wait
   input 	    c3_emesh_wait_in;  // wait
   input 	    c0_mesh_wait_in;   // wait
   input 	    c3_mesh_wait_in;   // wait
   input 	    c0_rdmesh_wait_in; // wait
   input 	    c1_rdmesh_wait_in; // wait
   input 	    c2_rdmesh_wait_in; // wait
   input 	    c3_rdmesh_wait_in; // wait

   // ##############
   // # Outputs
   // ##############

   // # Receiver
   output 	     rxi_rd_wait;      // wait indicator on read transaction  
   output 	     rxi_wr_wait;      // wait indicator on write transaction  

   // # Transmitter
   output  [LW-1:0]  txo_data;      // Byte word
   output            txo_lclk;      // transmit clock (adjusted to the frame/data)
   output            txo_frame;     // indicates new transmission 

   //# EMESH (write transactions with the off chip destination)
   output            c0_emesh_frame_out; // transaction frame
   output [2*LW-1:0] c0_emesh_tran_out;  // serialized transaction
   output            c3_emesh_frame_out; // transaction frame
   output [2*LW-1:0] c3_emesh_tran_out;  // serialized transaction
   // # RDMESH (any read transaction)
   output            c0_rdmesh_frame_out; // transaction frame
   output [2*LW-1:0] c0_rdmesh_tran_out;  // serialized transaction
   output            c1_rdmesh_frame_out; // transaction frame
   output [2*LW-1:0] c1_rdmesh_tran_out;  // serialized transaction
   output            c2_rdmesh_frame_out; // transaction frame
   output [2*LW-1:0] c2_rdmesh_tran_out;  // serialized transaction
   output            c3_rdmesh_frame_out; // transaction frame
   output [2*LW-1:0] c3_rdmesh_tran_out;  // serialized transaction
   // # MESH (write transactions internal and external corners)
   // # core0 
   output 	     c0_mesh_access_out;  // access control to the mesh
   output 	     c0_mesh_write_out;   // write control to the mesh
   output [AW-1:0]   c0_mesh_dstaddr_out; // destination address to the mesh
   output [AW-1:0]   c0_mesh_srcaddr_out; // source address to the mesh
   output [DW-1:0]   c0_mesh_data_out;    // data to the mesh
   output [1:0]      c0_mesh_datamode_out;// data mode to the mesh 
   output [3:0]      c0_mesh_ctrlmode_out;// ctrl mode to the mesh
   // # core3 
   output 	     c3_mesh_access_out;  // access control to the mesh
   output 	     c3_mesh_write_out;   // write control to the mesh
   output [AW-1:0]   c3_mesh_dstaddr_out; // destination address to the mesh
   output [AW-1:0]   c3_mesh_srcaddr_out; // source address to the mesh
   output [DW-1:0]   c3_mesh_data_out;    // data to the mesh
   output [1:0]      c3_mesh_datamode_out;// data mode to the mesh 
   output [3:0]      c3_mesh_ctrlmode_out;// ctrl mode to the mesh

   // # Waits
   output 	     c0_emesh_wait_out; // wait to the emesh   
   output 	     c1_emesh_wait_out; // wait to the emesh   
   output 	     c2_emesh_wait_out; // wait to the emesh   
   output 	     c3_emesh_wait_out; // wait to the emesh   

   output 	     c0_rdmesh_wait_out; // wait to the rdmesh   
   output 	     c1_rdmesh_wait_out; // wait to the rdmesh   
   output 	     c2_rdmesh_wait_out; // wait to the rdmesh   
   output 	     c3_rdmesh_wait_out; // wait to the rdmesh   

   output 	     c0_mesh_wait_out;  // wait to the mesh 
   output 	     c3_mesh_wait_out;  // wait to the mesh 
     
   /*AUTOINPUT*/
   /*AUTOWIRE*/
 
   // #########################
   // # Receiver instantiation
   // #########################
  
   link_receiver  link_receiver(/*AUTOINST*/
				// Outputs
				.rxi_wr_wait	(rxi_wr_wait),
				.rxi_rd_wait	(rxi_rd_wait),
				.c0_emesh_frame_out(c0_emesh_frame_out),
				.c0_emesh_tran_out(c0_emesh_tran_out[2*LW-1:0]),
				.c3_emesh_frame_out(c3_emesh_frame_out),
				.c3_emesh_tran_out(c3_emesh_tran_out[2*LW-1:0]),
				.c0_rdmesh_frame_out(c0_rdmesh_frame_out),
				.c0_rdmesh_tran_out(c0_rdmesh_tran_out[2*LW-1:0]),
				.c1_rdmesh_frame_out(c1_rdmesh_frame_out),
				.c1_rdmesh_tran_out(c1_rdmesh_tran_out[2*LW-1:0]),
				.c2_rdmesh_frame_out(c2_rdmesh_frame_out),
				.c2_rdmesh_tran_out(c2_rdmesh_tran_out[2*LW-1:0]),
				.c3_rdmesh_frame_out(c3_rdmesh_frame_out),
				.c3_rdmesh_tran_out(c3_rdmesh_tran_out[2*LW-1:0]),
				.c0_mesh_access_out(c0_mesh_access_out),
				.c0_mesh_write_out(c0_mesh_write_out),
				.c0_mesh_dstaddr_out(c0_mesh_dstaddr_out[AW-1:0]),
				.c0_mesh_srcaddr_out(c0_mesh_srcaddr_out[AW-1:0]),
				.c0_mesh_data_out(c0_mesh_data_out[DW-1:0]),
				.c0_mesh_datamode_out(c0_mesh_datamode_out[1:0]),
				.c0_mesh_ctrlmode_out(c0_mesh_ctrlmode_out[3:0]),
				.c3_mesh_access_out(c3_mesh_access_out),
				.c3_mesh_write_out(c3_mesh_write_out),
				.c3_mesh_dstaddr_out(c3_mesh_dstaddr_out[AW-1:0]),
				.c3_mesh_srcaddr_out(c3_mesh_srcaddr_out[AW-1:0]),
				.c3_mesh_data_out(c3_mesh_data_out[DW-1:0]),
				.c3_mesh_datamode_out(c3_mesh_datamode_out[1:0]),
				.c3_mesh_ctrlmode_out(c3_mesh_ctrlmode_out[3:0]),
				// Inputs
				.reset		(reset),
				.ext_yid_k	(ext_yid_k[3:0]),
				.ext_xid_k	(ext_xid_k[3:0]),
				.vertical_k	(vertical_k),
				.who_am_i	(who_am_i[3:0]),
				.cfg_extcomp_dis(cfg_extcomp_dis),
				.rxi_data	(rxi_data[LW-1:0]),
				.rxi_lclk	(rxi_lclk),
				.rxi_frame	(rxi_frame),
				.c0_clk_in	(c0_clk_in),
				.c1_clk_in	(c1_clk_in),
				.c2_clk_in	(c2_clk_in),
				.c3_clk_in	(c3_clk_in),
				.c0_emesh_wait_in(c0_emesh_wait_in),
				.c3_emesh_wait_in(c3_emesh_wait_in),
				.c0_mesh_wait_in(c0_mesh_wait_in),
				.c3_mesh_wait_in(c3_mesh_wait_in),
				.c0_rdmesh_wait_in(c0_rdmesh_wait_in),
				.c1_rdmesh_wait_in(c1_rdmesh_wait_in),
				.c2_rdmesh_wait_in(c2_rdmesh_wait_in),
				.c3_rdmesh_wait_in(c3_rdmesh_wait_in));
   

   // ############################
   // # Transmitter instantiation
   // ############################

   link_transmitter  link_transmitter(.txo_lclk90	(txo_lclk),
				      /*AUTOINST*/
				      // Outputs
				      .txo_data		(txo_data[LW-1:0]),
				      .txo_frame	(txo_frame),
				      .c0_emesh_wait_out(c0_emesh_wait_out),
				      .c1_emesh_wait_out(c1_emesh_wait_out),
				      .c2_emesh_wait_out(c2_emesh_wait_out),
				      .c3_emesh_wait_out(c3_emesh_wait_out),
				      .c0_rdmesh_wait_out(c0_rdmesh_wait_out),
				      .c1_rdmesh_wait_out(c1_rdmesh_wait_out),
				      .c2_rdmesh_wait_out(c2_rdmesh_wait_out),
				      .c3_rdmesh_wait_out(c3_rdmesh_wait_out),
				      .c0_mesh_wait_out	(c0_mesh_wait_out),
				      .c3_mesh_wait_out	(c3_mesh_wait_out),
				      // Inputs
				      .reset		(reset),
				      .ext_yid_k	(ext_yid_k[3:0]),
				      .ext_xid_k	(ext_xid_k[3:0]),
				      .who_am_i		(who_am_i[3:0]),
				      .txo_cfg_reg	(txo_cfg_reg[5:0]),
				      .txo_wr_wait	(txo_wr_wait),
				      .txo_rd_wait	(txo_rd_wait),
				      .c0_clk_in	(c0_clk_in),
				      .c1_clk_in	(c1_clk_in),
				      .c2_clk_in	(c2_clk_in),
				      .c3_clk_in	(c3_clk_in),
				      .c0_mesh_access_in(c0_mesh_access_in),
				      .c0_mesh_write_in	(c0_mesh_write_in),
				      .c0_mesh_dstaddr_in(c0_mesh_dstaddr_in[AW-1:0]),
				      .c0_mesh_srcaddr_in(c0_mesh_srcaddr_in[AW-1:0]),
				      .c0_mesh_data_in	(c0_mesh_data_in[DW-1:0]),
				      .c0_mesh_datamode_in(c0_mesh_datamode_in[1:0]),
				      .c0_mesh_ctrlmode_in(c0_mesh_ctrlmode_in[3:0]),
				      .c3_mesh_access_in(c3_mesh_access_in),
				      .c3_mesh_write_in	(c3_mesh_write_in),
				      .c3_mesh_dstaddr_in(c3_mesh_dstaddr_in[AW-1:0]),
				      .c3_mesh_srcaddr_in(c3_mesh_srcaddr_in[AW-1:0]),
				      .c3_mesh_data_in	(c3_mesh_data_in[DW-1:0]),
				      .c3_mesh_datamode_in(c3_mesh_datamode_in[1:0]),
				      .c3_mesh_ctrlmode_in(c3_mesh_ctrlmode_in[3:0]));
      
endmodule // link_port


module link_receiver(/*AUTOARG*/
   // Outputs
   rxi_wr_wait, rxi_rd_wait, c0_emesh_frame_out, c0_emesh_tran_out,
   c3_emesh_frame_out, c3_emesh_tran_out, c0_rdmesh_frame_out,
   c0_rdmesh_tran_out, c1_rdmesh_frame_out, c1_rdmesh_tran_out,
   c2_rdmesh_frame_out, c2_rdmesh_tran_out, c3_rdmesh_frame_out,
   c3_rdmesh_tran_out, c0_mesh_access_out, c0_mesh_write_out,
   c0_mesh_dstaddr_out, c0_mesh_srcaddr_out, c0_mesh_data_out,
   c0_mesh_datamode_out, c0_mesh_ctrlmode_out, c3_mesh_access_out,
   c3_mesh_write_out, c3_mesh_dstaddr_out, c3_mesh_srcaddr_out,
   c3_mesh_data_out, c3_mesh_datamode_out, c3_mesh_ctrlmode_out,
   // Inputs
   reset, ext_yid_k, ext_xid_k, vertical_k, who_am_i, cfg_extcomp_dis,
   rxi_data, rxi_lclk, rxi_frame, c0_clk_in, c1_clk_in, c2_clk_in,
   c3_clk_in, c0_emesh_wait_in, c3_emesh_wait_in, c0_mesh_wait_in,
   c3_mesh_wait_in, c0_rdmesh_wait_in, c1_rdmesh_wait_in,
   c2_rdmesh_wait_in, c3_rdmesh_wait_in
   );

   parameter LW   = `CFG_LW;//lvds tranceiver pairs per side
   parameter DW   = `CFG_DW;//data width  
   parameter AW   = `CFG_AW;//address width
		     
   // #########
   // # Inputs
   // #########

   input             reset;     // reset input
   input [3:0] 	     ext_yid_k; // external y-id 
   input [3:0] 	     ext_xid_k; // external x-id
   input             vertical_k;// specifies if block is vertical or horizontal
   input [3:0] 	     who_am_i;  // specifies what link is that (north,east,south,west)
   input 	     cfg_extcomp_dis;// Disable external coordinates comparison
                                     // Every input transaction is received by the chip
  
   input [LW-1:0]    rxi_data;  // Byte word
   input             rxi_lclk;  // receive clock (adjusted to the frame/data)
   input             rxi_frame; // indicates new transmission

   // # Sync clocks
   input             c0_clk_in; // clock of the core
   input             c1_clk_in; // clock of the core
   input             c2_clk_in; // clock of the core
   input             c3_clk_in; // clock of the core

   // # Wait indicators
   input             c0_emesh_wait_in;  // wait
   input             c3_emesh_wait_in;  // wait
   input 	     c0_mesh_wait_in;   // wait
   input 	     c3_mesh_wait_in;   // wait
   input             c0_rdmesh_wait_in; // wait
   input             c1_rdmesh_wait_in; // wait
   input             c2_rdmesh_wait_in; // wait
   input             c3_rdmesh_wait_in; // wait

   // ##########
   // # Outputs
   // ##########

   output 	     rxi_wr_wait;  //wait indicator for write transactions
   output 	     rxi_rd_wait;  //wait indicator for read transactions 

   //# EMESH (write transactions with the off chip destination)
   output            c0_emesh_frame_out; // transaction frame
   output [2*LW-1:0] c0_emesh_tran_out;  // serialized transaction
   output            c3_emesh_frame_out; // transaction frame
   output [2*LW-1:0] c3_emesh_tran_out;  // serialized transaction
   // # RDMESH (any read transaction)
   output            c0_rdmesh_frame_out; // transaction frame
   output [2*LW-1:0] c0_rdmesh_tran_out;  // serialized transaction
   output            c1_rdmesh_frame_out; // transaction frame
   output [2*LW-1:0] c1_rdmesh_tran_out;  // serialized transaction
   output            c2_rdmesh_frame_out; // transaction frame
   output [2*LW-1:0] c2_rdmesh_tran_out;  // serialized transaction
   output            c3_rdmesh_frame_out; // transaction frame
   output [2*LW-1:0] c3_rdmesh_tran_out;  // serialized transaction
   // # MESH (write transactions internal and external corners)
   // # core0 
   output 	     c0_mesh_access_out;  // access control to the mesh
   output 	     c0_mesh_write_out;   // write control to the mesh
   output [AW-1:0]   c0_mesh_dstaddr_out; // destination address to the mesh
   output [AW-1:0]   c0_mesh_srcaddr_out; // source address to the mesh
   output [DW-1:0]   c0_mesh_data_out;    // data to the mesh
   output [1:0]      c0_mesh_datamode_out;// data mode to the mesh 
   output [3:0]      c0_mesh_ctrlmode_out;// ctrl mode to the mesh
   // # core3 
   output 	     c3_mesh_access_out;  // access control to the mesh
   output 	     c3_mesh_write_out;   // write control to the mesh
   output [AW-1:0]   c3_mesh_dstaddr_out; // destination address to the mesh
   output [AW-1:0]   c3_mesh_srcaddr_out; // source address to the mesh
   output [DW-1:0]   c3_mesh_data_out;    // data to the mesh
   output [1:0]      c3_mesh_datamode_out;// data mode to the mesh 
   output [3:0]      c3_mesh_ctrlmode_out;// ctrl mode to the mesh
  
   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#################################
   //# Write Transactions Receiver
   //#################################

   link_rxi_wr link_rxi_wr(/*AUTOINST*/
			   // Outputs
			   .rxi_wr_wait		(rxi_wr_wait),
			   .c0_emesh_frame_out	(c0_emesh_frame_out),
			   .c0_emesh_tran_out	(c0_emesh_tran_out[2*LW-1:0]),
			   .c3_emesh_frame_out	(c3_emesh_frame_out),
			   .c3_emesh_tran_out	(c3_emesh_tran_out[2*LW-1:0]),
			   .c0_mesh_access_out	(c0_mesh_access_out),
			   .c0_mesh_write_out	(c0_mesh_write_out),
			   .c0_mesh_dstaddr_out	(c0_mesh_dstaddr_out[AW-1:0]),
			   .c0_mesh_srcaddr_out	(c0_mesh_srcaddr_out[AW-1:0]),
			   .c0_mesh_data_out	(c0_mesh_data_out[DW-1:0]),
			   .c0_mesh_datamode_out(c0_mesh_datamode_out[1:0]),
			   .c0_mesh_ctrlmode_out(c0_mesh_ctrlmode_out[3:0]),
			   .c3_mesh_access_out	(c3_mesh_access_out),
			   .c3_mesh_write_out	(c3_mesh_write_out),
			   .c3_mesh_dstaddr_out	(c3_mesh_dstaddr_out[AW-1:0]),
			   .c3_mesh_srcaddr_out	(c3_mesh_srcaddr_out[AW-1:0]),
			   .c3_mesh_data_out	(c3_mesh_data_out[DW-1:0]),
			   .c3_mesh_datamode_out(c3_mesh_datamode_out[1:0]),
			   .c3_mesh_ctrlmode_out(c3_mesh_ctrlmode_out[3:0]),
			   // Inputs
			   .reset		(reset),
			   .ext_yid_k		(ext_yid_k[3:0]),
			   .ext_xid_k		(ext_xid_k[3:0]),
			   .vertical_k		(vertical_k),
			   .who_am_i		(who_am_i[3:0]),
			   .cfg_extcomp_dis	(cfg_extcomp_dis),
			   .rxi_data		(rxi_data[LW-1:0]),
			   .rxi_lclk		(rxi_lclk),
			   .rxi_frame		(rxi_frame),
			   .c0_clk_in		(c0_clk_in),
			   .c3_clk_in		(c3_clk_in),
			   .c0_emesh_wait_in	(c0_emesh_wait_in),
			   .c3_emesh_wait_in	(c3_emesh_wait_in),
			   .c0_mesh_wait_in	(c0_mesh_wait_in),
			   .c3_mesh_wait_in	(c3_mesh_wait_in));

   //#################################
   //# Read Transactions Receiver
   //#################################

   link_rxi_rd link_rxi_rd(/*AUTOINST*/
			   // Outputs
			   .rxi_rd_wait		(rxi_rd_wait),
			   .c0_rdmesh_frame_out	(c0_rdmesh_frame_out),
			   .c0_rdmesh_tran_out	(c0_rdmesh_tran_out[2*LW-1:0]),
			   .c1_rdmesh_frame_out	(c1_rdmesh_frame_out),
			   .c1_rdmesh_tran_out	(c1_rdmesh_tran_out[2*LW-1:0]),
			   .c2_rdmesh_frame_out	(c2_rdmesh_frame_out),
			   .c2_rdmesh_tran_out	(c2_rdmesh_tran_out[2*LW-1:0]),
			   .c3_rdmesh_frame_out	(c3_rdmesh_frame_out),
			   .c3_rdmesh_tran_out	(c3_rdmesh_tran_out[2*LW-1:0]),
			   // Inputs
			   .reset		(reset),
			   .ext_yid_k		(ext_yid_k[3:0]),
			   .ext_xid_k		(ext_xid_k[3:0]),
			   .vertical_k		(vertical_k),
			   .who_am_i		(who_am_i[3:0]),
			   .cfg_extcomp_dis	(cfg_extcomp_dis),
			   .rxi_data		(rxi_data[LW-1:0]),
			   .rxi_lclk		(rxi_lclk),
			   .rxi_frame		(rxi_frame),
			   .c0_clk_in		(c0_clk_in),
			   .c1_clk_in		(c1_clk_in),
			   .c2_clk_in		(c2_clk_in),
			   .c3_clk_in		(c3_clk_in),
			   .c0_rdmesh_wait_in	(c0_rdmesh_wait_in),
			   .c1_rdmesh_wait_in	(c1_rdmesh_wait_in),
			   .c2_rdmesh_wait_in	(c2_rdmesh_wait_in),
			   .c3_rdmesh_wait_in	(c3_rdmesh_wait_in));


 
endmodule // link_receiver

     //############################################################################
//# The input data stream is of the following structure:
//#
//#        ---     ---     ---     ---     ---     ---
//# lclk _|   |___|   |___|   |___|   |___|   |___|   |_
//#
//#              -------------------------------
//# frame ______/
//#              --- --- --- --- ---
//# data  XXXXXXX 0 X 1 X 2 X 3 X 4 X .....
//#              --- --- --- --- ---
//#
//# byte0 (the byte received on the rising edge of the clock the 
//# same cycle the frame's rising edge is detected) holds the 
//# information of the transmitted transaction.
//#
//#      byte0          | transaction type
//#   ----------------- | ----------------
//#  8'b??_??_?0_<cid>  | New transaction with incremental bursting address
//#  8'b??_??_?1_<cid>  | New transaction with the same bursting address
//#
//#  cid[1:0] - channel id (for now for debugging usage only) 
//#
//#  New transaction structure:
//#  -------------------------
//#   byte1  -> ctrlmode[3:0],dstaddr[31:28]
//#   byte2  -> dstaddr[27:20]
//#   byte3  -> dstaddr[19:12]
//#   byte4  -> dstaddr[11:4]
//#   byte5  -> dstaddr[3:0],datamode[1:0],write,access
//#   byte6  -> data[31:24] (or srcaddr[31:24] if read transaction)
//#   byte7  -> data[23:16] (or srcaddr[23:16] if read transaction)
//#   byte8  -> data[15:8]  (or srcaddr[15:8]  if read transaction)
//#  *byte9  -> data[7:0]   (or srcaddr[7:0]   if read transaction)
//#   byte10 -> data[63:56]  
//#   byte11 -> data[55:48]  
//#   byte12 -> data[47:40]  
//#   byte13 -> data[39:32]  
//# **byte14 -> data[31:24]  
//#    ...
//#    ...
//#    ...
//#
//#  * byte9 is the last byte of 32 bit write or read transaction 
//#   
//# ** if 64 bit write transaction, data of byte14 is the first data byte of
//#    bursting transaction
//# 
//# -- The data is transmitted MSB first but in 32bits resolution. If we want
//#    to transmit 64 bits it will be [31:0] (msb first) and then [63:32] (msb first)
//#
//# !!!
//# !!! According to the above scheme, any new transaction (burst or not)
//# !!! will take at least four cycles to be transmitted.
//# !!! There are some internal mechanisms in the transmitter-receiver logic
//# !!! which are implemented considering this assumption true.
//# !!! Any change to this assumption (transaction takes at least four cycles)
//# !!! should be carefully reviewed with its implications on the internal
//# !!! implementation
//# !!!
//# 
//#####################################################################
module link_rxi_assembler (/*AUTOARG*/
   // Outputs
   rxi_assembled_tran, rxi_c0_access, rxi_c1_access, rxi_c2_access,
   rxi_c3_access,
   // Inputs
   reset, rxi_lclk, vertical_k, ext_yid_k, ext_xid_k, fifo_data_reg,
   fifo_data_val, start_tran, cfg_extcomp_dis
   );

   parameter LW   = `CFG_LW  ;//lvds tranceiver pairs per side
   parameter DW   = `CFG_DW  ;//data width
   parameter AW   = `CFG_AW  ;//address width

   // #########
   // # INPUTS
   // #########
   input            reset;       //reset input
   input 	    rxi_lclk;    //receive clock (adjusted to the frame/data)

   input            vertical_k;  //specifies if block is vertical or horizontal
   input [3:0] 	    ext_yid_k;   //external y-id 
   input [3:0] 	    ext_xid_k;   //external x-id

   input [2*LW-1:0] fifo_data_reg;// output of the input receiver fifo
   input 	    fifo_data_val;// fifo_data_reg is valid
   input 	    start_tran;   // Start transaction bit

   input 	    cfg_extcomp_dis;// Disable external coordinates comparison
                                    // Every input transaction is received by the chip
   // ##########
   // # OUTPUTS
   // ##########
   output [14*LW-1:0] rxi_assembled_tran; // data to be transferred to secondary fifos
   output             rxi_c0_access; //transfering to c0_fifo
   output 	      rxi_c1_access; //transfering to c1_fifo
   output 	      rxi_c2_access; //transfering to c2_fifo
   output 	      rxi_c3_access; //transfering to c3_fifo  

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   // #########
   // # REGS
   // #########
   reg [LW-1:0] tran_byte0;
   reg [2:0] 	rxi_assemble_cnt;
   reg [3:0] 	ctrlmode;
   reg [AW-1:0] dstaddr_int;
   reg [1:0] 	datamode;
   reg 		write;
   reg 		access;
   reg [DW-1:0] data;
   reg [AW-1:0] srcaddr;
   reg 		rxi_cx_access;

   // #########
   // # WIRES
   // #########
   wire          byte0_inc8; // Address of the burst transaction should be incremented
   wire 	 dstaddr_2712_en;
   wire 	 dstaddr_1100_en;
   wire 	 datamode_en;    
   wire 	 write_en;       
   wire 	 access_en;      
   wire 	 data_3116_en;   
   wire 	 data_1500_en;   
   wire 	 srcaddr_3116_en;
   wire 	 srcaddr_1500_en;
   wire [2:0] 	 rxi_assemble_cnt_next; // Next value of the assembly counter
   wire [2:0] 	 rxi_assemble_cnt_inc;  // Incremented value of the assembly counter
   wire 	 rxi_assemble_cnt_max;  // Maximum value of the counter 
   wire 	 burst_tran;            // detected burst transaction
   wire [AW-1:0] dstaddr_inc;           // Incremented value of burst transaction dstaddr
   wire [AW-1:0] dstaddr_in;            // Input to the next destination address FF
   wire 	 single_write;          // single write transaction
   wire 	 single_write_complete; // single write transaction is complete
   wire 	 read_jump;             // read transaction "jumps" over data part
   wire 	 tran_assembled;        // transaction is assembled
   wire [5:0] 	 comp_addr;
   wire [5:0] 	 chip_addr;
   wire [5:0] 	 comp_low;
   wire 	 carry_low;
   wire 	 zero_low;
   wire [5:0] 	 comp_high;
   wire 	 carry_high;
   wire 	 c0_match;
   wire 	 c1_match;
   wire 	 c2_match;
   wire 	 c3_match;
   wire 	 multicast_match;
   wire [AW-1:0] dstaddr;

   //##############################
   //# Assembled data and controls
   //##############################

   assign rxi_assembled_tran[14*LW-1:0]={
                                         srcaddr[7:0],{(LW){1'b0}},
				               srcaddr[23:8],
			                 data[7:0],srcaddr[31:24],
				                 data[23:8],
	                    dstaddr[3:0],datamode[1:0],write,access,data[31:24],
				                dstaddr[19:4],
			                 ctrlmode[3:0],dstaddr[31:20]
                                        };
 
   //####################
   //# Byte0 detection
   //####################

   always @ (posedge rxi_lclk)
     if(fifo_data_val & start_tran)
       begin
	  tran_byte0[LW-1:0]  <= fifo_data_reg[2*LW-1:LW]; 
	  ctrlmode[3:0]       <= fifo_data_reg[7:4];
       end

   //# byte0 decode
   //# bit[2] is the only one in use for now
   assign byte0_inc8   = ~tran_byte0[2];

   //##########################
   //# Transaction assembly
   //##########################

   //# destination address
   //# There is a special mode set in the Link Bypass Configuration Register
   //# which forces the chip to receive all of the transactions entering the chip
   //# In this case we just replace the external coordinates of the destination 
   //# address with the chip coordinates.
//   assign dstaddr[31:29] = cfg_extcomp_dis ? ext_yid_k[2:0] : dstaddr_int[31:29];
//   assign dstaddr[28:26] = cfg_extcomp_dis ? ext_xid_k[2:0] : dstaddr_int[28:26];
//   assign dstaddr[25:0]  = dstaddr_int[25:0];
   assign dstaddr[31:28] = cfg_extcomp_dis ? ext_yid_k[3:0] : dstaddr_int[31:28];
   assign dstaddr[25:22] = cfg_extcomp_dis ? ext_xid_k[3:0] : dstaddr_int[25:22];
   assign dstaddr[27:26] = dstaddr_int[27:26];
   assign dstaddr[21:0]  = dstaddr_int[21:0];

//   assign comp_addr[5:0]  = vertical_k ? {dstaddr[31:29],dstaddr[25:23]} : 
//                                         {dstaddr[28:26],dstaddr[22:20]} ;   

//   assign chip_addr[2:0]   = vertical_k ?  ext_yid_k[2:0] : ext_xid_k[2:0];
 
   //# destination address is updated on the beginning of burst transaction
   //# while datamode, write, access and control mode are unchanged
   assign dstaddr_inc[AW-1:0] = dstaddr[AW-1:0] + {{(AW-4){1'b0}},byte0_inc8,3'b000};

   assign dstaddr_in[31:28] = burst_tran ? dstaddr_inc[31:28] : fifo_data_reg[3:0];
   assign dstaddr_in[27:12] = burst_tran ? dstaddr_inc[27:12] : fifo_data_reg[2*LW-1:0];
   assign dstaddr_in[11:0]  = burst_tran ? dstaddr_inc[11:0]  : fifo_data_reg[2*LW-1:4];

   always @ (posedge rxi_lclk)
     if(fifo_data_val & (start_tran | burst_tran))
       dstaddr_int[31:28] <= dstaddr_in[31:28];

   always @ (posedge rxi_lclk)
     if(fifo_data_val & (dstaddr_2712_en | burst_tran))
       dstaddr_int[27:12] <= dstaddr_in[27:12];

   always @ (posedge rxi_lclk)
     if(fifo_data_val & (dstaddr_1100_en | burst_tran))
       dstaddr_int[11:0] <= dstaddr_in[11:0];
       
   //# data mode
   always @ (posedge rxi_lclk)
     if(fifo_data_val & datamode_en)
       datamode[1:0] <= fifo_data_reg[3:2];

   //# write
   always @ (posedge rxi_lclk)
     if(fifo_data_val & write_en)
       write <= fifo_data_reg[1];

   //# access
   always @ (posedge rxi_lclk)
     if(fifo_data_val & access_en)
       access <= fifo_data_reg[0];

   //# data
   always @ (posedge rxi_lclk)
     if(fifo_data_val & (data_3116_en | burst_tran))
       data[31:16] <= fifo_data_reg[2*LW-1:0];

   always @ (posedge rxi_lclk)
     if(fifo_data_val & data_1500_en)
       data[15:0] <= fifo_data_reg[2*LW-1:0];

   //# srcaddr
   always @ (posedge rxi_lclk)
     if(fifo_data_val & srcaddr_3116_en)
        srcaddr[31:16] <= fifo_data_reg[2*LW-1:0];

   always @ (posedge rxi_lclk)
     if(fifo_data_val & srcaddr_1500_en)
       srcaddr[15:0] <= fifo_data_reg[2*LW-1:0];
       

   //###################################################################
   //#            Order of the transaction fields in the fifo
   //#            -------------------------------------------
   //# Entry "n+6"                 srcaddr[15:0]
   //# Entry "n+5"		  srcaddr[31:16],
   //# Entry "n+4"                  data[15:0],
   //# Entry "n+3"                 data[31:16],
   //# Entry "n+2"  dstaddr[11:0],datamode[1:0],write,access,
   //# Entry "n+1"	          dstaddr[27:12],
   //# Entry "n"         byte0[7:0],ctrlmode[3:0],dstaddr[31:28],
   //#            --------------------------------------------
   //####################################################################

   assign dstaddr_2712_en  = (rxi_assemble_cnt[2:0] == 3'b001);
   assign dstaddr_1100_en  = (rxi_assemble_cnt[2:0] == 3'b010);
   assign datamode_en      = (rxi_assemble_cnt[2:0] == 3'b010);
   assign write_en         = (rxi_assemble_cnt[2:0] == 3'b010);
   assign access_en        = (rxi_assemble_cnt[2:0] == 3'b010);
   assign data_3116_en     = (rxi_assemble_cnt[2:0] == 3'b011);
   assign data_1500_en     = (rxi_assemble_cnt[2:0] == 3'b100);
   assign srcaddr_3116_en  = (rxi_assemble_cnt[2:0] == 3'b101);
   assign srcaddr_1500_en  = (rxi_assemble_cnt[2:0] == 3'b110);

   //# Assemble counter
   assign rxi_assemble_cnt_inc[2:0]  = rxi_assemble_cnt[2:0] + 3'b001;

   assign rxi_assemble_cnt_next[2:0] = burst_tran           ? 3'b100 :
				       tran_assembled       ? 3'b000 :
				       read_jump            ? 3'b101 :
				                              rxi_assemble_cnt_inc[2:0];
   always @ (posedge rxi_lclk or posedge reset)
     if (reset)
       rxi_assemble_cnt[2:0] <= 3'b000;
     else if(fifo_data_val)
       rxi_assemble_cnt[2:0] <= rxi_assemble_cnt_next[2:0];

   //# single write transaction completion
//   assign single_write = access & write & ~(&(datamode[1:0]));
   assign single_write = 1'b0; // no special treatment for single writes
   assign single_write_complete = single_write & (rxi_assemble_cnt[2:0] == 3'b100);

   //# read transaction "jumps" over data part of the counter
   //assign read_jump = ~fifo_data_reg[1] & (rxi_assemble_cnt[2:0] == 3'b010);
   //# read transaction "jump" feature is disabled because of the test-and-set inst
   assign read_jump = 1'b0;

   //# transaction completion
   assign rxi_assemble_cnt_max = (rxi_assemble_cnt[2:0] == 3'b110);
   assign tran_assembled = fifo_data_val & (single_write_complete | rxi_assemble_cnt_max);

   //# burst transaction detection
   assign burst_tran = (rxi_assemble_cnt[2:0] == 3'b000) & ~start_tran;

   //###########################################
   //# Secondary-FIFOs transaction distribution
   //###########################################

   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       rxi_cx_access <= 1'b0;
     else
       rxi_cx_access <= tran_assembled;

   assign rxi_c0_access   = (c0_match |  multicast_match) & rxi_cx_access;
   assign rxi_c1_access   = (c1_match & ~multicast_match) & rxi_cx_access;   
   assign rxi_c2_access   = (c2_match & ~multicast_match) & rxi_cx_access;   
   assign rxi_c3_access   = (c3_match & ~multicast_match) & rxi_cx_access;

   //# address preparation for comparison based on the links position (horiz or vert)
//   assign comp_addr[5:0]  = vertical_k ? {dstaddr[31:29],dstaddr[25:23]} : 
//                                         {dstaddr[28:26],dstaddr[22:20]} ;   
   assign comp_addr[5:0]  = vertical_k ? dstaddr[31:26] : dstaddr[25:20];   

//   assign chip_addr[2:0]   = vertical_k ?  ext_yid_k[2:0] : ext_xid_k[2:0];
   assign chip_addr[5:2] = vertical_k ?  ext_yid_k[3:0] : ext_xid_k[3:0];
   assign chip_addr[1:0] = 2'b11;
//   assign chip_addr_n[3:0] =~chip_addr[3:0];
   //# high comparison
//   assign {carry_high,comp_high[5:0]} = comp_addr[5:0] + {chip_addr_n[2:0],3'b101};
   assign {carry_high,comp_high[5:0]} = {1'b0,comp_addr[5:0]} - {1'b0,chip_addr[5:0]};
   //# channels matching
   assign c0_match =  carry_high; // chip addr is bigger
   assign c1_match =  (comp_addr[5:0] == {chip_addr[5:2],3'b01});//EQ   
   assign c2_match =  (comp_addr[5:0] == {chip_addr[5:2],3'b10});//EQ  
   assign c3_match = ~(c0_match | c1_match | c2_match);
   //# multicast tran detection
   assign multicast_match = write & 
			    (ctrlmode[1:0]==2'b11) & ~(datamode[1:0] == 2'b11);




endmodule // link_rxi_assembler
module link_rxi_buffer (/*AUTOARG*/
   // Outputs
   rxi_wait, rxi_assembled_tran, rxi_c0_access, rxi_c1_access,
   rxi_c2_access, rxi_c3_access,
   // Inputs
   reset, vertical_k, ext_yid_k, ext_xid_k, rxi_data, rxi_lclk,
   rxi_frame, rxi_rd, cfg_extcomp_dis, c0_fifo_full, c1_fifo_full,
   c2_fifo_full, c3_fifo_full
   );

   parameter LW   = `CFG_LW  ;//lvds tranceiver pairs per side
   parameter NC   = 32;// Number of cycles for save TXO-RXI "transaction interface"
   parameter FAD  = 5; // Number of bits to access all the entries (2^FAD + 1) > NC
   localparam MD = 1<<FAD;

   // #########
   // # INPUTS
   // #########

   input          reset;       //reset input
   input 	  vertical_k;  //specifies if block is vertical or horizontal
   input [3:0] 	  ext_yid_k;   //external y-id 
   input [3:0] 	  ext_xid_k;   //external x-id
   
   input [LW-1:0] rxi_data;      //Byte word
   input 	  rxi_lclk;      //receive clock (adjusted to the frame/data)
   input 	  rxi_frame;     //indicates new transmission
   
   input 	  rxi_rd;         // this is read transactions rxi_buffer
   input 	  cfg_extcomp_dis;// Disable external coordinates comparison
                                  // Every input transaction is received by the chip

   input 	  c0_fifo_full;
   input 	  c1_fifo_full;
   input 	  c2_fifo_full;
   input 	  c3_fifo_full;

   // ##########
   // # OUTPUTS
   // ##########

   output 	      rxi_wait;          //wait indicator   

   output [14*LW-1:0] rxi_assembled_tran; // data to be transferred to secondary fifos
   output             rxi_c0_access; //transfering to c0_fifo
   output 	      rxi_c1_access; //transfering to c1_fifo
   output 	      rxi_c2_access; //transfering to c2_fifo
   output 	      rxi_c3_access; //transfering to c3_fifo  
 
   /*AUTOINPUT*/
   /*AUTOWIRE*/

   // #########
   // # Regs
   // #########

   reg 		   rd_tran;
   reg [2*LW:0]    fifo_mem[MD-1:0];
   reg 		   frame_reg;
   reg 		   frame_reg_del;
   reg [LW-1:0]    data_even_reg;
   reg [LW-1:0]    data_odd_reg;
   reg [FAD:0] 	   wr_binary_pointer;
   reg [FAD:0] 	   rd_binary_pointer;
   reg 		   fifo_read;
   reg 		   rxi_wait;
   reg 		   start_tran;
   reg 		   fifo_data_val;
   reg [2*LW-1:0]  fifo_data_reg;

   // #########
   // # Wires
   // #########

   wire 	   my_tran;      // this transaction is dedicated to current rxi_buffer
   wire 	   new_tran;     // first cycle of the new transaction
   wire [2*LW:0]   fifo_data_in; // even and odd bytes combined into short words for fifo 
   wire [2*LW:0]   fifo_data_out;// output of the fifo
   wire [FAD:0]	   wr_binary_next; // next value of the write pointer
   wire [FAD:0]    rd_binary_next; // next value of the read pointer
   wire 	   fifo_write; // write into the fifo
   wire [FAD-1:0]  wr_addr; // write address of the fifo
   wire [FAD-1:0]  rd_addr; // read address of the fifo
   wire 	   fifo_empty; // indication of the empty fifo
   wire 	   stop_fifo_read; //one of the secondary fifos is full (stop reading)
   
   // ####################################################
   // #        Sample input transaction
   // # The positive edge FFs work all the time
   // # while the negative edge FFs can be disabled
   // # by the state of the detected frame (to save power)  
   // ####################################################     

   //# frame
   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       begin
	  frame_reg     <= 1'b0;
	  frame_reg_del <= 1'b0;
       end
     else
       begin
	  frame_reg     <= rxi_frame;
	  frame_reg_del <= frame_reg;
       end

   //# even bytes
   always @ (posedge rxi_lclk)
     data_even_reg[LW-1:0] <= rxi_data[LW-1:0];

   //# odd bytes
   always @ (negedge rxi_lclk)
     data_odd_reg[LW-1:0] <= rxi_data[LW-1:0];

   //##################################################
   //# We should differentiate between read and write
   //# transactions since link_rxi_buffer can accept
   //# the transactions of one type only.
   //# The indication of the type of the transaction
   //# is sent in the byte0 of the transaction.
   //##################################################

   assign my_tran = ~(rd_tran ^ rxi_rd);
   always @ (posedge rxi_lclk)
     if(~frame_reg)            //will stop sampling when byte0 is received
       rd_tran <= rxi_data[7];

   //# frame rising edge detection
   assign new_tran = my_tran & frame_reg & ~frame_reg_del;

   //# bytes packaging into short words + new transaction indication
   assign fifo_data_in[2*LW:0] = {new_tran,data_even_reg[LW-1:0],data_odd_reg[LW-1:0]};

   //###############################################################################
   //#          Wait indication to the transmitter
   //# When one of the secondary fifos becomes full we send wait indication 
   //# to the transmitter.
   //# There is some uncertainty regarding how long it will take for the wait 
   //# control to stop the transmitter (we have synchronization on the way, 
   //# which may cause +/-1 cycle of uncertainty).
   //# Our main fifo on the input port of the receiver is robust enough
   //# (has enough entries) to receive all of the transactions sent during the
   //# time of "wait traveling" without loosing any information.
   //# But the uncertainty mentioned above forces us to start from empty fifo
   //# every time after wait indication is raised in order to ensure that 
   //# the number of available entries won't be reduced.            
   //###############################################################################

   assign stop_fifo_read = c0_fifo_full | c1_fifo_full | c2_fifo_full | c3_fifo_full;

   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       rxi_wait <= 1'b0;
     else if(stop_fifo_read)
       rxi_wait <= 1'b1;
     else if(fifo_empty)
       rxi_wait <= 1'b0;

   //##################################
   //#   Input FIFO of the receiver
   //##################################

   always @ (posedge rxi_lclk)
     if (fifo_write)
       fifo_mem[wr_addr[FAD-1:0]] <= fifo_data_in[2*LW:0];

   //# Read from fifo
   assign fifo_data_out[2*LW:0] = fifo_mem[rd_addr[FAD-1:0]];

   //# Since the size of the FIFO is parametrized I prefer to sample the output
   //# data to prevent timing issues for the big number of entries (big mux on read)
   //# This shouldn't add any performance loss just latency increase

   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       start_tran  <= 1'b0;
     else if(fifo_read)
       start_tran  <= fifo_data_out[2*LW];
 
   always @ (posedge rxi_lclk)
     if(fifo_read)
       fifo_data_reg[2*LW-1:0] <= fifo_data_out[2*LW-1:0];

   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       fifo_data_val <= 1'b0;
     else
       fifo_data_val <= fifo_read;

   //#####################################################################
   //#                  FIFO Write State Machine
   //# !!!
   //# This FIFO will write the data in every time the FRAME IS HIGH and
   //# INDEPENDENT of the read out of the FIFO "frequency"
   //# !!!
   //# When the data cannot be read out of the FIFO, the indication will
   //# be sent to the transmitter to stop sending new transactions and the
   //# frame signal will be deasserted.
   //# The number of entries in the FIFO sould be big enough to receive
   //# all of the transactions sent by the transmitter in that case.
   //######################################################################

   assign fifo_write = my_tran & frame_reg;
   
   always @(posedge rxi_lclk or posedge reset)
     if(reset)
       wr_binary_pointer[FAD:0]     <= {(FAD+1){1'b0}};
     else if(fifo_write)
       wr_binary_pointer[FAD:0]     <= wr_binary_next[FAD:0];	  

   assign wr_addr[FAD-1:0]       = wr_binary_pointer[FAD-1:0];
   assign wr_binary_next[FAD:0]  = wr_binary_pointer[FAD:0] + {{(FAD){1'b0}},fifo_write};

   //#############################
   //# FIFO Read State Machine
   //#############################
   
   always @(posedge rxi_lclk or posedge reset)
     if(reset)
       fifo_read <= 1'b0;
     else
       fifo_read <= ~(fifo_empty | stop_fifo_read);

   always @(posedge rxi_lclk or posedge reset)
     if(reset)
       rd_binary_pointer[FAD:0]  <= {(FAD+1){1'b0}};
     else if(fifo_read)
       rd_binary_pointer[FAD:0]  <= rd_binary_next[FAD:0];	  

   assign rd_addr[FAD-1:0]       = rd_binary_pointer[FAD-1:0];
   assign rd_binary_next[FAD:0]  = rd_binary_pointer[FAD:0] + {{(FAD){1'b0}},fifo_read};

   assign fifo_empty = (rd_binary_next[FAD:0] == wr_binary_next[FAD:0]);

   //########################################
   //# Transaction assembly and distribution
   //########################################

   link_rxi_assembler link_rxi_assembler(/*AUTOINST*/
					 // Outputs
					 .rxi_assembled_tran	(rxi_assembled_tran[14*LW-1:0]),
					 .rxi_c0_access		(rxi_c0_access),
					 .rxi_c1_access		(rxi_c1_access),
					 .rxi_c2_access		(rxi_c2_access),
					 .rxi_c3_access		(rxi_c3_access),
					 // Inputs
					 .reset			(reset),
					 .rxi_lclk		(rxi_lclk),
					 .vertical_k		(vertical_k),
					 .ext_yid_k		(ext_yid_k[3:0]),
					 .ext_xid_k		(ext_xid_k[3:0]),
					 .fifo_data_reg		(fifo_data_reg[2*LW-1:0]),
					 .fifo_data_val		(fifo_data_val),
					 .start_tran		(start_tran),
					 .cfg_extcomp_dis	(cfg_extcomp_dis));

   
endmodule // link_rxi_buffer
module link_rxi_channel (/*AUTOARG*/
   // Outputs
   fifo_full_rlc, rdmesh_tran_out, rdmesh_frame_out,
   // Inputs
   reset, cclk, cclk_en, rxi_lclk, cfg_extcomp_dis,
   rxi_assembled_tran_rlc, fifo_access_rlc, rdmesh_wait_in
   );

   parameter LW    = `CFG_LW;//lvds tranceiver pairs per side
   
   //#########
   //# INPUTS
   //#########

   input             reset;   //reset input
   input 	     cclk;    //core clock
   input 	     cclk_en; // clock enable 
   input 	     rxi_lclk;//receiver link clock
   input 	     cfg_extcomp_dis;// Disable external coordinates comparison
                                     // Every input transaction is received by the chip

   input [14*LW-1:0] rxi_assembled_tran_rlc; // assembled data from the main fifo
   input 	     fifo_access_rlc;        // fifo is accessed

   input 	     rdmesh_wait_in; //wait indication from rdmesh
  
   //##########
   //# OUTPUTS
   //##########
   output 	  fifo_full_rlc;//fifo full push back indicator

   //# transaction to rdmesh
   output [2*LW-1:0] rdmesh_tran_out;  // transaction data
   output 	     rdmesh_frame_out; // core frame

   /*AUTOINPUT*/
   /*AUTOWIRE*/

  

endmodule // link_rxi_channel
module link_rxi_ctrl(/*AUTOARG*/
   // Outputs
   lclk,
   // Inputs
   io_lclk, rxi_cfg_reg
   );

   parameter DW = `CFG_DW;
   
   
   //Input clock
   input           io_lclk;    //link clock from IO
   input [DW-1:0]  rxi_cfg_reg;//used to deskew clock input

   //Should we have a monitor pin for locking the timing?
   
   
   //Delay Control word
   //1 for rise
   //1 for fall
   
   ///Output clocks to reciever block
  
   output  lclk;   //buffered clock without delay
   


   //Need to insert delay elements here
   //How to insert delay with cts?
   
   assign lclk   =  io_lclk;
  
   
   
endmodule // link_clock


//#############################################
//# This block is a "common" channel for both
//# mesh (multicast) and emesh transactions
//#############################################
module link_rxi_double_channel (/*AUTOARG*/
   // Outputs
   fifo_full_rlc, emesh_tran_out, emesh_frame_out, mesh_access_out,
   mesh_write_out, mesh_dstaddr_out, mesh_srcaddr_out, mesh_data_out,
   mesh_datamode_out, mesh_ctrlmode_out,
   // Inputs
   reset, cclk, cclk_en, ext_yid_k, ext_xid_k, rxi_lclk, who_am_i,
   cfg_extcomp_dis, rxi_assembled_tran_rlc, fifo_access_rlc,
   emesh_wait_in, mesh_wait_in
   );

   parameter LW   = `CFG_LW;//lvds tranceiver pairs per side
   parameter DW   = `CFG_DW;//data width  
   parameter AW   = `CFG_AW;//address width
  
   //#########
   //# INPUTS
   //#########

   input             reset;   //reset input
   input 	     cclk;    //core clock
   input 	     cclk_en; // clock enable 
   input [3:0] 	     ext_yid_k;//external y-id 
   input [3:0] 	     ext_xid_k;//external x-id
   input 	     rxi_lclk;//receiver link clock
   input [3:0] 	     who_am_i;// specifies what link is that (north,east,south,west)
   input 	     cfg_extcomp_dis;// Disable external coordinates comparison
                                     // Every input transaction is received by the chip

   input [14*LW-1:0] rxi_assembled_tran_rlc; // assembled data from the main fifo
   input 	     fifo_access_rlc;  // fifo is accessed 

   input 	     emesh_wait_in; //wait indication from emesh
   input 	     mesh_wait_in;  //wait indication from mesh

   //##########
   //# OUTPUTS
   //##########
   output 	     fifo_full_rlc;//fifo full push back indicator

   //# transaction to the emesh (transactions coming out off the chip)
   output [2*LW-1:0] emesh_tran_out;  // transaction data
   output 	     emesh_frame_out; // core frame

   //# transaction to the mesh 
   output 	     mesh_access_out;  // access control to the mesh
   output 	     mesh_write_out;   // write control to the mesh
   output [AW-1:0]   mesh_dstaddr_out; // destination address to the mesh
   output [AW-1:0]   mesh_srcaddr_out; // source address to the mesh
   output [DW-1:0]   mesh_data_out;    // data to the mesh
   output [1:0]      mesh_datamode_out;// data mode to the mesh 
   output [3:0]      mesh_ctrlmode_out;// ctrl mode to the mesh

   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			access;			// From link_rxi_mesh_launcher of link_rxi_mesh_launcher.v
   wire [3:0]		ctrlmode;		// From link_rxi_mesh_launcher of link_rxi_mesh_launcher.v
   wire [DW-1:0]	data;			// From link_rxi_mesh_launcher of link_rxi_mesh_launcher.v
   wire [1:0]		datamode;		// From link_rxi_mesh_launcher of link_rxi_mesh_launcher.v
   wire [AW-1:0]	dstaddr;		// From link_rxi_mesh_launcher of link_rxi_mesh_launcher.v
   wire			emesh_tran_dis;		// From link_rxi_mesh_launcher of link_rxi_mesh_launcher.v
   wire			fifo_empty;		// From link_rxi_fifo of link_rxi_fifo.v
   wire [14*LW-1:0]	fifo_tran_out;		// From link_rxi_fifo of link_rxi_fifo.v
   wire			mesh_fifo_read;		// From link_rxi_mesh_launcher of link_rxi_mesh_launcher.v
   wire [AW-1:0]	srcaddr;		// From link_rxi_mesh_launcher of link_rxi_mesh_launcher.v
   wire			write;			// From link_rxi_mesh_launcher of link_rxi_mesh_launcher.v
   // End of automatics

   // #########
   // # WIRES
   // #########
   wire     fifo_read;
   wire     emesh_fifo_empty;

   //#########
   //# FIFO
   //#########
   assign fifo_read       = mesh_fifo_read;
                         
   link_rxi_fifo link_rxi_fifo (/*AUTOINST*/
				// Outputs
				.fifo_full_rlc	(fifo_full_rlc),
				.fifo_tran_out	(fifo_tran_out[14*LW-1:0]),
				.fifo_empty	(fifo_empty),
				// Inputs
				.reset		(reset),
				.cclk		(cclk),
				.cclk_en	(cclk_en),
				.rxi_lclk	(rxi_lclk),
				.rxi_assembled_tran_rlc(rxi_assembled_tran_rlc[14*LW-1:0]),
				.fifo_access_rlc(fifo_access_rlc),
				.fifo_read	(fifo_read));

  
   //###################################
   //# Transaction Launcher to Mesh
   //###################################

   link_rxi_mesh_launcher link_rxi_mesh_launcher(/*AUTOINST*/
						 // Outputs
						 .mesh_fifo_read	(mesh_fifo_read),
						 .emesh_tran_dis	(emesh_tran_dis),
						 .access		(access),
						 .write			(write),
						 .datamode		(datamode[1:0]),
						 .ctrlmode		(ctrlmode[3:0]),
						 .data			(data[DW-1:0]),
						 .dstaddr		(dstaddr[AW-1:0]),
						 .srcaddr		(srcaddr[AW-1:0]),
						 // Inputs
						 .ext_yid_k		(ext_yid_k[3:0]),
						 .ext_xid_k		(ext_xid_k[3:0]),
						 .who_am_i		(who_am_i[3:0]),
						 .cfg_extcomp_dis	(cfg_extcomp_dis),
						 .fifo_tran_out		(fifo_tran_out[14*LW-1:0]),
						 .fifo_empty		(fifo_empty),
						 .mesh_wait_in		(mesh_wait_in));

 

   //##################################
   //#    Interface with mesh
   //# on output transactions only
   //# * input from the mesh is driven
   //# by a diferent block
   //##################################

   /* e16_mesh_interface AUTO_TEMPLATE (
                                    .clk               (cclk),
                                    .clk_en            (cclk_en),
 				    .access_in	       (1'b0),
				    .write_in	       (1'b0),
				    .datamode_in       (2'b00),
				    .ctrlmode_in       (4'b0000),
				    .data_in	       ({(DW){1'b0}}),
				    .dstaddr_in	       ({(AW){1'b0}}),
				    .srcaddr_in	       ({(AW){1'b0}}),
                                    .wait_int          (1'b0),
				    .emesh_core_wait   (1'b0),
				    .emesh_core_clk_en ({(11){1'b1}}),
				    .emesh_tran_sel    (1'b0),
                                    .wait_in           (mesh_wait_in),
                                    .\(.*\)_reg        (),
                                    .wait_out          (),
                                    .\(.*\)_out        (mesh_\1_out[]),
                                );
    */
   e16_mesh_interface mesh_interface(/*AUTOINST*/
				     // Outputs
				     .wait_out		(),		 // Templated
				     .access_out	(mesh_access_out), // Templated
				     .write_out		(mesh_write_out), // Templated
				     .datamode_out	(mesh_datamode_out[1:0]), // Templated
				     .ctrlmode_out	(mesh_ctrlmode_out[3:0]), // Templated
				     .data_out		(mesh_data_out[DW-1:0]), // Templated
				     .dstaddr_out	(mesh_dstaddr_out[AW-1:0]), // Templated
				     .srcaddr_out	(mesh_srcaddr_out[AW-1:0]), // Templated
				     .access_reg	(),		 // Templated
				     .write_reg		(),		 // Templated
				     .datamode_reg	(),		 // Templated
				     .ctrlmode_reg	(),		 // Templated
				     .data_reg		(),		 // Templated
				     .dstaddr_reg	(),		 // Templated
				     .srcaddr_reg	(),		 // Templated
				     // Inputs
				     .clk		(cclk),		 // Templated
				     .clk_en		(cclk_en),	 // Templated
				     .reset		(reset),
				     .wait_in		(mesh_wait_in),	 // Templated
				     .access_in		(1'b0),		 // Templated
				     .write_in		(1'b0),		 // Templated
				     .datamode_in	(2'b00),	 // Templated
				     .ctrlmode_in	(4'b0000),	 // Templated
				     .data_in		({(DW){1'b0}}),	 // Templated
				     .dstaddr_in	({(AW){1'b0}}),	 // Templated
				     .srcaddr_in	({(AW){1'b0}}),	 // Templated
				     .wait_int		(1'b0),		 // Templated
				     .access		(access),
				     .write		(write),
				     .datamode		(datamode[1:0]),
				     .ctrlmode		(ctrlmode[3:0]),
				     .data		(data[DW-1:0]),
				     .dstaddr		(dstaddr[AW-1:0]),
				     .srcaddr		(srcaddr[AW-1:0]));


endmodule // link_rxi_double_channel

//##############################################################################
//# 
//# This is a FOUR entries (FAD=2) receiver FIFO with the main function of
//# synchronization between RXI link clock domain and core clock domain
//# It seems that for the FIFO to function without "build in" push back
//# we will need at least THREE entries, so choosing FOUR entries puts us
//# in a safer position.
//#
//# * This FIFO will function even with a single entry (with some modifications)
//#   but if the number of entries is not sufficient for the synchronization
//#   the "build in" push back will be driven on every new write control.
//#
//################################################################################
 
module link_rxi_fifo (/*AUTOARG*/
   // Outputs
   fifo_full_rlc, fifo_tran_out, fifo_empty,
   // Inputs
   reset, cclk, cclk_en, rxi_lclk, rxi_assembled_tran_rlc,
   fifo_access_rlc, fifo_read
   );

   parameter LW    = `CFG_LW;//lvds tranceiver pairs per side
   parameter FAD   = 2; // Number of bits to access all the entries 
   localparam MD = 1<<FAD;
   
   //#########
   //# INPUTS
   //#########

   input          reset;   //reset input
   input 	  cclk;    //core clock
   input 	  cclk_en; // clock enable 
   input 	  rxi_lclk;//receiver link clock

   input [14*LW-1:0] rxi_assembled_tran_rlc; // assembled data from the main fifo
   input 	     fifo_access_rlc;        // fifo is accessed
   //# from the launcher
   input 	     fifo_read;
   //##########
   //# OUTPUTS
   //##########

   output 	     fifo_full_rlc;//fifo full push back indicator
   //# to the launcher
   output [14*LW-1:0] fifo_tran_out;
   output 	      fifo_empty;

   //##########
   //# REGS
   //##########

   reg [14*LW-1:0] fifo_mem[MD-1:0];
   reg [FAD:0] 	   wr_binary_pointer_rlc;
   reg [FAD:0] 	   wr_gray_pointer_rlc;
   reg 		   fifo_full_rlc;

   reg [FAD:0] 	   rd_binary_pointer;
   reg [FAD:0] 	   rd_gray_pointer;
   reg 		   fifo_empty;

   //#########
   //# WIRES
   //#########

   wire 	      wr_write_rlc; // FIFO write control
   wire [FAD-1:0]     wr_addr_rlc;
   wire [FAD:0]       wr_binary_next_rlc;
   wire [FAD:0]       wr_gray_next_rlc;
   wire 	      fifo_full_next_rlc;
   wire [FAD:0]       rd_gray_pointer_rlc;

   wire [FAD-1:0]     rd_addr;
   wire [FAD:0]       rd_binary_next;
   wire [FAD:0]       rd_gray_next;
   wire 	      fifo_empty_next;
   wire [FAD:0]       wr_gray_pointer;

   /*AUTOWIRE*/
   /*AUTOINPUT*/
  
   //##################################################################
   //#              Write control generation:
   //#
   //# FIFO is being written according to the state of fifo_access_rlc
   //# control driven by main fifo and independent on the current
   //# state of the FIFO.
   //# We do mask this control with fifo full signal but this mask
   //# is really redundant.
   //# The reason for that is the following:
   //# The FASTEST THROUGHPUT the transaction can be dispatched from
   //# the main fifo here is ONE TRANSACTION IN EVERY FOUR CYCLES.
   //# FIFO full indication is sent back on the first cycle after
   //# receiving the transaction causing the fifo to be full.
   //# This indication is sampled two more times in the main fifo
   //# and then prevents new transaction to be dispatched.
   //# So it takes THREE CYCLES to stop new transaction versus
   //# FOUR CYCLES to dispatch new one and therefore we are save.
   //####################################################################
   
   assign wr_write_rlc = fifo_access_rlc & ~fifo_full_rlc;

   //#################################
   //# FIFO data
   //#################################
 
   //# Write
   always @ (posedge rxi_lclk)
     if (wr_write_rlc)
       fifo_mem[wr_addr_rlc[FAD-1:0]] <= rxi_assembled_tran_rlc[14*LW-1:0];
   
   //# Read (for dispatch)
   assign fifo_tran_out[14*LW-1:0] = fifo_mem[rd_addr[FAD-1:0]];

   //#####################################
   //# FIFO Write State Machine
   //#####################################

   //# While for the actual address calculation we use [FAD-1:0] bits only,
   //# the bit FAD of the counter is needed in order to distinguish
   //# between the fifo entry currently being written and the one
   //# written in the previous "round" (FAD is a carry-out bit and is
   //# switched every "round")
   always @(posedge rxi_lclk or posedge reset)
     if(reset)
       begin
	  wr_binary_pointer_rlc[FAD:0] <= {(FAD+1){1'b0}};
	  wr_gray_pointer_rlc[FAD:0]   <= {(FAD+1){1'b0}};
       end
     else if(wr_write_rlc)
       begin
	  wr_binary_pointer_rlc[FAD:0] <= wr_binary_next_rlc[FAD:0];	  
	  wr_gray_pointer_rlc[FAD:0]   <= wr_gray_next_rlc[FAD:0];	  
       end	  

   assign wr_addr_rlc[FAD-1:0]       = wr_binary_pointer_rlc[FAD-1:0];
   assign wr_binary_next_rlc[FAD:0]  = wr_binary_pointer_rlc[FAD:0] + 
				       {{(FAD){1'b0}},wr_write_rlc};

   //# Gray Pointer Conversion (for more reliable synchronization)!
   assign wr_gray_next_rlc[FAD:0] = {1'b0,wr_binary_next_rlc[FAD:1]} ^ 
				    wr_binary_next_rlc[FAD:0];

   //# FIFO full indication
   assign fifo_full_next_rlc = 
			   (wr_gray_next_rlc[FAD-2:0] == rd_gray_pointer_rlc[FAD-2:0]) &
                           (wr_gray_next_rlc[FAD]     ^  rd_gray_pointer_rlc[FAD])     &
                           (wr_gray_next_rlc[FAD-1]   ^  rd_gray_pointer_rlc[FAD-1]);
			      
   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       fifo_full_rlc <= 1'b0;
     else 
       fifo_full_rlc <= fifo_full_next_rlc;

   //#############################
   //# FIFO Read State Machine
   //#############################
    
   always @(posedge cclk or posedge reset)
     if(reset)
       begin
	  rd_binary_pointer[FAD:0]  <= {(FAD+1){1'b0}};
	  rd_gray_pointer[FAD:0]    <= {(FAD+1){1'b0}};
       end
     else if(cclk_en)
       if(fifo_read)
	 begin
	    rd_binary_pointer[FAD:0]  <= rd_binary_next[FAD:0];	  
	    rd_gray_pointer[FAD:0]    <= rd_gray_next[FAD:0];	  
	 end

   assign rd_addr[FAD-1:0]       = rd_binary_pointer[FAD-1:0];
   assign rd_binary_next[FAD:0]  = rd_binary_pointer[FAD:0] + {{(FAD){1'b0}},fifo_read};

   //# Gray Pointer Conversion (for more reliable synchronization)!
   assign rd_gray_next[FAD:0]  = {1'b0,rd_binary_next[FAD:1]} ^ rd_binary_next[FAD:0];

   //# FIFO empty indication
   assign fifo_empty_next = (rd_gray_next[FAD:0]==wr_gray_pointer[FAD:0]);

   always @ (posedge cclk or posedge reset)
     if(reset)
       fifo_empty <= 1'b1;
     else if(cclk_en)
       fifo_empty <= fifo_empty_next;

   //####################################################
   //# Synchronization between rd/wr domains
   //####################################################

   e16_synchronizer #(.DW(FAD+1)) sync_rd2wr (.out	 (rd_gray_pointer_rlc[FAD:0]), 
                                          .in	 (rd_gray_pointer[FAD:0]), 
					  .clk	 (rxi_lclk),
					  .reset (reset));
   
   e16_synchronizer #(.DW(FAD+1)) sync_wr2rd (.out	 (wr_gray_pointer[FAD:0]), 
                                          .in	 (wr_gray_pointer_rlc[FAD:0]), 
					  .clk	 (cclk),
					  .reset (reset));
 


endmodule // link_rxi_fifo
module link_rxi_launcher (/*AUTOARG*/
   // Outputs
   fifo_read, emesh_tran, emesh_frame,
   // Inputs
   reset, cclk, cclk_en, fifo_tran_out, fifo_empty, emesh_wait_in
   );

   parameter LW   = `CFG_LW;//lvds tranceiver pairs per side
   
   //#########
   //# INPUTS
   //#########

   input             reset;   // reset input
   input 	     cclk;    // core clock
   input 	     cclk_en; // clock enable 

   //# from the fifo
   input [14*LW-1:0] fifo_tran_out; // transaction out of the fifo
   input 	     fifo_empty;    // fifo is empty
   //# from the emesh
   input 	     emesh_wait_in; // emesh wait indication 
 
   //##########
   //# OUTPUTS
   //##########
   //# to the fifo
   output 	     fifo_read; // read next entry
   //# to the emesh
   output [2*LW-1:0] emesh_tran;  // transaction data
   output 	     emesh_frame; // emesh frame 

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   // #########
   // # REGS
   // #########

   reg [2:0]  launch_pointer;

   // #########
   // # WIRES
   // #########

   wire       last_tran;
   wire [2:0] launch_pointer_incr;
   wire [6:0] launch_sel;

   //################################
   //# next transaction read control
   //################################

   assign fifo_read = last_tran & ~emesh_wait_in;

   //############################################
   //# transaction launcher state machine
   //############################################
   assign last_tran = (launch_pointer[2:0] == 3'b110);
                        
   assign launch_pointer_incr[2:0] = last_tran ? 3'b000 : (launch_pointer[2:0] + 3'b001);

   always @ (posedge cclk or posedge reset)
     if(reset)
       launch_pointer[2:0] <= 3'b000;
     else if(cclk_en)
       if (~(fifo_empty | emesh_wait_in))
	 launch_pointer[2:0] <= launch_pointer_incr[2:0];

   assign launch_sel[0] = (launch_pointer[2:0] == 3'b000);
   assign launch_sel[1] = (launch_pointer[2:0] == 3'b001);
   assign launch_sel[2] = (launch_pointer[2:0] == 3'b010);
   assign launch_sel[3] = (launch_pointer[2:0] == 3'b011);
   assign launch_sel[4] = (launch_pointer[2:0] == 3'b100);
   assign launch_sel[5] = (launch_pointer[2:0] == 3'b101);
   assign launch_sel[6] = (launch_pointer[2:0] == 3'b110);

   //###########################
   //# frame and data selection
   //###########################
   
   assign emesh_frame  =  ~(fifo_empty | last_tran);

   e16_mux7 #(2*LW) mux7(// Outputs
		     .out (emesh_tran[2*LW-1:0]),
		     // Inputs
		     .in0 (fifo_tran_out[2*LW-1:0]),      .sel0 (launch_sel[0]),
		     .in1 (fifo_tran_out[4*LW-1:2*LW]),   .sel1 (launch_sel[1]),
		     .in2 (fifo_tran_out[6*LW-1:4*LW]),   .sel2 (launch_sel[2]),
		     .in3 (fifo_tran_out[8*LW-1:6*LW]),   .sel3 (launch_sel[3]),
		     .in4 (fifo_tran_out[10*LW-1:8*LW]),  .sel4 (launch_sel[4]),
		     .in5 (fifo_tran_out[12*LW-1:10*LW]), .sel5 (launch_sel[5]),
		     .in6 (fifo_tran_out[14*LW-1:12*LW]), .sel6 (launch_sel[6]));

endmodule // link_rxi_launcher
module link_rxi_mesh_launcher (/*AUTOARG*/
   // Outputs
   mesh_fifo_read, emesh_tran_dis, access, write, datamode, ctrlmode,
   data, dstaddr, srcaddr,
   // Inputs
   ext_yid_k, ext_xid_k, who_am_i, cfg_extcomp_dis, fifo_tran_out,
   fifo_empty, mesh_wait_in
   );

   parameter AW   = `CFG_AW  ;//address width
   parameter DW   = `CFG_DW  ;//data width  
   parameter LW   = `CFG_LW  ;//lvds tranceiver pairs per side

   //#########
   //# INPUTS
   //#########

   input [3:0] 	     ext_yid_k;//external y-id 
   input [3:0] 	     ext_xid_k;//external x-id
   input [3:0] 	     who_am_i;// specifies what link is that (north,east,south,west)
   input 	     cfg_extcomp_dis;// Disable external coordinates comparison
                                     // Every input transaction is received by the chip
   //# from the fifo
   input [14*LW-1:0] fifo_tran_out; // transaction out of the fifo
   input 	     fifo_empty;    // fifo is empty
   //# from the mesh
   input 	     mesh_wait_in; // wait indication from mesh

   //##########
   //# OUTPUTS
   //##########
   //# to the fifo
   output 	     mesh_fifo_read; // read next entry
   //# to prevent emesh launch
   output 	     emesh_tran_dis;
   //# to the mesh
   output 	     access;
   output 	     write;
   output [1:0]      datamode;
   output [3:0]      ctrlmode;   		    
   output [DW-1:0]   data;
   output [AW-1:0]   dstaddr;
   output [AW-1:0]   srcaddr;   

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   // #########
   // # WIRES
   // #########
   wire [AW-1:0] srcaddr_int;
   wire [AW-1:0] srcaddr_multicast;
   wire 	 access_int;
   wire 	 multicast_match;

   wire [1:0] 	 srcaddr_int_ycoord;
   wire [1:0] 	 srcaddr_int_xcoord;

   wire [1:0] 	 north_srcaddr_int_ycoord;
   wire [1:0] 	 north_srcaddr_int_xcoord;
   wire [1:0] 	 east_srcaddr_int_ycoord;
   wire [1:0] 	 east_srcaddr_int_xcoord;
   wire [1:0] 	 south_srcaddr_int_ycoord;
   wire [1:0] 	 south_srcaddr_int_xcoord;
   wire [1:0] 	 west_srcaddr_int_ycoord;
   wire [1:0] 	 west_srcaddr_int_xcoord;

   wire [3:0] 	 dst_y_k;
   wire [3:0] 	 dst_x_k;
   wire 	 west_east_corner_tran;
   wire 	 north_south_corner_tran;
   wire [3:0] 	 corner_tran;
   wire 	 corner_tran_match;
   wire 	 mesh_tran_match;

   //# If valid mesh transaction is detected we should prevent the launch
   //# of this transaction on the emesh
   assign emesh_tran_dis = access;

   //# Valid mesh (multicast or not) transaction
   assign access = ~fifo_empty & access_int & 
		   (corner_tran_match | multicast_match | mesh_tran_match);

   //# Read next entry
   assign mesh_fifo_read = access & ~mesh_wait_in;

   //# Mesh transaction fields extraction
   assign ctrlmode[3:0]   =  fifo_tran_out[2*LW-1:2*LW-4];

   assign dstaddr[AW-1:0] = {fifo_tran_out[2*LW-5:0],
                             fifo_tran_out[4*LW-1:2*LW],
                             fifo_tran_out[6*LW-1:6*LW-4]};

   assign datamode[1:0]   =  fifo_tran_out[6*LW-5:6*LW-6];
   assign write           =  fifo_tran_out[6*LW-7]; 
   assign access_int      =  fifo_tran_out[5*LW]; 

   assign data[DW-1:0]    = {fifo_tran_out[5*LW-1:4*LW],
                             fifo_tran_out[8*LW-1:6*LW],
                             fifo_tran_out[10*LW-1:9*LW]};

   assign srcaddr_int[AW-1:0] = {fifo_tran_out[9*LW-1:8*LW],
                                 fifo_tran_out[12*LW-1:10*LW],
                                 fifo_tran_out[14*LW-1:13*LW]};

   //# Multicast transaction (there is no multicast transaction when no external compare)
   assign multicast_match = write & ~cfg_extcomp_dis &
			    (ctrlmode[1:0]==2'b11) & ~(datamode[1:0] == 2'b11);

   //# We rewrite the internal coordinates of every multicast transaction
   //# in the way it will propagate through all the scores in the system
   //# The new internal coordinates will be those of the attached to the
   //# current link score and are constant and different for every link
   //# !!! Since the transaction will propagate in all directions out of the
   //# !!! attached score, it will try to get out of the chip on the same
   //# !!! link, but it won't happen due to the external coordinate comparison
   //# !!! of the link transmitter.

   assign north_srcaddr_int_ycoord[1:0] = 2'b00;
   assign east_srcaddr_int_ycoord[1:0]  = 2'b00;
   assign south_srcaddr_int_ycoord[1:0] = 2'b11;
   assign west_srcaddr_int_ycoord[1:0]  = 2'b00;

   assign north_srcaddr_int_xcoord[1:0] = 2'b00;
   assign east_srcaddr_int_xcoord[1:0]  = 2'b11;
   assign south_srcaddr_int_xcoord[1:0] = 2'b00;
   assign west_srcaddr_int_xcoord[1:0]  = 2'b00;

   assign srcaddr_int_ycoord[1:0] = {(2){who_am_i[3]}} & north_srcaddr_int_ycoord[1:0]|
				    {(2){who_am_i[2]}} & east_srcaddr_int_ycoord[1:0] |
				    {(2){who_am_i[1]}} & south_srcaddr_int_ycoord[1:0]|
				    {(2){who_am_i[0]}} & west_srcaddr_int_ycoord[1:0];

   assign srcaddr_int_xcoord[1:0] = {(2){who_am_i[3]}} & north_srcaddr_int_xcoord[1:0]|
				    {(2){who_am_i[2]}} & east_srcaddr_int_xcoord[1:0] |
				    {(2){who_am_i[1]}} & south_srcaddr_int_xcoord[1:0]|
				    {(2){who_am_i[0]}} & west_srcaddr_int_xcoord[1:0];

   //# Modified source address
   //assign srcaddr_multicast[AW-1:0] = {srcaddr_int[31:26],1'b0,srcaddr_int_ycoord[1:0],
   //				                1'b0,srcaddr_int_xcoord[1:0],
   //                                    srcaddr_int[19:0]};

   assign srcaddr_multicast[AW-1:0] = {srcaddr_int[31:28],srcaddr_int_ycoord[1:0],
             		               srcaddr_int[25:22],srcaddr_int_xcoord[1:0],
                                       srcaddr_int[19:0]};

   assign srcaddr[AW-1:0] = multicast_match ? srcaddr_multicast[AW-1:0] : 
			                      srcaddr_int[AW-1:0];

   //# Mesh transaction for external corners detection
//   assign dst_y_k[2:0] = dstaddr[31:29];
//   assign dst_x_k[2:0] = dstaddr[28:26];
   assign dst_y_k[3:0] = dstaddr[31:28];
   assign dst_x_k[3:0] = dstaddr[25:22];

   assign west_east_corner_tran = ((dst_x_k[3:0] == ext_xid_k[3:0]) &
				  ~(dst_y_k[3:0] == ext_yid_k[3:0]));

   assign north_south_corner_tran = (~(dst_x_k[3:0] == ext_xid_k[3:0]) &
				      (dst_y_k[3:0] == ext_yid_k[3:0]));

   assign corner_tran[3:0] = {north_south_corner_tran, west_east_corner_tran,
                              north_south_corner_tran, west_east_corner_tran};

   assign corner_tran_match = ~cfg_extcomp_dis & (|(corner_tran[3:0] & who_am_i[3:0]));
   //# Regular Mesh transaction
   assign mesh_tran_match = cfg_extcomp_dis | 
			    (~multicast_match & ((dst_x_k[3:0] == ext_xid_k[3:0]) &
			                         (dst_y_k[3:0] == ext_yid_k[3:0])));

endmodule // link_rxi_mesh_launcher
//#############################################################
//# This block is a receiver of the read transactions only
//# Read transactions will enter the chip on rdmesh only
//#############################################################
module link_rxi_rd (/*AUTOARG*/
   // Outputs
   rxi_rd_wait, c0_rdmesh_frame_out, c0_rdmesh_tran_out,
   c1_rdmesh_frame_out, c1_rdmesh_tran_out, c2_rdmesh_frame_out,
   c2_rdmesh_tran_out, c3_rdmesh_frame_out, c3_rdmesh_tran_out,
   // Inputs
   reset, ext_yid_k, ext_xid_k, vertical_k, who_am_i, cfg_extcomp_dis,
   rxi_data, rxi_lclk, rxi_frame, c0_clk_in, c1_clk_in, c2_clk_in,
   c3_clk_in, c0_rdmesh_wait_in, c1_rdmesh_wait_in, c2_rdmesh_wait_in,
   c3_rdmesh_wait_in, c0_fifo_full_rlc, c1_fifo_full_rlc,
   c2_fifo_full_rlc, c3_fifo_full_rlc
   );

   parameter LW   = `CFG_LW;//lvds tranceiver pairs per side
		     
   // #########
   // # Inputs
   // #########

   input             reset;     // reset input
   input [3:0] 	     ext_yid_k; // external y-id 
   input [3:0] 	     ext_xid_k; // external x-id
   input             vertical_k;// specifies if block is vertical or horizontal
   input [3:0] 	     who_am_i;  // specifies what link is that (north,east,south,west)
   input 	     cfg_extcomp_dis;// Disable external coordinates comparison
                                     // Every input transaction is received by the chip
  
   input [LW-1:0]    rxi_data;  // Byte word
   input             rxi_lclk;  // receive clock (adjusted to the frame/data)
   input             rxi_frame; // indicates new transmission

   // # Sync clocks
   input             c0_clk_in; // clock of the core
   input             c1_clk_in; // clock of the core
   input             c2_clk_in; // clock of the core
   input             c3_clk_in; // clock of the core

   // # Wait indicators
   input             c0_rdmesh_wait_in; // wait
   input             c1_rdmesh_wait_in; // wait
   input             c2_rdmesh_wait_in; // wait
   input             c3_rdmesh_wait_in; // wait

   // ##########
   // # Outputs
   // ##########

   output 	     rxi_rd_wait;  //wait indicator for read transactions 

   // # RDMESH (any read transaction)
   output            c0_rdmesh_frame_out; // transaction frame
   output [2*LW-1:0] c0_rdmesh_tran_out;  // serialized transaction
   output            c1_rdmesh_frame_out; // transaction frame
   output [2*LW-1:0] c1_rdmesh_tran_out;  // serialized transaction
   output            c2_rdmesh_frame_out; // transaction frame
   output [2*LW-1:0] c2_rdmesh_tran_out;  // serialized transaction
   output            c3_rdmesh_frame_out; // transaction frame
   output [2*LW-1:0] c3_rdmesh_tran_out;  // serialized transaction

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		c0_fifo_full_rlc;	// To link_rxi_buffer of link_rxi_buffer.v
   input		c1_fifo_full_rlc;	// To link_rxi_buffer of link_rxi_buffer.v
   input		c2_fifo_full_rlc;	// To link_rxi_buffer of link_rxi_buffer.v
   input		c3_fifo_full_rlc;	// To link_rxi_buffer of link_rxi_buffer.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			c0_fifo_access_rlc;	// From link_rxi_buffer of link_rxi_buffer.v
   wire			c1_fifo_access_rlc;	// From link_rxi_buffer of link_rxi_buffer.v
   wire			c2_fifo_access_rlc;	// From link_rxi_buffer of link_rxi_buffer.v
   wire			c3_fifo_access_rlc;	// From link_rxi_buffer of link_rxi_buffer.v
   wire [14*LW-1:0]	rxi_assembled_tran_rlc;	// From link_rxi_buffer of link_rxi_buffer.v
   // End of automatics

   // ################################
   // # Receiver buffer instantiation
   // ################################

   /*link_rxi_buffer AUTO_TEMPLATE (.rxi_rd             (1'b1),
                                    .rxi_wait		(rxi_rd_wait),
                                    .reset		(reset),
                                    .vertical_k		(vertical_k),
                                    .ext_yid_k		(ext_yid_k[3:0]),
                                    .ext_xid_k		(ext_xid_k[3:0]),
                                    .rxi_data		(rxi_data[LW-1:0]),
				    .rxi_lclk		(rxi_lclk),
				    .rxi_frame		(rxi_frame),
                                    .rxi_\(.*\)_access  (\1_fifo_access_rlc),
                                    .\(.*\)             (\1_rlc[]),
				    .cfg_extcomp_dis	(cfg_extcomp_dis), 
                                        );
    */
   link_rxi_buffer link_rxi_buffer(/*AUTOINST*/
				   // Outputs
				   .rxi_wait		(rxi_rd_wait),	 // Templated
				   .rxi_assembled_tran	(rxi_assembled_tran_rlc[14*LW-1:0]), // Templated
				   .rxi_c0_access	(c0_fifo_access_rlc), // Templated
				   .rxi_c1_access	(c1_fifo_access_rlc), // Templated
				   .rxi_c2_access	(c2_fifo_access_rlc), // Templated
				   .rxi_c3_access	(c3_fifo_access_rlc), // Templated
				   // Inputs
				   .reset		(reset),	 // Templated
				   .vertical_k		(vertical_k),	 // Templated
				   .ext_yid_k		(ext_yid_k[3:0]), // Templated
				   .ext_xid_k		(ext_xid_k[3:0]), // Templated
				   .rxi_data		(rxi_data[LW-1:0]), // Templated
				   .rxi_lclk		(rxi_lclk),	 // Templated
				   .rxi_frame		(rxi_frame),	 // Templated
				   .rxi_rd		(1'b1),		 // Templated
				   .cfg_extcomp_dis	(cfg_extcomp_dis), // Templated
				   .c0_fifo_full	(c0_fifo_full_rlc), // Templated
				   .c1_fifo_full	(c1_fifo_full_rlc), // Templated
				   .c2_fifo_full	(c2_fifo_full_rlc), // Templated
				   .c3_fifo_full	(c3_fifo_full_rlc)); // Templated


endmodule // link_rxi_rd
module link_rxi_router (/*AUTOARG*/
   // Outputs
   fifo_read_cvre, read_out, write_out, dst_addr_out, src_addr_out,
   data_out, datamode_out, ctrlmode_out,
   // Inputs
   fifo_data_out_cvre, fifo_empty_cvre, wait_in
   );

   parameter AW  = 32;
   parameter MDW = 32;
   parameter FW  = 112;
   parameter XW  = 6;
   parameter YW  = 6;
   parameter ZW  = 6;
   parameter IAW = 20;//internal address width=20 bits=1MB
   
   /********************************************/
   /*FIFO Interface                            */
   /********************************************/
   input [FW-1:0]   fifo_data_out_cvre;
   input            fifo_empty_cvre;
   output           fifo_read_cvre;     //depends on empty and grants
   
   /********************************************/
   /*Transaction                               */
   /********************************************/
   //Mesh wait indicators
   input             wait_in;
   output            read_out;
   output            write_out;
   output [AW-1:0]   dst_addr_out;
   output [AW-1:0]   src_addr_out;
   output [MDW-1:0]  data_out;    
   output [1:0]      datamode_out;
   output [3:0]      ctrlmode_out;


 
   /********************************************/
   /*Wires                                     */
   /********************************************/
   wire           mesh_write_cvre;
   wire           mesh_read_cvre;
   wire [1:0]     mesh_datamode_cvre;
   wire [3:0]     mesh_ctrlmode_cvre;
   wire [7:0]     mesh_reserved_cvre;
   wire [MDW-1:0] mesh_data_cvre;
   wire [AW-1:0]  mesh_src_addr_cvre;
   wire [AW-1:0]  mesh_dst_addr_cvre;
   wire [1:0]     compare_addr;
   
   wire           request_cvre;
   
   /********************************************/
   /*Splitting Vector Into Components          */
   /********************************************/
   assign mesh_write_cvre           = fifo_data_out_cvre[0];
   assign mesh_read_cvre            = fifo_data_out_cvre[1];
   assign mesh_datamode_cvre[1:0]   = fifo_data_out_cvre[3:2];
   assign mesh_ctrlmode_cvre[3:0]   = fifo_data_out_cvre[7:4];
   assign mesh_reserved_cvre[7:0]   = fifo_data_out_cvre[15:8];
   assign mesh_data_cvre[MDW-1:0]   = fifo_data_out_cvre[47:16];
   assign mesh_dst_addr_cvre[AW-1:0]= fifo_data_out_cvre[79:48];
   assign mesh_src_addr_cvre[AW-1:0]= fifo_data_out_cvre[111:80];


   /********************************************/
   /*Address Decoding                          */
   /********************************************/

   /********************************************/
   /*Address Decoding                          */
   /********************************************/
   //Requests
   //How to 
   assign request_cvre         = ~fifo_empty_cvre;
   
   /********************************************/
   /*Only Doing FIFO read when granted         */
   /********************************************/
   assign fifo_read_cvre       = (request_cvre  & ~wait_in);
   
   
   /********************************************/
   /*DISTRIBUTING TO ALL AGENTS                */
   /********************************************/
   //turn on directions with read/write

   //READ
   assign read_out             = request_cvre & mesh_read_cvre;
   
   //WRITE
   assign write_out            = request_cvre & mesh_write_cvre;
   
   //Mesh transaction
   assign dst_addr_out[AW-1:0] = mesh_dst_addr_cvre[AW-1:0];
   assign src_addr_out[AW-1:0] = mesh_src_addr_cvre[AW-1:0];
   assign data_out[MDW-1:0]    = mesh_data_cvre[MDW-1:0];   
   assign datamode_out[1:0]    = mesh_datamode_cvre[1:0];
   assign ctrlmode_out[3:0]    = mesh_ctrlmode_cvre[3:0];


endmodule // link_rxi_router

     //#############################################################
//# This block is a receiver of the write transactions only
//# Write transactions will enter the chip on emesh and mesh
//# only but not on the rdmesh
//#############################################################
module link_rxi_wr(/*AUTOARG*/
   // Outputs
   rxi_wr_wait, c0_emesh_frame_out, c0_emesh_tran_out,
   c3_emesh_frame_out, c3_emesh_tran_out, c0_mesh_access_out,
   c0_mesh_write_out, c0_mesh_dstaddr_out, c0_mesh_srcaddr_out,
   c0_mesh_data_out, c0_mesh_datamode_out, c0_mesh_ctrlmode_out,
   c3_mesh_access_out, c3_mesh_write_out, c3_mesh_dstaddr_out,
   c3_mesh_srcaddr_out, c3_mesh_data_out, c3_mesh_datamode_out,
   c3_mesh_ctrlmode_out,
   // Inputs
   reset, ext_yid_k, ext_xid_k, vertical_k, who_am_i, cfg_extcomp_dis,
   rxi_data, rxi_lclk, rxi_frame, c0_clk_in, c3_clk_in,
   c0_emesh_wait_in, c3_emesh_wait_in, c0_mesh_wait_in,
   c3_mesh_wait_in
   );

   parameter LW   = `CFG_LW;//lvds tranceiver pairs per side
   parameter DW   = `CFG_DW;//data width  
   parameter AW   = `CFG_AW;//address width
		     
   // #########
   // # Inputs
   // #########

   input             reset;     // reset input
   input [3:0] 	     ext_yid_k; // external y-id 
   input [3:0] 	     ext_xid_k; // external x-id
   input             vertical_k;// specifies if block is vertical or horizontal
   input [3:0] 	     who_am_i;  // specifies what link is that (north,east,south,west)
   input 	     cfg_extcomp_dis;// Disable external coordinates comparison
                                     // Every input transaction is received by the chip
   input [LW-1:0]    rxi_data;  // Byte word
   input             rxi_lclk;  // receive clock (adjusted to the frame/data)
   input             rxi_frame; // indicates new transmission

   // # Sync clocks
   input             c0_clk_in; // clock of the core
   input             c3_clk_in; // clock of the core

   // # Wait indicators
   input             c0_emesh_wait_in;  // wait
   input             c3_emesh_wait_in;  // wait
   input 	     c0_mesh_wait_in;   // wait
   input 	     c3_mesh_wait_in;   // wait

   // ##########
   // # Outputs
   // ##########

   output 	     rxi_wr_wait;  //wait indicator for write transactions

   //# EMESH (write transactions with the off chip destination)
   output            c0_emesh_frame_out; // transaction frame
   output [2*LW-1:0] c0_emesh_tran_out;  // serialized transaction
   output            c3_emesh_frame_out; // transaction frame
   output [2*LW-1:0] c3_emesh_tran_out;  // serialized transaction
   // # MESH (write transactions internal and external corners)
   // # core0 
   output 	     c0_mesh_access_out;  // access control to the mesh
   output 	     c0_mesh_write_out;   // write control to the mesh
   output [AW-1:0]   c0_mesh_dstaddr_out; // destination address to the mesh
   output [AW-1:0]   c0_mesh_srcaddr_out; // source address to the mesh
   output [DW-1:0]   c0_mesh_data_out;    // data to the mesh
   output [1:0]      c0_mesh_datamode_out;// data mode to the mesh 
   output [3:0]      c0_mesh_ctrlmode_out;// ctrl mode to the mesh
   // # core3 
   output 	     c3_mesh_access_out;  // access control to the mesh
   output 	     c3_mesh_write_out;   // write control to the mesh
   output [AW-1:0]   c3_mesh_dstaddr_out; // destination address to the mesh
   output [AW-1:0]   c3_mesh_srcaddr_out; // source address to the mesh
   output [DW-1:0]   c3_mesh_data_out;    // data to the mesh
   output [1:0]      c3_mesh_datamode_out;// data mode to the mesh 
   output [3:0]      c3_mesh_ctrlmode_out;// ctrl mode to the mesh

   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			c0_fifo_access;		// From link_rxi_buffer of link_rxi_buffer.v
   wire			c0_fifo_full_rlc;	// From c0_link_rxi_double_channel of link_rxi_double_channel.v
   wire			c1_fifo_access;		// From link_rxi_buffer of link_rxi_buffer.v
   wire			c2_fifo_access;		// From link_rxi_buffer of link_rxi_buffer.v
   wire			c3_fifo_access;		// From link_rxi_buffer of link_rxi_buffer.v
   wire			c3_fifo_full_rlc;	// From c3_link_rxi_double_channel of link_rxi_double_channel.v
   wire [14*LW-1:0]	rxi_assembled_tran_rlc;	// From link_rxi_buffer of link_rxi_buffer.v
   // End of automatics

   //##########
   //# WIRES
   //##########

   wire    c0_fifo_access_rlc;
   wire    c3_fifo_access_rlc;


   // ################################
   // # Receiver buffer instantiation
   // ################################

   /*link_rxi_buffer AUTO_TEMPLATE (.rxi_rd             (1'b0),
                                    .rxi_wait		(rxi_wr_wait),
                                    .reset		(reset),
                                    .vertical_k		(vertical_k),
                                    .ext_yid_k		(ext_yid_k[3:0]),
                                    .ext_xid_k		(ext_xid_k[3:0]),
                                    .rxi_data		(rxi_data[LW-1:0]),
				    .rxi_lclk		(rxi_lclk),
				    .rxi_frame		(rxi_frame),
                                    .rxi_\(.*\)_access  (\1_fifo_access),
                                    .\(.*\)             (\1_rlc[]),
				    .cfg_extcomp_dis	(cfg_extcomp_dis), 
				    .c1_fifo_full	(1'b0), 
				    .c2_fifo_full	(1'b0), 
                                        );
    */
   link_rxi_buffer link_rxi_buffer(/*AUTOINST*/
				   // Outputs
				   .rxi_wait		(rxi_wr_wait),	 // Templated
				   .rxi_assembled_tran	(rxi_assembled_tran_rlc[14*LW-1:0]), // Templated
				   .rxi_c0_access	(c0_fifo_access), // Templated
				   .rxi_c1_access	(c1_fifo_access), // Templated
				   .rxi_c2_access	(c2_fifo_access), // Templated
				   .rxi_c3_access	(c3_fifo_access), // Templated
				   // Inputs
				   .reset		(reset),	 // Templated
				   .vertical_k		(vertical_k),	 // Templated
				   .ext_yid_k		(ext_yid_k[3:0]), // Templated
				   .ext_xid_k		(ext_xid_k[3:0]), // Templated
				   .rxi_data		(rxi_data[LW-1:0]), // Templated
				   .rxi_lclk		(rxi_lclk),	 // Templated
				   .rxi_frame		(rxi_frame),	 // Templated
				   .rxi_rd		(1'b0),		 // Templated
				   .cfg_extcomp_dis	(cfg_extcomp_dis), // Templated
				   .c0_fifo_full	(c0_fifo_full_rlc), // Templated
				   .c1_fifo_full	(1'b0),		 // Templated
				   .c2_fifo_full	(1'b0),		 // Templated
				   .c3_fifo_full	(c3_fifo_full_rlc)); // Templated

   // ################################################
   // # Receiver channels instantiation  
   // ################################################

   //# All the received transactions will be issued on channel0 or channel3 only
   assign c0_fifo_access_rlc = c0_fifo_access | c1_fifo_access;
   assign c3_fifo_access_rlc = c2_fifo_access | c3_fifo_access;

   /*link_rxi_double_channel AUTO_TEMPLATE (
                       .fifo_full_rlc   (@"(substring vl-cell-name 0 2)"_fifo_full_rlc),
                       .\(.*\)_out      (@"(substring vl-cell-name 0 2)"_\1_out[]),
                       .emesh_wait_in   (@"(substring vl-cell-name 0 2)"_emesh_wait_in),
                       .mesh_\(.*\)     (@"(substring vl-cell-name 0 2)"_mesh_\1[]),
		       .cclk	        (@"(substring vl-cell-name 0 2)"_clk_in),
                       .cclk_en         (1'b1),
                       .fifo_access_rlc (@"(substring vl-cell-name 0 2)"_fifo_access_rlc),
                       .mesh_fifo_access_rlc (mesh_fifo_access_rlc),
                                   );
    */

   //# channel 0 (emesh + mesh + mesh for multicast)
   link_rxi_double_channel c0_link_rxi_double_channel(/*AUTOINST*/
						      // Outputs
						      .fifo_full_rlc	(c0_fifo_full_rlc), // Templated
						      .emesh_tran_out	(c0_emesh_tran_out[2*LW-1:0]), // Templated
						      .emesh_frame_out	(c0_emesh_frame_out), // Templated
						      .mesh_access_out	(c0_mesh_access_out), // Templated
						      .mesh_write_out	(c0_mesh_write_out), // Templated
						      .mesh_dstaddr_out	(c0_mesh_dstaddr_out[AW-1:0]), // Templated
						      .mesh_srcaddr_out	(c0_mesh_srcaddr_out[AW-1:0]), // Templated
						      .mesh_data_out	(c0_mesh_data_out[DW-1:0]), // Templated
						      .mesh_datamode_out(c0_mesh_datamode_out[1:0]), // Templated
						      .mesh_ctrlmode_out(c0_mesh_ctrlmode_out[3:0]), // Templated
						      // Inputs
						      .reset		(reset),
						      .cclk		(c0_clk_in),	 // Templated
						      .cclk_en		(1'b1),		 // Templated
						      .ext_yid_k	(ext_yid_k[3:0]),
						      .ext_xid_k	(ext_xid_k[3:0]),
						      .rxi_lclk		(rxi_lclk),
						      .who_am_i		(who_am_i[3:0]),
						      .cfg_extcomp_dis	(cfg_extcomp_dis),
						      .rxi_assembled_tran_rlc(rxi_assembled_tran_rlc[14*LW-1:0]),
						      .fifo_access_rlc	(c0_fifo_access_rlc), // Templated
						      .emesh_wait_in	(c0_emesh_wait_in), // Templated
						      .mesh_wait_in	(c0_mesh_wait_in)); // Templated

   //# channel 3 (emesh + mesh)
   link_rxi_double_channel c3_link_rxi_double_channel(/*AUTOINST*/
						      // Outputs
						      .fifo_full_rlc	(c3_fifo_full_rlc), // Templated
						      .emesh_tran_out	(c3_emesh_tran_out[2*LW-1:0]), // Templated
						      .emesh_frame_out	(c3_emesh_frame_out), // Templated
						      .mesh_access_out	(c3_mesh_access_out), // Templated
						      .mesh_write_out	(c3_mesh_write_out), // Templated
						      .mesh_dstaddr_out	(c3_mesh_dstaddr_out[AW-1:0]), // Templated
						      .mesh_srcaddr_out	(c3_mesh_srcaddr_out[AW-1:0]), // Templated
						      .mesh_data_out	(c3_mesh_data_out[DW-1:0]), // Templated
						      .mesh_datamode_out(c3_mesh_datamode_out[1:0]), // Templated
						      .mesh_ctrlmode_out(c3_mesh_ctrlmode_out[3:0]), // Templated
						      // Inputs
						      .reset		(reset),
						      .cclk		(c3_clk_in),	 // Templated
						      .cclk_en		(1'b1),		 // Templated
						      .ext_yid_k	(ext_yid_k[3:0]),
						      .ext_xid_k	(ext_xid_k[3:0]),
						      .rxi_lclk		(rxi_lclk),
						      .who_am_i		(who_am_i[3:0]),
						      .cfg_extcomp_dis	(cfg_extcomp_dis),
						      .rxi_assembled_tran_rlc(rxi_assembled_tran_rlc[14*LW-1:0]),
						      .fifo_access_rlc	(c3_fifo_access_rlc), // Templated
						      .emesh_wait_in	(c3_emesh_wait_in), // Templated
						      .mesh_wait_in	(c3_mesh_wait_in)); // Templated


endmodule // link_rxi_wr
module link_transmitter (/*AUTOARG*/
   // Outputs
   txo_data, txo_lclk90, txo_frame, c0_emesh_wait_out,
   c1_emesh_wait_out, c2_emesh_wait_out, c3_emesh_wait_out,
   c0_rdmesh_wait_out, c1_rdmesh_wait_out, c2_rdmesh_wait_out,
   c3_rdmesh_wait_out, c0_mesh_wait_out, c3_mesh_wait_out,
   // Inputs
   reset, ext_yid_k, ext_xid_k, who_am_i, txo_cfg_reg, txo_wr_wait,
   txo_rd_wait, c0_clk_in, c1_clk_in, c2_clk_in, c3_clk_in,
   c0_mesh_access_in, c0_mesh_write_in, c0_mesh_dstaddr_in,
   c0_mesh_srcaddr_in, c0_mesh_data_in, c0_mesh_datamode_in,
   c0_mesh_ctrlmode_in, c3_mesh_access_in, c3_mesh_write_in,
   c3_mesh_dstaddr_in, c3_mesh_srcaddr_in, c3_mesh_data_in,
   c3_mesh_datamode_in, c3_mesh_ctrlmode_in, c0_emesh_frame_in,
   c0_emesh_tran_in, c1_emesh_frame_in, c1_emesh_tran_in,
   c2_emesh_frame_in, c2_emesh_tran_in, c3_emesh_frame_in,
   c3_emesh_tran_in
   );

   parameter LW   = `CFG_LW  ;//lvds tranceiver pairs per side
   parameter AW   = `CFG_AW  ;//address width
   parameter DW   = `CFG_DW  ;//data width  
   
   // #########
   // # Inputs
   // #########

   input            reset;
   input [3:0] 	    ext_yid_k; //external y-id 
   input [3:0] 	    ext_xid_k; //external x-id
   input [3:0] 	    who_am_i;  // specifies what link is that (north,east,south,west)
   
   // # Configuration registers
   input [5:0] 	    txo_cfg_reg; //Clock divider configuration on bits 3-0,
                                  //Bursting disable control on bit 4
                                  //Multicast disable control on bit 5
   // # from io
   input 	    txo_wr_wait; //wait indicator for write transactions
   input 	    txo_rd_wait; //wait indicator for read transactions

   // # Clocks
   input 	    c0_clk_in;         // clock of the core  
   input 	    c1_clk_in;         // clock of the core  
   input 	    c2_clk_in;         // clock of the core  
   input 	    c3_clk_in;         // clock of the core  
  
   // # MESH 
   // # core0 (external corners and multicast)
   input 	    c0_mesh_access_in;  // access control from the mesh
   input 	    c0_mesh_write_in;   // write control from the mesh
   input [AW-1:0]   c0_mesh_dstaddr_in; // destination address from the mesh
   input [AW-1:0]   c0_mesh_srcaddr_in; // source address from the mesh
   input [DW-1:0]   c0_mesh_data_in;    // data from the mesh
   input [1:0] 	    c0_mesh_datamode_in;// data mode from the mesh 
   input [3:0] 	    c0_mesh_ctrlmode_in;// ctrl mode from the mesh
   // # core3 (external corners only)
   input 	    c3_mesh_access_in;  // access control from the mesh
   input 	    c3_mesh_write_in;   // write control from the mesh
   input [AW-1:0]   c3_mesh_dstaddr_in; // destination address from the mesh
   input [AW-1:0]   c3_mesh_srcaddr_in; // source address from the mesh
   input [DW-1:0]   c3_mesh_data_in;    // data from the mesh
   input [1:0] 	    c3_mesh_datamode_in;// data mode from the mesh 
   input [3:0] 	    c3_mesh_ctrlmode_in;// ctrl mode from the mesh

   // ##############
   // # Outputs
   // ##############

   output  [LW-1:0]  txo_data;      //Byte word
   output            txo_lclk90;    //transmit clock (adjusted to the frame/data)
   output            txo_frame;     //indicates new transmission 
  
   output 	     c0_emesh_wait_out; // wait to the emesh   
   output 	     c1_emesh_wait_out; // wait to the emesh   
   output 	     c2_emesh_wait_out; // wait to the emesh   
   output 	     c3_emesh_wait_out; // wait to the emesh   

   output 	     c0_rdmesh_wait_out; // wait to the rdmesh   
   output 	     c1_rdmesh_wait_out; // wait to the rdmesh   
   output 	     c2_rdmesh_wait_out; // wait to the rdmesh   
   output 	     c3_rdmesh_wait_out; // wait to the rdmesh   

   output 	     c0_mesh_wait_out;  // wait to the mesh 
   output 	     c3_mesh_wait_out;  // wait to the mesh 

   // ##########
   // # WIRES
   // ##########

   wire 	     txo_lclk;  //transmit clock to be used internally
   wire 	     txo_lclk90;//transmit clock (adjusted to the frame/data)

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		c0_emesh_frame_in;	// To link_txo_wr of link_txo_wr.v
   input [2*LW-1:0]	c0_emesh_tran_in;	// To link_txo_wr of link_txo_wr.v
   input		c1_emesh_frame_in;	// To link_txo_wr of link_txo_wr.v
   input [2*LW-1:0]	c1_emesh_tran_in;	// To link_txo_wr of link_txo_wr.v
   input		c2_emesh_frame_in;	// To link_txo_wr of link_txo_wr.v
   input [2*LW-1:0]	c2_emesh_tran_in;	// To link_txo_wr of link_txo_wr.v
   input		c3_emesh_frame_in;	// To link_txo_wr of link_txo_wr.v
   input [2*LW-1:0]	c3_emesh_tran_in;	// To link_txo_wr of link_txo_wr.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [LW-1:0]	txo_wr_data_even;	// From link_txo_wr of link_txo_wr.v
   wire [LW-1:0]	txo_wr_data_odd;	// From link_txo_wr of link_txo_wr.v
   wire			txo_wr_frame;		// From link_txo_wr of link_txo_wr.v
   wire			txo_wr_launch_req_tlc;	// From link_txo_wr of link_txo_wr.v
   wire			txo_wr_rotate_dis;	// From link_txo_wr of link_txo_wr.v
   // End of automatics
   

   // ##############################
   // # Clock divider instantiation
   // ##############################

   //# Since the logic of the fifo of the transmitter's channel 
   //# assumes txo_lck and cclk to be asynchronous clocks, we don't
   //# mind to have txo_lclk be generated out of any of the clk_in
   //# clocks even though they are inverted relative to each other.
   //# c1_clk_in is selected because of the physical implementation
   //# considerations.
   e16_clock_divider clock_divider (.clk_out	(txo_lclk),
				.clk_out90      (txo_lclk90),
				.clk_in		(c1_clk_in),
				.reset		(reset),
				.div_cfg	(4'b0)
				);

   //########################
   //# Transmitter interface 
   //########################

   link_txo_interface link_txo_interface(
					 // Outputs
					 .txo_data		(txo_data[LW-1:0]),
					 .txo_frame		(txo_frame),
					 .txo_wr_wait_int	(txo_wr_wait_int),
					 .txo_rd_wait_int	(txo_rd_wait_int),
					 // Inputs
					 .txo_lclk		(txo_lclk),
					 .reset			(reset),
					 .txo_wr_data_even	(txo_wr_data_even[LW-1:0]),
					 .txo_wr_data_odd	(txo_wr_data_odd[LW-1:0]),
					 .txo_wr_frame		(txo_wr_frame),
					 .txo_wr_launch_req_tlc	(txo_wr_launch_req_tlc),
					 .txo_wr_rotate_dis	(txo_wr_rotate_dis),
					 .txo_rd_data_even	(8'd0),
					 .txo_rd_data_odd	(8'd0),
					 .txo_rd_frame		(1'd0),
					 .txo_rd_launch_req_tlc	(1'd0),
					 .txo_rd_rotate_dis	(1'd0)
					 ); 
   
   //#################################
   //# Write Transactions Transmitter
   //#################################

   link_txo_wr link_txo_wr(.cfg_burst_dis	(txo_cfg_reg[4]),
			   .cfg_multicast_dis	(txo_cfg_reg[5]),
			   .txo_wr_wait_int	(txo_wr_wait_int),
			   /*AUTOINST*/
			   // Outputs
			   .txo_wr_data_even	(txo_wr_data_even[LW-1:0]),
			   .txo_wr_data_odd	(txo_wr_data_odd[LW-1:0]),
			   .txo_wr_frame	(txo_wr_frame),
			   .txo_wr_launch_req_tlc(txo_wr_launch_req_tlc),
			   .txo_wr_rotate_dis	(txo_wr_rotate_dis),
			   .c0_emesh_wait_out	(c0_emesh_wait_out),
			   .c1_emesh_wait_out	(c1_emesh_wait_out),
			   .c2_emesh_wait_out	(c2_emesh_wait_out),
			   .c3_emesh_wait_out	(c3_emesh_wait_out),
			   .c0_mesh_wait_out	(c0_mesh_wait_out),
			   .c3_mesh_wait_out	(c3_mesh_wait_out),
			   // Inputs
			   .txo_lclk		(txo_lclk),
			   .reset		(reset),
			   .ext_yid_k		(ext_yid_k[3:0]),
			   .ext_xid_k		(ext_xid_k[3:0]),
			   .who_am_i		(who_am_i[3:0]),
			   .txo_wr_wait		(txo_wr_wait),
			   .c0_clk_in		(c0_clk_in),
			   .c1_clk_in		(c1_clk_in),
			   .c2_clk_in		(c2_clk_in),
			   .c3_clk_in		(c3_clk_in),
			   .c0_emesh_tran_in	(c0_emesh_tran_in[2*LW-1:0]),
			   .c0_emesh_frame_in	(c0_emesh_frame_in),
			   .c1_emesh_tran_in	(c1_emesh_tran_in[2*LW-1:0]),
			   .c1_emesh_frame_in	(c1_emesh_frame_in),
			   .c2_emesh_tran_in	(c2_emesh_tran_in[2*LW-1:0]),
			   .c2_emesh_frame_in	(c2_emesh_frame_in),
			   .c3_emesh_tran_in	(c3_emesh_tran_in[2*LW-1:0]),
			   .c3_emesh_frame_in	(c3_emesh_frame_in),
			   .c0_mesh_access_in	(c0_mesh_access_in),
			   .c0_mesh_write_in	(c0_mesh_write_in),
			   .c0_mesh_dstaddr_in	(c0_mesh_dstaddr_in[AW-1:0]),
			   .c0_mesh_srcaddr_in	(c0_mesh_srcaddr_in[AW-1:0]),
			   .c0_mesh_data_in	(c0_mesh_data_in[DW-1:0]),
			   .c0_mesh_datamode_in	(c0_mesh_datamode_in[1:0]),
			   .c0_mesh_ctrlmode_in	(c0_mesh_ctrlmode_in[3:0]),
			   .c3_mesh_access_in	(c3_mesh_access_in),
			   .c3_mesh_write_in	(c3_mesh_write_in),
			   .c3_mesh_dstaddr_in	(c3_mesh_dstaddr_in[AW-1:0]),
			   .c3_mesh_srcaddr_in	(c3_mesh_srcaddr_in[AW-1:0]),
			   .c3_mesh_data_in	(c3_mesh_data_in[DW-1:0]),
			   .c3_mesh_datamode_in	(c3_mesh_datamode_in[1:0]),
			   .c3_mesh_ctrlmode_in	(c3_mesh_ctrlmode_in[3:0]));


endmodule // link_transmitter
module link_txo_arbiter(/*AUTOARG*/
   // Outputs
   txo_launch_req_tlc, txo_rotate_dis_tlc, c0_txo_launch_ack_tlc,
   c1_txo_launch_ack_tlc, c2_txo_launch_ack_tlc,
   c3_txo_launch_ack_tlc,
   // Inputs
   txo_lclk, reset, txo_wait, txo_wait_int, c0_txo_launch_req_tlc,
   c0_txo_rotate_dis, c1_txo_launch_req_tlc, c1_txo_rotate_dis,
   c2_txo_launch_req_tlc, c2_txo_rotate_dis, c3_txo_launch_req_tlc,
   c3_txo_rotate_dis
   );


   // ##########
   // # Inputs
   // ##########

   input       txo_lclk;   
   input       reset;
   input       txo_wait; // Wait from the receiver (we have to finish current transmission)
   input       txo_wait_int; // Wait from the txo_interface (have to stall immediately)

   //Channel 0
   input       c0_txo_launch_req_tlc; // Launch request
   input       c0_txo_rotate_dis;     // Arbiter's rotate disable 
   //Channel 1
   input       c1_txo_launch_req_tlc; // Launch request
   input       c1_txo_rotate_dis;     // Arbiter's rotate disable 
   //Channel 2
   input       c2_txo_launch_req_tlc; // Launch request
   input       c2_txo_rotate_dis;     // Arbiter's rotate disable 
   //Channel 3
   input       c3_txo_launch_req_tlc; // Launch request
   input       c3_txo_rotate_dis;     // Arbiter's rotate disable 

   // ##########
   // # Outputs
   // ##########
   // to the txo_interface
   output      txo_launch_req_tlc;
   output      txo_rotate_dis_tlc;
   // to the channels
   output      c0_txo_launch_ack_tlc;
   output      c1_txo_launch_ack_tlc;
   output      c2_txo_launch_ack_tlc;
   output      c3_txo_launch_ack_tlc;

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   // #######
   // # REGS
   // #######

   reg [3:0]   grants_reg;

   // ############
   // # WIRES
   // ############

   wire [3:0]  txo_rotate_dis;
   wire        en_arbitration;
   wire        en_rotate;

   wire [3:0]   grants;             //one-hot grants signals
   wire [3:0] 	requests_unmasked;  //unmasked (original) requests
   wire [3:0]   requests;           //requests
   wire 	txo_wait_tlc;

   //############################
   //# txo_wait synchronization
   //############################
   e16_synchronizer #(.DW(1)) synchronizer(.out	(txo_wait_tlc),
			               .in	(txo_wait),
				       .clk	(txo_lclk),
				       .reset	(reset));

   //#############################################################
   //# creating requests information for the additional
   //# arbitration which is performed in the txo_interface
   //#############################################################
   assign txo_launch_req_tlc = c0_txo_launch_req_tlc | c1_txo_launch_req_tlc |
			       c2_txo_launch_req_tlc | c3_txo_launch_req_tlc;

   assign txo_rotate_dis_tlc = c0_txo_rotate_dis | c1_txo_rotate_dis |
			       c2_txo_rotate_dis | c3_txo_rotate_dis;

   //###########################################
   //# Rotation mechanism and requests creation
   //###########################################
   always @ (posedge txo_lclk or posedge reset)
     if(reset)
       grants_reg[3:0] <= 4'b0000;
     else
       grants_reg[3:0] <= grants[3:0];

   assign txo_rotate_dis[3:0] = {c3_txo_rotate_dis,
				 c2_txo_rotate_dis,
				 c1_txo_rotate_dis,
				 c0_txo_rotate_dis};

   assign en_rotate = ~(|(grants_reg[3:0] & txo_rotate_dis[3:0]));

   assign en_arbitration = ~txo_wait_tlc | (|(txo_rotate_dis[3:0]));

   assign requests_unmasked[3:0] = {c3_txo_launch_req_tlc,
                                    c2_txo_launch_req_tlc,
                                    c1_txo_launch_req_tlc,
                                    c0_txo_launch_req_tlc};
   
   assign requests[3:0] = {(4){en_arbitration}} & 
			  requests_unmasked[3:0] & (grants_reg[3:0] | {(4){en_rotate}});

   //############
   //# Grants
   //############
   assign c3_txo_launch_ack_tlc   = grants[3] & ~txo_wait_int;
   assign c2_txo_launch_ack_tlc   = grants[2] & ~txo_wait_int;
   assign c1_txo_launch_ack_tlc   = grants[1] & ~txo_wait_int;
   assign c0_txo_launch_ack_tlc   = grants[0] & ~txo_wait_int;

   //######################################
   //# Round-Robin Arbiter Instantiation
   //######################################
   /*e16_arbiter_roundrobin AUTO_TEMPLATE (.clk	   (txo_lclk),
                                       .clk_en	   (1'b1),
                                       .grants	   (grants[3:0]),
                                       .requests   (requests[3:0]),
                                       );
    */ 
   e16_arbiter_roundrobin #(.ARW(4)) arbiter_roundrobin(/*AUTOINST*/
							// Outputs
							.grants		(grants[3:0]),	 // Templated
							// Inputs
							.clk		(txo_lclk),	 // Templated
							.clk_en		(1'b1),		 // Templated
							.reset		(reset),
							.en_rotate	(en_rotate),
							.requests	(requests[3:0])); // Templated

endmodule // link_txo_arbiter
module link_txo_buffer(/*AUTOARG*/
   // Outputs
   txo_data_even, txo_data_odd, txo_frame,
   // Inputs
   c0_tran_frame_tlc, c0_tran_byte_even_tlc, c0_tran_byte_odd_tlc,
   c1_tran_frame_tlc, c1_tran_byte_even_tlc, c1_tran_byte_odd_tlc,
   c2_tran_frame_tlc, c2_tran_byte_even_tlc, c2_tran_byte_odd_tlc,
   c3_tran_frame_tlc, c3_tran_byte_even_tlc, c3_tran_byte_odd_tlc
   );

   parameter LW  = `CFG_LW;
   
   // #########
   // # Inputs
   // #########

   //# from channel 0
   input          c0_tran_frame_tlc;      // Frame of the transaction
   input [LW-1:0] c0_tran_byte_even_tlc;  // Even byte of the transaction
   input [LW-1:0] c0_tran_byte_odd_tlc;   // Odd byte of the transaction
   //# from channel 1
   input          c1_tran_frame_tlc;      // Frame of the transaction
   input [LW-1:0] c1_tran_byte_even_tlc;  // Even byte of the transaction
   input [LW-1:0] c1_tran_byte_odd_tlc;   // Odd byte of the transaction
   //# from channel 2
   input          c2_tran_frame_tlc;      // Frame of the transaction
   input [LW-1:0] c2_tran_byte_even_tlc;  // Even byte of the transaction
   input [LW-1:0] c2_tran_byte_odd_tlc;   // Odd byte of the transaction
   //# from channel 3
   input          c3_tran_frame_tlc;      // Frame of the transaction
   input [LW-1:0] c3_tran_byte_even_tlc;  // Even byte of the transaction
   input [LW-1:0] c3_tran_byte_odd_tlc;   // Odd byte of the transaction

   // ##########
   // # Outputs
   // ##########
 
   output [LW-1:0]  txo_data_even; //Even byte word
   output [LW-1:0]  txo_data_odd;  //Odd byte word
   output 	    txo_frame;     //indicates new transmission 

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   // ##########
   // # Regs
   // ##########
   
   // ##########
   // # Wires
   // ##########

   wire 	 txo_frame;     // selected frame of the transmission
   wire [LW-1:0] txo_data_even; // selected even bytes of the transmission
   wire [LW-1:0] txo_data_odd;  // selected odd bytes of the transmission

   //###########################################
   //#           Transaction mux
   //# The "and" part of the "and-or" mux is
   //# implemented in the link channels blocks  
   //# therefore here we are good with "or" only
   //###########################################

   assign txo_frame = c0_tran_frame_tlc;
 
   assign txo_data_even[LW-1:0] = c0_tran_byte_even_tlc[LW-1:0];
   
   assign txo_data_odd[LW-1:0] = c0_tran_byte_odd_tlc[LW-1:0];
   

endmodule // link_txo_buffer



			
//#########################################################
//# This block is a single channel of the link transmitter
//# mechanism.
//#
//# The input transaction of this block is of the fixed size,  
//# while the output transaction has an option
//# of the bursting where data of the new transaction
//# is sent without the address. In such a case the
//# address of the transaction will be determined in
//# the receiver according to the address of the
//# previous transaction.
//#
//#          TXO-RXI TRANSMISSION PROTOCOL
//#         ###############################
//#        ----      ----      ----      ----      ----      --
//# LCLK _|    |____|    |____|    |____|    |____|    |____| 
//#
//#              -------------------------------------
//# FRAME ______/
//#              ----- ----- ----- ----- -----
//# DATA  XXXXXXX  0  X  1  X  2  X  3  X  4  X .....
//#              ----- ----- ----- ----- -----
//#
//# The byte sampled on the first rising edge of the LCLK following 
//# the "low-to-high" change of the FRAME signal (byte0) will determine 
//# the type of the transmitted data according to the following
//# encoding scheme:
//#    
//#      byte0          | transaction type
//#   ----------------- | ----------------
//#  8'b??_??_?0_<cid>  | New transaction with incremental bursting address
//#  8'b??_??_?1_<cid>  | New transaction with the same bursting address
//#
//#  cid[1:0] - channel id (for debugging usage only for now)
//#
//#  New transaction structure:
//#  -------------------------
//#   byte1  -> ctrlmode[3:0],dstaddr[31:28]
//#   byte2  -> dstaddr[27:20]
//#   byte3  -> dstaddr[19:12]
//#   byte4  -> dstaddr[11:4]
//#   byte5  -> dstaddr[3:0],datamode[1:0],write,access
//#   byte6  -> data[31:24] (or srcaddr[31:24] if read transaction)
//#   byte7  -> data[23:16] (or srcaddr[23:16] if read transaction)
//#   byte8  -> data[15:8]  (or srcaddr[15:8]  if read transaction)
//#  *byte9  -> data[7:0]   (or srcaddr[7:0]   if read transaction)
//#   byte10 -> data[63:56]  
//#   byte11 -> data[55:48]  
//#   byte12 -> data[47:40]  
//#   byte13 -> data[39:32]  
//# **byte14 -> data[31:24]  
//#    ...
//#    ...
//#    ...
//#
//#  * byte9 is the last byte of 32 bit write or read transaction 
//#   
//# ** if 64 bit write transaction, data of byte14 is the first data byte of
//#    bursting transaction
//# 
//# -- The data is transmitted MSB first but in 32bits resolution. If we want
//#    to transmit 64 bits it will be [31:0] (msb first) and then [63:32] (msb first)
//#
//# !!!
//# !!! According to the above scheme, any new transaction (burst or not)
//# !!! will take at least four cycles to be transmitted.
//# !!! There are some internal mechanisms in the transmitter-receiver logic
//# !!! which are implemented considering this assumption true.
//# !!! Any change to this assumption (transaction takes at least four cycles)
//# !!! should be carefully reviewed with its implications on the internal
//# !!! implementation
//# !!!
//#      
//#####################################################################

module link_txo_channel (/*AUTOARG*/
   // Outputs
   emesh_wait_out, txo_launch_req_tlc, txo_rotate_dis, tran_frame_tlc,
   tran_byte_even_tlc, tran_byte_odd_tlc,
   // Inputs
   cclk, cclk_en, txo_lclk, reset, txo_rd, txo_cid, cfg_burst_dis,
   emesh_tran_in, emesh_frame_in, txo_launch_ack_tlc
   );

   parameter AW   = `CFG_AW  ;//address width
   parameter DW   = `CFG_DW  ;//data width  
   parameter LW   = `CFG_LW  ;//lvds tranceiver pairs per side
   parameter FW   = `CFG_NW*`CFG_LW;
   parameter FAD  = 5; // Number of bits to access all the entries (2^FAD + 1) > AE*PE

   //##########
   //# INPUTS
   //##########

   input 	  cclk;     // clock of the score the emesh comes from
   input 	  cclk_en;  // clock enable 
   input 	  txo_lclk; // clock of the link transmitter
   input          reset;

   input 	  txo_rd;  // this is read transactions channel
   input [1:0] 	  txo_cid; // transmitter channel ID
   input 	  cfg_burst_dis; // control register bursting disable

   //# from the EMESH
   input [2*LW-1:0] emesh_tran_in;  // serialized transaction
   input 	    emesh_frame_in; // transaction frame

   //# from the arbiter
   input 	    txo_launch_ack_tlc;

   //###########
   //# OUTPUTS
   //###########
   //# to emesh
   output 	    emesh_wait_out; // wait to the emesh   

   //# to the arbiter
   output 	    txo_launch_req_tlc; // Launch request
   output 	    txo_rotate_dis; // Arbiter's rotate disable 

   //# to the output mux/buffer
   output 	    tran_frame_tlc;       // Frame of the transaction
   output [LW-1:0]  tran_byte_even_tlc;  // Even byte of the transaction
   output [LW-1:0]  tran_byte_odd_tlc;   // Odd byte of the transaction

   /*AUTOINPUT*/
   /*AUTOWIRE*/




endmodule // link_txo_channel

//#############################################################################
//# This block is a custom fifo for the link single channel
//# transmitter.
//# The fifo has a following structure:
//# - 4  "architectural" entries to contain 4 full-size transactions. 
//#    Every architectural entry has 7 "sub-entries" of 16bit each
//#    112 bits in total (104 bits of actual transaction + 8 bits of zerros)
//# - 28 "physical" entries in total (4*7)
//# 
//# The fifo is written in the "regular" manner - i.e. whenever there is an
//# empty "physical" entry to write in.
//# The fifo is read "freely" from within every "architectural" entry 
//# (7 "physical" entries in a raw) once the "architectural" entry is written 
//# in full.
//# 
//# For this purpose, the "fifo write" domain indicates to the "fifo-read"
//# domain every "architectural" entry being written,
//# While the "fifo read" domain indicates to the "fifo-write" domain
//# every "physical" entry being read.          
//#############################################################################

module link_txo_fifo (/*AUTOARG*/
   // Outputs
   wr_fifo_full, fifo_out_tlc, tran_written_tlc, next_ctrlmode_tlc,
   next_dstaddr_tlc, next_datamode_tlc, next_write_tlc,
   next_access_tlc,
   // Inputs
   reset, cclk, cclk_en, txo_lclk, tran_in, frame_in, rd_read_tlc,
   check_next_dstaddr_tlc
   );

   parameter AW   = `CFG_AW  ;//address width
   parameter LW   = `CFG_LW  ;//lvds tranceiver pairs per side
   parameter AE   = 4; // Number of "architectural" entries
   parameter PE   = 7; // Number of "physical" entries in the "architectural" one
   parameter FAD  = 5; // Number of bits to access all the entries (2^FAD + 1) > AE*PE
   localparam MD = 1<<FAD;

   // #########
   // # Inputs
   // #########
   
   input          reset;

   input 	  cclk;      // core clock
   input 	  cclk_en;   // core clock enable
   input 	  txo_lclk;  // link transmitter clock   

   //# from the emesh/mesh selection logic
   input [2*LW-1:0] tran_in;  // serialized transaction
   input 	    frame_in; // transaction frame

   //# from the control
   input [FAD:0]    rd_read_tlc; // Read containing potential jump for bursting
   input 	    check_next_dstaddr_tlc; // Next transaction dstaddr can be checked

   // ##########
   // # Outputs
   // ##########

   //# to the emesh/mesh selection logic
   output 	   wr_fifo_full;    

   //# to the control
   output [2*LW-1:0] fifo_out_tlc;      
   output 	   tran_written_tlc;
   output [3:0]    next_ctrlmode_tlc;
   output [AW-1:0] next_dstaddr_tlc;
   output [1:0]    next_datamode_tlc;
   output 	   next_write_tlc;
   output 	   next_access_tlc;

   /*AUTOINPUT*/
   /*AUTOWIRE*/
  
   // ##########
   // # REGS
   // #########
   reg [LW-1:0]    even_byte;
   reg [2*LW-1:0] fifo_mem[MD-1:0];
 
   reg [FAD:0]   rd_gray_pointer_tlc;
   reg [FAD:0]   rd_binary_pointer_tlc;
   reg [FAD:0]   rd_addr_traninfo0_tlc;

   reg 		 frame_del;
   reg [FAD:0] 	 wr_binary_pointer;
   reg 		 wr_fifo_full;

   // #########
   // # WIRES
   // #########
   wire [FAD-1:0]  rd_addr_tlc;
   wire [FAD:0]    rd_binary_next_tlc;
   wire [FAD:0]    rd_gray_next_tlc;
   wire [FAD:0]    rd_addr_traninfo0_next_tlc;
   wire [FAD-1:0]  rd_addr_traninfo1_tlc;
   wire [FAD-1:0]  rd_addr_traninfo2_tlc;
   wire [2*LW-1:0] traninfo0_tlc;
   wire [2*LW-1:0] traninfo1_tlc;
   wire [2*LW-1:0] traninfo2_tlc;

   wire [FAD-1:0] wr_addr;	
   wire 	  wr_write;
   wire 	  tran_written;
   wire [FAD:0]   rd_gray_pointer;	
   wire 	  wr_fifo_full_next;
   wire [FAD:0]   wr_gray_next;
   wire [FAD:0]   wr_binary_next;

   //###########################
   //# Write control generation
   //###########################
   always @ (posedge cclk or posedge reset)
     if(reset)
       frame_del <= 1'b0;
     else if(cclk_en)
       if(!wr_fifo_full)
	 frame_del <= frame_in;

   assign wr_write = (frame_in | frame_del) & ~wr_fifo_full;

   //###################################
   //# Full transaction write completed
   //###################################
   assign tran_written = ~frame_in & frame_del & ~wr_fifo_full;

   //#################################
   //# FIFO data
   //#################################
 
   //# Write
   //# two bytes of the tran short word should enter different fifo entries
   //# in order to get 32 bit of data, dstaddr and srcaddr each "sitting" in two
   //# entries only.
   //# In this case byte0 of the first entry of the transaction
   //# ({byte0,ctrlmode[3:0],dstaddr[31:28]}) will be a "zevel" but we don't care
   //# since this byte is replaced later anyway.
   
   always @ (posedge cclk)
     if (cclk_en)
       if(!wr_fifo_full)
	 even_byte[LW-1:0] <= tran_in[LW-1:0];

   always @ (posedge cclk)
     if (cclk_en)
       if (wr_write)
	 fifo_mem[wr_addr[FAD-1:0]] <= {even_byte[LW-1:0],tran_in[2*LW-1:LW]};
   
   //# Read (for dispatch)
   assign fifo_out_tlc[2*LW-1:0] = fifo_mem[rd_addr_tlc[FAD-1:0]];

   //# Read (first short word of the next transaction to dispatch)
   assign traninfo0_tlc[2*LW-1:0] = fifo_mem[rd_addr_traninfo0_tlc[FAD-1:0]];

   //# Read (second short word of the next transaction to dispatch)
   assign traninfo1_tlc[2*LW-1:0] = fifo_mem[rd_addr_traninfo1_tlc[FAD-1:0]];

   //# Read (third short word of the next transaction to dispatch)
   assign traninfo2_tlc[2*LW-1:0] = fifo_mem[rd_addr_traninfo2_tlc[FAD-1:0]];

   assign next_ctrlmode_tlc[3:0]   = traninfo0_tlc[LW-1:LW-4];

   assign next_dstaddr_tlc[AW-1:0] = {traninfo0_tlc[3:0],
                                      traninfo1_tlc[2*LW-1:0],
                                      traninfo2_tlc[2*LW-1:4]};

   assign next_datamode_tlc[1:0] = traninfo2_tlc[3:2];

   assign next_write_tlc  = traninfo2_tlc[1];
   assign next_access_tlc = traninfo2_tlc[0];

   //#####################################
   //# FIFO Write State Machine
   //#####################################

   //# While for the actual address calculation we use [FAD-1:0] bits only,
   //# the bit FAD of the counter is needed in order to distinguish
   //# between the fifo entry currently being written and the one
   //# written in the previous "round" (FAD is a carry-out bit and is
   //# switched every "round")
   always @(posedge cclk or posedge reset)
     if(reset)
       wr_binary_pointer[FAD:0]     <= {(FAD+1){1'b0}};
     else if(cclk_en)
       if(wr_write)
	 wr_binary_pointer[FAD:0]     <= wr_binary_next[FAD:0];	  
   
   assign wr_addr[FAD-1:0]       = wr_binary_pointer[FAD-1:0];
   assign wr_binary_next[FAD:0]  = wr_binary_pointer[FAD:0] + {{(FAD){1'b0}},wr_write};

   //# Gray Pointer Conversion (for more reliable synchronization)!
   assign wr_gray_next[FAD:0] = {1'b0,wr_binary_next[FAD:1]} ^ wr_binary_next[FAD:0];

   //# FIFO full indication
   assign wr_fifo_full_next = (wr_gray_next[FAD-2:0] == rd_gray_pointer[FAD-2:0]) &
                              (wr_gray_next[FAD]     ^  rd_gray_pointer[FAD])     &
                              (wr_gray_next[FAD-1]   ^  rd_gray_pointer[FAD-1]);
			      
   always @ (posedge cclk or posedge reset)
     if(reset)
       wr_fifo_full <= 1'b0;
     else if(cclk_en)
       wr_fifo_full <=wr_fifo_full_next;

   //#############################
   //# FIFO Read State Machine
   //#############################
    
   always @(posedge txo_lclk or posedge reset)
     if(reset)
       begin
	  rd_binary_pointer_tlc[FAD:0]  <= {(FAD+1){1'b0}};
	  rd_gray_pointer_tlc[FAD:0]    <= {(FAD+1){1'b0}};
       end
     else if(|(rd_read_tlc[FAD:0]))
       begin	  rd_binary_pointer_tlc[FAD:0]  <= rd_binary_next_tlc[FAD:0];	  
	  rd_gray_pointer_tlc[FAD:0]    <= rd_gray_next_tlc[FAD:0];	  
       end

   assign rd_addr_tlc[FAD-1:0]       = rd_binary_pointer_tlc[FAD-1:0];
   assign rd_binary_next_tlc[FAD:0]  = rd_binary_pointer_tlc[FAD:0] + rd_read_tlc[FAD:0];

   //# Gray Pointer Conversion (for more reliable synchronization)!
   assign rd_gray_next_tlc[FAD:0]  = {1'b0,rd_binary_next_tlc[FAD:1]} ^ 
                                           rd_binary_next_tlc[FAD:0];

   //#
   //# address and controls of the next transaction to be dispatch
   //# * the size is actually FAD-1:0 but since FAD=3 causes syntax
   //#   error for (FAD-3){1'b0} expression, we use a biger range
   //#   FAD:0 and (FAD-2){1'b0}
   //assign rd_addr_traninfo0_next_tlc[FAD-1:0] = rd_addr_traninfo0_tlc[FAD-1:0] + 
   //                                             {{(FAD-3){1'b0}},3'b111};
   assign rd_addr_traninfo0_next_tlc[FAD:0] = rd_addr_traninfo0_tlc[FAD:0] + 
                                                {{(FAD-2){1'b0}},3'b111};

   always @(posedge txo_lclk or posedge reset)
     if(reset)
       rd_addr_traninfo0_tlc[FAD:0]   <= {(FAD){1'b0}};
     else if(check_next_dstaddr_tlc)
       rd_addr_traninfo0_tlc[FAD-1:0] <= rd_addr_traninfo0_next_tlc[FAD-1:0];

   assign rd_addr_traninfo1_tlc[FAD-1:0] = rd_addr_traninfo0_tlc[FAD-1:0] +
                                           {{(FAD-2){1'b0}},2'b01};

   assign rd_addr_traninfo2_tlc[FAD-1:0] = rd_addr_traninfo0_tlc[FAD-1:0] +
                                           {{(FAD-2){1'b0}},2'b10};

   //####################################################
   //# Synchronization between rd/wr domains
   //####################################################

   e16_pulse2pulse pulse_wr2rd  (.out         (tran_written_tlc),
                             .outclk      (txo_lclk),
                             .in          (tran_written),
                             .inclk       (cclk),
                             .reset       (reset));

   e16_synchronizer #(.DW(FAD+1)) sync_rd2wr (.out	 (rd_gray_pointer[FAD:0]), 
                                          .in	 (rd_gray_pointer_tlc[FAD:0]), 
					  .clk	 (cclk),
					  .reset (reset));
   

endmodule // link_txo_fifo

module link_txo_interface (/*AUTOARG*/
   // Outputs
   txo_data, txo_frame, txo_wr_wait_int, txo_rd_wait_int,
   // Inputs
   txo_lclk, reset, txo_wr_data_even, txo_wr_data_odd, txo_wr_frame,
   txo_wr_launch_req_tlc, txo_wr_rotate_dis, txo_rd_data_even,
   txo_rd_data_odd, txo_rd_frame, txo_rd_launch_req_tlc,
   txo_rd_rotate_dis
   );

   parameter LW  = `CFG_LW;
   
   //#########
   //# Inputs
   //#########

   input          txo_lclk;
   input 	  reset;

   //# write transactions
   input [LW-1:0]  txo_wr_data_even; //Even byte word
   input [LW-1:0]  txo_wr_data_odd;  //Odd byte word
   input 	   txo_wr_frame;     //indicates new transmission 
   input 	   txo_wr_launch_req_tlc;
   input 	   txo_wr_rotate_dis;
   //# read transactions
   input [LW-1:0]  txo_rd_data_even; //Even byte word
   input [LW-1:0]  txo_rd_data_odd;  //Odd byte word
   input 	   txo_rd_frame;     //indicates new transmission 
   input 	   txo_rd_launch_req_tlc;
   input 	   txo_rd_rotate_dis;

   //############
   //# Outputs
   //############

   output [LW-1:0]  txo_data;      //Byte word
   output 	    txo_frame;     //indicates new transmission 
   
   output 	    txo_wr_wait_int; // Wait to txo_wr (have to stall immediately)
   output 	    txo_rd_wait_int; // Wait to txo_rd (have to stall immediately)

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //##########
   //# REGS
   //##########
   reg [LW-1:0]   data_even_lsl;// Even bytes of the transmission
   reg [LW-1:0]   data_even_lsh;// Even bytes of the transmission
   reg [LW-1:0]   data_odd_lsl; // Odd bytes of the transmission
   reg 		  txo_frame; //indicates transmission of new package

   //###########
   //# WIRES
   //###########
   wire 	 txo_frame_in;   // selected frame of the transmission
   wire [LW-1:0] data_even_in;   // selected even bytes of the transmission
   wire [LW-1:0] data_odd_in;    // selected odd bytes of the transmission
   wire [LW-1:0] txo_data;       // ddr data

   //###########################
   //# Priority arbitration
   //###########################

   assign txo_wr_wait_int = txo_rd_rotate_dis;
   assign txo_rd_wait_int = txo_wr_launch_req_tlc & ~txo_rd_rotate_dis;

   //###########################################
   //#           Transaction mux
   //# The "and" part of the "and-or" mux is
   //# implemented in the link channels blocks  
   //# therefore here we are good with "or" only
   //###########################################

   assign txo_frame_in = txo_wr_frame | txo_rd_frame;

   assign data_even_in[LW-1:0] = txo_wr_data_even[LW-1:0] |
				 txo_rd_data_even[LW-1:0];

   assign data_odd_in[LW-1:0] = txo_wr_data_odd[LW-1:0] |
				txo_rd_data_odd[LW-1:0];

   // ################################
   // # Transaction output
   // ################################
   
   always @ (posedge txo_lclk or posedge reset)
     if (reset)
       begin
	  txo_frame             <= 1'b0;
	  data_even_lsl[LW-1:0] <= {(LW){1'b0}};
	  data_odd_lsl[LW-1:0]  <= {(LW){1'b0}};
       end
     else 
       begin
	  txo_frame              <= txo_frame_in;
 	  data_even_lsl[LW-1:0]  <= data_even_in[LW-1:0];
	  data_odd_lsl[LW-1:0]   <= data_odd_in[LW-1:0];
       end

   // # Creating data that is stable high
   always @ (negedge txo_lclk or posedge reset)
     if (reset)
       data_even_lsh[LW-1:0] <= {(LW){1'b0}};
     else
       data_even_lsh[LW-1:0]  <= data_even_lsl[LW-1:0];

   // #################################
   // # Dual data rate implementation
   // #################################

   assign txo_data[LW-1:0] = txo_lclk ? data_even_lsh[LW-1:0]://stable high data
                                        data_odd_lsl[LW-1:0]; //stable low data


endmodule // link_txo_interface
module link_txo_launcher (/*AUTOARG*/
   // Outputs
   rd_read, check_next_dstaddr, txo_launch_req, txo_rotate_dis,
   tran_frame, tran_byte_even, tran_byte_odd,
   // Inputs
   reset, txo_lclk, txo_rd, txo_cid, cfg_burst_dis, fifo_out,
   tran_written, next_ctrlmode, next_dstaddr, next_datamode,
   next_write, next_access, txo_launch_ack
   );

   parameter LW   = `CFG_LW  ;//lvds tranceiver pairs per side
   parameter AW   = `CFG_AW  ;//address width
   parameter AE   = 4; // Number of "architectural" entries
   parameter PE   = 7; // Number of "physical" entries in the "architectural" one
   parameter FAD  = 5; // Number of bits to access all the entries (2^FAD + 1) > AE*PE

   //##########
   //# INPUTS
   //##########
   input          reset;
   input 	  txo_lclk;  // link transmitter clock   

   input 	  txo_rd;  // this is read transactions channel
   input [1:0] 	  txo_cid; // transmitter channel ID
   //# from configuration register
   input 	  cfg_burst_dis; // control register bursting disable

   //# from the fifo
   input [2*LW-1:0] fifo_out;      
   input 	  tran_written;
   input [3:0] 	  next_ctrlmode;
   input [AW-1:0] next_dstaddr;
   input [1:0] 	  next_datamode;
   input 	  next_write;
   input 	  next_access;

   //# from the arbiter
   input 	  txo_launch_ack;

   //############
   //# OUTPUTS
   //############

   //# to the fifo
   output [FAD:0] rd_read; // Read containing potential jump for bursting
   output 	  check_next_dstaddr; // Next transaction dstaddr can be checked

   //# to the arbiter
   output 	  txo_launch_req; // Launch request
   output 	  txo_rotate_dis; // Arbiter's rotate disable 

   //# to the output mux/buffer
   output 	  tran_frame;       // Frame of the transaction
   output [LW-1:0] tran_byte_even;  // Even byte of the transaction
   output [LW-1:0] tran_byte_odd;   // Odd byte of the transaction

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#############
   //# REGS
   //#############
   reg [AE+1:0]   fifo_trans;
   reg [3:0] 	  ref_ctrlmode;
   reg [AW-1:0]   ref_dstaddr;
   reg [1:0] 	  ref_datamode;
   reg 		  ref_write;
   reg 		  ref_access;
   reg 		  byte0_inc0;
   reg 		  txo_launch_init_req; 
   reg 		  txo_launch_ack_del1;
   reg 		  txo_launch_ack_del2;
   reg 		  tran_frame;
   reg [LW-1:0]   byte_odd_del;
   reg [LW-1:0]   tran_byte_even;
   reg [LW-1:0]   tran_byte_odd;
   reg [2:0] 	  txo_launch_cnt;
   reg 		  burst_req;
   reg [1:0] 	  burst_backup_cnt;

   //#############
   //# WIRES
   //#############
   wire 	  start_new_read;
   wire [AW-1:0]  ref_dstaddr_inc8; //Refernce address incremented by 8
   wire 	  next_inc8_match; // Next address match (incremented by 8)
   wire 	  next_inc0_match; // Next address match (un-incremented)
   wire [7:0] 	  ref_ctrl; // Control type of reference transaction
   wire [7:0] 	  next_ctrl;// Control type of next transaction
   wire 	  type_match; // Reference and next transactions are of the same type
   wire [7:0]	  tran_byte0; // Byte0 of the transaction
   wire 	  burst_tran; // Burst transaction
   wire [2:0] 	  txo_launch_cnt_inc; // Incremented value of the counter
   wire [2:0]	  txo_launch_cnt_next;// Next value of the counter
   wire 	  txo_launch_cnt_max; // The counter reached its maximum value
   wire 	  tran_read;  // Transaction is read (last cycle of the transmission)
   wire 	  jump_4entries;  // Jump forward four entries
   wire 	  jump_3entries;  // Jump forward three entries
   wire 	  jump_3entries_write; // jump over srcaddr part of the tran on write
   wire 	  jump_3entries_read;  // jump over data part of the transaction on read
   wire 	  jump_1entry; // single entry "jump"
   wire [2:0] 	  jump_value;  // value of the jump for read pointer
   wire 	  txo_op_ack;       // "operation" acknowledge
   wire 	  txo_op_ack_first; // first "operation" acknowledge cycle
   wire [LW-1:0]  byte_even_mux;
   wire [LW-1:0]  byte_odd_mux;
   wire [LW-1:0]  byte_even;
   wire [LW-1:0]  byte_odd;
   wire 	  make_gap;     // make gap in the transaction frame
   wire 	  single_write; // single write transaction
   wire 	  double_write; // double write transaction
   wire 	  burst_req_denied; // request of burst transaction is not acknowledged
   wire 	  burst_backup_inc; // burst transaction backup counter increment
   wire [1:0] 	  burst_backup_inc_cnt;  // Incremented burst backup counter
   wire [1:0] 	  burst_backup_next_cnt; // Next burst backup counter value
   wire 	  freeze_fifo;           // FIFO and main counter advance should stoped
   wire sel_ref_byte0; // select byte0 from the reference information of the transaction 
   wire sel_ref_byte1; // select byte1 from the reference information of the transaction 
   wire sel_ref_byte2; // select byte2 from the reference information of the transaction 
   wire sel_ref_byte3; // select byte3 from the reference information of the transaction 
   wire sel_ref_byte4; // select byte4 from the reference information of the transaction 
   wire sel_ref_byte5; // select byte5 from the reference information of the transaction 

   //####################################################
   //#               Interface to the arbiter
   //#
   //#####################################################

   //# When the acknowledge is received on the last cycle of the transaction
   //# and if the next transaction is not a burst transaction then we should  
   //# create an "artificial gap" in the frame signal.
   //# If burst request was denied we should de-assert frame signal 
   
   assign make_gap = tran_read & ~burst_tran;

   always @ (posedge txo_lclk or posedge reset)
     if(reset)
       begin
	  txo_launch_ack_del1 <= 1'b0;
	  txo_launch_ack_del2 <= 1'b0;
       end
     else
       begin
	  txo_launch_ack_del1 <= txo_launch_ack      & ~make_gap;
	  txo_launch_ack_del2 <= txo_launch_ack_del1 & ~burst_req_denied;
       end

   assign txo_op_ack       = txo_launch_ack      &  txo_launch_ack_del1;
   assign txo_op_ack_first = txo_launch_ack_del1 & ~txo_launch_ack_del2;

   //# Request and rotate disable
   //# On the first cycle of the acknowledge the launch count is not incremented
   //# yet, therefore we have to force request and rotate disable "artificially"
   always @ (posedge txo_lclk or posedge reset)
     if (reset)
       txo_launch_init_req <= 1'b0;
     else if(start_new_read)
       txo_launch_init_req <= 1'b1;
     else if(txo_launch_ack)
       txo_launch_init_req <= 1'b0;

   assign txo_launch_req = txo_launch_init_req | 
			    txo_op_ack_first | (|(txo_launch_cnt[2:0]));

   assign txo_rotate_dis = ~txo_launch_init_req & 
			   (txo_op_ack_first | (|(txo_launch_cnt[2:0])));

   //#######################################
   //# Architectural entries state tracking
   //# (written/read transactions tracking)
   //#######################################

   always @ (posedge txo_lclk or posedge reset)
     if(reset)
       fifo_trans[AE+1:0] <= {{(AE+1){1'b0}},1'b1};
     else if(tran_written & ~tran_read)
       fifo_trans[AE+1:0] <= {fifo_trans[AE:0],1'b0};
     else if(tran_read & ~tran_written)
       fifo_trans[AE+1:0] <= {1'b0,fifo_trans[AE+1:1]};

   //# we start new read if:
   //# 1. there is an indication of the first written transaction
   //# 2. transaction is read and the new one is written at the same cycle
   //# 3. transaction is read but there are more already written indicated by fifo_trans
   assign start_new_read = (fifo_trans[0]           & tran_written) |
			   (tran_read               & tran_written) |
			   ((|(fifo_trans[AE+1:2])) & tran_read );

   assign check_next_dstaddr = start_new_read;

   //#####################
   //# Bursting logic
   //#####################

   //# keeping track of the address increment mode of burst transaction
   always @ (posedge txo_lclk or posedge reset)
     if(reset)
       byte0_inc0     <= 1'b0;
     else if(start_new_read)
       byte0_inc0     <= next_inc0_match;
   
   //# reference destination address and controls
   always @(posedge txo_lclk)
     if(start_new_read)
       begin
	  ref_ctrlmode[3:0]   <= next_ctrlmode[3:0];
	  ref_dstaddr[AW-1:0] <= next_dstaddr[AW-1:0];
	  ref_datamode[1:0]   <= next_datamode[1:0];
	  ref_write           <= next_write;
	  ref_access          <= next_access;
       end

   //# transaction type (double write should be known in advance for burst determination)
//   assign single_write = ref_access  & ref_write  & ~(&(ref_datamode[1:0]));
   assign single_write = 1'b0; // No special treatment for single write
   assign double_write = next_access & next_write &  (&(next_datamode[1:0]));

   //# compare address
   assign ref_dstaddr_inc8[AW-1:0] = ref_dstaddr[AW-1:0]+{{(AW-4){1'b0}},4'b1000};

   assign next_inc8_match = (ref_dstaddr_inc8[AW-1:0] == next_dstaddr[AW-1:0]);
   assign next_inc0_match = (ref_dstaddr[AW-1:0]      == next_dstaddr[AW-1:0]);

   assign ref_ctrl[7:0]  = {ref_ctrlmode[3:0], ref_datamode[1:0], ref_write, ref_access};
   assign next_ctrl[7:0] = {next_ctrlmode[3:0],next_datamode[1:0],next_write,next_access};

   assign type_match = (ref_ctrl[7:0] == next_ctrl[7:0]);

   //# burst mode determination
   assign burst_tran = ~cfg_burst_dis  & // bursting is enabled by user
		        start_new_read & // valid cycle
		        tran_read      & // only continuous burst is supported
		        type_match     & // type match
		        double_write   & // double write transaction
		        ((next_inc8_match  & ~byte0_inc0) |  // address match
			 (next_inc0_match  &  byte0_inc0));

   always @ (posedge txo_lclk or posedge reset)
     if (reset)
       burst_req    <= 1'b0;
     else
       burst_req    <= burst_tran;

  //####################################################################################
   //# Composing byte0 of the transaction
   //# 
   //# Byte0 has the following encoding scheme:
   //#
   //#  8'b1?_??_??_<cid>  | New READ transaction 
   //#  8'b0?_??_?0_<cid>  | New WRITE transaction with incremental bursting address 
   //#  8'b0?_??_?1_<cid>  | New WRITE transaction with the same bursting address
   //#
   //#  cid[1:0] - channel id (for debugging usage only in the current version of design)
   //####################################################################################

   assign tran_byte0[7:0] = {txo_rd,4'b0000, byte0_inc0, txo_cid[1:0]};

   //###################################################################
   //#            Order of the transaction fields in the fifo
   //#            -------------------------------------------
   //# Entry "n+6"                 srcaddr[15:0]
   //# Entry "n+5"		  srcaddr[31:16],
   //# Entry "n+4"                  data[15:0],
   //# Entry "n+3"                 data[31:16],
   //# Entry "n+2"  dstaddr[11:0],datamode[1:0],write,access,
   //# Entry "n+1"	          dstaddr[27:12],
   //# Entry "n"          "zevel",ctrlmode[3:0],dstaddr[31:28],
   //#            --------------------------------------------
   //####################################################################

   //# 4 entries jump on burst transaction (counter comparison is redundant but used
   //# here to underline the mutex between different jumps)
   assign jump_4entries = burst_tran & (txo_launch_cnt[2:0] == 3'b110);
   //# 3 entries jump on single write or read
   assign jump_3entries = jump_3entries_write | 
			  jump_3entries_read;
   //# single write will jump 3 entries to the end of the transaction
   assign jump_3entries_write = single_write & (txo_launch_cnt[2:0] == 3'b100); 
   //# read transaction will jump 3 entries over the data part of that transaction
   //assign jump_3entries_read = ~ref_write & (txo_launch_cnt[2:0] == 3'b010);
   //# read jump over data feature is disabled because of the test-and-set instr.
   assign jump_3entries_read = 1'b0;
   //# single jump when acknowledged and no other jumps and no freeze control
   assign jump_1entry = ~(jump_4entries | jump_3entries | freeze_fifo) & txo_op_ack;

   //###########################################################
   //# Counter/FIFO Read Pointer increment prevention mechanism
   //# when bursting is not acknowledged.
   //# When burst_backup_cnt[1:0] is not zero, the counter and
   //# FIFO read pointers won't advance and the data out
   //# will be selected from the reference controls and address
   //###########################################################

   assign burst_req_denied = burst_req   & ~txo_op_ack;
   assign burst_backup_inc = freeze_fifo &  txo_op_ack;

   assign burst_backup_inc_cnt[1:0]  = burst_backup_cnt[1:0] + 2'b01;

   assign burst_backup_next_cnt[1:0] = burst_req_denied ? 2'b01 :
				       burst_backup_inc ? burst_backup_inc_cnt[1:0] :
				                          burst_backup_cnt[1:0];

   always @ (posedge txo_lclk or posedge reset)
     if(reset)
       burst_backup_cnt[1:0] <= 2'b00;
     else
       burst_backup_cnt[1:0] <= burst_backup_next_cnt[1:0];

   assign freeze_fifo = |(burst_backup_cnt[1:0]);

   //###################################################################
   //#       Launch Counter vs. FIFO Read Pointer:
   //# FIFO Read Pointer is incremented in the range 0-6
   //# relative to any particular entry pointed out in a particular
   //# cycle.
   //# Launch Counter on the other hand is incremented in the same 
   //# range of 0-6 but relative to a specific counter state.
   //# For example, FIFO Read Pointer can have a jump of 4 from any
   //# entry, while Launch Counter will have a jump of 4 only if
   //# the current state of the counter is 3'b110 (+ some conditions)
   //#
   //# This difference in behavior is caused by the fact that 
   //# for every transaction in the counter we have to go through all
   //# the eight existing states of the counter, while it will take
   //# only six entriest of the FIFO.
   //###################################################################         

   //# FIFO Read Pointer Jump Value
   assign jump_value[2:0] = ({(3){jump_4entries}} & 3'b100) |
			    ({(3){jump_3entries}} & 3'b011) |
			    ({(3){jump_1entry}}   & 3'b001);

   assign rd_read[FAD:0] = {{(FAD-2){1'b0}},jump_value[2:0]};

   //# Counter Next Cycle Value
   assign txo_launch_cnt_max = (txo_launch_cnt[2:0] == 3'b110);

   assign txo_launch_cnt_inc[2:0] = txo_launch_cnt[2:0] + {2'b00,jump_1entry};

   assign txo_launch_cnt_next[2:0] =  jump_4entries ? 3'b011 :
	 (jump_3entries_write | txo_launch_cnt_max) ? 3'b000 :
			         jump_3entries_read ? 3'b101 : txo_launch_cnt_inc[2:0];

   //# Launch counter
   always @ (posedge txo_lclk or posedge reset)
     if (reset)
       txo_launch_cnt[2:0] <= 3'b000;
     else if(txo_op_ack)
       txo_launch_cnt[2:0] <= txo_launch_cnt_next[2:0];

   //#############################################
   //# Completion of the transaction transmission 
   //#############################################

   assign tran_read = (~single_write & (txo_launch_cnt[2:0] == 3'b110)) |
		      ( single_write & (txo_launch_cnt[2:0] == 3'b100));

   //##################################################
   //# Even/Odd bytes construction + tran out sampling
   //##################################################

   assign sel_ref_byte0 = txo_op_ack_first;
   assign sel_ref_byte2 = (burst_backup_cnt[1:0] == 2'b10);
   assign sel_ref_byte4 = (burst_backup_cnt[1:0] == 2'b11);

   assign sel_ref_byte1 = (burst_backup_cnt[1:0] == 2'b01);
   assign sel_ref_byte3 = (burst_backup_cnt[1:0] == 2'b10);
   assign sel_ref_byte5 = (burst_backup_cnt[1:0] == 2'b11);

   assign byte_even_mux[LW-1:0] = sel_ref_byte0 ? tran_byte0[7:0]    :
				  sel_ref_byte2 ? ref_dstaddr[27:20] :
				  sel_ref_byte4 ? ref_dstaddr[11:4]  :
				                  fifo_out[2*LW-1:LW];

   assign byte_odd_mux[LW-1:0] = sel_ref_byte1 ? {ref_ctrlmode[3:0],ref_dstaddr[31:28]} :
				 sel_ref_byte3 ? ref_dstaddr[19:12] :
	      sel_ref_byte5 ? {ref_dstaddr[3:0],ref_datamode[1:0],ref_write,ref_access} :
				                 fifo_out[LW-1:0];

   assign byte_even[LW-1:0] = {(LW){txo_op_ack}} & byte_even_mux[LW-1:0];
   assign byte_odd[LW-1:0]  = {(LW){txo_op_ack}} & byte_odd_mux[LW-1:0];

   always @ (posedge txo_lclk or posedge reset)
     if(reset)
       tran_frame <= 1'b0;
     else
       tran_frame <= txo_launch_ack_del2;

   always @ (posedge txo_lclk)
     begin
	byte_odd_del[LW-1:0]   <= byte_odd[LW-1:0];
	tran_byte_odd[LW-1:0]  <= byte_odd_del[LW-1:0];
	tran_byte_even[LW-1:0] <= byte_even[LW-1:0];
     end

   //###################
   //# ERROR CHECKERS 
   //###################
   // synthesis translate_off
   always @*
     if(~(|(fifo_trans[AE+1:0])) & $time>0)
       $display("ERROR>>link launcher mechanism is broken in cell %m");

   always @*
     if(((jump_4entries       & (jump_3entries_read | jump_3entries_write | jump_1entry))|
	 (jump_3entries_read  & (                     jump_3entries_write | jump_1entry))|
	 (jump_3entries_write & (                                           jump_1entry)))
	& $time>0)
       $display("ERROR>>detected more than one jump for launcher mechanism in cell %m");
   // synthesis translate_on


endmodule // link_txo_launcher
module link_txo_mesh_channel (/*AUTOARG*/
   // Outputs
   emesh_wait_out, mesh_wait_out, txo_launch_req_tlc,
   txo_rotate_dis_tlc, tran_frame_tlc, tran_byte_even_tlc,
   tran_byte_odd_tlc,
   // Inputs
   cclk, cclk_en, txo_lclk, reset, ext_yid_k, ext_xid_k, who_am_i,
   txo_rd, txo_cid, cfg_multicast_dis, cfg_burst_dis, emesh_tran_in,
   emesh_frame_in, mesh_access_in, mesh_write_in, mesh_dstaddr_in,
   mesh_srcaddr_in, mesh_data_in, mesh_datamode_in, mesh_ctrlmode_in,
   txo_launch_ack_tlc
   );

   parameter AW   = `CFG_AW  ;//address width
   parameter DW   = `CFG_DW  ;//data width  
   parameter LW   = `CFG_LW  ;//lvds tranceiver pairs per side
   parameter FW   = `CFG_NW*`CFG_LW;
   parameter FAD  = 5; // Number of bits to access all the entries (2^FAD + 1) > AE*PE

   //##########
   //# INPUTS
   //##########

   input 	  cclk;     // clock of the score the emesh comes from
   input 	  cclk_en;  // clock enable 
   input 	  txo_lclk; // clock of the link transmitter
   input          reset;
   input [3:0] 	  ext_yid_k; //external y-id 
   input [3:0] 	  ext_xid_k; //external x-id
   input [3:0]	  who_am_i;  // specifies what link is that (north,east,south,west)

   input 	  txo_rd;  // this is read transactions channel
   input [1:0] 	  txo_cid; // transmitter channel ID
   input 	  cfg_multicast_dis; // control register multicast disable
   input 	  cfg_burst_dis; // control register bursting disable

   //# from the EMESH
   input [2*LW-1:0] emesh_tran_in;  // serialized transaction
   input 	    emesh_frame_in; // transaction frame

   //# from the MESH
   input 	  mesh_access_in;  // access control from the mesh
   input 	  mesh_write_in;   // write control from the mesh
   input [AW-1:0] mesh_dstaddr_in; // destination address from the mesh
   input [AW-1:0] mesh_srcaddr_in; // source address from the mesh
   input [DW-1:0] mesh_data_in;    // data from the mesh
   input [1:0] 	  mesh_datamode_in;// data mode from the mesh 
   input [3:0] 	  mesh_ctrlmode_in;// ctrl mode from the mesh

   //# from the arbiter
   input 	  txo_launch_ack_tlc;

   //###########
   //# OUTPUTS
   //###########
   //# to emesh
   output 	  emesh_wait_out; // wait to the emesh   

   //# to mesh
   output 	  mesh_wait_out; // wait to the mesh   

   //# to the arbiter
   output 	  txo_launch_req_tlc; // Launch request
   output 	  txo_rotate_dis_tlc; // Arbiter's rotate disable 

   //# to the output mux/buffer
   output 	   tran_frame_tlc;      // Frame of the transaction
   output [LW-1:0] tran_byte_even_tlc;  // Even byte of the transaction
   output [LW-1:0] tran_byte_odd_tlc;   // Odd byte of the transaction

   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			access_reg;		// From mesh_interface of e16_mesh_interface.v
   wire			check_next_dstaddr_tlc;	// From link_txo_launcher of link_txo_launcher.v
   wire [3:0]		ctrlmode_reg;		// From mesh_interface of e16_mesh_interface.v
   wire [DW-1:0]	data_reg;		// From mesh_interface of e16_mesh_interface.v
   wire [1:0]		datamode_reg;		// From mesh_interface of e16_mesh_interface.v
   wire [AW-1:0]	dstaddr_reg;		// From mesh_interface of e16_mesh_interface.v
   wire [2*LW-1:0]	fifo_out_tlc;		// From link_txo_fifo of link_txo_fifo.v
   wire			mesh_frame;		// From link_txo_mesh_launcher of link_txo_mesh_launcher.v
   wire			mesh_req;		// From link_txo_mesh_launcher of link_txo_mesh_launcher.v
   wire			mesh_rotate_dis;	// From link_txo_mesh_launcher of link_txo_mesh_launcher.v
   wire [2*LW-1:0]	mesh_tran;		// From link_txo_mesh_launcher of link_txo_mesh_launcher.v
   wire			mesh_wait_int;		// From link_txo_mesh_launcher of link_txo_mesh_launcher.v
   wire			next_access_tlc;	// From link_txo_fifo of link_txo_fifo.v
   wire [3:0]		next_ctrlmode_tlc;	// From link_txo_fifo of link_txo_fifo.v
   wire [1:0]		next_datamode_tlc;	// From link_txo_fifo of link_txo_fifo.v
   wire [AW-1:0]	next_dstaddr_tlc;	// From link_txo_fifo of link_txo_fifo.v
   wire			next_write_tlc;		// From link_txo_fifo of link_txo_fifo.v
   wire [FAD:0]		rd_read_tlc;		// From link_txo_launcher of link_txo_launcher.v
   wire [AW-1:0]	srcaddr_reg;		// From mesh_interface of e16_mesh_interface.v
   wire			tran_written_tlc;	// From link_txo_fifo of link_txo_fifo.v
   wire			wr_fifo_full;		// From link_txo_fifo of link_txo_fifo.v
   wire			write_reg;		// From mesh_interface of e16_mesh_interface.v
   // End of automatics

   //#######################
   //# Transaction Launcher
   //#######################

   /* link_txo_launcher AUTO_TEMPLATE (
                                       .txo_rotate_dis	(txo_rotate_dis_tlc), 
                                       .reset		(reset),
                                       .txo_lclk	(txo_lclk),
                                       .txo_rd          (txo_rd),
                                       .txo_cid		(txo_cid[1:0]),
                                       .cfg_burst_dis	(cfg_burst_dis),
                                       .\(.*\)          (\1_tlc[]),
                                      );
    */

   link_txo_launcher #(.FAD(FAD)) link_txo_launcher(/*AUTOINST*/
						    // Outputs
						    .rd_read		(rd_read_tlc[FAD:0]), // Templated
						    .check_next_dstaddr	(check_next_dstaddr_tlc), // Templated
						    .txo_launch_req	(txo_launch_req_tlc), // Templated
						    .txo_rotate_dis	(txo_rotate_dis_tlc), // Templated
						    .tran_frame		(tran_frame_tlc), // Templated
						    .tran_byte_even	(tran_byte_even_tlc[LW-1:0]), // Templated
						    .tran_byte_odd	(tran_byte_odd_tlc[LW-1:0]), // Templated
						    // Inputs
						    .reset		(reset),	 // Templated
						    .txo_lclk		(txo_lclk),	 // Templated
						    .txo_rd		(txo_rd),	 // Templated
						    .txo_cid		(txo_cid[1:0]),	 // Templated
						    .cfg_burst_dis	(cfg_burst_dis), // Templated
						    .fifo_out		(fifo_out_tlc[2*LW-1:0]), // Templated
						    .tran_written	(tran_written_tlc), // Templated
						    .next_ctrlmode	(next_ctrlmode_tlc[3:0]), // Templated
						    .next_dstaddr	(next_dstaddr_tlc[AW-1:0]), // Templated
						    .next_datamode	(next_datamode_tlc[1:0]), // Templated
						    .next_write		(next_write_tlc), // Templated
						    .next_access	(next_access_tlc), // Templated
						    .txo_launch_ack	(txo_launch_ack_tlc)); // Templated

   //########
   //# FIFO
   //########
   
   link_txo_fifo #(.FAD(FAD)) link_txo_fifo(.tran_in		(mesh_tran[2*LW-1:0]),
					    .frame_in		(mesh_frame),
					    /*AUTOINST*/
					    // Outputs
					    .wr_fifo_full	(wr_fifo_full),
					    .fifo_out_tlc	(fifo_out_tlc[2*LW-1:0]),
					    .tran_written_tlc	(tran_written_tlc),
					    .next_ctrlmode_tlc	(next_ctrlmode_tlc[3:0]),
					    .next_dstaddr_tlc	(next_dstaddr_tlc[AW-1:0]),
					    .next_datamode_tlc	(next_datamode_tlc[1:0]),
					    .next_write_tlc	(next_write_tlc),
					    .next_access_tlc	(next_access_tlc),
					    // Inputs
					    .reset		(reset),
					    .cclk		(cclk),
					    .cclk_en		(cclk_en),
					    .txo_lclk		(txo_lclk),
					    .rd_read_tlc	(rd_read_tlc[FAD:0]),
					    .check_next_dstaddr_tlc(check_next_dstaddr_tlc));

  
   //##################################
   //#    Interface with mesh
   //# on input transactions only
   //# * output to the mesh is driven
   //# by a diferent block
   //##################################

   /*e16_mesh_interface AUTO_TEMPLATE (
                                    .clk               (cclk),
                                    .clk_en            (cclk_en),
                                    .wait_int          (mesh_wait_int),
				    .wait_out	       (mesh_wait_out),	
                                    .\(.*\)_out        (),
                                    .wait_in           (1'b0),
                                    .\(.*\)_in         (mesh_\1_in[]),
    				    .access	       (1'b0),
				    .write 	       (1'b0),
				    .datamode	       (2'b00),
				    .ctrlmode	       (4'b0000),
				    .data	       ({(DW){1'b0}}),
				    .dstaddr	       ({(AW){1'b0}}),
				    .srcaddr	       ({(AW){1'b0}}),
                                   );
    */
   e16_mesh_interface mesh_interface(/*AUTOINST*/
				     // Outputs
				     .wait_out		(mesh_wait_out), // Templated
				     .access_out	(),		 // Templated
				     .write_out		(),		 // Templated
				     .datamode_out	(),		 // Templated
				     .ctrlmode_out	(),		 // Templated
				     .data_out		(),		 // Templated
				     .dstaddr_out	(),		 // Templated
				     .srcaddr_out	(),		 // Templated
				     .access_reg	(access_reg),
				     .write_reg		(write_reg),
				     .datamode_reg	(datamode_reg[1:0]),
				     .ctrlmode_reg	(ctrlmode_reg[3:0]),
				     .data_reg		(data_reg[DW-1:0]),
				     .dstaddr_reg	(dstaddr_reg[AW-1:0]),
				     .srcaddr_reg	(srcaddr_reg[AW-1:0]),
				     // Inputs
				     .clk		(cclk),		 // Templated
				     .clk_en		(cclk_en),	 // Templated
				     .reset		(reset),
				     .wait_in		(1'b0),		 // Templated
				     .access_in		(mesh_access_in), // Templated
				     .write_in		(mesh_write_in), // Templated
				     .datamode_in	(mesh_datamode_in[1:0]), // Templated
				     .ctrlmode_in	(mesh_ctrlmode_in[3:0]), // Templated
				     .data_in		(mesh_data_in[DW-1:0]), // Templated
				     .dstaddr_in	(mesh_dstaddr_in[AW-1:0]), // Templated
				     .srcaddr_in	(mesh_srcaddr_in[AW-1:0]), // Templated
				     .wait_int		(mesh_wait_int), // Templated
				     .access		(1'b0),		 // Templated
				     .write		(1'b0),		 // Templated
				     .datamode		(2'b00),	 // Templated
				     .ctrlmode		(4'b0000),	 // Templated
				     .data		({(DW){1'b0}}),	 // Templated
				     .dstaddr		({(AW){1'b0}}),	 // Templated
				     .srcaddr		({(AW){1'b0}}));	 // Templated


   //#################################
   //# MESH Transaction Launcher
   //#################################
   
   link_txo_mesh_launcher link_txo_mesh_launcher(.mesh_grant		(~wr_fifo_full),
						 /*AUTOINST*/
						 // Outputs
						 .mesh_wait_int		(mesh_wait_int),
						 .mesh_req		(mesh_req),
						 .mesh_rotate_dis	(mesh_rotate_dis),
						 .mesh_tran		(mesh_tran[2*LW-1:0]),
						 .mesh_frame		(mesh_frame),
						 // Inputs
						 .cclk			(cclk),
						 .cclk_en		(cclk_en),
						 .reset			(reset),
						 .ext_yid_k		(ext_yid_k[3:0]),
						 .ext_xid_k		(ext_xid_k[3:0]),
						 .who_am_i		(who_am_i[3:0]),
						 .cfg_multicast_dis	(cfg_multicast_dis),
						 .access_reg		(access_reg),
						 .write_reg		(write_reg),
						 .datamode_reg		(datamode_reg[1:0]),
						 .ctrlmode_reg		(ctrlmode_reg[3:0]),
						 .data_reg		(data_reg[DW-1:0]),
						 .dstaddr_reg		(dstaddr_reg[AW-1:0]),
						 .srcaddr_reg		(srcaddr_reg[AW-1:0]));

endmodule // link_txo_mesh_channel
module link_txo_mesh_launcher(/*AUTOARG*/
   // Outputs
   mesh_wait_int, mesh_req, mesh_rotate_dis, mesh_tran, mesh_frame,
   // Inputs
   cclk, cclk_en, reset, ext_yid_k, ext_xid_k, who_am_i,
   cfg_multicast_dis, access_reg, write_reg, datamode_reg,
   ctrlmode_reg, data_reg, dstaddr_reg, srcaddr_reg, mesh_grant
   );

   parameter AW   = `CFG_AW  ;//address width
   parameter DW   = `CFG_DW  ;//data width  
   parameter LW   = `CFG_LW  ;//lvds tranceiver pairs per side

   //##########
   //# INPUTS
   //##########
   input 	  cclk;      // clock of the score the emesh comes from
   input 	  cclk_en;   // clock enable 
   input          reset;
   input [3:0] 	  ext_yid_k; // external y-id 
   input [3:0] 	  ext_xid_k; // external x-id
   input [3:0]	  who_am_i;  // specifies what link is that (north,east,south,west)

   input 	  cfg_multicast_dis; // control register multicast disable

   //# input transaction (after mesh interface)
   input 	  access_reg;
   input 	  write_reg;
   input [1:0] 	  datamode_reg;
   input [3:0] 	  ctrlmode_reg;   		    
   input [DW-1:0] data_reg;
   input [AW-1:0] dstaddr_reg;
   input [AW-1:0] srcaddr_reg;  

   //# from the mesh/emesh arbiter
   input 	  mesh_grant;

   //############
   //# OUTPUTS
   //############

   //# to the mesh interface
   output 	  mesh_wait_int; // Wait indication

   //# to the arbiter
   output 	  mesh_req; // Launch request to the arbiter
   output 	  mesh_rotate_dis; // Arbiter's rotate disable 

   //# to the output mux/buffer
   output [2*LW-1:0] mesh_tran;  // transaction data
   output 	     mesh_frame; // mesh frame

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#############
   //# REGS
   //#############
   reg [2:0]   mesh_pointer;

   //#############
   //# WIRES
   //#############
   wire        multicast_tran_valid; // Valid multicast transaction
   wire        multicast_tran; // transaction is of the multicast type
   wire [3:0]  ycoord_k_n; // inverted external y coordinates
   wire [3:0]  xcoord_k_n; // inverted external x coordinates
   wire [3:0]  addr_y; // external y coordinates of the source address
   wire [3:0]  addr_x; // external x coordinates of the source address
   wire        ext_yzero;
   wire        ext_xzero;
   wire [4:0]  ext_xdiff;
   wire [4:0]  ext_ydiff;
   wire        ext_xcarry;   
   wire        ext_ycarry;   
   wire        ext_xgt;   
   wire        ext_xlt;   
   wire        ext_ygt;   
   wire        ext_ylt;   
   wire        route_east;   
   wire        route_west;   
   wire        route_north;   
   wire        route_south;   
   wire        route_east_normal;   
   wire        route_west_normal;   
   wire        route_north_normal;   
   wire        route_south_normal;   
   wire        route_east_multicast;   
   wire        route_west_multicast;   
   wire        route_north_multicast;   
   wire        route_south_multicast;   
   wire [3:0]  route_sides; // where to route {north,east,south,west}
   wire        route_out;   // Route out of this link was detected
   wire        mesh_ack;
   wire        mesh_ack_n;
   wire        mesh_last_tran;
   wire [2:0]  mesh_pointer_incr;
   wire [6:0]  launcher_sel;
   wire [14*LW-1:0] mesh_tran_in;

   //###########################################
   //# Valid MESH-to-LINK transaction detection
   //###########################################

   //# Multicast transaction detection
   assign multicast_tran = write_reg & 
			   (ctrlmode_reg[1:0]==2'b11) & ~(datamode_reg[1:0] == 2'b11);

   //# External source or destination address of the transaction for the comparison
//   assign addr_y[2:0] = multicast_tran ? srcaddr_reg[31:29] : dstaddr_reg[31:29];
//   assign addr_x[2:0] = multicast_tran ? srcaddr_reg[28:26] : dstaddr_reg[28:26];
   assign addr_y[3:0] = multicast_tran ? srcaddr_reg[31:28] : dstaddr_reg[31:28];
   assign addr_x[3:0] = multicast_tran ? srcaddr_reg[25:22] : dstaddr_reg[25:22];

   //# External address based router
   assign ycoord_k_n[3:0] = ~ext_yid_k[3:0];
   assign xcoord_k_n[3:0] = ~ext_xid_k[3:0];

   //# External address comparison 
   assign ext_yzero      = addr_y[3:0]==ext_yid_k[3:0];
   assign ext_xzero      = addr_x[3:0]==ext_xid_k[3:0];   
   assign ext_ydiff[4:0] = addr_y[3:0] + ycoord_k_n[3:0] + 1'b1 ; 
   assign ext_xdiff[4:0] = addr_x[3:0] + xcoord_k_n[3:0] + 1'b1 ;
   assign ext_xcarry     = ext_xdiff[4]; //result is positive or zero
   assign ext_ycarry     = ext_ydiff[4]; //result is positive or zero    
   assign ext_xgt        = ext_xcarry & ~ext_xzero;// src/dst X-address is greater than
   assign ext_xlt        = ~ext_xcarry;  // src/dst X-address is less than
   assign ext_ygt        = ext_ycarry & ~ext_yzero;// src/dst Y-address is greater than
   assign ext_ylt        = ~ext_ycarry;  // src/dst Y-address is less than 

   //# NON-MULTICAST ROUTING
   assign route_east_normal   =  ext_xgt;   
   assign route_west_normal   =  ext_xlt;
   assign route_south_normal  =  ext_ygt & ext_xzero;
   assign route_north_normal  =  ext_ylt & ext_xzero;

   //# MULTICAST ROUTING
   assign route_east_multicast  = (ext_xlt | ext_xzero) & ext_yzero;
   assign route_west_multicast  = (ext_xgt | ext_xzero) & ext_yzero;
   assign route_south_multicast =  ext_ylt | ext_yzero;
   assign route_north_multicast =  ext_ygt | ext_yzero;

   //# normal-multicast selection
   assign route_east  = multicast_tran ? route_east_multicast  : route_east_normal;
   assign route_west  = multicast_tran ? route_west_multicast  : route_west_normal;
   assign route_south = multicast_tran ? route_south_multicast : route_south_normal;
   assign route_north = multicast_tran ? route_north_multicast : route_north_normal;

   assign route_sides[3:0] = 4'b1111;//{route_north,route_east,route_south,route_west};
   assign route_out = |(who_am_i[3:0] & route_sides[3:0]);

   //# Request
   assign mesh_req = access_reg & route_out & ((multicast_tran & ~cfg_multicast_dis) |
					       ~multicast_tran);

   //# Wait
   assign mesh_ack_n    = mesh_req & ~mesh_grant;
   assign mesh_ack      = mesh_req &  mesh_grant;
   assign mesh_wait_int = mesh_req & ~mesh_last_tran | mesh_ack_n;

   //############################################
   //# Transaction launcher state machine
   //############################################

   assign mesh_last_tran = mesh_pointer[2] & mesh_pointer[1] & ~mesh_pointer[0];
                        
   assign mesh_pointer_incr[2:0] = mesh_last_tran ? 3'b000 :
				   (mesh_pointer[2:0] + 3'b001);

   always @ (posedge cclk or posedge reset)
     if(reset)
       mesh_pointer[2:0] <= 3'b000;
     else if(cclk_en)
       if (mesh_ack)
	 mesh_pointer[2:0] <= mesh_pointer_incr[2:0];

   assign launcher_sel[0] = (mesh_pointer[2:0] == 3'b000);
   assign launcher_sel[1] = (mesh_pointer[2:0] == 3'b001);
   assign launcher_sel[2] = (mesh_pointer[2:0] == 3'b010);
   assign launcher_sel[3] = (mesh_pointer[2:0] == 3'b011);
   assign launcher_sel[4] = (mesh_pointer[2:0] == 3'b100);
   assign launcher_sel[5] = (mesh_pointer[2:0] == 3'b101);
   assign launcher_sel[6] = (mesh_pointer[2:0] == 3'b110);

   assign mesh_frame      =   mesh_req & ~mesh_last_tran;
   assign mesh_rotate_dis = |(mesh_pointer[2:0]);

   //#############################
   //# mesh transaction 7:1 mux
   //#############################

   //# We are launching in the following order (MSBs first):
   assign mesh_tran_in[14*LW-1:0]={
                                srcaddr_reg[7:0],{(LW){1'b0}},
				   srcaddr_reg[23:8],
			    data_reg[7:0],srcaddr_reg[31:24],
				   data_reg[23:8],
	 dstaddr_reg[3:0],datamode_reg[1:0],write_reg,access_reg,data_reg[31:24],
				   dstaddr_reg[19:4],
			  ctrlmode_reg[3:0],dstaddr_reg[31:20]
                                   };

   e16_mux7 #(2*LW) mux7(// Outputs
		     .out (mesh_tran[2*LW-1:0]),
		     // Inputs
		     .in0 (mesh_tran_in[2*LW-1:0]),      .sel0 (launcher_sel[0]),
		     .in1 (mesh_tran_in[4*LW-1:2*LW]),   .sel1 (launcher_sel[1]),
		     .in2 (mesh_tran_in[6*LW-1:4*LW]),   .sel2 (launcher_sel[2]),
		     .in3 (mesh_tran_in[8*LW-1:6*LW]),   .sel3 (launcher_sel[3]),
		     .in4 (mesh_tran_in[10*LW-1:8*LW]),  .sel4 (launcher_sel[4]),
		     .in5 (mesh_tran_in[12*LW-1:10*LW]), .sel5 (launcher_sel[5]),
		     .in6 (mesh_tran_in[14*LW-1:12*LW]), .sel6 (launcher_sel[6]));


endmodule // link_txo_mesh_launcher
//#############################################################
//# This block is a transmitter of the read transactions only
//# Read transactions can be sent out off the chip from
//# rdmesh only
//#############################################################

module link_txo_rd (/*AUTOARG*/
   // Outputs
   txo_rd_data_even, txo_rd_data_odd, txo_rd_frame,
   txo_rd_launch_req_tlc, txo_rd_rotate_dis, c0_rdmesh_wait_out,
   c1_rdmesh_wait_out, c2_rdmesh_wait_out, c3_rdmesh_wait_out,
   // Inputs
   txo_lclk, reset, txo_rd_wait, txo_rd_wait_int, c0_clk_in,
   c1_clk_in, c2_clk_in, c3_clk_in, c0_rdmesh_tran_in,
   c0_rdmesh_frame_in, c1_rdmesh_tran_in, c1_rdmesh_frame_in,
   c2_rdmesh_tran_in, c2_rdmesh_frame_in, c3_rdmesh_tran_in,
   c3_rdmesh_frame_in
   );

   parameter LW   = `CFG_LW  ;//lvds tranceiver pairs per side

   // #########
   // # Inputs
   // #########

   input 	txo_lclk;  //transmit clock to be used internally
   input        reset;

   // # from io
   input 	txo_rd_wait; // Wait from the receiver
   input 	txo_rd_wait_int;  //wait indicator for read transactions
   // # Clocks
   input 	c0_clk_in;   //clock of the core  
   input 	c1_clk_in;   //clock of the core  
   input 	c2_clk_in;   //clock of the core  
   input 	c3_clk_in;   //clock of the core  

   // # RDMESH
   input [2*LW-1:0] c0_rdmesh_tran_in;  // serialized transaction
   input 	    c0_rdmesh_frame_in; // transaction frame
   input [2*LW-1:0] c1_rdmesh_tran_in;  // serialized transaction
   input 	    c1_rdmesh_frame_in; // transaction frame
   input [2*LW-1:0] c2_rdmesh_tran_in;  // serialized transaction
   input 	    c2_rdmesh_frame_in; // transaction frame
   input [2*LW-1:0] c3_rdmesh_tran_in;  // serialized transaction
   input 	    c3_rdmesh_frame_in; // transaction frame

   // ##############
   // # Outputs
   // ##############

   // to the txo_interface
   output [LW-1:0] txo_rd_data_even; //Even byte word
   output [LW-1:0] txo_rd_data_odd;  //Odd byte word
   output 	   txo_rd_frame; //indicates new transmission 
   output 	   txo_rd_launch_req_tlc;
   output 	   txo_rd_rotate_dis;

   output 	   c0_rdmesh_wait_out; // wait to the rdmesh   
   output 	   c1_rdmesh_wait_out; // wait to the rdmesh   
   output 	   c2_rdmesh_wait_out; // wait to the rdmesh   
   output 	   c3_rdmesh_wait_out; // wait to the rdmesh   

   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [LW-1:0]	c0_tran_byte_even_tlc;	// From c0_link_txo_channel of link_txo_channel.v
   wire [LW-1:0]	c0_tran_byte_odd_tlc;	// From c0_link_txo_channel of link_txo_channel.v
   wire			c0_tran_frame_tlc;	// From c0_link_txo_channel of link_txo_channel.v
   wire			c0_txo_launch_ack_tlc;	// From link_txo_arbiter of link_txo_arbiter.v
   wire			c0_txo_launch_req_tlc;	// From c0_link_txo_channel of link_txo_channel.v
   wire			c0_txo_rotate_dis;	// From c0_link_txo_channel of link_txo_channel.v
   wire [LW-1:0]	c1_tran_byte_even_tlc;	// From c1_link_txo_channel of link_txo_channel.v
   wire [LW-1:0]	c1_tran_byte_odd_tlc;	// From c1_link_txo_channel of link_txo_channel.v
   wire			c1_tran_frame_tlc;	// From c1_link_txo_channel of link_txo_channel.v
   wire			c1_txo_launch_ack_tlc;	// From link_txo_arbiter of link_txo_arbiter.v
   wire			c1_txo_launch_req_tlc;	// From c1_link_txo_channel of link_txo_channel.v
   wire			c1_txo_rotate_dis;	// From c1_link_txo_channel of link_txo_channel.v
   wire [LW-1:0]	c2_tran_byte_even_tlc;	// From c2_link_txo_channel of link_txo_channel.v
   wire [LW-1:0]	c2_tran_byte_odd_tlc;	// From c2_link_txo_channel of link_txo_channel.v
   wire			c2_tran_frame_tlc;	// From c2_link_txo_channel of link_txo_channel.v
   wire			c2_txo_launch_ack_tlc;	// From link_txo_arbiter of link_txo_arbiter.v
   wire			c2_txo_launch_req_tlc;	// From c2_link_txo_channel of link_txo_channel.v
   wire			c2_txo_rotate_dis;	// From c2_link_txo_channel of link_txo_channel.v
   wire [LW-1:0]	c3_tran_byte_even_tlc;	// From c3_link_txo_channel of link_txo_channel.v
   wire [LW-1:0]	c3_tran_byte_odd_tlc;	// From c3_link_txo_channel of link_txo_channel.v
   wire			c3_tran_frame_tlc;	// From c3_link_txo_channel of link_txo_channel.v
   wire			c3_txo_launch_ack_tlc;	// From link_txo_arbiter of link_txo_arbiter.v
   wire			c3_txo_launch_req_tlc;	// From c3_link_txo_channel of link_txo_channel.v
   wire			c3_txo_rotate_dis;	// From c3_link_txo_channel of link_txo_channel.v
   // End of automatics

   // ##########
   // # WIRES
   // ##########

   wire [1:0] 	     c0_txo_cid;//channel 0 ID
   wire [1:0] 	     c1_txo_cid;//channel 1 ID
   wire [1:0] 	     c2_txo_cid;//channel 2 ID
   wire [1:0] 	     c3_txo_cid;//channel 3 ID

   // ################################
   // # Transmit buffer instantiation
   // ################################

   /*link_txo_buffer AUTO_TEMPLATE(
                                  .txo_data_even (txo_rd_data_even[]),
                                  .txo_data_odd  (txo_rd_data_odd[]),
                                  .txo_frame     (txo_rd_frame),
                                   );
    */
   link_txo_buffer link_txo_buffer(/*AUTOINST*/
				   // Outputs
				   .txo_data_even	(txo_rd_data_even[LW-1:0]), // Templated
				   .txo_data_odd	(txo_rd_data_odd[LW-1:0]), // Templated
				   .txo_frame		(txo_rd_frame),	 // Templated
				   // Inputs
				   .c0_tran_frame_tlc	(c0_tran_frame_tlc),
				   .c0_tran_byte_even_tlc(c0_tran_byte_even_tlc[LW-1:0]),
				   .c0_tran_byte_odd_tlc(c0_tran_byte_odd_tlc[LW-1:0]),
				   .c1_tran_frame_tlc	(c1_tran_frame_tlc),
				   .c1_tran_byte_even_tlc(c1_tran_byte_even_tlc[LW-1:0]),
				   .c1_tran_byte_odd_tlc(c1_tran_byte_odd_tlc[LW-1:0]),
				   .c2_tran_frame_tlc	(c2_tran_frame_tlc),
				   .c2_tran_byte_even_tlc(c2_tran_byte_even_tlc[LW-1:0]),
				   .c2_tran_byte_odd_tlc(c2_tran_byte_odd_tlc[LW-1:0]),
				   .c3_tran_frame_tlc	(c3_tran_frame_tlc),
				   .c3_tran_byte_even_tlc(c3_tran_byte_even_tlc[LW-1:0]),
				   .c3_tran_byte_odd_tlc(c3_tran_byte_odd_tlc[LW-1:0]));

   // #########################
   // # Arbiter instantiation
   // #########################

   /*link_txo_arbiter AUTO_TEMPLATE(
                                  .txo_wait            (txo_rd_wait),
                                  .txo_wait_int        (txo_rd_wait_int),
                                  .txo_launch_req_tlc  (txo_rd_launch_req_tlc),
                                  .txo_rotate_dis_tlc  (txo_rd_rotate_dis),
                                   );
    */
   link_txo_arbiter link_txo_arbiter (/*AUTOINST*/
				      // Outputs
				      .txo_launch_req_tlc(txo_rd_launch_req_tlc), // Templated
				      .txo_rotate_dis_tlc(txo_rd_rotate_dis), // Templated
				      .c0_txo_launch_ack_tlc(c0_txo_launch_ack_tlc),
				      .c1_txo_launch_ack_tlc(c1_txo_launch_ack_tlc),
				      .c2_txo_launch_ack_tlc(c2_txo_launch_ack_tlc),
				      .c3_txo_launch_ack_tlc(c3_txo_launch_ack_tlc),
				      // Inputs
				      .txo_lclk		(txo_lclk),
				      .reset		(reset),
				      .txo_wait		(txo_rd_wait),	 // Templated
				      .txo_wait_int	(txo_rd_wait_int), // Templated
				      .c0_txo_launch_req_tlc(c0_txo_launch_req_tlc),
				      .c0_txo_rotate_dis(c0_txo_rotate_dis),
				      .c1_txo_launch_req_tlc(c1_txo_launch_req_tlc),
				      .c1_txo_rotate_dis(c1_txo_rotate_dis),
				      .c2_txo_launch_req_tlc(c2_txo_launch_req_tlc),
				      .c2_txo_rotate_dis(c2_txo_rotate_dis),
				      .c3_txo_launch_req_tlc(c3_txo_launch_req_tlc),
				      .c3_txo_rotate_dis(c3_txo_rotate_dis));

   // #########################
   // # Channels instantiation
   // #########################

   /*link_txo_channel AUTO_TEMPLATE (
                   .cclk       (@"(substring vl-cell-name  0 2)"_clk_in),
                   .cclk_en    (1'b1),
                   .txo_rd     (1'b1),
		   .txo_lclk   (txo_lclk),
		   .reset      (reset),
                   .cfg_burst_dis (1'b1),
                   .emesh_\(.*\) (@"(substring vl-cell-name  0 2)"_rdmesh_\1[]),
                   .\(.*\)       (@"(substring vl-cell-name  0 2)"_\1[]),
                                     );
    */

   //# channel 0
   link_txo_channel #(.FAD(3)) c0_link_txo_channel (/*AUTOINST*/
						    // Outputs
						    .emesh_wait_out	(c0_rdmesh_wait_out), // Templated
						    .txo_launch_req_tlc	(c0_txo_launch_req_tlc), // Templated
						    .txo_rotate_dis	(c0_txo_rotate_dis), // Templated
						    .tran_frame_tlc	(c0_tran_frame_tlc), // Templated
						    .tran_byte_even_tlc	(c0_tran_byte_even_tlc[LW-1:0]), // Templated
						    .tran_byte_odd_tlc	(c0_tran_byte_odd_tlc[LW-1:0]), // Templated
						    // Inputs
						    .cclk		(c0_clk_in),	 // Templated
						    .cclk_en		(1'b1),		 // Templated
						    .txo_lclk		(txo_lclk),	 // Templated
						    .reset		(reset),	 // Templated
						    .txo_rd		(1'b1),		 // Templated
						    .txo_cid		(c0_txo_cid[1:0]), // Templated
						    .cfg_burst_dis	(1'b1),		 // Templated
						    .emesh_tran_in	(c0_rdmesh_tran_in[2*LW-1:0]), // Templated
						    .emesh_frame_in	(c0_rdmesh_frame_in), // Templated
						    .txo_launch_ack_tlc	(c0_txo_launch_ack_tlc)); // Templated

   //# channel 1
   link_txo_channel #(.FAD(3)) c1_link_txo_channel (/*AUTOINST*/
						    // Outputs
						    .emesh_wait_out	(c1_rdmesh_wait_out), // Templated
						    .txo_launch_req_tlc	(c1_txo_launch_req_tlc), // Templated
						    .txo_rotate_dis	(c1_txo_rotate_dis), // Templated
						    .tran_frame_tlc	(c1_tran_frame_tlc), // Templated
						    .tran_byte_even_tlc	(c1_tran_byte_even_tlc[LW-1:0]), // Templated
						    .tran_byte_odd_tlc	(c1_tran_byte_odd_tlc[LW-1:0]), // Templated
						    // Inputs
						    .cclk		(c1_clk_in),	 // Templated
						    .cclk_en		(1'b1),		 // Templated
						    .txo_lclk		(txo_lclk),	 // Templated
						    .reset		(reset),	 // Templated
						    .txo_rd		(1'b1),		 // Templated
						    .txo_cid		(c1_txo_cid[1:0]), // Templated
						    .cfg_burst_dis	(1'b1),		 // Templated
						    .emesh_tran_in	(c1_rdmesh_tran_in[2*LW-1:0]), // Templated
						    .emesh_frame_in	(c1_rdmesh_frame_in), // Templated
						    .txo_launch_ack_tlc	(c1_txo_launch_ack_tlc)); // Templated

   //# channel 2
   link_txo_channel #(.FAD(3)) c2_link_txo_channel (/*AUTOINST*/
						    // Outputs
						    .emesh_wait_out	(c2_rdmesh_wait_out), // Templated
						    .txo_launch_req_tlc	(c2_txo_launch_req_tlc), // Templated
						    .txo_rotate_dis	(c2_txo_rotate_dis), // Templated
						    .tran_frame_tlc	(c2_tran_frame_tlc), // Templated
						    .tran_byte_even_tlc	(c2_tran_byte_even_tlc[LW-1:0]), // Templated
						    .tran_byte_odd_tlc	(c2_tran_byte_odd_tlc[LW-1:0]), // Templated
						    // Inputs
						    .cclk		(c2_clk_in),	 // Templated
						    .cclk_en		(1'b1),		 // Templated
						    .txo_lclk		(txo_lclk),	 // Templated
						    .reset		(reset),	 // Templated
						    .txo_rd		(1'b1),		 // Templated
						    .txo_cid		(c2_txo_cid[1:0]), // Templated
						    .cfg_burst_dis	(1'b1),		 // Templated
						    .emesh_tran_in	(c2_rdmesh_tran_in[2*LW-1:0]), // Templated
						    .emesh_frame_in	(c2_rdmesh_frame_in), // Templated
						    .txo_launch_ack_tlc	(c2_txo_launch_ack_tlc)); // Templated

   //# channel 3
   link_txo_channel #(.FAD(3)) c3_link_txo_channel (/*AUTOINST*/
						    // Outputs
						    .emesh_wait_out	(c3_rdmesh_wait_out), // Templated
						    .txo_launch_req_tlc	(c3_txo_launch_req_tlc), // Templated
						    .txo_rotate_dis	(c3_txo_rotate_dis), // Templated
						    .tran_frame_tlc	(c3_tran_frame_tlc), // Templated
						    .tran_byte_even_tlc	(c3_tran_byte_even_tlc[LW-1:0]), // Templated
						    .tran_byte_odd_tlc	(c3_tran_byte_odd_tlc[LW-1:0]), // Templated
						    // Inputs
						    .cclk		(c3_clk_in),	 // Templated
						    .cclk_en		(1'b1),		 // Templated
						    .txo_lclk		(txo_lclk),	 // Templated
						    .reset		(reset),	 // Templated
						    .txo_rd		(1'b1),		 // Templated
						    .txo_cid		(c3_txo_cid[1:0]), // Templated
						    .cfg_burst_dis	(1'b1),		 // Templated
						    .emesh_tran_in	(c3_rdmesh_tran_in[2*LW-1:0]), // Templated
						    .emesh_frame_in	(c3_rdmesh_frame_in), // Templated
						    .txo_launch_ack_tlc	(c3_txo_launch_ack_tlc)); // Templated

endmodule // link_txo_rd
//#############################################################
//# This block is a transmitter of the write transactions only
//# Write transactions can be sent out off the chip from
//# emesh and mesh but not from rdmesh
//#############################################################

module link_txo_wr (/*AUTOARG*/
   // Outputs
   txo_wr_data_even, txo_wr_data_odd, txo_wr_frame,
   txo_wr_launch_req_tlc, txo_wr_rotate_dis, c0_emesh_wait_out,
   c1_emesh_wait_out, c2_emesh_wait_out, c3_emesh_wait_out,
   c0_mesh_wait_out, c3_mesh_wait_out,
   // Inputs
   txo_lclk, reset, ext_yid_k, ext_xid_k, who_am_i, cfg_burst_dis,
   cfg_multicast_dis, txo_wr_wait, txo_wr_wait_int, c0_clk_in,
   c1_clk_in, c2_clk_in, c3_clk_in, c0_emesh_tran_in,
   c0_emesh_frame_in, c1_emesh_tran_in, c1_emesh_frame_in,
   c2_emesh_tran_in, c2_emesh_frame_in, c3_emesh_tran_in,
   c3_emesh_frame_in, c0_mesh_access_in, c0_mesh_write_in,
   c0_mesh_dstaddr_in, c0_mesh_srcaddr_in, c0_mesh_data_in,
   c0_mesh_datamode_in, c0_mesh_ctrlmode_in, c3_mesh_access_in,
   c3_mesh_write_in, c3_mesh_dstaddr_in, c3_mesh_srcaddr_in,
   c3_mesh_data_in, c3_mesh_datamode_in, c3_mesh_ctrlmode_in,
   c1_tran_byte_even_tlc, c1_tran_byte_odd_tlc, c1_tran_frame_tlc,
   c2_tran_byte_even_tlc, c2_tran_byte_odd_tlc, c2_tran_frame_tlc
   );

   parameter LW   = `CFG_LW  ;//lvds tranceiver pairs per side
   parameter AW   = `CFG_AW  ;//address width
   parameter DW   = `CFG_DW  ;//data width  
   
   // #########
   // # Inputs
   // #########

   input 	txo_lclk;  //transmit clock to be used internally
   input        reset;
   input [3:0] 	ext_yid_k; //external y-id 
   input [3:0] 	ext_xid_k; //external x-id
   input [3:0] 	who_am_i;  //specifies what link is that (north,east,south,west)
   input 	cfg_burst_dis; //control register bursting disable
   input 	cfg_multicast_dis;//control register multicast disable
   // # from io
   input 	txo_wr_wait; // Wait from the receiver
   input 	txo_wr_wait_int; // Wait from the txo_interface (have to stall immediately)
   // # Clocks
   input 	c0_clk_in;   //clock of the core  
   input 	c1_clk_in;   //clock of the core  
   input 	c2_clk_in;   //clock of the core  
   input 	c3_clk_in;   //clock of the core  
  
   // # EMESH
   input [2*LW-1:0] c0_emesh_tran_in;  // serialized transaction
   input 	    c0_emesh_frame_in; // transaction frame
   input [2*LW-1:0] c1_emesh_tran_in;  // serialized transaction
   input 	    c1_emesh_frame_in; // transaction frame
   input [2*LW-1:0] c2_emesh_tran_in;  // serialized transaction
   input 	    c2_emesh_frame_in; // transaction frame
   input [2*LW-1:0] c3_emesh_tran_in;  // serialized transaction
   input 	    c3_emesh_frame_in; // transaction frame

   // # MESH 
   // # core0 (external corners and multicast)
   input 	    c0_mesh_access_in;  // access control from the mesh
   input 	    c0_mesh_write_in;   // write control from the mesh
   input [AW-1:0]   c0_mesh_dstaddr_in; // destination address from the mesh
   input [AW-1:0]   c0_mesh_srcaddr_in; // source address from the mesh
   input [DW-1:0]   c0_mesh_data_in;    // data from the mesh
   input [1:0] 	    c0_mesh_datamode_in;// data mode from the mesh 
   input [3:0] 	    c0_mesh_ctrlmode_in;// ctrl mode from the mesh
   // # core3 (external corners only)
   input 	    c3_mesh_access_in;  // access control from the mesh
   input 	    c3_mesh_write_in;   // write control from the mesh
   input [AW-1:0]   c3_mesh_dstaddr_in; // destination address from the mesh
   input [AW-1:0]   c3_mesh_srcaddr_in; // source address from the mesh
   input [DW-1:0]   c3_mesh_data_in;    // data from the mesh
   input [1:0] 	    c3_mesh_datamode_in;// data mode from the mesh 
   input [3:0] 	    c3_mesh_ctrlmode_in;// ctrl mode from the mesh

   // ##############
   // # Outputs
   // ##############

   // to the txo_interface
   output [LW-1:0] txo_wr_data_even; //Even byte word
   output [LW-1:0] txo_wr_data_odd;  //Odd byte word
   output 	   txo_wr_frame; //indicates new transmission 
   output 	   txo_wr_launch_req_tlc;
   output 	   txo_wr_rotate_dis;

   output 	   c0_emesh_wait_out; //wait to the emesh   
   output 	   c1_emesh_wait_out; //wait to the emesh   
   output 	   c2_emesh_wait_out; //wait to the emesh   
   output 	   c3_emesh_wait_out; //wait to the emesh   

   output 	   c0_mesh_wait_out;  //wait to the mesh 
   output 	   c3_mesh_wait_out;  //wait to the mesh 

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [LW-1:0]	c1_tran_byte_even_tlc;	// To link_txo_buffer of link_txo_buffer.v
   input [LW-1:0]	c1_tran_byte_odd_tlc;	// To link_txo_buffer of link_txo_buffer.v
   input		c1_tran_frame_tlc;	// To link_txo_buffer of link_txo_buffer.v
   input [LW-1:0]	c2_tran_byte_even_tlc;	// To link_txo_buffer of link_txo_buffer.v
   input [LW-1:0]	c2_tran_byte_odd_tlc;	// To link_txo_buffer of link_txo_buffer.v
   input		c2_tran_frame_tlc;	// To link_txo_buffer of link_txo_buffer.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [LW-1:0]	c0_tran_byte_even_tlc;	// From c0_link_txo_mesh_channel of link_txo_mesh_channel.v
   wire [LW-1:0]	c0_tran_byte_odd_tlc;	// From c0_link_txo_mesh_channel of link_txo_mesh_channel.v
   wire			c0_tran_frame_tlc;	// From c0_link_txo_mesh_channel of link_txo_mesh_channel.v
   wire			c0_txo_launch_ack_tlc;	// From link_txo_arbiter of link_txo_arbiter.v
   wire			c0_txo_launch_req_tlc;	// From c0_link_txo_mesh_channel of link_txo_mesh_channel.v
   wire			c0_txo_rotate_dis;	// From c0_link_txo_mesh_channel of link_txo_mesh_channel.v
   wire			c1_txo_launch_ack_tlc;	// From link_txo_arbiter of link_txo_arbiter.v
   wire			c2_txo_launch_ack_tlc;	// From link_txo_arbiter of link_txo_arbiter.v
   wire [LW-1:0]	c3_tran_byte_even_tlc;	// From c3_link_txo_mesh_channel of link_txo_mesh_channel.v
   wire [LW-1:0]	c3_tran_byte_odd_tlc;	// From c3_link_txo_mesh_channel of link_txo_mesh_channel.v
   wire			c3_tran_frame_tlc;	// From c3_link_txo_mesh_channel of link_txo_mesh_channel.v
   wire			c3_txo_launch_ack_tlc;	// From link_txo_arbiter of link_txo_arbiter.v
   wire			c3_txo_launch_req_tlc;	// From c3_link_txo_mesh_channel of link_txo_mesh_channel.v
   wire			c3_txo_rotate_dis;	// From c3_link_txo_mesh_channel of link_txo_mesh_channel.v
   // End of automatics

   // ##########
   // # WIRES
   // ##########

   wire [1:0] 	     c0_txo_cid;//channel 0 ID
   wire [1:0] 	     c1_txo_cid;//channel 1 ID
   wire [1:0] 	     c2_txo_cid;//channel 2 ID
   wire [1:0] 	     c3_txo_cid;//channel 3 ID

   // #####################################
   // # Transmitter channels instantiation
   // #####################################

   assign c0_txo_cid[1:0] = 2'b00;
   assign c1_txo_cid[1:0] = 2'b01;
   assign c2_txo_cid[1:0] = 2'b10;
   assign c3_txo_cid[1:0] = 2'b11;

   // ################################
   // # Transmit buffer instantiation
   // ################################

   /*link_txo_buffer AUTO_TEMPLATE(
                                  .txo_data_even (txo_wr_data_even[]),
                                  .txo_data_odd  (txo_wr_data_odd[]),
                                  .txo_frame     (txo_wr_frame),
                                   );
    */
   link_txo_buffer link_txo_buffer(/*AUTOINST*/
				   // Outputs
				   .txo_data_even	(txo_wr_data_even[LW-1:0]), // Templated
				   .txo_data_odd	(txo_wr_data_odd[LW-1:0]), // Templated
				   .txo_frame		(txo_wr_frame),	 // Templated
				   // Inputs
				   .c0_tran_frame_tlc	(c0_tran_frame_tlc),
				   .c0_tran_byte_even_tlc(c0_tran_byte_even_tlc[LW-1:0]),
				   .c0_tran_byte_odd_tlc(c0_tran_byte_odd_tlc[LW-1:0]),
				   .c1_tran_frame_tlc	(c1_tran_frame_tlc),
				   .c1_tran_byte_even_tlc(c1_tran_byte_even_tlc[LW-1:0]),
				   .c1_tran_byte_odd_tlc(c1_tran_byte_odd_tlc[LW-1:0]),
				   .c2_tran_frame_tlc	(c2_tran_frame_tlc),
				   .c2_tran_byte_even_tlc(c2_tran_byte_even_tlc[LW-1:0]),
				   .c2_tran_byte_odd_tlc(c2_tran_byte_odd_tlc[LW-1:0]),
				   .c3_tran_frame_tlc	(c3_tran_frame_tlc),
				   .c3_tran_byte_even_tlc(c3_tran_byte_even_tlc[LW-1:0]),
				   .c3_tran_byte_odd_tlc(c3_tran_byte_odd_tlc[LW-1:0])); 

   // #########################
   // # Arbiter instantiation
   // #########################

   /*link_txo_arbiter AUTO_TEMPLATE(
                                  .txo_wait            (txo_wr_wait),
                                  .txo_wait_int        (txo_wr_wait_int),
                                  .txo_launch_req_tlc  (txo_wr_launch_req_tlc),
                                  .txo_rotate_dis_tlc  (txo_wr_rotate_dis),
                                   );
    */
   link_txo_arbiter link_txo_arbiter (.c1_txo_launch_req_tlc(1'b0),
				      .c1_txo_rotate_dis(1'b0),
				      .c2_txo_launch_req_tlc(1'b0),
				      .c2_txo_rotate_dis(1'b0),
				      .c3_txo_launch_req_tlc(1'b0),
				      .c3_txo_rotate_dis(1'b0),
				      /*AUTOINST*/
				      // Outputs
				      .txo_launch_req_tlc(txo_wr_launch_req_tlc), // Templated
				      .txo_rotate_dis_tlc(txo_wr_rotate_dis), // Templated
				      .c0_txo_launch_ack_tlc(c0_txo_launch_ack_tlc),
				      .c1_txo_launch_ack_tlc(c1_txo_launch_ack_tlc),
				      .c2_txo_launch_ack_tlc(c2_txo_launch_ack_tlc),
				      .c3_txo_launch_ack_tlc(c3_txo_launch_ack_tlc),
				      // Inputs
				      .txo_lclk		(txo_lclk),
				      .reset		(reset),
				      .txo_wait		(txo_wr_wait),	 // Templated
				      .txo_wait_int	(txo_wr_wait_int), // Templated
				      .c0_txo_launch_req_tlc(c0_txo_launch_req_tlc),
				      .c0_txo_rotate_dis(c0_txo_rotate_dis));

   // #########################
   // # Channels instantiation
   // #########################

   /*link_txo_mesh_channel AUTO_TEMPLATE (
          .cclk	         (@"(substring vl-cell-name  0 2)"_clk_in),
          .cclk_en       (1'b1),
          .txo_rd	 (1'b0),
	  .txo_lclk      (txo_lclk),
	  .reset         (reset),
          .cfg_burst_dis (cfg_burst_dis),
          .txo_rotate_dis_tlc (@"(substring vl-cell-name  0 2)"_txo_rotate_dis),
          .emesh_\(.*\)  (@"(substring vl-cell-name  0 2)"_emesh_\1[]),
          .\(.*\)        (@"(substring vl-cell-name  0 2)"_\1[]),
          .ext_yid_k     (ext_yid_k[]),
	  .ext_xid_k     (ext_xid_k[]),
          .who_am_i      (who_am_i[]),
                                     );
    */

   //# channel 0 (emesh + mesh for external corners + mesh for multicast)
   link_txo_mesh_channel c0_link_txo_mesh_channel(.cfg_multicast_dis (cfg_multicast_dis),
						  /*AUTOINST*/
						  // Outputs
						  .emesh_wait_out	(c0_emesh_wait_out), // Templated
						  .mesh_wait_out	(c0_mesh_wait_out), // Templated
						  .txo_launch_req_tlc	(c0_txo_launch_req_tlc), // Templated
						  .txo_rotate_dis_tlc	(c0_txo_rotate_dis), // Templated
						  .tran_frame_tlc	(c0_tran_frame_tlc), // Templated
						  .tran_byte_even_tlc	(c0_tran_byte_even_tlc[LW-1:0]), // Templated
						  .tran_byte_odd_tlc	(c0_tran_byte_odd_tlc[LW-1:0]), // Templated
						  // Inputs
						  .cclk			(c0_clk_in),	 // Templated
						  .cclk_en		(1'b1),		 // Templated
						  .txo_lclk		(txo_lclk),	 // Templated
						  .reset		(reset),	 // Templated
						  .ext_yid_k		(ext_yid_k[3:0]), // Templated
						  .ext_xid_k		(ext_xid_k[3:0]), // Templated
						  .who_am_i		(who_am_i[3:0]), // Templated
						  .txo_rd		(1'b0),		 // Templated
						  .txo_cid		(c0_txo_cid[1:0]), // Templated
						  .cfg_burst_dis	(cfg_burst_dis), // Templated
						  .emesh_tran_in	(c0_emesh_tran_in[2*LW-1:0]), // Templated
						  .emesh_frame_in	(c0_emesh_frame_in), // Templated
						  .mesh_access_in	(c0_mesh_access_in), // Templated
						  .mesh_write_in	(c0_mesh_write_in), // Templated
						  .mesh_dstaddr_in	(c0_mesh_dstaddr_in[AW-1:0]), // Templated
						  .mesh_srcaddr_in	(c0_mesh_srcaddr_in[AW-1:0]), // Templated
						  .mesh_data_in		(c0_mesh_data_in[DW-1:0]), // Templated
						  .mesh_datamode_in	(c0_mesh_datamode_in[1:0]), // Templated
						  .mesh_ctrlmode_in	(c0_mesh_ctrlmode_in[3:0]), // Templated
						  .txo_launch_ack_tlc	(c0_txo_launch_ack_tlc)); // Templated

   //# channel 3 (emesh + mesh for external corners)
   link_txo_mesh_channel c3_link_txo_mesh_channel(.cfg_multicast_dis (1'b1),
						  /*AUTOINST*/
						  // Outputs
						  .emesh_wait_out	(c3_emesh_wait_out), // Templated
						  .mesh_wait_out	(c3_mesh_wait_out), // Templated
						  .txo_launch_req_tlc	(c3_txo_launch_req_tlc), // Templated
						  .txo_rotate_dis_tlc	(c3_txo_rotate_dis), // Templated
						  .tran_frame_tlc	(c3_tran_frame_tlc), // Templated
						  .tran_byte_even_tlc	(c3_tran_byte_even_tlc[LW-1:0]), // Templated
						  .tran_byte_odd_tlc	(c3_tran_byte_odd_tlc[LW-1:0]), // Templated
						  // Inputs
						  .cclk			(c3_clk_in),	 // Templated
						  .cclk_en		(1'b1),		 // Templated
						  .txo_lclk		(txo_lclk),	 // Templated
						  .reset		(reset),	 // Templated
						  .ext_yid_k		(ext_yid_k[3:0]), // Templated
						  .ext_xid_k		(ext_xid_k[3:0]), // Templated
						  .who_am_i		(who_am_i[3:0]), // Templated
						  .txo_rd		(1'b0),		 // Templated
						  .txo_cid		(c3_txo_cid[1:0]), // Templated
						  .cfg_burst_dis	(cfg_burst_dis), // Templated
						  .emesh_tran_in	(c3_emesh_tran_in[2*LW-1:0]), // Templated
						  .emesh_frame_in	(c3_emesh_frame_in), // Templated
						  .mesh_access_in	(c3_mesh_access_in), // Templated
						  .mesh_write_in	(c3_mesh_write_in), // Templated
						  .mesh_dstaddr_in	(c3_mesh_dstaddr_in[AW-1:0]), // Templated
						  .mesh_srcaddr_in	(c3_mesh_srcaddr_in[AW-1:0]), // Templated
						  .mesh_data_in		(c3_mesh_data_in[DW-1:0]), // Templated
						  .mesh_datamode_in	(c3_mesh_datamode_in[1:0]), // Templated
						  .mesh_ctrlmode_in	(c3_mesh_ctrlmode_in[3:0]), // Templated
						  .txo_launch_ack_tlc	(c3_txo_launch_ack_tlc)); // Templated

 
endmodule // link_txo_wr
module _MAGMA_CELL_FF_ (DATA, CLOCK, CLEAR, PRESET, SLAVE_CLOCK, OUT);

   input DATA;
   input CLOCK;
   input CLEAR;
   input PRESET;
   input SLAVE_CLOCK;
   output OUT;
   reg    OUT;

   // synopsys one_hot "PRESET, CLEAR"
   always @(posedge CLOCK or posedge PRESET or posedge CLEAR)
   if (CLEAR)
     OUT <= 1'b0;
   else
     if (PRESET)
       OUT <= 1'b1;
     else
       OUT <= DATA;
endmodule

// Entity:dffnq Model:DFFNQX3A12TR Library:cmos10sf_5_20_02_scadv12
module DFFNQX3A12TR (CKN, D, Q);
  input CKN, D;
  output Q;
  supply0 N7;
  _MAGMA_CELL_FF_ C1 (.DATA(D), .CLOCK(CKN__br_in_not), .CLEAR(N7), .PRESET(N7), .SLAVE_CLOCK(N7), .OUT(Q));
  not (CKN__br_in_not, CKN);
endmodule // DFFNQX3A12TR

module DFFQX4A12TR (CK, D, Q);
  input CK, D;
  output Q;
  supply0 N6;
  _MAGMA_CELL_FF_ C1 (.DATA(D), .CLOCK(CK), .CLEAR(N6), .PRESET(N6), .SLAVE_CLOCK(N6), .OUT(Q));
endmodule

module MX2X4A12TR (A, B, S0, Y);
  input A, B, S0;
  output Y;
  wire N3, N6;
  and C1 (N3, S0, B);
  and C3 (N6, S0__br_in_not, A);
  not (S0__br_in_not, S0);
  or C4 (Y, N3, N6);
endmodule




