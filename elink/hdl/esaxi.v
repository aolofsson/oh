module esaxi (/*autoarg*/
   // Outputs
   emwr_access, emwr_write, emwr_datamode, emwr_ctrlmode,
   emwr_dstaddr, emwr_data, emwr_srcaddr, emrq_access, emrq_write,
   emrq_datamode, emrq_ctrlmode, emrq_dstaddr, emrq_data,
   emrq_srcaddr, emrr_rd_en, mi_clk, mi_rx_emmu_sel, mi_tx_emmu_sel,
   mi_ecfg_sel, mi_embox_sel, mi_we, mi_addr, mi_din, s_axi_arready,
   s_axi_awready, s_axi_bid, s_axi_bresp, s_axi_bvalid, s_axi_rid,
   s_axi_rdata, s_axi_rlast, s_axi_rresp, s_axi_rvalid, s_axi_wready,
   // Inputs
   emwr_progfull, emrq_progfull, emrr_data, emrr_access, mi_ecfg_dout,
   mi_tx_emmu_dout, mi_rx_emmu_dout, mi_embox_dout, ecfg_tx_ctrlmode,
   ecfg_coreid, ecfg_timeout_enable, s_axi_aclk, s_axi_aresetn,
   s_axi_arid, s_axi_araddr, s_axi_arburst, s_axi_arcache,
   s_axi_arlock, s_axi_arlen, s_axi_arprot, s_axi_arqos, s_axi_arsize,
   s_axi_arvalid, s_axi_awid, s_axi_awaddr, s_axi_awburst,
   s_axi_awcache, s_axi_awlock, s_axi_awlen, s_axi_awprot,
   s_axi_awqos, s_axi_awsize, s_axi_awvalid, s_axi_bready,
   s_axi_rready, s_axi_wid, s_axi_wdata, s_axi_wlast, s_axi_wstrb,
   s_axi_wvalid
   );

   parameter [11:0]  c_read_tag_addr     = 12'h810;//emesh srcaddr tag  
   parameter integer c_s_axi_addr_width  = 30;     //address width
   parameter [11:0]  ELINKID             = 12'h810;
   parameter         IDW                 = 12;
   
   /*****************************/
   /*Write request for TX fifo  */
   /*****************************/  
   output 	  emwr_access;   
   output 	  emwr_write;
   output [1:0]   emwr_datamode;
   output [3:0]   emwr_ctrlmode;
   output [31:0]  emwr_dstaddr;
   output [31:0]  emwr_data;
   output [31:0]  emwr_srcaddr;   
   input 	  emwr_progfull;
   
   /*****************************/
   /*Read request for TX fifo   */
   /*****************************/  
   output 	  emrq_access;   
   output 	  emrq_write;
   output [1:0]   emrq_datamode;
   output [3:0]   emrq_ctrlmode;
   output [31:0]  emrq_dstaddr;
   output [31:0]  emrq_data;
   output [31:0]  emrq_srcaddr;      
   input 	  emrq_progfull; //TODO? used for?
   
   /*****************************/
   /*Read response from RX fifo */
   /*****************************/  
   //Only data needed
   input [31:0]   emrr_data;
   input 	  emrr_access;         
   output 	  emrr_rd_en; //update read fifo
   
   
   /*****************************/
   /*Register RD/WR Interface   */
   /*****************************/  
   output 	  mi_clk;
   output 	  mi_rx_emmu_sel;
   output 	  mi_tx_emmu_sel;
   output 	  mi_ecfg_sel;
   output 	  mi_embox_sel;
   output 	  mi_we;   
   output [19:0]  mi_addr;   
   output [31:0]  mi_din;     
   input [31:0]   mi_ecfg_dout;
   input [31:0]   mi_tx_emmu_dout;
   input [31:0]   mi_rx_emmu_dout;
   input [31:0]   mi_embox_dout;
   
   /*****************************/
   /*Config Settings            */
   /*****************************/  
   input [3:0] 	  ecfg_tx_ctrlmode;
   input [11:0]   ecfg_coreid;
   input 	  ecfg_timeout_enable;
   
   /*****************************/
   /*AXI slave interface        */
   /*****************************/  
   //Clock and reset
   input 	  s_axi_aclk;
   input 	  s_axi_aresetn;
   
   //Read address channel
   input [IDW-1:0] s_axi_arid;    //write address ID
   input [31:0]    s_axi_araddr;
   input [1:0] 	   s_axi_arburst;
   input [3:0] 	   s_axi_arcache;
   input [1:0] 	   s_axi_arlock;
   input [7:0] 	   s_axi_arlen;
   input [2:0] 	   s_axi_arprot;
   input [3:0] 	   s_axi_arqos;
   output 	   s_axi_arready;
   input [2:0] 	   s_axi_arsize;
   input 	   s_axi_arvalid;
   
   //Write address channel
   input [IDW-1:0] s_axi_awid;    //write address ID
   input [31:0]    s_axi_awaddr;
   input [1:0] 	   s_axi_awburst;
   input [3:0] 	   s_axi_awcache;
   input [1:0] 	   s_axi_awlock;
   input [7:0] 	   s_axi_awlen;
   input [2:0] 	   s_axi_awprot;
   input [3:0] 	   s_axi_awqos;   
   input [2:0] 	   s_axi_awsize;
   input 	   s_axi_awvalid;
   output 	   s_axi_awready;
   
   //Buffered write response channel
   output [IDW-1:0] s_axi_bid;    //write address ID
   output [1:0]     s_axi_bresp;
   output 	    s_axi_bvalid;
   input 	    s_axi_bready;
   
   //Read channel
   output [IDW-1:0] s_axi_rid;    //write address ID
   output [31:0]    s_axi_rdata;
   output 	    s_axi_rlast;   
   output [1:0]     s_axi_rresp;
   output 	    s_axi_rvalid;
   input 	    s_axi_rready;

   //Write channel
   input [IDW-1:0]  s_axi_wid;    //write address ID
   input [31:0]     s_axi_wdata;
   input 	    s_axi_wlast;   
   input [3:0] 	    s_axi_wstrb;
   input 	    s_axi_wvalid;
   output 	    s_axi_wready;
   
   /*-------------------------BODY----------------------------------*/
   reg 		      s_axi_awready;
   reg 		      s_axi_wready;
   reg 		      s_axi_bvalid;
   reg [1:0] 	      s_axi_bresp;
   reg 		      s_axi_arready;
   
   reg [31:0] 	      emwr_data_reg;
   reg [31:0] 	      emwr_dstaddr_reg;
   reg [3:0] 	      emwr_ctrlmode_reg;
   reg [1:0] 	      emwr_datamode_reg;
   
   reg [31:0] 	      axi_awaddr;  // 32b for epiphany addr
   reg [1:0] 	      axi_awburst;
   reg [2:0] 	      axi_awsize;
 
   reg [31:0] 	      axi_araddr;
   reg [7:0] 	      axi_arlen;
   reg [1:0] 	      axi_arburst;
   reg [2:0] 	      axi_arsize;
   
   reg [31:0] 	      s_axi_rdata;
   reg [1:0] 	      s_axi_rresp;
   reg 		      s_axi_rlast;
   reg 		      s_axi_rvalid;
   
   reg 		      read_active;
   reg [31:0] 	      read_addr;
   reg 		      write_active;
   reg 		      b_wait;      // waiting to issue write response (unlikely?)
   
   reg 		      emwr_access_all;
   reg [3:0] 	      emwr_ctrlmode;
   reg [1:0] 	      emwr_datamode;
   reg [31:0] 	      emwr_dstaddr;
   reg [31:0] 	      emwr_data;
   reg [31:0] 	      emwr_srcaddr;  //upper 32 bits in case 64 bit writes are supported

   reg 		      emrq_access_all;
   reg [3:0] 	      emrq_ctrlmode;
   reg [1:0] 	      emrq_datamode;
   reg [31:0] 	      emrq_dstaddr;
   reg [31:0] 	      emrq_srcaddr;  //upper 32 bits in case 64 bit writes are supported
   
   reg 		      pre_wr_en;   // delay for data alignment
   
   reg 		      ractive_reg;  // need leading edge of active for 1st req
   reg 		      rnext;
        
   reg 		      mi_rx_emmu_reg;
   reg 		      mi_tx_emmu_reg;
   reg 		      mi_ecfg_reg;
   reg 		      mi_embox_reg;
   reg 		      mi_rd_reg;
   
   wire 	      last_wr_beat;
   wire 	      last_rd_beat;
   wire 	      mi_wr;
   wire 	      mi_rd;
   wire 	      mi_we;
   wire 	      mi_en;
   wire [31:0] 	      mi_dout;
   wire 	      mi_sel;
   wire [31:0] 	      emrr_mux_data;
   
   //local parameter for addressing 32 bit / 64 bit c_s_axi_data_width
   //addr_lsb is used for addressing 32/64 bit registers/memories
   //addr_lsb = 2 for 32 bits (n downto 2)
   //addr_lsb = 3 for 64 bits (n downto 3)
   //TODO? Do we really need this?
   localparam integer            addr_lsb = 2;
   wire [11:0] 			 elinkid=ELINKID;

   //###################################################
   //#WRITE ADDRESS CHANNEL
   //###################################################

   assign  last_wr_beat = s_axi_wready & s_axi_wvalid & s_axi_wlast;
   
   // axi_awready is asserted when there is no write transfer in progress

   always @(posedge s_axi_aclk ) 
     begin
      if(~s_axi_aresetn)  
	begin
           s_axi_awready <= 1'b0;
           write_active  <= 1'b0;           
	end 
      else 
	begin
           // we're always ready for an address cycle if we're not doing something else
           //  note: might make this faster by going ready on last beat instead of after,
           //  but if we want the very best each channel should be fifo'd.
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
   
	  
   // capture address & other aw info, update address during cycle
   always @( posedge s_axi_aclk ) 
     if (~s_axi_aresetn)  
       begin
          //s_axi_bid          <= 'd0;  // capture for write response
          axi_awaddr[31:0] <= 32'd0;
          axi_awsize[2:0]  <= 3'd0;
          axi_awburst[1:0] <= 2'd0;         
       end 
     else 
       begin	  
          if( s_axi_awready & s_axi_awvalid ) 
	    begin	     
               axi_awaddr[31:0] <= s_axi_awaddr[31:0];
               axi_awsize       <= s_axi_awsize;  // 0=byte, 1=16b, 2=32b
               axi_awburst      <= s_axi_awburst; // type, 0=fixed, 1=incr, 2=wrap
	       
            end 
	  else if( s_axi_wvalid & s_axi_wready ) 
            if( axi_awburst == 2'b01 ) 
		 begin //incremental burst
		    // the write address for all the beats in the transaction are increments by the data width.
		    // note: this should be based on awsize instead to support narrow bursts, i think.
		    //TODO: BUG!!
		    axi_awaddr[31:addr_lsb] <= axi_awaddr[31:addr_lsb] + 30'd1;
		    //awaddr alignedto data width
		    axi_awaddr[addr_lsb-1:0]  <= {addr_lsb{1'b0}};   		  
		 end  // both fixed & wrapping types are treated as fixed, no update.
       end // else: !if(~s_axi_aresetn)
   
   
   //###################################################
   //#WRITE CHANNEL
   //###################################################
   always @ (posedge s_axi_aclk)
     if(~s_axi_aresetn) 
       s_axi_wready <= 1'b0;      
     else
       begin
	  if( last_wr_beat )
	    s_axi_wready <= 1'b0;
	  else if( write_active )
	    s_axi_wready <= ~emwr_progfull;
       end
   
   // implement write response logic generation
   // the write response and response valid signals are asserted by the slave 
   // at the end of each transaction, burst or single.

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
              s_axi_bresp[1:0]  <= 2'b0;       // 'okay' response
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

   assign          last_rd_beat = s_axi_rvalid & s_axi_rlast & s_axi_rready;

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
           axi_araddr[31:0] <= 0;
           axi_arlen        <= 8'd0;
           axi_arburst      <= 2'd0;
           axi_arsize[2:0]  <= 3'b0;
           s_axi_rlast      <= 1'b0;
           //s_axi_rid        <= 'd0;         
	end
      else 
	begin         
         if( s_axi_arready & s_axi_arvalid ) 
	   begin
	      //NOTE: upper 2 bits get chopped by Zynq
              axi_araddr[31:0]  <= s_axi_araddr[31:0]; //transfer start address
              axi_arlen         <= s_axi_arlen;
              axi_arburst       <= s_axi_arburst;
              axi_arsize        <= s_axi_arsize;
              s_axi_rlast       <= ~(|s_axi_arlen);
              //s_axi_rid     <= s_axi_arid;              
         end 
	 else if( s_axi_rvalid & s_axi_rready) 
	   begin	      
              axi_arlen <= axi_arlen - 1;
              if(axi_arlen == 8'd1)
		s_axi_rlast <= 1'b1;              
              if( s_axi_arburst == 2'b01) 
		begin //incremental burst
		   // the read address for all the beats in the transaction are increments by awsize
		   // note: this should be based on awsize instead to support narrow bursts, i think?
		   axi_araddr[c_s_axi_addr_width - 1:addr_lsb] <= axi_araddr[c_s_axi_addr_width - 1:addr_lsb] + 1;
		   //araddr aligned to 4 byte boundary
		   axi_araddr[addr_lsb-1:0]  <= {addr_lsb{1'b0}};   
		   //for awsize = 4 bytes (010)
		end
           end // if ( s_axi_rvalid & s_axi_rready)
	end // else: !if( s_axi_aresetn == 1'b0 )
   

   //###################################################
   //#WRITE DATA
   //###################################################  
   assign emwr_write         = 1'b1;
   
   always @( posedge s_axi_aclk ) 
     if (~s_axi_aresetn) 
       begin
          emwr_data_reg[31:0]     <= 32'd0;	  
          emwr_dstaddr_reg[31:0]  <= 32'd0;	 
	  emwr_ctrlmode_reg[3:0]  <= 4'd0;
          emwr_datamode_reg[1:0]  <= 2'd0;
          emwr_access_all         <= 1'b0;
          pre_wr_en               <= 1'b0;
       end 
     else 
       begin
	  pre_wr_en                 <= s_axi_wready & s_axi_wvalid;
          emwr_access_all           <= pre_wr_en;
	  emwr_ctrlmode_reg[3:0]    <= ecfg_tx_ctrlmode[3:0];//static
	  emwr_datamode_reg[1:0]    <= axi_awsize[1:0];	
          emwr_dstaddr_reg[31:2]    <= axi_awaddr[31:2]; //set lsbs of address based on write strobes	 
	  if(s_axi_wstrb[0] | (axi_awsize[1:0]==2'b10))
	    begin
	       emwr_data_reg[31:0]   <= s_axi_wdata[31:0];
	       emwr_dstaddr_reg[1:0] <= 2'd0;
	    end
	  else if(s_axi_wstrb[1])
	    begin
	       emwr_data_reg[31:0]   <= {8'd0, s_axi_wdata[31:8]};
	       emwr_dstaddr_reg[1:0] <= 2'd1;
	    end
	  else if(s_axi_wstrb[2])
	    begin
	       emwr_data_reg[31:0]   <= {16'd0, s_axi_wdata[31:16]};
	       emwr_dstaddr_reg[1:0] <= 2'd2;
	    end
	  else
	    begin
	       emwr_data_reg[31:0]   <= {24'd0, s_axi_wdata[31:24]};
	       emwr_dstaddr_reg[1:0] <= 2'd3;
	    end
       end // else: !if(~s_axi_aresetn)

//Pipeline stage
 always @( posedge s_axi_aclk ) 
     if (~s_axi_aresetn)
       begin
	  emwr_srcaddr[31:0]  <= 32'd0;	 
          emwr_data[31:0]     <= 32'd0;	  
          emwr_dstaddr[31:0]  <= 32'd0;	 
	  emwr_ctrlmode[3:0]  <= 4'd0;
          emwr_datamode[1:0]  <= 2'd0;
       end
     else
       begin
          emwr_srcaddr[31:0]  <= 32'b0;	  
          emwr_data[31:0]     <= emwr_data_reg[31:0];	  
          emwr_dstaddr[31:0]  <= emwr_dstaddr_reg[31:0];	  
	  emwr_ctrlmode[3:0]  <= emwr_ctrlmode_reg[3:0];	  
          emwr_datamode[1:0]  <= emwr_datamode_reg[1:0];	  
       end // else: !if(~s_axi_aresetn)

   assign emwr_access=emwr_access_all & ~(emwr_dstaddr[31:20]==elinkid[11:0]);
   
   
   //###################################################
   //#READ REQUEST (DATA CHANNEL)
   //###################################################  
   // ------------------------------------------
   // -- read data handler
   // -- reads are performed by sending a read
   // -- request out the tx port and waiting for
   // -- data to come back through the rx port.
   // --
   // -- because elink reads are not generally 
   // -- returned in order, we will only allow
   // -- one at a time.  that's ok because reads
   // -- are to be avoided for speed anyway.
   // ------------------------------------------

   // since we're only sending one req at a time we can ignore the fifo flags
   // always read response data immediately
   assign emrr_rd_en = emrr_access & ~mi_rd_reg;   //TODO: Verify this assumption!!!
   
   assign emrq_write         = 1'b0;
   assign emrq_data[31:0]    = 32'b0;
   
   always @( posedge s_axi_aclk )
     if (~s_axi_aresetn) 
       begin
	  emrq_access_all     <= 1'b0;      
	  emrq_datamode[1:0]  <= 2'd0;
	  emrq_ctrlmode[3:0]  <= 4'd0;
	  emrq_dstaddr[31:0]  <= 32'd0;
	  emrq_srcaddr[31:0]  <= 32'd0;	 
          ractive_reg         <= 1'b0;
          rnext               <= 1'b0;          
      end 
     else 
       begin
          ractive_reg         <= read_active; //read request state machone
          rnext               <= s_axi_rvalid & s_axi_rready & ~s_axi_rlast;         
          emrq_access_all     <= ( ~ractive_reg & read_active ) | rnext;         
	  emrq_datamode[1:0]  <= axi_arsize[1:0];
	  emrq_ctrlmode[3:0]  <= ecfg_tx_ctrlmode;	  
	  emrq_dstaddr[31:0]  <= axi_araddr[31:0];
	  emrq_srcaddr[31:0]  <= {c_read_tag_addr[11:0], 20'd0};//TODO? What can we do with lower 32 bits?
       end

   ///Only letting through proper read requests
   assign emrq_access=emrq_access_all & ~(emrq_dstaddr[31:20]==elinkid[11:0]);
  
   //Read response AXI state machine
   always @( posedge s_axi_aclk ) 
      if ( s_axi_aresetn == 1'b0 ) 
	begin
           s_axi_rvalid       <= 1'b0;
           s_axi_rdata[31:0]  <= 32'd0;
           s_axi_rresp        <= 2'd0;	   
	end 
      else 
	begin
         if( emrr_access | mi_rd_reg ) 
	   begin
              s_axi_rvalid <= 1'b1;
              s_axi_rresp  <= 2'd0;
            case( axi_arsize[1:0] )
              2'b00:   s_axi_rdata[31:0] <= {4{emrr_mux_data[7:0]}};  //8-bit
              2'b01:   s_axi_rdata[31:0] <= {2{emrr_mux_data[15:0]}}; //16-bit
              default: s_axi_rdata[31:0] <= emrr_mux_data[31:0];      //32-bit
            endcase // case ( axi_arsize[1:0] )
           end 
	 else if( s_axi_rready ) 
           s_axi_rvalid <= 1'b0;
	end // else: !if( s_axi_aresetn == 1'b0 )
  
   //###################################################
   //#Register Inteface Logic
   //###################################################  

        
   assign mi_clk = s_axi_aclk;
   
   //Register file access (from slave)
   assign mi_wr = emwr_access_all & (emwr_dstaddr[31:20]==elinkid[11:0]);   
   assign mi_rd = emrq_access_all & (emrq_dstaddr[31:20]==elinkid[11:0]);
   
   //Only 32 bit writes supported
   assign mi_we         =  mi_wr;   
   assign mi_en         =  mi_wr | mi_rd;

   //Read/write address
   assign mi_addr[19:0] =  mi_we ? emwr_dstaddr[19:0] :
			           emrq_dstaddr[19:0];
   		
   //Block select
   assign mi_ecfg_sel     = mi_en & (mi_addr[19:16]==`EGROUP_MMR);
   assign mi_rx_emmu_sel  = mi_en & (mi_addr[19:16]==`EGROUP_RXMMU);
   assign mi_tx_emmu_sel  = mi_en & (mi_addr[19:16]==`EGROUP_TXMMU);
   assign mi_embox_sel    = mi_ecfg_sel & (mi_addr[6:2]==`EMBOXLO |
					  mi_addr[6:2]==`EMBOXHI)
					  ;			   
   //Data
   assign mi_din[31:0]     = emwr_data[31:0];
	 
   //Readback
   always@ (posedge mi_clk)
     begin
	mi_ecfg_reg    <= mi_ecfg_sel;
	mi_rx_emmu_reg <= mi_rx_emmu_sel;	
	mi_tx_emmu_reg <= mi_tx_emmu_sel;
	//feel hacky, clean up?
	mi_embox_reg   <= mi_embox_sel;	
	mi_rd_reg      <= mi_rd;
     end

   //Data mux
   assign mi_dout[31:0] = mi_ecfg_reg    ? mi_ecfg_dout[31:0]    :
			  mi_rx_emmu_reg ? mi_rx_emmu_dout[31:0] :
			  mi_tx_emmu_reg ? mi_tx_emmu_dout[31:0] :
			                   mi_embox_dout[31:0];
   /********************************/
   /*INTERFACE TO AXI SLAVE        */
   /********************************/  

   //Read Response
   assign   emrr_mux_data[31:0]       = mi_rd_reg ? mi_dout[31:0] :
				                    emrr_data[31:0];

endmodule // esaxi

/*
 Copyright (C) 2014 Adapteva, Inc.
 
 Contributed by Andreas Olofsson <andreas@adapteva.com>
 Contributed by Fred Huettig <fred@adapteva.com>

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.This program is distributed in the hope 
 that it will be useful,but WITHOUT ANY WARRANTY; without even the implied 
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details. You should have received a copy 
 of the GNU General Public License along with this program (see the file 
 COPYING).  If not, see <http://www.gnu.org/licenses/>.
 */
