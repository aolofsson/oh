//#############################################################################
//# Purpose: MIO Receiver IO                                                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module mrx_io #(parameter IOW    = 64,          // IO width
	        parameter TARGET = "GENERIC"  // target selector
		)
   
   ( //reset, clk, cfg
     input 	      nreset, // async active low reset
     input 	      ddr_mode, // select between sdr/ddr data
     input [1:0]      iowidth, // dynamically configured io bus width
     //IO interface
     input 	      rx_clk, // clock for IO
     input [IOW-1:0]  rx_packet, // data for IO
     input 	      rx_access, // access signal for IO
     //FIFO interface (core side)
     output 	      io_access,// fifo write
     output reg [7:0] io_valid, // fifo byte valid
     output [63:0]    io_packet // fifo packet
     );
   
   // local wires
   wire [IOW-1:0]    ddr_data;
   wire 	     io_nreset;
   wire [63:0] 	     io_data;
   wire [63:0] 	     mux_data;
   wire [7:0] 	     data_select;
   wire [7:0] 	     valid_input;
   wire [7:0] 	     valid_next;   
   wire [IOW/2-1:0]  ddr_even;
   wire [IOW/2-1:0]  ddr_odd;   
   wire 	     io_frame;
   wire 	     dmode8;
   wire 	     dmode16;
   wire 	     dmode32;
   wire 	     dmode64;
   wire 	     reload;
   wire 	     transfer_done;
   wire 	     transfer_active;
   
   reg [63:0] 	     shiftreg;
   reg [IOW-1:0]     sdr_data;
   reg [1:0] 	     rx_access_reg;
   
   
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

   assign valid_input[7:0] = dmode8  ? 8'b00000001 :
			     dmode16 ? 8'b00000011 :
			     dmode32 ? 8'b00001111 :
                                       8'b11111111;
   
   assign valid_next[7:0] = dmode8  ? {io_valid[6:0],1'b1}     :
			    dmode16 ? {io_valid[5:0],2'b11}    :
                            dmode32 ? {io_valid[3:0],4'b1111} :
			               8'b11111111;
 
   //Keep track of valid bytes in shift register
   always @ (posedge rx_clk or negedge io_nreset)
     if(!io_nreset)
       io_valid[7:0] <= 8'b0;
     else if(reload)
       io_valid[7:0] <= valid_input[7:0];   
     else if(io_frame)
       io_valid[7:0] <= valid_next[7:0];
     else
       io_valid[7:0] <= 8'b0;
   
   assign reload = (io_frame &  transfer_done) |  // continuing stream
		   (io_frame & ~transfer_active); // new frame

   assign transfer_active = |io_valid[7:0];
   assign transfer_done   = &io_valid[7:0];

   //Access signal for FIFO
   assign io_access = transfer_done                 | // full vector
		      (~io_frame & transfer_active);  // partial vector 
          
   //########################################
   //# DATA CAPTURE
   //########################################
      
   // DDR
   oh_iddr #(.DW(IOW/2))
   data_iddr(.q1			(ddr_even[IOW/2-1:0]),
	     .q2			(ddr_odd[IOW/2-1:0]),
	     .clk			(rx_clk),
	     .ce			(rx_access),
	     .din			(rx_packet[IOW/2-1:0]));

   assign ddr_data[IOW-1:0] = (iowidth[1:0]==2'b00) ? {ddr_odd[3:0],ddr_even[3:0]}   :
			      (iowidth[1:0]==2'b01) ? {ddr_odd[7:0],ddr_even[7:0]}   :
			      (iowidth[1:0]==2'b10) ? {ddr_odd[15:0],ddr_even[15:0]} :
			                              {ddr_odd[31:0],ddr_even[31:0]};
    
   // SDR
   always @ (posedge rx_clk)
     if(rx_access)
       sdr_data[IOW-1:0] <= rx_packet[IOW-1:0];

   // select between ddr/sdr data
   assign io_data[IOW-1:0]   = ddr_mode ? ddr_data[IOW-1:0] :
                                          sdr_data[IOW-1:0];


   //align data based on IOW
   assign mux_data[IOW-1:0] = dmode8  ? {(8){io_data[7:0]}}  :
			      dmode16 ? {(4){io_data[15:0]}} :
			      dmode32 ? {(2){io_data[31:0]}} :
			                    io_data[IOW-1:0];
   
   // pipeline access signal
   always @ (posedge rx_clk or negedge io_nreset)
     if(!io_nreset)
       rx_access_reg[1:0] <= 1'b0;
     else
       rx_access_reg[1:0] <= {rx_access_reg[0],rx_access};

   assign io_frame = ddr_mode ? rx_access_reg[1] :
                                rx_access_reg[0];
    
   //########################################
   //# PACKETIZER
   //########################################

   //detect selection based on valid pattern edge
   assign data_select[7:0] = reload ? valid_input[7:0] :
			              valid_next[7:0] & ~io_valid[7:0];
   
   integer 	      i;   
   always @ (posedge rx_clk)
     for (i=0;i<8;i=i+1)
       shiftreg[i*8+:8] <= data_select[i] ? mux_data[i*8+:8] : shiftreg[i*8+:8];
   
   assign io_packet[63:0] = shiftreg[63:0];
   
   //########################################
   //# SYNCHRONIZERS
   //########################################

   oh_rsync oh_rsync(.nrst_out	(io_nreset),
		     .clk	(rx_clk),
		     .nrst_in	(nreset));
   
endmodule // mrx_io

// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

  
