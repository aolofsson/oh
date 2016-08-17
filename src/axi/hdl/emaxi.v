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
   wr_wait, rd_wait, rr_access, rr_packet, m_axi_awid, m_axi_awaddr,
   m_axi_awlen, m_axi_awsize, m_axi_awburst, m_axi_awlock,
   m_axi_awcache, m_axi_awprot, m_axi_awqos, m_axi_awvalid, m_axi_wid,
   m_axi_wdata, m_axi_wstrb, m_axi_wlast, m_axi_wvalid, m_axi_bready,
   m_axi_arid, m_axi_araddr, m_axi_arlen, m_axi_arsize, m_axi_arburst,
   m_axi_arlock, m_axi_arcache, m_axi_arprot, m_axi_arqos,
   m_axi_arvalid, m_axi_rready,
   // Inputs
   wr_access, wr_packet, rd_access, rd_packet, rr_wait, m_axi_aclk,
   m_axi_aresetn, m_axi_awready, m_axi_wready, m_axi_bid, m_axi_bresp,
   m_axi_bvalid, m_axi_arready, m_axi_rid, m_axi_rdata, m_axi_rresp,
   m_axi_rlast, m_axi_rvalid
   );

   parameter M_IDW  = 12;
   parameter PW     = 104;
   parameter AW     = 32;
   parameter DW     = 32;

   //########################
   //EMESH INTERFACE
   //########################

   //Write request
   input 	       wr_access;
   input [PW-1:0]      wr_packet;   
   output 	       wr_wait;
   
   //Read request
   input 	       rd_access;
   input [PW-1:0]      rd_packet;
   output 	       rd_wait;
   
   //Read response
   output 	       rr_access;
   output [PW-1:0]     rr_packet;
   input 	       rr_wait;

   //########################
   //AXI MASTER INTERFACE
   //########################

   input  	       m_axi_aclk;    // global clock signal.
   input  	       m_axi_aresetn; // global reset singal.

   //Write address channel
   output [M_IDW-1:0]  m_axi_awid;    // write address ID
   output [31 : 0]     m_axi_awaddr;  // master interface write address   
   output [7 : 0]      m_axi_awlen;   // burst length.
   output [2 : 0]      m_axi_awsize;  // burst size.
   output [1 : 0]      m_axi_awburst; // burst type.
   output              m_axi_awlock;  // lock type   
   output [3 : 0]      m_axi_awcache; // memory type.
   output [2 : 0]      m_axi_awprot;  // protection type.
   output [3 : 0]      m_axi_awqos;   // quality of service
   output 	       m_axi_awvalid; // write address valid
   input 	       m_axi_awready; // write address ready

   //Write data channel
   output [M_IDW-1:0]  m_axi_wid;     
   output [63 : 0]     m_axi_wdata;   // master interface write data.
   output [7 : 0]      m_axi_wstrb;   // byte write strobes
   output 	       m_axi_wlast;   // last transfer in a write burst.
   output 	       m_axi_wvalid;  // indicates data is ready to go
   input 	       m_axi_wready;  // slave is ready for data

   //Write response channel
   input [M_IDW-1:0]   m_axi_bid;
   input [1 : 0]       m_axi_bresp;   // status of the write transaction.
   input 	       m_axi_bvalid;  // channel is a valid write response
   output 	       m_axi_bready;  // master can accept write response.

   //Read address channel
   output [M_IDW-1:0]  m_axi_arid;    // read address ID
   output [31 : 0]     m_axi_araddr;  // initial address of a read burst
   output [7 : 0]      m_axi_arlen;   // burst length
   output [2 : 0]      m_axi_arsize;  // burst size
   output [1 : 0]      m_axi_arburst; // burst type
   output              m_axi_arlock;  // lock type   
   output [3 : 0]      m_axi_arcache; // memory type
   output [2 : 0]      m_axi_arprot;  // protection type
   output [3 : 0]      m_axi_arqos;   // quality of service info
   output 	       m_axi_arvalid; // valid read address
   input 	       m_axi_arready; // slave is ready to accept an address

   //Read data channel   
   input [M_IDW-1:0]   m_axi_rid;     // read data ID
   input [63 : 0]      m_axi_rdata;   // master read data
   input [1 : 0]       m_axi_rresp;   // status of the read transfer
   input 	       m_axi_rlast;   // last transfer in a read burst
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
   reg [63 : 0]        m_axi_rdata_reg;
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
   
   reg 		       rr_access;
   reg [31:0] 	       rr_data;
   reg [31:0] 	       rr_srcaddr;
   reg [3:0] 	       rr_datamode;
   reg [3:0] 	       rr_ctrlmode;
   reg [31:0] 	       rr_dstaddr;
   reg [63:0] 	       m_axi_rdata_fifo;
   reg 		       rr_access_fifo;
  
   
   //wires
   wire 	       aw_go;
   wire 	       w_go;
   wire 	       readinfo_wren;
   wire 	       readinfo_full;
   wire [40:0] 	       readinfo_out;
   wire [40:0] 	       readinfo_in;
   wire 	       awvalid_in;
   
   wire [1:0] 	       wr_datamode;
   wire [AW-1:0]       wr_dstaddr;
   wire [DW-1:0]       wr_data;
   wire [AW-1:0]       wr_srcaddr;

   wire [1:0] 	       rd_datamode;
   wire [4:0] 	       rd_ctrlmode;
   wire [AW-1:0]       rd_dstaddr;
   wire [AW-1:0]       rd_srcaddr;

   wire [1:0] 	       rr_datamode_fifo;
   wire [3:0] 	       rr_ctrlmode_fifo;
   wire [31:0] 	       rr_dstaddr_fifo;
   wire [2:0] 	       rr_alignaddr_fifo;
   wire [103:0]        packet_out;   
   wire 	       fifo_prog_full;
   wire 	       fifo_full;   	
   wire 	       fifo_rd_en;
   wire 	       fifo_wr_en;
   
   //#########################################################################
   //EMESH 2 PACKET CONVERSION
   //#########################################################################

   //RXWR
   packet2emesh p2e_rxwr (
			  // Outputs
			  .write_in		(),
			  .datamode_in		(wr_datamode[1:0]),
			  .ctrlmode_in		(),
			  .dstaddr_in		(wr_dstaddr[AW-1:0]),
			  .data_in		(wr_data[DW-1:0]),
			  .srcaddr_in		(wr_srcaddr[AW-1:0]),
			  // Inputs
			  .packet_in		(wr_packet[PW-1:0])
			  );
   
   //RXRD
   packet2emesh p2e_rxrd (
			  // Outputs
			  .write_in		(),
			  .datamode_in		(rd_datamode[1:0]),
			  .ctrlmode_in		(rd_ctrlmode[4:0]),
			  .dstaddr_in		(rd_dstaddr[AW-1:0]),
			  .data_in		(),
			  .srcaddr_in		(rd_srcaddr[AW-1:0]),
			  // Inputs
			  .packet_in		(rd_packet[PW-1:0])
			  );

   //RR
   emesh2packet e2p (
		     // Outputs
		     .packet_out	(rr_packet[PW-1:0]),
		     // Inputs
		     .write_out		(1'b1),
		     .datamode_out	(rr_datamode[1:0]),
		     .ctrlmode_out	({1'b0,rr_ctrlmode[3:0]}),
		     .dstaddr_out	(rr_dstaddr[AW-1:0]),
		     .data_out		(rr_data[DW-1:0]),
		     .srcaddr_out	(rr_srcaddr[AW-1:0])
		     );
   			    
   //#########################################################################
   //AXI unimplemented constants
   //#########################################################################

   //AW
   assign m_axi_awid[M_IDW-1:0]  = {(M_IDW){1'b0}};
   assign m_axi_awburst[1:0]	= 2'b01; //only increment burst supported
   assign m_axi_awcache[3:0]	= 4'b0000; //TODO: should this be 0000 or 0010???
   assign m_axi_awprot[2:0]	= 3'b000;
   assign m_axi_awqos[3:0]	= 4'b0000;
   assign m_axi_awlock          = 1'b0;

   //AR
   assign m_axi_arid[M_IDW-1:0] = {(M_IDW){1'b0}};
   assign m_axi_arburst[1:0]	= 2'b01; //only increment burst supported
   assign m_axi_arcache[3:0]	= 4'b0000;
   assign m_axi_arprot[2:0]	= 3'h0;
   assign m_axi_arqos[3:0]	= 4'h0;
   assign m_axi_arlock          = 1'b0;
    
   //B
   assign m_axi_bready    	= 1'b1;//TODO: tie to wait signal????   

   //W
   assign m_axi_wid[M_IDW-1:0]  = {(M_IDW){1'b0}};

   //#########################################################################
   //Write address channel
   //#########################################################################

   assign aw_go       = m_axi_awvalid & m_axi_awready;
   assign w_go        = m_axi_wvalid  & m_axi_wready;
   assign wr_wait     = awvalid_b | wvalid_b;
   assign awvalid_in  = wr_access & ~awvalid_b & ~wvalid_b;
   
   // generate write-address signals
   always @( posedge m_axi_aclk )     
     if(!m_axi_aresetn) 
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
		   m_axi_awaddr[31:0]  <= wr_dstaddr[31:0];
		   m_axi_awlen[7:0]    <= 8'b0;
		   m_axi_awsize[2:0]   <= { 1'b0, wr_datamode[1:0]};
		end
	    end
          if( awvalid_in & m_axi_awvalid & ~aw_go )
            awvalid_b <= 1'b1;
          else if( aw_go )
            awvalid_b <= 1'b0;
          
	 //Pipeline stage
         if( awvalid_in )
	   begin
              awaddr_b[31:0]  <= wr_dstaddr[31:0];
              awlen_b[7:0]    <= 8'b0;
              awsize_b[2:0]   <= { 1'b0, wr_datamode[1:0] };
         end        
       end // else: !if(~m_axi_aresetn)
   
   //#########################################################################
   //Write data alignment circuit
   //#########################################################################

   always @*
     case( wr_datamode[1:0] )        
       2'b00:    wdata_aligned[63:0] = { 8{wr_data[7:0]}};
       2'b01:    wdata_aligned[63:0] = { 4{wr_data[15:0]}};
       2'b10:    wdata_aligned[63:0] = { 2{wr_data[31:0]}};
       default: wdata_aligned[63:0]  = { wr_srcaddr[31:0], wr_data[31:0]};
     endcase

   always @*
     begin
	case(wr_datamode[1:0])
          2'd0: // byte
            case(wr_dstaddr[2:0])
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
            case(wr_dstaddr[2:1])
              2'd0:    wstrb_aligned[7:0] = 8'h03;
              2'd1:    wstrb_aligned[7:0] = 8'h0c;
              2'd2:    wstrb_aligned[7:0] = 8'h30;
              default: wstrb_aligned[7:0] = 8'hc0;
            endcase
          2'd2: // 32b word
            if(wr_dstaddr[2])
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

         if( wr_access & m_axi_wvalid & ~w_go )
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
   
   assign  readinfo_in[40:0] = {rd_srcaddr[31:0],//40:9
				rd_dstaddr[2:0], //8:6
				rd_ctrlmode[3:0],//5:2
				rd_datamode[1:0] //1:0
				};
   

   //Rest synchronization (for safety, assume incoming reset is async)
   wire sync_nreset;   
   oh_dsync dsync(.dout	(sync_nreset),
	       .clk	(m_axi_aclk),
	       .nreset       (1'b1),
	       .din	(m_axi_aresetn)
	       );
   
   //Synchronous FIFO for read transactions  	 

   oh_fifo_sync #(.DW(104), 
		   .DEPTH(32)) 
   fifo_async (.full		(fifo_full),
	       .prog_full	(fifo_prog_full),
	       .dout		(packet_out[103:0]),
	       .empty		(),
	       // Inputs
	       .nreset		(sync_nreset),
	       .clk	        (m_axi_aclk),
	       .wr_en		(fifo_wr_en),
	       .din		({63'b0,readinfo_in[40:0]}),
	       .rd_en		(fifo_rd_en)
	       ); 

   assign  rr_datamode_fifo[1:0]  = packet_out[1:0];
   assign  rr_ctrlmode_fifo[3:0]  = packet_out[5:2];
   assign  rr_alignaddr_fifo[2:0] = packet_out[8:6];
   assign  rr_dstaddr_fifo[31:0]  = packet_out[40:9];
   
   //###################################################################
   //Read address channel
   //###################################################################
   
   assign    m_axi_araddr[31:0]   = rd_dstaddr[31:0];
   assign    m_axi_arsize[2:0]    = {1'b0, rd_datamode[1:0]};
   assign    m_axi_arlen[7:0]     = 8'd0;  
   assign    m_axi_arvalid        = rd_access & ~fifo_prog_full; //BUG& ~rr_wait & ~fifo_prog_full; //remove 
   assign    fifo_wr_en           = m_axi_arvalid & m_axi_arready ;
   assign    rd_wait              = ~m_axi_arready | fifo_prog_full;//BUG| rr_wait
   assign    fifo_rd_en           =  m_axi_rvalid & m_axi_rready;//BUG & ~rr_wait
				      
   //#################################################################
   //Read response channel
   //#################################################################
   assign    m_axi_rready         = ~rr_wait; //BUG!: 1'b1

   //Pipeline axi transaction to account for FIFO read latency   
   always @ (posedge m_axi_aclk)
     if(!m_axi_aresetn) 
       begin
	  rr_access_fifo  <= 1'b0;	  
	  rr_access       <= 1'b0;	  
       end
     else	 
       begin
	  rr_access_fifo   <= fifo_rd_en;
	  rr_access        <= rr_access_fifo;	  
       end

   //Alignment Mux (one cycle)
   always @ (posedge m_axi_aclk)    
     begin	  
	m_axi_rdata_fifo[63:0] <= m_axi_rdata[63:0];      	  
	rr_datamode[1:0]       <= rr_datamode_fifo[1:0];
	rr_ctrlmode[3:0]       <= rr_ctrlmode_fifo[3:0];
	rr_dstaddr[31:0]       <= rr_dstaddr_fifo[31:0];	  
	//all data needs to be right aligned
	//(this is due to the Epiphany right aligning all words)
	case(rr_datamode_fifo[1:0])//datamode
          2'd0:  // byte read
            case(rr_alignaddr_fifo[2:0])
	      3'd0:     rr_data[31:0] <= {24'b0,m_axi_rdata_fifo[7:0]};
	      3'd1:     rr_data[31:0] <= {24'b0,m_axi_rdata_fifo[15:8]};
	      3'd2:     rr_data[31:0] <= {24'b0,m_axi_rdata_fifo[23:16]};
	      3'd3:     rr_data[31:0] <= {24'b0,m_axi_rdata_fifo[31:24]};
	      3'd4:     rr_data[31:0] <= {24'b0,m_axi_rdata_fifo[39:32]};
	      3'd5:     rr_data[31:0] <= {24'b0,m_axi_rdata_fifo[47:40]};
	      3'd6:     rr_data[31:0] <= {24'b0,m_axi_rdata_fifo[55:48]};
	      3'd7:     rr_data[31:0] <= {24'b0,m_axi_rdata_fifo[63:56]};
	      default:  rr_data[31:0] <= {24'b0,m_axi_rdata_fifo[7:0]};
            endcase	    
          2'd1:  // 16b hword
            case(rr_alignaddr_fifo[2:1])
	      2'd0:    rr_data[31:0] <= {16'b0,m_axi_rdata_fifo[15:0]};
	      2'd1:    rr_data[31:0] <= {16'b0,m_axi_rdata_fifo[31:16]};
	      2'd2:    rr_data[31:0] <= {16'b0,m_axi_rdata_fifo[47:32]};
	      2'd3:    rr_data[31:0] <= {16'b0,m_axi_rdata_fifo[63:48]};
	      default: rr_data[31:0] <= {16'b0,m_axi_rdata_fifo[15:0]};
            endcase
          2'd2:  // 32b word
	    begin
               if(rr_alignaddr_fifo[2])
		 rr_data[31:0] <= m_axi_rdata_fifo[63:32];
               else
		 rr_data[31:0] <= m_axi_rdata_fifo[31:0];
	    end
          // 64b word already defined by defaults above
          2'd3: 
	    begin // 64b dword
	       rr_data[31:0]     <= m_axi_rdata_fifo[31:0];
	       rr_srcaddr[31:0]  <= m_axi_rdata_fifo[63:32];
            end
        endcase         
     end // always @ (posedge m_axi_aclk1 )
   
endmodule // emaxi
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../memory/hdl" "../../common/hdl"  )
// End:

