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
   reg [63:0] 	   shiftreg;
   reg [2:0] 	   tx_state;
   reg [IOW-1:0]   tx_packet_sdr;
   wire [IOW/2-1:0] tx_packet_ddr;
   reg [7:0] 	   io_valid_reg;
   
   //########################################
   //# STATE MACHINE
   //########################################   

   assign dmode8   = (iowidth[1:0]==2'b00);
   assign dmode16  = (iowidth[1:0]==2'b01);
   assign dmode32  = (iowidth[1:0]==2'b10);
   assign dmode64  = (iowidth[1:0]==2'b11);
  
   always @ (posedge io_clk or negedge io_nreset)
     if(!io_nreset)
       io_valid_reg[7:0] <= 'b0;
     else if(transfer_active & dmode8 )
       io_valid_reg[7:0] <= {1'b0,io_valid_reg[7:1]};
     else if(transfer_active & dmode16 )
       io_valid_reg[7:0] <= {2'b0,io_valid_reg[7:2]};
     else if(transfer_active & dmode32 )
       io_valid_reg[7:0] <= {4'b0,io_valid_reg[7:4]};
     else if(transfer_active & dmode32 )
       io_valid_reg[7:0] <= 'b0;

   assign transfer_active = |io_valid_reg[7:0];
   
   //pipeline access signal
   always @ (posedge io_clk or negedge io_nreset)
     if(!io_nreset)
       tx_access <= 1'b0;   
     else
       tx_access <= transfer_active;
   
   //########################################
   //# SHIFT REGISTER  (SHIFT DOWN)
   //########################################

   always @ (posedge io_clk)
     if(transfer_active & dmode8)//8 bit
       shiftreg[63:0] <= {8'b0,shiftreg[IOW-8-1:0]};   
     else if(transfer_active & dmode16)//16 bit
       shiftreg[63:0] <= {16'b0,shiftreg[IOW-16-1:0]};
     else if(transfer_active & dmode32)//32 bit
       shiftreg[63:0] <= {32'b0,shiftreg[IOW-32-1:0]};   
     else
       shiftreg[63:0] = io_packet[IOW-1:0];
   
   //########################################
   //# DDR OUTPUT
   //########################################

   // pipeline sdr to compensate for ddr
   always @ (posedge io_clk)
     tx_packet_sdr[IOW-1:0] <= shiftreg[IOW-1:0];
      
   // ddr circuit (one stage pipeline delay!)
   oh_oddr#(.DW(IOW/2))
   data_oddr (.out	(tx_packet_ddr[IOW/2-1:0]),
              .clk	(io_clk),
	      .din1	(shiftreg[IOW/2-1:0]),
	      .din2	(shiftreg[IOW-1:IOW/2]));

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
		      .dout     (io_wait));
   
endmodule // mtx_io
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:


  
