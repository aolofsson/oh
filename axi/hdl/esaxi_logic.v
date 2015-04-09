
`timescale 1 ns / 1 ps

module esaxi_logic #
  (
   // Users to add parameters here
   parameter [11:0]  C_READ_TAG_ADDR = 12'h810,
   // User parameters ends
   // Do not modify the parameters beyond this line
   
   // Width of ID for for write address, write data, read address and read data
   parameter integer C_S_AXI_ID_WIDTH    = 1,
   // Width of S_AXI data bus
        parameter integer C_S_AXI_DATA_WIDTH    = 32,
   // Width of S_AXI address bus
   parameter integer C_S_AXI_ADDR_WIDTH    = 30,
   // Width of optional user defined signal in write address channel
   parameter integer C_S_AXI_AWUSER_WIDTH    = 0,
   // Width of optional user defined signal in read address channel
   parameter integer C_S_AXI_ARUSER_WIDTH    = 0,
   // Width of optional user defined signal in write data channel
   parameter integer C_S_AXI_WUSER_WIDTH    = 0,
   // Width of optional user defined signal in read data channel
   parameter integer C_S_AXI_RUSER_WIDTH    = 0,
   // Width of optional user defined signal in write response channel
   parameter integer C_S_AXI_BUSER_WIDTH    = 0
   )
   (
    // Users to add ports here
    // FIFO write port, write requests
    output reg [102:0] 			      emwr_wr_data,
    output reg 				      emwr_wr_en,
    input 				      emwr_full,
    input 				      emwr_prog_full,
    
    // FIFO write port, read requests
    output reg [102:0] 			      emrq_wr_data,
    output reg 				      emrq_wr_en,
    input 				      emrq_full,
    input 				      emrq_prog_full,
    
    // FIFO read port, read responses
    input [102:0] 			      emrr_rd_data,
    output 				      emrr_rd_en,
    input 				      emrr_empty,

    // Control bits from eConfig
    input  [3:0] 			      ecfg_tx_ctrl_mode,
    input  [11:0] 			      ecfg_coreid,

    // User ports ends
    // Do not modify the ports beyond this line

    // Global Clock Signal
    input  				      S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input  				      S_AXI_ARESETN,
    // Write Address ID
    input  [C_S_AXI_ID_WIDTH-1 : 0]       S_AXI_AWID,
    // Write address
    input  [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_AWADDR,
    // Burst length. The burst length gives the exact number of transfers in a burst
    input  [7 : 0] 			      S_AXI_AWLEN,
    // Burst size. This signal indicates the size of each transfer in the burst
    input  [2 : 0] 			      S_AXI_AWSIZE,
    // Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
    input  [1 : 0] 			      S_AXI_AWBURST,
    // Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
    input  				      S_AXI_AWLOCK,
    // Memory type. This signal indicates how transactions
    // are required to progress through a system.
    input  [3 : 0] 			      S_AXI_AWCACHE,
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    input  [2 : 0] 			      S_AXI_AWPROT,
    // Quality of Service, QoS identifier sent for each
    // write transaction.
    input  [3 : 0] 			      S_AXI_AWQOS,
    // Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
    input  [3 : 0] 			      S_AXI_AWREGION,
    // Optional User-defined signal in the write address channel.
    input  [C_S_AXI_AWUSER_WIDTH-1 : 0]   S_AXI_AWUSER,
    // Write address valid. This signal indicates that
    // the channel is signaling valid write address and
    // control information.
    input  				      S_AXI_AWVALID,
    // Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
    output  			      S_AXI_AWREADY,
    // Write Data
    input  [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_WDATA,
    // Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
    input  [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write last. This signal indicates the last transfer
    // in a write burst.
    input  				      S_AXI_WLAST,
    // Optional User-defined signal in the write data channel.
    input  [C_S_AXI_WUSER_WIDTH-1 : 0]    S_AXI_WUSER,
    // Write valid. This signal indicates that valid write
    // data and strobes are available.
    input  				      S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
    // can accept the write data.
    output  			      S_AXI_WREADY,
    // Response ID tag. This signal is the ID tag of the
    // write response.
    output  [C_S_AXI_ID_WIDTH-1 : 0]      S_AXI_BID,
    // Write response. This signal indicates the status
    // of the write transaction.
    output  [1 : 0] 		      S_AXI_BRESP,
    // Optional User-defined signal in the write response channel.
    output  [C_S_AXI_BUSER_WIDTH-1 : 0]   S_AXI_BUSER,
    // Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
    output  			      S_AXI_BVALID,
    // Response ready. This signal indicates that the master
    // can accept a write response.
    input  				      S_AXI_BREADY,
    // Read address ID. This signal is the identification
    // tag for the read address group of signals.
    input  [C_S_AXI_ID_WIDTH-1 : 0]       S_AXI_ARID,
    // Read address. This signal indicates the initial
    // address of a read burst transaction.
    input  [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_ARADDR,
    // Burst length. The burst length gives the exact number of transfers in a burst
    input  [7 : 0] 			      S_AXI_ARLEN,
    // Burst size. This signal indicates the size of each transfer in the burst
    input  [2 : 0] 			      S_AXI_ARSIZE,
    // Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
    input  [1 : 0] 			      S_AXI_ARBURST,
    // Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
    input  				      S_AXI_ARLOCK,
    // Memory type. This signal indicates how transactions
    // are required to progress through a system.
    input  [3 : 0] 			      S_AXI_ARCACHE,
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    input  [2 : 0] 			      S_AXI_ARPROT,
    // Quality of Service, QoS identifier sent for each
    // read transaction.
    input  [3 : 0] 			      S_AXI_ARQOS,
    // Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
    input  [3 : 0] 			      S_AXI_ARREGION,
    // Optional User-defined signal in the read address channel.
    input  [C_S_AXI_ARUSER_WIDTH-1 : 0]   S_AXI_ARUSER,
    // Write address valid. This signal indicates that
    // the channel is signaling valid read address and
    // control information.
    input  				      S_AXI_ARVALID,
    // Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
    output  			      S_AXI_ARREADY,
    // Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
    output  [C_S_AXI_ID_WIDTH-1 : 0]      S_AXI_RID,
    // Read Data
    output  [C_S_AXI_DATA_WIDTH-1 : 0]    S_AXI_RDATA,
    // Read response. This signal indicates the status of
    // the read transfer.
    output  [1 : 0] 		      S_AXI_RRESP,
    // Read last. This signal indicates the last transfer
    // in a read burst.
    output  			      S_AXI_RLAST,
    // Optional User-defined signal in the read address channel.
    output  [C_S_AXI_RUSER_WIDTH-1 : 0]   S_AXI_RUSER,
    // Read valid. This signal indicates that the channel
    // is signaling the required read data.
    output  			      S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
    // accept the read data and response information.
    input  				      S_AXI_RREADY
    );

   // AXI4FULL signals
   reg [31:0]                    axi_awaddr;  // 32b for Epiphany addr
   reg [1:0]                     axi_awburst;
   reg [2:0]                     axi_awsize;
   reg                           axi_awready;

   reg                           axi_wready;

   reg [C_S_AXI_ID_WIDTH-1:0]    axi_bid;
   reg [1:0]                     axi_bresp;
   reg                           axi_bvalid;

   reg [31:0]                    axi_araddr;  // 32b for Epiphany addr
   reg [7:0]                     axi_arlen;
   reg [1:0]                     axi_arburst;
   reg [2:0]                     axi_arsize;
   reg                           axi_arready;

   reg [C_S_AXI_ID_WIDTH-1:0]    axi_rid;
   reg [C_S_AXI_DATA_WIDTH-1:0]  axi_rdata;
   reg [1:0]                     axi_rresp;
   reg                           axi_rlast;
   reg                           axi_rvalid;

   //local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
   //ADDR_LSB is used for addressing 32/64 bit registers/memories
   //ADDR_LSB = 2 for 32 bits (n downto 2)
   //ADDR_LSB = 3 for 64 bits (n downto 3)
   localparam integer            ADDR_LSB = (C_S_AXI_DATA_WIDTH/32)+ 1;

   // I/O Connections assignments

   assign S_AXI_AWREADY    = axi_awready;
   assign S_AXI_WREADY     = axi_wready;
   assign S_AXI_BRESP      = axi_bresp;
   assign S_AXI_BID        = axi_bid;
   assign S_AXI_BVALID     = axi_bvalid;
   assign S_AXI_ARREADY    = axi_arready;
   assign S_AXI_RDATA      = axi_rdata;
   assign S_AXI_RRESP      = axi_rresp;
   assign S_AXI_RLAST      = axi_rlast;
   assign S_AXI_RVALID     = axi_rvalid;
   assign S_AXI_RID        = axi_rid;
   assign S_AXI_BUSER      = 'd0;
   assign S_AXI_BUSER      = 'd0;
   assign S_AXI_RUSER      = 'd0;
   
   // Implement write address channel
   reg              write_active;
   reg              b_wait;      // Waiting to issue write response (unlikely?)

   wire             last_wr_beat = axi_wready & S_AXI_WVALID & S_AXI_WLAST;
   
   // axi_awready is asserted when there is no write transfer in progress

   always @( posedge S_AXI_ACLK ) begin
      if( S_AXI_ARESETN == 1'b0 )  begin

         axi_awready <= 1'b0;
         write_active <= 1'b0;
         
      end else begin

         // We're always ready for an address cycle if we're not doing something else
         //  NOTE: Might make this faster by going ready on last beat instead of after,
         //  but if we want the very best each channel should be FIFO'd.
         if( ~axi_awready & ~write_active & ~b_wait )
           axi_awready <= 1'b1;
         else if( S_AXI_AWVALID )
           axi_awready <= 1'b0;

         // The write cycle is "active" as soon as we capture an address, it
         // ends on the last beat.
         if( axi_awready & S_AXI_AWVALID )
           write_active <= 1'b1;
         else if( last_wr_beat )
           write_active <= 1'b0;
         
      end // else: !if( S_AXI_ARESETN == 1'b0 )
   end // always @ ( posedge S_AXI_ACLK )
   
   // Capture address & other AW info, update address during cycle
   
   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 )  begin

         axi_bid      <= 'd0;  // capture for write response
         axi_awaddr   <= 'd0;
         axi_awsize   <= 3'd0;
         axi_awburst  <= 2'd0;
         
      end else begin

         if( axi_awready & S_AXI_AWVALID ) begin

            axi_bid      <= S_AXI_AWID;
            axi_awaddr   <= { ecfg_coreid[11:C_S_AXI_ADDR_WIDTH-20],
                              S_AXI_AWADDR };
            axi_awsize   <= S_AXI_AWSIZE;  // 0=byte, 1=16b, 2=32b
            axi_awburst  <= S_AXI_AWBURST; // type, 0=fixed, 1=incr, 2=wrap

         end else if( S_AXI_WVALID & axi_wready ) begin

            if( axi_awburst == 2'b01 ) begin //incremental burst
               // The write address for all the beats in the transaction are increments by the data width.
               // NOTE: This should be based on awsize instead to support narrow bursts, I think.
               
               axi_awaddr[31:ADDR_LSB] <= axi_awaddr[31:ADDR_LSB] + 32'd1;
               //awaddr aligned to data width
               axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   

            end  // Both FIXED & WRAPPING types are treated as FIXED, no update.

         end // if ( S_AXI_WVALID & axi_wready )
      end // else: !if( S_AXI_ARESETN == 1'b0 )
   end // always @ ( posedge S_AXI_ACLK )
   
   // Write Channel Implementation

   always @( posedge S_AXI_ACLK ) begin
      if( S_AXI_ARESETN == 1'b0 ) begin
         
         axi_wready <= 1'b0;

      end else begin

         if( last_wr_beat )
           axi_wready <= 1'b0;
         else if( write_active )
           axi_wready <= ~emwr_prog_full;

      end // else: !if( S_AXI_ARESETN == 1'b0 )
   end // always @ ( posedge S_AXI_ACLK )
   
   // Implement write response logic generation
   // The write response and response valid signals are asserted by the slave 
   // at the end of each transaction, burst or single.

   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin

         axi_bvalid <= 1'b0;
         axi_bresp  <= 2'b0;
         b_wait     <= 1'b0;
         
      end else begin
         
         if( last_wr_beat ) begin

            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b0;       // 'OKAY' response
            b_wait     <= ~S_AXI_BREADY;  // NOTE: Assumes bready will not drop without valid?
            
         end else if (S_AXI_BREADY & axi_bvalid) begin

            axi_bvalid <= 1'b0;
            b_wait     <= 1'b0;
            
         end
      end // else: !if( S_AXI_ARESETN == 1'b0 )
   end // always @ ( posedge S_AXI_ACLK )


   // Read registers
   reg           read_active;
   reg [31:0]    read_addr;
   
   wire          last_rd_beat = axi_rvalid & axi_rlast & S_AXI_RREADY;
   
   // Read request channel

   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin

         axi_arready <= 1'b0;
         read_active <= 1'b0;
         
      end else begin    

         if( ~axi_arready & ~read_active )
            axi_arready <= 1'b1;
         else if( S_AXI_ARVALID )
            axi_arready <= 1'b0;

         if( axi_arready & S_AXI_ARVALID )
           read_active <= 1'b1;
         else if( last_rd_beat )
           read_active <= 1'b0;
         
      end // else: !if( S_AXI_ARESETN == 1'b0 )
   end // always @ ( posedge S_AXI_ACLK )
   
   // Implement axi_araddr, etc. latching & counting

   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin

         axi_araddr  <= 0;
         axi_arlen   <= 8'd0;
         axi_arburst <= 2'd0;
         axi_arsize  <= 2'b0;
         axi_rlast   <= 1'b0;
         axi_rid     <= 'd0;
         
      end else begin
         
         if( axi_arready & S_AXI_ARVALID ) begin

            axi_araddr  <= { ecfg_coreid[11:C_S_AXI_ADDR_WIDTH-20],
                            S_AXI_ARADDR };     // start address of transfer
            axi_arlen   <= S_AXI_ARLEN;
            axi_arburst <= S_AXI_ARBURST;
            axi_arsize  <= S_AXI_ARSIZE;
            axi_rlast   <= ~(|S_AXI_ARLEN);
            axi_rid     <= S_AXI_ARID;
            
         end else if(axi_rvalid & S_AXI_RREADY) begin

            axi_arlen <= axi_arlen - 1;

            if(axi_arlen == 8'd1)
              axi_rlast <= 1'b1;
            
            if( S_AXI_ARBURST == 2'b01) begin //incremental burst
               // The read address for all the beats in the transaction are increments by awsize
               // NOTE: This should be based on awsize instead to support narrow bursts, I think.

               axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
               //araddr aligned to 4 byte boundary
               axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
               //for awsize = 4 bytes (010)
            end

         end // if (axi_rvalid & S_AXI_RREADY)

      end // else: !if( S_AXI_ARESETN == 1'b0 )
   end // always @ ( posedge S_AXI_ACLK )
   
   // ------------------------------------------
   // -- Write Data Handler
   // ------------------------------------------

   reg [31:0]  aligned_data;
   reg [31:0]  aligned_addr;
   reg [1:0]   wsize;
   reg         pre_wr_en;   // delay for data alignment
   reg [3:0]   ctrl_mode;   // Sync'd from ecfg
   
   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin

         aligned_data[31:0]  <= 32'd0;
         aligned_addr[31:0]  <= 32'd0;
         wsize[1:0]          <= 2'd0;
         emwr_wr_data[102:0] <= 103'd0;
         pre_wr_en           <= 1'b0;
         emwr_wr_en          <= 1'b0;
         ctrl_mode[3:0]      <= 4'd0;
         
      end else begin

         ctrl_mode <= ecfg_tx_ctrl_mode;  // No timing on this

         // Set lsbs of address based on write strobes, 
         // right-justify data.
         aligned_addr[31:2] <= axi_awaddr[31:2];
         
         if( S_AXI_WSTRB[0] ) begin
            aligned_data      <= S_AXI_WDATA[31:0];
            aligned_addr[1:0] <= 2'd0;
         end else if(S_AXI_WSTRB[1] ) begin
            aligned_data <= {8'd0, S_AXI_WDATA[31:8]};
            aligned_addr[1:0] <= 2'd1;
         end else if(S_AXI_WSTRB[2] ) begin
            aligned_data <= {16'd0, S_AXI_WDATA[31:16]};
            aligned_addr[1:0] <= 2'd2;
         end else begin
            aligned_data <= {24'd0, S_AXI_WDATA[31:24]};
            aligned_addr[1:0] <= 2'd3;
         end

         wsize <= axi_awsize[1:0];
         pre_wr_en <= axi_wready & S_AXI_WVALID;
         emwr_wr_en <= pre_wr_en;
         
         emwr_wr_data[102:0] <=                         
           { 1'b1,            // write
             wsize,           // only up to 32b
             ctrl_mode,
             aligned_addr,    // dstaddr
             32'd0,           // srcaddr ignored
             aligned_data[31:0]};
         
      end // else: !if( S_AXI_ARESETN == 1'b0 )
   end // always @ ( posedge S_AXI_ACLK )
   
   
   // ------------------------------------------
   // --    Read Data Handler
   // -- Reads are performed by sending a read
   // -- request out the TX port and waiting for
   // -- data to come back through the RX port.
   // --
   // -- Because eLink reads are not generally 
   // -- returned in order, we will only allow
   // -- one at a time.  That's OK because reads
   // -- are to be avoided for speed anyway.
   // ------------------------------------------

   // Process to issue eLink read requests

   // Since we're only sending one req at a time we can ignore the FIFO flags

   reg       ractive_reg;  // Need leading edge of active for 1st req
   reg       rnext;
   
   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin

         emrq_wr_en   <= 1'b0;
         emrq_wr_data[102:0] <= 'd0;
         ractive_reg  <= 1'b0;
         rnext        <= 1'b0;
         
      end else begin

         ractive_reg <= read_active;

         rnext <= axi_rvalid & S_AXI_RREADY & ~axi_rlast;
         
         emrq_wr_en <= ( ~ractive_reg & read_active ) | rnext;
         
         emrq_wr_data[102:0] <=
           { 1'b0,                            // !write
             axi_arsize[1:0],                 // 32b max
             ctrl_mode[3:0],
             axi_araddr[31:0],                // dstaddr (read from)
             {C_READ_TAG_ADDR[11:0], 20'd0},  // srcaddr (tag)
             32'd0                            // no data
             };

      end // else: !if( S_AXI_ARESETN == 1'b0 )
   end // always @ ( posedge S_AXI_ACLK )
   
   // Handle eLink response data

   // always read response data immediately
   assign emrr_rd_en = ~emrr_empty;

   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin

         axi_rvalid <= 1'b0;
         axi_rdata  <= 'd0;
         axi_rresp  <= 2'd0;

      end else begin

         if( ~emrr_empty ) begin

            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'd0;

            case( axi_arsize[1:0] )

              2'b00: axi_rdata <= {4{emrr_rd_data[7:0]}};
              2'b01: axi_rdata <= {2{emrr_rd_data[15:0]}};
              default: axi_rdata <= emrr_rd_data;

            endcase // case ( axi_araddr[1:0] }...

         end else if( S_AXI_RREADY ) begin // if ( ~emrr_empty )

            axi_rvalid <= 1'b0;

         end
      end // else: !if( S_AXI_ARESETN == 1'b0 )
   end // always @ ( posedge S_AXI_ACLK )
   
endmodule
