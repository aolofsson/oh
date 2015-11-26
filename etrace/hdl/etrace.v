`include "etrace_regmap.v"
module etrace (/*AUTOARG*/
   // Outputs
   mi_dout,
   // Inputs
   trace_clk, trace_trigger, trace_vector, nreset, mi_clk, mi_en,
   mi_we, mi_addr, mi_din
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
   
   //sample interface
   input 	    trace_clk;
   input 	    trace_trigger;   
   input [VW-1:0]   trace_vector;
   
   //memory access interface   
   input            nreset;
   input 	    mi_clk;   
   input 	    mi_en;   //TODO: change to read/write??
   input   	    mi_we;      
   input [AW-1:0]   mi_addr;
   input [DW-1:0]   mi_din;
   output [DW-1:0]  mi_dout;   
   
   
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
   always @ (posedge mi_clk)
     if(!nreset)
       cfg_reg[15:0] <= 'b0;
     else if (mi_cfg_write)
       cfg_reg[15:0] <= mi_din[15:0];

   assign mi_trace_enable = cfg_reg[0];

   //################################
   //# SYNC CFG SIGNALS TO SAMPLE CLK
   //#################################

   dsync #(.DW(1))

   dsync(// Outputs
	 .dout			(trace_enable),
	 // Inputs
	 .clk			(trace_clk),
	 .din			(mi_trace_enable)
	 );
   
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

   //###########################
   //# TRACE MEMORY
   //###########################   
   memory_dp 
     #(.DW(MW),
       .WED(MW/8),
       .AW(MAW))     
   memory (// Outputs
	   .rd_data	(mem_data[MW-1:0]),
	   // write interface
	   .wr_clk	(trace_clk),
	   .wr_en	({(MW/8){trace_sample}}),
	   .wr_addr	(trace_addr[MAW-1:0]),
	   .wr_data	({cycle_counter[DW-1:0],trace_vector[VW-1:0]}),
	   // read interface
	   .rd_clk	(mi_clk),
	   .rd_en	(mi_rd),
	   .rd_addr	(mi_addr[MAW+2:3])
	   );

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
