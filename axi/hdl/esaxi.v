module esaxi (/*autoarg*/
   // Outputs
   txwr_access, txwr_packet, txrd_access, txrd_packet, rxrr_wait,
   s_axi_arready, s_axi_awready, s_axi_bid, s_axi_bresp, s_axi_bvalid,
   s_axi_rid, s_axi_rdata, s_axi_rlast, s_axi_rresp, s_axi_rvalid,
   s_axi_wready,
   // Inputs
   txwr_wait, txrd_wait, rxrr_access, rxrr_packet, s_axi_aclk,
   s_axi_aresetn, s_axi_arid, s_axi_araddr, s_axi_arburst,
   s_axi_arcache, s_axi_arlock, s_axi_arlen, s_axi_arprot,
   s_axi_arqos, s_axi_arsize, s_axi_arvalid, s_axi_awid, s_axi_awaddr,
   s_axi_awburst, s_axi_awcache, s_axi_awlock, s_axi_awlen,
   s_axi_awprot, s_axi_awqos, s_axi_awsize, s_axi_awvalid,
   s_axi_bready, s_axi_rready, s_axi_wid, s_axi_wdata, s_axi_wlast,
   s_axi_wstrb, s_axi_wvalid
   );
   
   parameter         ID                  = 12'h999;   
   parameter         S_IDW               = 12;
   parameter         PW                  = 104;
   parameter [15:0]  RETURN_ADDR         = {ID,`EGROUP_RR};
   parameter         AW                  = 32;
   parameter         DW                  = 32;

`ifdef TARGET_SIM
   parameter         TW                  = 8;   //timeout counter width
`else
   parameter         TW                  = 16;  //timeout counter width
`endif
 
   //#############################
   //# Write request (outbound)
   //#############################
   output 	   txwr_access;   
   output [PW-1:0] txwr_packet;
   input 	   txwr_wait;
   
   //#############################
   //# Read request (outbound)
   //#############################
   output 	   txrd_access;   
   output [PW-1:0] txrd_packet;
   input 	   txrd_wait;
   
   //#############################
   //# Read response (inbound)
   //#############################
   input 	   rxrr_access;         
   input [PW-1:0]  rxrr_packet;
   output 	   rxrr_wait;

   //#############################
   //# AXI Slave Interface
   //#############################
 
   //Clock and reset
   input 	  s_axi_aclk;
   input 	  s_axi_aresetn;
   
   //Read address channel
   input [S_IDW-1:0] s_axi_arid;    //write address ID
   input [31:0]    s_axi_araddr;
   input [1:0] 	   s_axi_arburst;
   input [3:0] 	   s_axi_arcache;
   input  	   s_axi_arlock;
   input [7:0] 	   s_axi_arlen;
   input [2:0] 	   s_axi_arprot;
   input [3:0] 	   s_axi_arqos;
   output 	   s_axi_arready;
   input [2:0] 	   s_axi_arsize;
   input 	   s_axi_arvalid;
   
   //Write address channel
   input [S_IDW-1:0] s_axi_awid;    //write address ID
   input [31:0]    s_axi_awaddr;
   input [1:0] 	   s_axi_awburst;
   input [3:0] 	   s_axi_awcache;
   input  	   s_axi_awlock;
   input [7:0] 	   s_axi_awlen;
   input [2:0] 	   s_axi_awprot;
   input [3:0] 	   s_axi_awqos;   
   input [2:0] 	   s_axi_awsize;
   input 	   s_axi_awvalid;
   output 	   s_axi_awready;
   
   //Buffered write response channel
   output [S_IDW-1:0] s_axi_bid;    //write address ID
   output [1:0]     s_axi_bresp;
   output 	    s_axi_bvalid;
   input 	    s_axi_bready;
   
   //Read channel
   output [S_IDW-1:0] s_axi_rid;    //write address ID
   output [31:0]      s_axi_rdata;
   output 	      s_axi_rlast;   
   output [1:0]       s_axi_rresp;
   output 	      s_axi_rvalid;
   input 	      s_axi_rready;

   //Write channel
   input [S_IDW-1:0]  s_axi_wid;    //write address ID
   input [31:0]       s_axi_wdata;
   input 	      s_axi_wlast;   
   input [3:0] 	      s_axi_wstrb;
   input 	      s_axi_wvalid;
   output 	      s_axi_wready;

   //###################################################
   //#WIRE/REG DECLARATIONS
   //###################################################

   reg 		      s_axi_awready;
   reg 		      s_axi_wready;
   reg 		      s_axi_bvalid;
   reg [1:0] 	      s_axi_bresp;
   reg 		      s_axi_arready;
   
   reg [31:0] 	      axi_awaddr;  // 32b for epiphany addr
   reg [1:0] 	      axi_awburst;
   reg [2:0] 	      axi_awsize;
   reg [S_IDW-1:0]    axi_bid;     //what to do with this?
 
   reg [31:0] 	      axi_araddr;
   reg [7:0] 	      axi_arlen;
   reg [1:0] 	      axi_arburst;
   reg [2:0] 	      axi_arsize;
   
   reg [31:0] 	      s_axi_rdata;
   reg [1:0] 	      s_axi_rresp;
   reg 		      s_axi_rlast;
   reg 		      s_axi_rvalid;
   reg [S_IDW-1:0]      s_axi_rid;
   
   reg 		      read_active;
   reg [31:0] 	      read_addr;
   reg 		      write_active;
   reg 		      b_wait;      // waiting to issue write response (unlikely?)
   
   reg 		      txwr_access;
   reg [1:0] 	      txwr_datamode;
   reg [31:0] 	      txwr_dstaddr;
   reg [31:0] 	      txwr_data;

   reg [31:0] 	      txwr_data_reg;
   reg [31:0] 	      txwr_dstaddr_reg;
   reg [1:0] 	      txwr_datamode_reg;
   
   reg 		      txrd_access;
   reg [1:0] 	      txrd_datamode;
   reg [31:0] 	      txrd_dstaddr;
   reg [31:0] 	      txrd_srcaddr;  //read reaspne address
   
   reg 		      pre_wr_en;    // delay for data alignment
   
   reg 		      ractive_reg;  // need leading edge of active for 1st req
   reg 		      rnext;
        
   wire 	      last_wr_beat;
   wire 	      last_rd_beat;
  
   wire [31:0] 	      rxrr_mux_data;
   wire [DW-1:0]      rxrr_data;
   wire [31:0] 	      rxrr_return_data;
   reg [TW-1:0]       timeout_counter;
   
   //###################################################
   //#PACKET TO MESH
   //###################################################

   //TXWR
   emesh2packet e2p_txwr (
		     // Outputs
		     .packet_out	(txwr_packet[PW-1:0]),
		     // Inputs
		     .write_in		(1'b1),
		     .datamode_in	(txwr_datamode[1:0]),
		     .ctrlmode_in	(4'b0),
		     .dstaddr_in	(txwr_dstaddr[AW-1:0]),
		     .data_in		(txwr_data[DW-1:0]),
		     .srcaddr_in	(32'b0)//only 32b slave write supported
		     );

   //TXRD
   emesh2packet e2p_txrd (
		     // Outputs
		     .packet_out	(txrd_packet[PW-1:0]),
		     // Inputs
		     .write_in		(1'b0),
		     .datamode_in	(txrd_datamode[1:0]),
		     .ctrlmode_in	(4'b0),
		     .dstaddr_in	(txrd_dstaddr[AW-1:0]),
		     .data_in		(32'b0),
		     .srcaddr_in	(txrd_srcaddr[AW-1:0])
		     );   
   //RXRR
   packet2emesh p2e_rxrr (
			  // Outputs
			  .write_out		(),
			  .datamode_out		(),
			  .ctrlmode_out		(),
			  .dstaddr_out		(),
			  .data_out		(rxrr_data[DW-1:0]),
			  .srcaddr_out		(),
			  // Inputs
			  .packet_in		(rxrr_packet[PW-1:0])
			  );

   //###################################################
   //#WRITE ADDRESS CHANNEL
   //###################################################

   assign  last_wr_beat = s_axi_wready & s_axi_wvalid & s_axi_wlast;
   
   // axi_awready is asserted when there is no write transfer in progress

   always @(posedge s_axi_aclk ) 
     begin
      if(~s_axi_aresetn)  
	begin
           s_axi_awready <= 1'b1; //TODO: why not set default as 1?
           write_active  <= 1'b0;           
	end 
      else 
	begin
           // we're always ready for an address cycle if we're not doing something else
           // note: might make this faster by going ready on last beat instead of after,
           // but if we want the very best each channel should be fifo'd.
           if( ~s_axi_awready & ~write_active & ~b_wait )
             s_axi_awready <= 1'b1;
           else if( s_axi_awvalid )
             s_axi_awready <= 1'b0;
	   
           // the write cycle is "active" as soon as we capture an address, it
           // ends on the last beat.
           if( s_axi_awready & s_axi_awvalid )
             write_active <= 1'b1;
           else if( last_wr_beat )
             write_active <= 1'b0;         
	end // else: !if(~s_axi_aresetn)
     end // always @ (posedge s_axi_aclk )
        
   always @( posedge s_axi_aclk ) 
     if (~s_axi_aresetn)  
       begin
          axi_bid[S_IDW-1:0] <= 'd0;  // capture for write response
          axi_awaddr[31:0]   <= 32'd0;
          axi_awsize[2:0]    <= 3'd0;
          axi_awburst[1:0]   <= 2'd0;         
       end 
     else 
       begin	  
          if( s_axi_awready & s_axi_awvalid ) 
	    begin	     
	       axi_bid[S_IDW-1:0] <= s_axi_awid[S_IDW-1:0];
               axi_awaddr[31:0]   <= s_axi_awaddr[31:0];
               axi_awsize[2:0]    <= s_axi_awsize[2:0];  // 0=byte, 1=16b, 2=32b
               axi_awburst[1:0]   <= s_axi_awburst[1:0]; // type, 0=fixed, 1=incr, 2=wrap
            end 
	  else if( s_axi_wvalid & s_axi_wready ) 
            if( axi_awburst == 2'b01 ) 
	      begin //incremental burst
		 //TODOL FIX This, this is not right (double bug canceling!!)
		 axi_awaddr[31:2] <= axi_awaddr[31:2] + 32'd1;
		 axi_awaddr[1:0]  <= 2'b0;		 
	      end 
       end // else: !if(~s_axi_aresetn)
   
   //###################################################
   //#WRITE RESPONSE CHANNEL
   //###################################################
    assign s_axi_bid = axi_bid;
   
   always @ (posedge s_axi_aclk)
     if(~s_axi_aresetn) 
       s_axi_wready <= 1'b0;      
     else
       begin
	  if( last_wr_beat )
	    s_axi_wready <= 1'b0;
	  else if( write_active )
	    s_axi_wready <= ~txwr_wait;
       end                             
   
   always @( posedge s_axi_aclk )
     if (~s_axi_aresetn) 
       begin
          s_axi_bvalid      <= 1'b0;
          s_axi_bresp[1:0]  <= 2'b0;
          b_wait            <= 1'b0;         
       end 
     else 
       begin         
         if( last_wr_beat ) 
	   begin
              s_axi_bvalid      <= 1'b1;
              s_axi_bresp[1:0]  <= 2'b0;           // 'okay' response
              b_wait            <= ~s_axi_bready;  // note: assumes bready will not drop without valid?            
         end 
	 else if (s_axi_bready & s_axi_bvalid) 
	   begin	    
              s_axi_bvalid <= 1'b0;
              b_wait       <= 1'b0;            
           end
       end // else: !if( s_axi_aresetn == 1'b0 )

   //###################################################
   //#READ REQUEST CHANNEL
   //###################################################  

   //No
   assign  last_rd_beat = s_axi_rvalid & s_axi_rlast & s_axi_rready;

   always @( posedge s_axi_aclk ) 
     if (~s_axi_aresetn) 
       begin	  
         s_axi_arready <= 1'b0;
         read_active   <= 1'b0;         
       end 
     else 
       begin    
	  //arready
          if( ~s_axi_arready & ~read_active )
            s_axi_arready <= 1'b1;
          else if( s_axi_arvalid )
            s_axi_arready <= 1'b0;

	  //read_active
          if( s_axi_arready & s_axi_arvalid )
            read_active <= 1'b1;
          else if( last_rd_beat )
            read_active <= 1'b0;         
       end // else: !if( s_axi_aresetn == 1'b0 )
   
   //Read address channel state machine
   always @( posedge s_axi_aclk ) 
      if (~s_axi_aresetn) 
	begin
           axi_araddr[31:0]   <= 0;
           axi_arlen          <= 8'd0;
           axi_arburst        <= 2'd0;
           axi_arsize[2:0]    <= 3'b0;
           s_axi_rlast        <= 1'b0;
           s_axi_rid[S_IDW-1:0] <= 'd0;         
	end
      else 
	begin         
         if( s_axi_arready & s_axi_arvalid ) 
	   begin	      
              axi_araddr[31:0]   <= s_axi_araddr[31:0]; //NOTE: upper 2 bits get chopped by Zynq
              axi_arlen[7:0]     <= s_axi_arlen[7:0];
              axi_arburst        <= s_axi_arburst;
              axi_arsize         <= s_axi_arsize;
              s_axi_rlast        <= ~(|s_axi_arlen[7:0]);
              s_axi_rid[S_IDW-1:0] <= s_axi_arid[S_IDW-1:0];              
         end 
	 else if( s_axi_rvalid & s_axi_rready) 
	   begin	      
              axi_arlen[7:0] <= axi_arlen[7:0] - 1;
              if(axi_arlen[7:0] == 8'd1)
		s_axi_rlast <= 1'b1;              
              if( s_axi_arburst == 2'b01) 
		begin //incremental burst
		   axi_araddr[31:2] <= axi_araddr[31:2] + 1;
		   axi_araddr[1:0]  <= 2'b0;   
		end
           end // if ( s_axi_rvalid & s_axi_rready)
	end // else: !if( s_axi_aresetn == 1'b0 )
   

   //###################################################
   //#WRITE REQUEST
   //###################################################  
   
   always @( posedge s_axi_aclk ) 
     if (~s_axi_aresetn) 
       begin
          txwr_data_reg[31:0]     <= 32'd0;	  
          txwr_dstaddr_reg[31:0]  <= 32'd0;	 
          txwr_datamode_reg[1:0]  <= 2'd0;
          txwr_access             <= 1'b0;
          pre_wr_en               <= 1'b0;
       end 
     else 
       begin
	  pre_wr_en                 <= s_axi_wready & s_axi_wvalid;
          txwr_access               <= pre_wr_en;
	  txwr_datamode_reg[1:0]    <= axi_awsize[1:0];	
          txwr_dstaddr_reg[31:2]    <= axi_awaddr[31:2]; //set lsbs of address based on write strobes	 
	  //What is up with this logic??
	  if(s_axi_wstrb[0])//| (axi_awsize[1:0]==2'b10)32-bits
	    begin
	       txwr_data_reg[31:0]   <= s_axi_wdata[31:0];
	       txwr_dstaddr_reg[1:0] <= 2'd0;
	    end
	  else if(s_axi_wstrb[1])
	    begin
	       txwr_data_reg[31:0]   <= {8'd0, s_axi_wdata[31:8]};
	       txwr_dstaddr_reg[1:0] <= 2'd1;
	    end
	  else if(s_axi_wstrb[2])
	    begin
	       txwr_data_reg[31:0]   <= {16'd0, s_axi_wdata[31:16]};
	       txwr_dstaddr_reg[1:0] <= 2'd2;
	    end
	  else
	    begin
	       txwr_data_reg[31:0]   <= {24'd0, s_axi_wdata[31:24]};
	       txwr_dstaddr_reg[1:0] <= 2'd3;
	    end
       end // else: !if(~s_axi_aresetn)

   //Pipeline stage!
   always @( posedge s_axi_aclk )     
     begin
        txwr_data[31:0]     <= txwr_data_reg[31:0];	  
        txwr_dstaddr[31:0]  <= txwr_dstaddr_reg[31:0];	  
        txwr_datamode[1:0]  <= txwr_datamode_reg[1:0];	  
     end
   
   //###################################################
   //#READ REQUEST (DATA CHANNEL)
   //###################################################  
   // -- reads are performed by sending a read
   // -- request out the tx port and waiting for
   // -- data to come back through the rx read response port.
   // --
   // -- because elink reads are not generally 
   // -- returned in order, we will only allow
   // -- one at a time.
   //Need to look at txrd_wait signal
   
   always @( posedge s_axi_aclk )
     if (~s_axi_aresetn) 
       begin
	  txrd_access         <= 1'b0;      
	  txrd_datamode[1:0]  <= 2'd0;
	  txrd_dstaddr[31:0]  <= 32'd0;
	  txrd_srcaddr[31:0]  <= 32'd0;	 
          ractive_reg         <= 1'b0;
          rnext               <= 1'b0;          
      end 
     else
       begin
          ractive_reg         <= read_active;
          rnext               <= s_axi_rvalid & s_axi_rready & ~s_axi_rlast;    
          txrd_access         <= ( ~ractive_reg & read_active ) | rnext;       
	  txrd_datamode[1:0]  <= axi_arsize[1:0];
	  txrd_dstaddr[31:0]  <= axi_araddr[31:0];
	  txrd_srcaddr[31:0]  <= {RETURN_ADDR, 16'd0};
	  //TODO: use arid+srcaddr for out of order ?
       end

   //###################################################
   //#READ RESPONSE (DATA CHANNEL)
   //###################################################  
   //Read response AXI state machine
   //Only one outstanding read

   assign rxrr_wait = 1'b0;


   assign rxrr_return_access     = rxrr_access | rxrr_timeout_access;
   assign rxrr_return_data[31:0] = rxrr_timeout_access ? 32'hDEADBEEF :
				                         rxrr_data[31:0];
   
   always @( posedge s_axi_aclk ) 
      if (!s_axi_aresetn) 
	begin
           s_axi_rvalid       <= 1'b0;
           s_axi_rdata[31:0]  <= 32'd0;
           s_axi_rresp        <= 2'd0;	   
	end 
      else 
	begin
         if( rxrr_return_access ) 
	   begin
              s_axi_rvalid <= 1'b1;
              s_axi_rresp  <= rxrr_timeout_access ? 2'b10 : 2'b00;
            case( axi_arsize[1:0] )
              2'b00:   s_axi_rdata[31:0] <= {4{rxrr_return_data[7:0]}};  //8-bit
              2'b01:   s_axi_rdata[31:0] <= {2{rxrr_return_data[15:0]}}; //16-bit
              default: s_axi_rdata[31:0] <= rxrr_return_data[31:0];      //32-bit
            endcase // case ( axi_arsize[1:0] )
           end 
	 else if( s_axi_rready ) 
           s_axi_rvalid <= 1'b0;
	end // else: !if( s_axi_aresetn == 1'b0 )

   //###################################################
   //#TIMEOUT CIRCUIT
   //###################################################  

   reg [1:0] timeout_state;     
`define TIMEOUT_IDLE    2'b00
`define TIMEOUT_ARMED   2'b01
`define TIMEOUT_EXPIRED 2'b10
  
   always @ (posedge s_axi_aclk)
     if(!s_axi_aresetn)
       timeout_state[1:0] <= `TIMEOUT_IDLE;
     else
       case(timeout_state[1:0])
	 `TIMEOUT_IDLE    : timeout_state[1:0] <= (s_axi_arvalid & s_axi_arready ) ? `TIMEOUT_ARMED : 
						                                     `TIMEOUT_IDLE;
	 `TIMEOUT_ARMED   : timeout_state[1:0] <=  rxrr_access     ? `TIMEOUT_IDLE    :
						   counter_expired ? `TIMEOUT_EXPIRED : 
						                     `TIMEOUT_ARMED;
	 `TIMEOUT_EXPIRED : timeout_state[1:0] <= `TIMEOUT_IDLE;	 
	 default : timeout_state[1:0]          <= `TIMEOUT_IDLE;
       endcase // case (timeout_state[1:0])
   	   
   //release bus after 64K clock cycles (seems reasonable?)   
   always @ (posedge s_axi_aclk)
     if(timeout_state[1:0]==`TIMEOUT_IDLE)
       timeout_counter[TW-1:0] <= {(TW){1'b1}};   
     else if (timeout_state[1:0]==`TIMEOUT_ARMED)  //decrement while counter > 0
       timeout_counter[TW-1:0] <= timeout_counter[TW-1:0] - 1'b1;

   assign counter_expired     = ~(|timeout_counter[TW-1:0]);
   assign rxrr_timeout_access = (timeout_state[1:0]==`TIMEOUT_EXPIRED);
        
endmodule // esaxi


