/*
 ########################################################################
 Epiphany eLink AXI Master Module
 ######################################################################## 

  NOTES:
 --write channels: write address, write data, write response
 --read channels: read address, read data channel
 --'valid' source signal used to show valid address,data,control is available
 --'ready' destination  ready signal indicates readyness to accept information
 --'last' signal indicates the transfer of final data item
 --read and write have separate address channels
 --read data channel carries read data from slave to master
 --write channel includes a byte lane strobe signal for every eight data bits
 --there is no acknowledge on write, treated as buffered 
 --channels are unidirectional
 --valid is asserted uncondotionally
 --ready occurs cycle after valid
 --there can be no combinatorial path between input and output of interface
 --destination is permitted to wait for valud before asserting READY
 --source is not allowed to wait for READY to assert VALID
 --AWVALID must remain asserted until the rising clock edge after slave asserts AWREADY??
 --The default state of AWREADY can be either HIGH or LOW. This specification recommends a default state of HIGH.
 --During a write burst, the master can assert the WVALID signal only when it drives valid write data.
 --The default state of WREADY can be HIGH, but only if the slave can always accept write data in a single cycle.
 --The master must assert the WLAST signal while it is driving the final write transfer in the burst.

 --_aw=write address channel
 --_ar=read address channel
 --_r=read data channel
 --_w=write data channel
 --_b=write response channel

  */

