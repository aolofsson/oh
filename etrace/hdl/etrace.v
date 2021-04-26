`include "etrace_regmap.vh"
module etrace (/*AUTOARG*/
   // Outputs
   data_access_out, data_packet_out, cfg_access_out, cfg_packet_out,
   // Inputs
   trace_clk, trace_trigger, trace_vector, cfg_access_in,
   cfg_packet_in
   );

   parameter VW     = 32;           //width of vector to sample
   parameter DW     = 32;           //width of counter
   parameter AW     = 32;           //width of address input bus
   parameter DEPTH  = 1024;         //memory depth
   parameter ID     = 999;
   parameter NAME   = "my";
   parameter RFAW   = 6;            //

   parameter MW     = VW+DW;        //memory width should be 64,128,256
   parameter MAW    = $clog2(DEPTH);// 
   parameter LSB    = $clog2(MW/32);//address lsb for memory
   
   //Logic analyzer interface
   input 	    trace_clk;
   input 	    trace_trigger;   
   input [VW-1:0]   trace_vector;

   //Data streaming interface
   output	    data_access_out;
   output [PW-1:0]  data_packet_out;

   //Config interface
   input 	    cfg_access_in;
   input [PW-1:0]   cfg_packet_in;
   output	    cfg_access_out;
   output [PW-1:0]  cfg_packet_out;

  
      
   //local regs
   reg [15:0] 	    cfg_reg;   
   reg [DW-1:0]     cycle_counter;
   reg [VW-1:0]     trace_vector_reg;
   reg [2:0]        mi_addr_reg;
   reg [MAW-1:0]    trace_addr;
   
   wire 	    mi_write;
   wire 	    mi_cfg_write;
   wire [MW-1:0]    mem_data;   
   wire 	    trace_enable_sync;


   wire [3:0] 	    ctrlmode_out;
   wire [DW-1:0]    data_out;
   wire [1:0] 	    datamode_out;
   wire [AW-1:0]    dstaddr_out;
   wire [AW-1:0]    srcaddr_out;
   wire 	    write_out;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [PW-1:0]	packet_out;		// From e2p of emesh2packet.v
   // End of automatics
   
   //###########################
   //# PACKET PARSING
   //###########################

   //Config
   packet2emesh p2e0 (/*AUTOINST*/
		      // Outputs
		      .write_out	(write_out),
		      .datamode_out	(datamode_out[1:0]),
		      .ctrlmode_out	(ctrlmode_out[3:0]),
		      .data_out		(data_out[DW-1:0]),
		      .dstaddr_out	(dstaddr_out[AW-1:0]),
		      .srcaddr_out	(srcaddr_out[AW-1:0]),
		      // Inputs
		      .packet_in	(packet_in[PW-1:0]));
   
   //Readback
   emesh2packet e2p0 (/*AUTOINST*/
		     // Outputs
		     .packet_out	(packet_out[PW-1:0]),
		     // Inputs
		     .write_in		(write_in),
		     .datamode_in	(datamode_in[1:0]),
		     .ctrlmode_in	(ctrlmode_in[3:0]),
		     .dstaddr_in	(dstaddr_in[AW-1:0]),
		     .data_in		(data_in[DW-1:0]),
		     .srcaddr_in	(srcaddr_in[AW-1:0]));

   //Data
   emesh2packet e2p0 (/*AUTOINST*/
		     // Outputs
		     .packet_out	(packet_out[PW-1:0]),
		     // Inputs
		     .write_in		(write_in),
		     .datamode_in	(datamode_in[1:0]),
		     .ctrlmode_in	(ctrlmode_in[3:0]),
		     .dstaddr_in	(dstaddr_in[AW-1:0]),
		     .data_in		(data_in[DW-1:0]),
		     .srcaddr_in	(srcaddr_in[AW-1:0]));
   
   
   
   //###########################
   //# REGISTER INTERFACE
   //###########################

   assign mi_write         = mi_en & mi_we;
   assign mi_cfg_write     = mi_write &  
			     (mi_addr[31:20]   ==ID)            & 
			     (mi_addr[19:16]   ==`ETRACE_REGS) & 
			     (mi_addr[RFAW+1:2]==`ETRACE_CFG);

   assign mi_rd            = mi_en &
			     (mi_addr[31:20]   ==ID)          &
			     (mi_addr[19:16]   ==`ETRACE_MEM);

   //TODO: parametrize
   always @ (posedge mi_clk)
     mi_addr_reg[2:0] <= mi_addr[2:0];
   
   //TODO: parametrize, keep to 32 bits for now
   assign mi_dout[DW-1:0]  = mi_addr_reg[2] ? mem_data[63:32] :
			                      mem_data[31:0];
      
   //###########################
   //# CONFIG
   //###########################
   //Destination start address ETRACE_BASEADDR [32 bit]
   //Destination samples       ETRACE_SAMPLES [32 bit]
   
   always @ (posedge mi_clk)
     if(!nreset)
       cfg_reg[15:0] <= 'b0;
     else if (mi_cfg_write)
       cfg_reg[15:0] <= mi_din[15:0];

   assign mi_trace_enable  = cfg_reg[0];
   assign mi_loop_enable   = cfg_reg[1];//runs forever as circular buffer
   assign mi_async_mode    = cfg_reg[2];//treats input signals as async/sync
   assign mi_samplerate    = cfg_reg[7:4];
   /*
    * 100MS/s
    * 50MS/s
    * 25MS/s
    * 12.5MS/s
    * 6.25MS/s
    * 3.125Ms/s
    * 1.0Ms/s
    * 0.5Ms/s
    */
    
   
   //###########################
   //# "DMA"
   //###########################
   //With 64 channels + 32 bit timer (==96 bits) 
   //Max sample rate??
   
  
   //################################
   //# SYNC CFG SIGNALS TO SAMPLE CLK
   //#################################

   dsync dsync(// Outputs
	       .dout	(trace_enable),
	       // Inputs
	       .clk	(trace_clk),
	       .din	(mi_trace_enable));
      
   //###########################
   //# TIME KEEPER
   //###########################
   //count if trigger enabled and counter enabled (SW + HW)
   
   always @ (posedge trace_clk)
     if(~trace_enable)
       cycle_counter[DW-1:0] <= 'b0;
     else if (trace_trigger)
       cycle_counter[DW-1:0] <= cycle_counter[DW-1:0] + 1'b1;
   
   //###########################
   //# SAMPLING LOGIC
   //###########################   
   
   //Change detect logic
   always @ (posedge trace_clk)
     trace_vector_reg[VW-1:0] <= trace_vector[VW-1:0];

   assign change_detect = |(trace_vector_reg[VW-1:0] ^ trace_vector[VW-1:0]);

   //Sample signal
   assign trace_sample = trace_enable    &
			 trace_trigger  &
			 change_detect;
   
   //Address counter
   always @ (posedge trace_clk)
     if(~trace_enable)
       trace_addr[MAW-1:0] <= 'b0;
     else if (trace_sample)
       trace_addr[MAW-1:0] <= trace_addr[MAW-1:0] + 1'b1;
   
   //Trace memory
   fifo_cdc fifo (// Outputs
		  .wait_out		(),
		  .access_out		(access_out),
		  .packet_out		(packet_out[DW-1:0]),
		  // Inputs
		  .nreset		(nreset),
		  .clk_in		(clk_in),
		  .access_in		(access_in),
		  .packet_in		(packet_in[DW-1:0]),
		  .clk_out		(clk_out),
		  .wait_in		(wait_in));
   
`ifdef TARGET_SIM
   reg [31:0] 	    ftrace;
   reg [255:0] 	    tracefile;
   initial
     begin      
	$sformat(tracefile,"%s%s",NAME,".trace");
        ftrace  = $fopen({tracefile}, "w");  
     end
   
   always @ (posedge trace_clk)
     if(trace_sample)
          $fwrite(ftrace, "%h,%0d\n",trace_vector[VW-1:0],cycle_counter[DW-1:0]);   
   
`endif //  `ifdef TARGET_SIM
   
endmodule // emailbox


// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../memory/hdl" "../../common/hdl")
// End:
