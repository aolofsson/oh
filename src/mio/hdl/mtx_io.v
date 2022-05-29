//#############################################################################
//# Purpose: MIO Transmit IO                                                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module mtx_io #(parameter IOW    = 64,          // IO width
	        parameter TARGET = "GENERIC"  // target selector
	       )
  (// reset, clk, cfg
   input 	    nreset, // async active low reset
   input 	    io_clk, // clock from divider
   input 	    ddr_mode, // send data as ddr
   input [1:0] 	    iowidth, // iowidth *8,16,32,64  
   // chip IO interface
   output [IOW-1:0] tx_packet, // data for IO
   output reg 	    tx_access, // access signal for IO
   input 	    tx_wait, // IO wait signals
   // core side 
   input [7:0] 	    io_valid, // per byte valid indicator
   input [IOW-1:0]  io_packet, // packet
   output 	    io_wait // pushback to serializer in sdr mode   
   );

   //local wires
   reg [63:0] 	    shiftreg;
   reg [2:0] 	    tx_state;
   reg [IOW-1:0]    tx_packet_sdr;
   reg [7:0] 	    io_valid_reg;
   wire [IOW/2-1:0] tx_packet_ddr;
   wire 	    tx_wait_sync;
   wire 	    transfer_active;
   wire [7:0] 	    io_valid_next;
   wire [IOW/2-1:0] ddr_data_even;
   wire [IOW/2-1:0] ddr_data_odd;
   wire 	    dmode8;
   wire 	    dmode16;
   wire 	    dmode32;
   wire 	    dmode64;
   wire 	    io_nreset;
   wire 	    reload;
   
   //########################################
   //# STATE MACHINE
   //########################################   

   assign dmode8   = (iowidth[1:0]==2'b00);   
   assign dmode16  = ((iowidth[1:0]==2'b01) & ~ddr_mode) |
                     (iowidth[1:0]==2'b00) & ddr_mode;   
   assign dmode32  = ((iowidth[1:0]==2'b10) & ~ddr_mode) |
                     (iowidth[1:0]==2'b01) & ddr_mode;   
   assign dmode64  = ((iowidth[1:0]==2'b11) & ~ddr_mode) |
                     (iowidth[1:0]==2'b10) & ddr_mode;   

   assign io_valid_next[7:0] = dmode8  ? {1'b0,io_valid_reg[7:1]} :
			       dmode16 ? {2'b0,io_valid_reg[7:2]} :
			       dmode32 ? {4'b0,io_valid_reg[7:4]} :
			                  8'b0;
   
   assign reload = ~transfer_active | dmode64 | (io_valid_next[7:0]==8'b0);
  
   always @ (posedge io_clk or negedge io_nreset)
     if(!io_nreset)
       io_valid_reg[7:0] <= 'b0;
     else if(reload)
       io_valid_reg[7:0] <= io_valid[7:0];
     else
       io_valid_reg[7:0] <= io_valid_next[7:0];
       
   assign transfer_active = |io_valid_reg[7:0];
   
   //pipeline access signal
   always @ (posedge io_clk or negedge io_nreset)
     if(!io_nreset)
       tx_access <= 1'b0;   
     else
       tx_access <= transfer_active;

   assign io_wait = tx_wait_sync | ~reload;
   
   //########################################
   //# SHIFT REGISTER  (SHIFT DOWN)
   //########################################

   always @ (posedge io_clk)
     if(reload)
       shiftreg[63:0] <= io_packet[IOW-1:0];
     else if(dmode8)//8 bit
       shiftreg[63:0] <= {8'b0,shiftreg[IOW-1:8]};   
     else if(dmode16)//16 bit
       shiftreg[63:0] <= {16'b0,shiftreg[IOW-1:16]};
     else if(dmode32)//32 bit
       shiftreg[63:0] <= {32'b0,shiftreg[IOW-1:32]};   
   
   //########################################
   //# DDR OUTPUT
   //########################################

   // pipeline sdr to compensate for ddr
   always @ (posedge io_clk)
     tx_packet_sdr[IOW-1:0] <= shiftreg[IOW-1:0];
      
   // ddr circuit (one stage pipeline delay!)
   assign ddr_data_even[IOW/2-1:0] = shiftreg[IOW/2-1:0];

   assign ddr_data_odd[IOW/2-1:0] = (iowidth[1:0]==2'b00) ? shiftreg[7:4]   : //byte
				    (iowidth[1:0]==2'b01) ? shiftreg[15:8]  : //short
    				    (iowidth[1:0]==2'b10) ? shiftreg[31:16] : //word
				                            shiftreg[63:32];  //double
   
   oh_oddr#(.DW(IOW/2))
   data_oddr (.out	(tx_packet_ddr[IOW/2-1:0]),
              .clk	(io_clk),
	      .din1	(ddr_data_even[IOW/2-1:0]),
	      .din2	(ddr_data_odd[IOW/2-1:0]));

   //select between ddr/sdr
   assign tx_packet[IOW-1:0] = ddr_mode ? {{(IOW/2){1'b0}},tx_packet_ddr[IOW/2-1:0]}:
		                                           tx_packet_sdr[IOW-1:0];
   
   //########################################
   //# Synchronizers
   //########################################  

   // synchronize reset to io clock
   oh_rsync sync_reset(.nrst_out (io_nreset),
		       .clk	 (io_clk),
		       .nrst_in	 (nreset));
   
   //synchronize wait
   oh_dsync sync_wait(.nreset	(io_nreset),
		      .clk	(io_clk),
		      .din      (tx_wait),
		      .dout     (tx_wait_sync));
   
endmodule // mtx_io
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:


  