module emaxi(/*autoarg*/
   // Outputs
   rxwr_wait, rxrd_wait, txrr_access, txrr_packet, m_axi_awid,
   m_axi_awaddr, m_axi_awlen, m_axi_awsize, m_axi_awburst,
   m_axi_awlock, m_axi_awcache, m_axi_awprot, m_axi_awqos,
   m_axi_awvalid, m_axi_wid, m_axi_wdata, m_axi_wstrb, m_axi_wlast,
   m_axi_wvalid, m_axi_bready, m_axi_arid, m_axi_araddr, m_axi_arlen,
   m_axi_arsize, m_axi_arburst, m_axi_arlock, m_axi_arcache,
   m_axi_arprot, m_axi_arqos, m_axi_arvalid, m_axi_rready,
   // Inputs
   rxwr_access, rxwr_packet, rxrd_access, rxrd_packet, txrr_wait,
   m_axi_aclk, m_axi_aresetn, m_axi_awready, m_axi_wready, m_axi_bid,
   m_axi_bresp, m_axi_bvalid, m_axi_arready, m_axi_rid, m_axi_rdata,
   m_axi_rresp, m_axi_rlast, m_axi_rvalid
   );

   parameter IDW    = 12;
   parameter PW     = 104;
   parameter AW     = 32;
   parameter DW     = 32;

   //########################
   //ELINK INTERFACE
   //########################

   
   //Write request from erx
   input 	       rxwr_access;
   input [PW-1:0]      rxwr_packet;   
   output 	       rxwr_wait;
   
   //Read request from erx
   input 	       rxrd_access;
   input [PW-1:0]      rxrd_packet;
   output 	       rxrd_wait;
   
   //Read respoonse for etx
   output 	       txrr_access;
   output [PW-1:0]     txrr_packet;
   input 	       txrr_wait;

   //########################
   //AXI MASTER INTERFACE
   //########################

   input  	       m_axi_aclk;    // global clock signal.
   input  	       m_axi_aresetn; // global reset singal.

   //Write address channel
   output [IDW-1:0]    m_axi_awid;    // write address ID
   output [31 : 0]     m_axi_awaddr;  // master interface write address   
   output [7 : 0]      m_axi_awlen;   // burst length.
   output [2 : 0]      m_axi_awsize;  // burst size.
   output [1 : 0]      m_axi_awburst; // burst type.
   output [1 : 0]      m_axi_awlock;  // lock type   
   output [3 : 0]      m_axi_awcache; // memory type.
   output [2 : 0]      m_axi_awprot;  // protection type.
   output [3 : 0]      m_axi_awqos;   // quality of service
   output 	       m_axi_awvalid; // write address valid
   input 	       m_axi_awready; // write address ready

   //Write data channel
   output [IDW-1:0]    m_axi_wid;     
   output [63 : 0]     m_axi_wdata;   // master interface write data.
   output [7 : 0]      m_axi_wstrb;   // byte write strobes
   output 	       m_axi_wlast;   // indicates last transfer in a write burst.
   output 	       m_axi_wvalid;  // indicates data is ready to go
   input 	       m_axi_wready;  // indicates that the slave is ready for data

   //Write response channel
   input [IDW-1:0]     m_axi_bid;
   input [1 : 0]       m_axi_bresp;   // status of the write transaction.
   input 	       m_axi_bvalid;  // channel is signaling a valid write response
   output 	       m_axi_bready;  // master can accept write response.

   //Read address channel
   output [IDW-1:0]    m_axi_arid;    // read address ID
   output [31 : 0]     m_axi_araddr;  // initial address of a read burst
   output [7 : 0]      m_axi_arlen;   // burst length
   output [2 : 0]      m_axi_arsize;  // burst size
   output [1 : 0]      m_axi_arburst; // burst type
   output [1 : 0]      m_axi_arlock;  //lock type   
   output [3 : 0]      m_axi_arcache; // memory type
   output [2 : 0]      m_axi_arprot;  // protection type
   output [3 : 0]      m_axi_arqos;   // 
   output 	       m_axi_arvalid; // valid read address and control information
   input 	       m_axi_arready; // slave is ready to accept an address

   //Read data channel   
   input [IDW-1:0]     m_axi_rid; 
   input [63 : 0]      m_axi_rdata;   // master read data
   input [1 : 0]       m_axi_rresp;   // status of the read transfer
   input 	       m_axi_rlast;   // signals last transfer in a read burst
   input 	       m_axi_rvalid;  // signaling the required read data
   output 	       m_axi_rready;  // master can accept the readback data
  

   //#########################################################################
   //REGISTER/WIRE DECLARATIONS
   //#########################################################################
   reg [31 : 0]        m_axi_awaddr;
   reg [7:0] 	       m_axi_awlen;
   reg [2:0] 	       m_axi_awsize;
   reg 		       m_axi_awvalid;
   reg [63 : 0]        m_axi_wdata;
   reg [63 : 0]     m_axi_rdata_reg;
   reg [7 : 0] 	       m_axi_wstrb;
   reg 		       m_axi_wlast;
   reg 		       m_axi_wvalid;
   reg 		       awvalid_b;
   reg [31:0] 	       awaddr_b;
   reg [2:0] 	       awsize_b;
   reg [7:0] 	       awlen_b;
   reg 		       wvalid_b;
   reg [63:0] 	       wdata_b;
   reg [7:0] 	       wstrb_b;
   reg [63 : 0]        wdata_aligned;
   reg [7 : 0] 	       wstrb_aligned;
   
   reg 		       txrr_access;
   reg 		       txrr_access_reg;
   reg [31:0] 	       txrr_data;
   reg [31:0] 	       txrr_srcaddr;
   
   //wires
   wire 	       aw_go;
   wire 	       w_go;
   wire 	       readinfo_wren;
   wire 	       readinfo_full;
   wire [47:0] 	       readinfo_out;
   wire [47:0] 	       readinfo_in;

   wire 	       awvalid_in;
   
   wire [1:0] 	       rxwr_datamode;
   wire [AW-1:0]       rxwr_dstaddr;
   wire [DW-1:0]       rxwr_data;
   wire [AW-1:0]       rxwr_srcaddr;

   wire [1:0] 	       rxrd_datamode;
   wire [3:0] 	       rxrd_ctrlmode;
   wire [AW-1:0]       rxrd_dstaddr;
   wire [AW-1:0]       rxrd_srcaddr;

   wire [1:0] 	       txrr_datamode;
   wire [3:0] 	       txrr_ctrlmode;
   wire [31:0] 	       txrr_dstaddr;
   
   //#########################################################################
   //EMESH 2 PACKET CONVERSION
   //#########################################################################

   //RXWR
   packet2emesh p2e_rxwr (
			  // Outputs
			  .access_out		(),
			  .write_out		(),
			  .datamode_out		(rxwr_datamode[1:0]),
			  .ctrlmode_out		(),
			  .dstaddr_out		(rxwr_dstaddr[AW-1:0]),
			  .data_out		(rxwr_data[DW-1:0]),
			  .srcaddr_out		(rxwr_srcaddr[AW-1:0]),
			  // Inputs
			  .packet_in		(rxwr_packet[PW-1:0])
			  );
   
   //RXRD
   packet2emesh p2e_rxrd (
			  // Outputs
			  .access_out		(),
			  .write_out		(),
			  .datamode_out		(rxrd_datamode[1:0]),
			  .ctrlmode_out		(rxrd_ctrlmode[3:0]),
			  .dstaddr_out		(rxrd_dstaddr[AW-1:0]),
			  .data_out		(),
			  .srcaddr_out		(rxrd_srcaddr[AW-1:0]),
			  // Inputs
			  .packet_in		(rxrd_packet[PW-1:0])
			  );

   //TXRR
   emesh2packet e2p (
		     // Outputs
		     .packet_out	(txrr_packet[PW-1:0]),
		     // Inputs
		     .access_in		(txrr_access),
		     .write_in		(1'b1),
		     .datamode_in	(txrr_datamode[1:0]),
		     .ctrlmode_in	(txrr_ctrlmode[3:0]),
		     .dstaddr_in	(txrr_dstaddr[AW-1:0]),
		     .data_in		(txrr_data[DW-1:0]),
		     .srcaddr_in	(txrr_srcaddr[AW-1:0])
		     );
   			    
   //#########################################################################
   //AXI unimplemented constants
   //#########################################################################

   assign m_axi_awburst[1:0]	= 2'b01; //only increment burst supported
   assign m_axi_awcache[3:0]	= 4'b0000;//TODO: correct value??
   assign m_axi_awprot[2:0]	= 3'b000;
   assign m_axi_awqos[3:0]	= 4'b0000;
   assign m_axi_awlock          = 2'b00;

   assign m_axi_arburst[1:0]	= 2'b01; //only increment burst supported
   assign m_axi_arcache[3:0]	= 4'b0000;
   assign m_axi_arprot[2:0]	= 3'h0;
   assign m_axi_arqos[3:0]	= 4'h0;

   assign m_axi_bready    	= 1'b1;//tie to wait signal????   
   
   //#########################################################################
   //Write address channel
   //#########################################################################

   assign aw_go       = m_axi_awvalid & m_axi_awready;
   assign w_go        = m_axi_wvalid  & m_axi_wready;
   assign rxwr_wait   = awvalid_b   | wvalid_b;
   assign awvalid_in  = rxwr_access & ~awvalid_b & ~wvalid_b;
   
   // generate write-address signals
   always @( posedge m_axi_aclk )     
     if(~m_axi_aresetn) 
       begin
          m_axi_awvalid      <= 1'b0;
          m_axi_awaddr[31:0] <= 32'd0;
          m_axi_awlen[7:0]   <= 8'd0;
          m_axi_awsize[2:0]  <= 3'd0;	  
          awvalid_b          <= 1'b0;
          awaddr_b           <= 'd0;
          awlen_b[7:0]       <= 'd0;
          awsize_b[2:0]      <= 'd0;
       end 
     else 
       begin
          if( ~m_axi_awvalid | aw_go ) 
	    begin
               if( awvalid_b ) 
		 begin
		    m_axi_awvalid       <= 1'b1;
		    m_axi_awaddr[31:0]  <= awaddr_b[31:0];
		    m_axi_awlen[7:0]    <= awlen_b[7:0];
		    m_axi_awsize[2:0]   <= awsize_b[2:0];
		 end 
	      else 
		begin
		   m_axi_awvalid       <= awvalid_in;
		   m_axi_awaddr[31:0]  <= rxwr_dstaddr[31:0];
		   m_axi_awlen[7:0]    <= 8'b0;
		   m_axi_awsize[2:0]   <= { 1'b0, rxwr_datamode[1:0]};
		end
	    end
          if( awvalid_in & m_axi_awvalid & ~aw_go )
            awvalid_b <= 1'b1;
          else if( aw_go )
            awvalid_b <= 1'b0;
          
	 //Pipeline stage
         if( awvalid_in )
	   begin
              awaddr_b[31:0]  <= rxwr_dstaddr[31:0];
              awlen_b[7:0]    <= 8'b0;
              awsize_b[2:0]   <= { 1'b0, rxwr_datamode[1:0] };
         end        
       end // else: !if(~m_axi_aresetn)
   
   //#########################################################################
   //Write data alignment circuit
   //#########################################################################

   always @*
     case( rxwr_datamode[1:0] )        
       2'd0:    wdata_aligned[63:0] = { 8{rxwr_data[7:0]}};
       2'd1:    wdata_aligned[63:0] = { 4{rxwr_data[15:0]}};
       2'd2:    wdata_aligned[63:0] = { 2{rxwr_data[31:0]}};
       default: wdata_aligned[63:0] = { rxwr_srcaddr[31:0], rxwr_data[31:0]};
     endcase

   always @*
     begin
	case(rxwr_datamode[1:0])
          2'd0: // byte
            case(rxwr_dstaddr[2:0])
              3'd0:    wstrb_aligned[7:0] = 8'h01;
              3'd1:    wstrb_aligned[7:0] = 8'h02;
              3'd2:    wstrb_aligned[7:0] = 8'h04;
              3'd3:    wstrb_aligned[7:0] = 8'h08;
              3'd4:    wstrb_aligned[7:0] = 8'h10;
              3'd5:    wstrb_aligned[7:0] = 8'h20;
              3'd6:    wstrb_aligned[7:0] = 8'h40;
              default: wstrb_aligned[7:0] = 8'h80;
            endcase
          2'd1: // 16b hword
            case(rxwr_dstaddr[2:1])
              2'd0:    wstrb_aligned[7:0] = 8'h03;
              2'd1:    wstrb_aligned[7:0] = 8'h0c;
              2'd2:    wstrb_aligned[7:0] = 8'h30;
              default: wstrb_aligned[7:0] = 8'hc0;
            endcase
          2'd2: // 32b word
            if(rxwr_dstaddr[2])
	      wstrb_aligned[7:0] = 8'hf0;
            else
	      wstrb_aligned[7:0] = 8'h0f;
	  2'd3: 
	    wstrb_aligned[7:0] = 8'hff;
	endcase // case (emwr_datamode[1:0])
     end // always @ *

   //#########################################################################
   //Write data channel
   //#########################################################################

   always @ (posedge m_axi_aclk )
     if(~m_axi_aresetn) 
       begin	  
	  m_axi_wvalid      <= 1'b0;
          m_axi_wdata[63:0] <= 64'b0;
          m_axi_wstrb[7:0]  <= 8'b0;
          m_axi_wlast       <= 1'b1; // TODO:bursts!!	  
          wvalid_b          <= 1'b0;
          wdata_b[63:0]     <= 64'b0;
          wstrb_b[7:0]      <= 8'b0;         
       end 
     else 
       begin
          if( ~m_axi_wvalid | w_go ) 
	    begin
            if( wvalid_b ) 
	      begin
		 m_axi_wvalid       <= 1'b1;
		 m_axi_wdata[63:0]  <= wdata_b[63:0];
		 m_axi_wstrb[7:0]   <= wstrb_b[7:0];
              end 
	    else 
	      begin
		 m_axi_wvalid       <= awvalid_in;
		 m_axi_wdata[63:0]  <= wdata_aligned[63:0];
		 m_axi_wstrb[7:0]   <= wstrb_aligned[7:0];
              end
            end // if ( ~axi_wvalid | w_go )

         if( rxwr_access & m_axi_wvalid & ~w_go )
           wvalid_b <= 1'b1;
         else if( w_go )
           wvalid_b <= 1'b0;
	  
          if( awvalid_in ) 
	    begin
               wdata_b[63:0] <= wdata_aligned[63:0];
               wstrb_b[7:0]  <= wstrb_aligned[7:0];
            end
       end // else: !if(~m_axi_aresetn)
   
   //#########################################################################
   //Read request channel
   //#########################################################################
   //1. read request comes in on ar channel
   //2. use src address to match with writes coming back
   //3. Assumes in order returns
   
   assign  readinfo_in[47:0] = 
               {
		7'b0,
                rxrd_srcaddr[31:0],//40:9
                rxrd_dstaddr[2:0], //8:6
                rxrd_ctrlmode[3:0], //5:2
                rxrd_datamode[1:0]
                };
   
   fifo_sync 
     #(
       // parameters
       .AW                              (5),
       .DW                              (48)) 
   fifo_readinfo_i
     (
      // outputs
      .rd_data                          (readinfo_out[47:0]),
      .rd_empty                         (),
      .wr_full                          (readinfo_full),
      // inputs
      .clk                              (m_axi_aclk),
      .reset                            (~m_axi_aresetn),
      .wr_data                          (readinfo_in[47:0]),
      .wr_en                            (m_axi_arvalid & m_axi_arready),
      .rd_en                            (m_axi_rready & m_axi_rvalid)
      );

   assign txrr_datamode[1:0]  = readinfo_out[1:0];
   assign txrr_ctrlmode[3:0]  = readinfo_out[5:2];
   assign txrr_dstaddr[31:0]  = readinfo_out[40:9];

   //#########################################################################
   //Read address channel
   //#########################################################################
   
   assign    m_axi_araddr[31:0]   = rxrd_dstaddr[31:0];
   assign    m_axi_arsize[2:0]    = {1'b0, rxrd_datamode[1:0]};
   assign    m_axi_arlen[7:0]     = 8'd0;
   assign    m_axi_arvalid        = rxrd_access & ~readinfo_full;
   assign    rxrd_wait            = m_axi_arvalid & ~m_axi_arready;
   
   //#########################################################################
   //Read response channel
   //#########################################################################

   assign m_axi_rready  = ~txrr_wait; //pass through

   always @( posedge m_axi_aclk )
       if ( ~m_axi_aresetn )
           m_axi_rdata_reg <= 'b0;
       else
           m_axi_rdata_reg <= m_axi_rdata;

   
   always @( posedge m_axi_aclk )
     if( ~m_axi_aresetn ) 
       begin      
	  txrr_data[31:0]     <= 32'b0;
	  txrr_srcaddr[31:0]  <= 32'b0;
	  txrr_access_reg     <= 1'b0;
	  txrr_access         <= 1'b0;         
      end 
     else 
       begin
          txrr_access_reg     <= m_axi_rready & m_axi_rvalid;
	  txrr_access         <= txrr_access_reg;//added pipeline stage for data 
	  // steer read data according to size & host address lsbs
	  //all data needs to be right aligned
	  //(this is due to the Epiphany right aligning all words)
	  case(readinfo_out[1:0])//datamode
            2'd0:  // byte read
              case(readinfo_out[8:6])
		3'd0:     txrr_data[7:0] <= m_axi_rdata_reg[7:0];
		3'd1:     txrr_data[7:0] <= m_axi_rdata_reg[15:8];
		3'd2:     txrr_data[7:0] <= m_axi_rdata_reg[23:16];
		3'd3:     txrr_data[7:0] <= m_axi_rdata_reg[31:24];
		3'd4:     txrr_data[7:0] <= m_axi_rdata_reg[39:32];
		3'd5:     txrr_data[7:0] <= m_axi_rdata_reg[47:40];
		3'd6:     txrr_data[7:0] <= m_axi_rdata_reg[55:48];
		default:  txrr_data[7:0] <= m_axi_rdata_reg[63:56];
              endcase	    
            2'd1:  // 16b hword
              case( readinfo_out[8:7] )
		2'd0:    txrr_data[15:0] <= m_axi_rdata_reg[15:0];
		2'd1:    txrr_data[15:0] <= m_axi_rdata_reg[31:16];
		2'd2:    txrr_data[15:0] <= m_axi_rdata_reg[47:32];
		default: txrr_data[15:0] <= m_axi_rdata_reg[63:48];
              endcase
            2'd2:  // 32b word
              if( readinfo_out[8] )
               txrr_data[31:0] <= m_axi_rdata_reg[63:32];
             else
               txrr_data[31:0] <= m_axi_rdata_reg[31:0];
           // 64b word already defined by defaults above
           2'd3: 
	     begin // 64b dword
		txrr_data[31:0]  <= m_axi_rdata_reg[31:0];
		txrr_srcaddr[31:0]  <= m_axi_rdata_reg[63:32];
             end
         endcase         
       end // else: !if( ~m_axi_aresetn )
   
endmodule // emaxi
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../memory/hdl")
// End:

/*
 copyright (c) 2014 adapteva, inc.
 contributed by fred huettig <fred@adapteva.com>
 contributed by andreas olofsson <andreas@adapteva.com>
 
 this program is free software: you can redistribute it and/or modify
 it under the terms of the gnu general public license as published by
 the free software foundation, either version 3 of the license, or
 (at your option) any later version.
 
 this program is distributed in the hope that it will be useful,
 but without any warranty; without even the implied warranty of
 merchantability or fitness for a particular purpose.  see the
 gnu general public license for more details.
 
 you should have received a copy of the gnu general public license
 along with this program (see the file copying).  if not, see
 <http://www.gnu.org/licenses/>.
 */
