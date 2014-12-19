/*
 Copyright (C) 2014 Adapteva, Inc.
 Contributed by Fred Huettig <fred@adapteva.com>
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program (see the file COPYING).  If not, see
 <http://www.gnu.org/licenses/>.
 */
/*
 ########################################################################
 Epiphany eLink AXI Master Module
 ########################################################################
 
 */

`define WRITE_BIT      102
`define DATAMODE_RANGE 101:100
`define CTRLMODE_RANGE 99:96
`define DSTADDR_RANGE  95:64
`define DSTADDR_LSB    64
`define SRCADDR_RANGE  63:32
`define SRCADDR_LSB    32
`define DATA_RANGE     31:0
`define DATA_LSB       0

`timescale 1 ns / 1 ps

	module emaxi_v1_0_M00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Base address of targeted slave
		parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
		// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
		parameter integer C_M_AXI_BURST_LEN	= 16,
		// Thread ID Width
		parameter integer C_M_AXI_ID_WIDTH	= 1,
		// Width of Address Bus
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		// Width of Data Bus
		parameter integer C_M_AXI_DATA_WIDTH	= 64,
		// Width of User Write Address Bus
		parameter integer C_M_AXI_AWUSER_WIDTH	= 0,
		// Width of User Read Address Bus
		parameter integer C_M_AXI_ARUSER_WIDTH	= 0,
		// Width of User Write Data Bus
		parameter integer C_M_AXI_WUSER_WIDTH	= 0,
		// Width of User Read Data Bus
		parameter integer C_M_AXI_RUSER_WIDTH	= 0,
		// Width of User Response Bus
		parameter integer C_M_AXI_BUSER_WIDTH	= 0
	)
	(
		// Users to add ports here
		   // FIFO read-master port, writes from RX channel
        input wire [102:0]  emwr_rd_data,
        output wire         emwr_rd_en,
        input wire          emwr_empty,
  
        // FIFO read-master port, read requests from RX channel
        input wire [102:0]  emrq_rd_data,
        output wire         emrq_rd_en,
        input wire          emrq_empty,
     
        // FIFO write-master port, read responses to TX channel
        output reg  [102:0] emrr_wr_data,
        output reg          emrr_wr_en,
        input wire          emrr_full,
        input wire          emrr_prog_full,

		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal.
		input wire  M_AXI_ACLK,
		// Global Reset Singal. This Signal is Active Low
		input wire  M_AXI_ARESETN,
		// Master Interface Write Address ID
		output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
		// Master Interface Write Address
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		output wire [7 : 0] M_AXI_AWLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		output wire [2 : 0] M_AXI_AWSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		output wire [1 : 0] M_AXI_AWBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		output wire  M_AXI_AWLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		output wire [3 : 0] M_AXI_AWCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_AWPROT,
		// Quality of Service, QoS identifier sent for each write transaction.
		output wire [3 : 0] M_AXI_AWQOS,
		// Optional User-defined signal in the write address channel.
		output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid write address and control information.
		output wire  M_AXI_AWVALID,
		// Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
		input wire  M_AXI_AWREADY,
		// Master Interface Write Data.
		output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
		// Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
		output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
		// Write last. This signal indicates the last transfer in a write burst.
		output wire  M_AXI_WLAST,
		// Optional User-defined signal in the write data channel.
		output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER,
		// Write valid. This signal indicates that valid write
    // data and strobes are available
		output wire  M_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    // can accept the write data.
		input wire  M_AXI_WREADY,
		// Master Interface Write Response.
		input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,
		// Write response. This signal indicates the status of the write transaction.
		input wire [1 : 0] M_AXI_BRESP,
		// Optional User-defined signal in the write response channel
		input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER,
		// Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
		input wire  M_AXI_BVALID,
		// Response ready. This signal indicates that the master
    // can accept a write response.
		output wire  M_AXI_BREADY,
		// Master Interface Read Address.
		output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID,
		// Read address. This signal indicates the initial
    // address of a read burst transaction.
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		output wire [7 : 0] M_AXI_ARLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		output wire [2 : 0] M_AXI_ARSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		output wire [1 : 0] M_AXI_ARBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		output wire  M_AXI_ARLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		output wire [3 : 0] M_AXI_ARCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_ARPROT,
		// Quality of Service, QoS identifier sent for each read transaction
		output wire [3 : 0] M_AXI_ARQOS,
		// Optional User-defined signal in the read address channel.
		output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid read address and control information
		output wire  M_AXI_ARVALID,
		// Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
		input wire  M_AXI_ARREADY,
		// Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
		input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID,
		// Master Read Data
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
		// Read response. This signal indicates the status of the read transfer
		input wire [1 : 0] M_AXI_RRESP,
		// Read last. This signal indicates the last transfer in a read burst
		input wire  M_AXI_RLAST,
		// Optional User-defined signal in the read address channel.
		input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER,
		// Read valid. This signal indicates that the channel
    // is signaling the required read data.
		input wire  M_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    // accept the read data and response information.
		output wire  M_AXI_RREADY
	);


	// function called clogb2 that returns an integer which has the
	//value of the ceiling of the log base 2

	  // function called clogb2 that returns an integer which has the 
	  // value of the ceiling of the log base 2.                      
	  function integer clogb2 (input integer bit_depth);              
	  begin                                                           
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	      bit_depth = bit_depth >> 1;                                 
	    end                                                           
	  endfunction // clogb2

	// AXI4LITE signals
	//AXI4 internal temp signals
   reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
   reg [7:0]                        axi_awlen;
   reg [2:0]                        axi_awsize;
   reg                              axi_awvalid;

   reg [C_M_AXI_DATA_WIDTH-1 : 0]   axi_wdata;
   reg [C_M_AXI_DATA_WIDTH/8-1 : 0] axi_wstrb;
   reg                              axi_wlast;
   reg                              axi_wvalid;

   //reg                              axi_bready;

   reg [C_M_AXI_ADDR_WIDTH-1 : 0]   axi_araddr;
   reg [7:0]                        axi_arlen;
   reg [2:0]                        axi_arsize;
   reg                              axi_arvalid;

   wire                             axi_rready;

   // I/O Connections assignments

   //I/O Connections. Write Address (AW)
   assign M_AXI_AWID	= 'b0;
   //The AXI address is a concatenation of the target base address + active offset range
   assign M_AXI_AWADDR	= axi_awaddr;
   //Burst LENgth is number of transaction beats, minus 1
   assign M_AXI_AWLEN	= axi_awlen;
   //Size should be C_M_AXI_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
   assign M_AXI_AWSIZE	= axi_awsize;
   //INCR burst type is usually used, except for keyhole bursts
   assign M_AXI_AWBURST	= 2'b01;
   assign M_AXI_AWLOCK	= 1'b0;
   //Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
   assign M_AXI_AWCACHE	= 4'b0010;
   assign M_AXI_AWPROT	= 3'h0;
   assign M_AXI_AWQOS	= 4'h0;
   assign M_AXI_AWUSER	= 'b1;
   assign M_AXI_AWVALID	= axi_awvalid;
   //Write Data(W)
   assign M_AXI_WDATA	= axi_wdata;
   //All bursts are complete and aligned in this example
   assign M_AXI_WSTRB	= axi_wstrb;
   assign M_AXI_WLAST	= axi_wlast;
   assign M_AXI_WUSER	= 'b0;
   assign M_AXI_WVALID	= axi_wvalid;
   //Write Response (B)
   assign M_AXI_BREADY	= 1'b1;  // axi_bready;
   //Read Address (AR)
   assign M_AXI_ARID	= 'b0;
   assign M_AXI_ARADDR	= axi_araddr;
   //Burst LENgth is number of transaction beats, minus 1
   assign M_AXI_ARLEN	= axi_arlen;
   //Size should be C_M_AXI_DATA_WIDTH, in 2^n bytes, otherwise narrow bursts are used
   assign M_AXI_ARSIZE	= axi_arsize;
   //INCR burst type is usually used, except for keyhole bursts
   assign M_AXI_ARBURST	= 2'b01;
   assign M_AXI_ARLOCK	= 1'b0;
   //Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
   assign M_AXI_ARCACHE	= 4'b0010;
   assign M_AXI_ARPROT	= 3'h0;
   assign M_AXI_ARQOS	= 4'h0;
   assign M_AXI_ARUSER	= 'b1;
   assign M_AXI_ARVALID	= axi_arvalid;
   //Read and Read Response (R)
   assign M_AXI_RREADY	= axi_rready;

   //--------------------
   //Write Address Channel
   //--------------------

   // Holding buffers for AW and W channels
   reg                              awvalid_b;
   reg [C_M_AXI_ADDR_WIDTH-1 : 0]   awaddr_b;
   reg [2:0]                        awsize_b;
   reg [7:0]                        awlen_b;

   reg                              wvalid_b;
   reg [C_M_AXI_DATA_WIDTH-1 : 0]   wdata_b;
   reg [C_M_AXI_DATA_WIDTH/8-1 : 0] wstrb_b;

   wire                             aw_go = axi_awvalid & M_AXI_AWREADY;
   wire                             w_go  = axi_wvalid & M_AXI_WREADY;
   
   assign emwr_rd_en = ( ~emwr_empty & ~awvalid_b & ~wvalid_b);

   // Generate write-address signals
   always @( posedge M_AXI_ACLK ) begin
	  if( M_AXI_ARESETN == 1'b0 ) begin

         axi_awvalid <= 1'b0;
         axi_awaddr  <= 'd0;
         axi_awlen   <= 'd0;
         axi_awsize  <= 'd0;

         awvalid_b   <= 1'b0;
         awaddr_b    <= 'd0;
         awlen_b     <= 'd0;
         awsize_b    <= 'd0;
         
      end else begin

         if( ~axi_awvalid | aw_go ) begin
            if( awvalid_b ) begin
               axi_awvalid <= 1'b1;
               axi_awaddr  <= awaddr_b;
               axi_awlen   <= awlen_b;
               axi_awsize  <= awsize_b;
            end else begin
               axi_awvalid <= emwr_rd_en;
               axi_awaddr  <= emwr_rd_data[`DSTADDR_RANGE];
               axi_awlen   <= 'd0;
               axi_awsize  <= { 1'b0, emwr_rd_data[`DATAMODE_RANGE] };
            end // else: !if(awvalid_b)
         end // if (~axi_awvalid | aw_go)

         if( emwr_rd_en & axi_awvalid & ~aw_go )
           awvalid_b <= 1'b1;
         else if( aw_go )
           awvalid_b <= 1'b0;
         
         if( emwr_rd_en ) begin
            awaddr_b  <= emwr_rd_data[`DSTADDR_RANGE];
            awlen_b   <= 'd0;
            awsize_b  <= { 1'b0, emwr_rd_data[`DATAMODE_RANGE] };
         end
         
      end // else: !if( M_AXI_ARESETN == 1'b0 )
   end // always @ ( posedge M_AXI_ACLK )

   reg [C_M_AXI_DATA_WIDTH-1 : 0]   wdata_aligned;
   reg [C_M_AXI_DATA_WIDTH/8-1 : 0] wstrb_aligned;

   always @ ( emwr_rd_data ) begin

      // Place data of stated size in all legal positions
      case( emwr_rd_data[`DATAMODE_RANGE] )
        
        2'd0: wdata_aligned = { 8{emwr_rd_data[`DATA_LSB+7 -: 8]}};
        2'd1: wdata_aligned = { 4{emwr_rd_data[`DATA_LSB+15 -: 16]}};
        2'd2: wdata_aligned = { 2{emwr_rd_data[`DATA_LSB+31 -: 32]}};
        default: wdata_aligned = { emwr_rd_data[`SRCADDR_RANGE],
                                emwr_rd_data[`DATA_RANGE]};
      endcase // case ( emwr_rd_data[`DATAMODE_RANGE] )

      // Create write strobes
      case( emwr_rd_data[`DATAMODE_RANGE] )
        2'd0: // BYTE
          case( emwr_rd_data[`DSTADDR_LSB+2 -: 3] )
            3'd0: wstrb_aligned = 8'h01;
            3'd1: wstrb_aligned = 8'h02;
            3'd2: wstrb_aligned = 8'h04;
            3'd3: wstrb_aligned = 8'h08;
            3'd4: wstrb_aligned = 8'h10;
            3'd5: wstrb_aligned = 8'h20;
            3'd6: wstrb_aligned = 8'h40;
            default: wstrb_aligned = 8'h80;
          endcase

        2'd1: // 16b HWORD
          case( emwr_rd_data[`DSTADDR_LSB+2 -: 2] )
            2'd0: wstrb_aligned = 8'h03;
            2'd1: wstrb_aligned = 8'h0C;
            2'd2: wstrb_aligned = 8'h30;
            default: wstrb_aligned = 8'hC0;
          endcase

        2'd2: // 32b WORD
          if( emwr_rd_data[`DSTADDR_LSB+2] )
            wstrb_aligned = 8'hF0;
          else
            wstrb_aligned = 8'h0F;

        default: // 64b DWORD
          wstrb_aligned = 8'hFF;
        
      endcase // case ( emwr_rd_data[`DATAMODE_RANGE] )
   end // always @ (...

   // Generate the write-data signals
   always @( posedge M_AXI_ACLK ) begin
	  if( M_AXI_ARESETN == 1'b0 ) begin

         axi_wvalid  <= 1'b0;
         axi_wdata   <= 'd0;
         axi_wstrb   <= 'd0;
         axi_wlast   <= 1'b1; // TODO: no bursts for now

         wvalid_b   <= 1'b0;
         wdata_b    <= 'd0;
         wstrb_b    <= 'd0;
         
      end else begin // if ( M_AXI_ARESETN == 1'b0 )

         if( ~axi_wvalid | w_go ) begin
            if( wvalid_b ) begin
               axi_wvalid <= 1'b1;
               axi_wdata  <= wdata_b;
               axi_wstrb  <= wstrb_b;
            end else begin
               axi_wvalid <= emwr_rd_en;
               axi_wdata  <= wdata_aligned;
               axi_wstrb  <= wstrb_aligned;
            end
         end // if ( ~axi_wvalid | w_go )

         if( emwr_rd_en & axi_wvalid & ~w_go )
           wvalid_b <= 1'b1;
         else if( w_go )
           wvalid_b <= 1'b0;

         if( emwr_rd_en ) begin
            wdata_b <= wdata_aligned;
            wstrb_b <= wstrb_aligned;
         end

      end // else: !if( M_AXI_ARESETN == 1'b0 )
   end // always @ ( posedge M_AXI_ACLK )
	                                                                        
   //----------------------------
   // Read Address Channel
   //----------------------------

   reg       read_waiting;

   assign    emrq_rd_en = axi_rready & M_AXI_RVALID;
   
   always @( posedge M_AXI_ACLK ) begin
	  if ( ~M_AXI_ARESETN ) begin

         axi_araddr   <= 'd0;
         axi_arlen    <= 'd0;
         axi_arsize   <= 'd0;
         axi_arvalid  <= 1'b0;
         read_waiting <= 1'b0;
         
	  end else begin

         if( ~emrq_empty & ~read_waiting ) begin

            axi_arvalid <= 1'b1;
            axi_arsize  <= {1'b0, emrq_rd_data[`DATAMODE_RANGE]};
            axi_araddr  <= emrq_rd_data[`DSTADDR_RANGE];

         end else if( M_AXI_ARREADY ) begin

            axi_arvalid <= 1'b0;

         end

         if( ~emrq_empty & ~read_waiting )
           read_waiting <= 1'b1;
         else if( axi_rready & M_AXI_RVALID )
           read_waiting <= 1'b0;

      end
   end // always @ ( posedge M_AXI_ACLK )
   
   //--------------------------------
   // Read Data (and Response) Channel
   //--------------------------------

   assign axi_rready = ~emrr_full;
   
   always @( posedge M_AXI_ACLK ) begin
	  if( ~M_AXI_ARESETN ) begin

         emrr_wr_data <= 'd0;
         emrr_wr_en   <= 1'b0;
         
      end else begin

         emrr_wr_en <= axi_rready & M_AXI_RVALID;
         
         emrr_wr_data[`WRITE_BIT] <= 1'b1;
         emrr_wr_data[`DATAMODE_RANGE] <= emrq_rd_data[`DATAMODE_RANGE];
         emrr_wr_data[`CTRLMODE_RANGE] <= emrq_rd_data[`CTRLMODE_RANGE];  // TODO: This or cfg value?
         emrr_wr_data[`DSTADDR_RANGE]  <= emrq_rd_data[`SRCADDR_RANGE];
         emrr_wr_data[`SRCADDR_RANGE]  <= M_AXI_RDATA[63:32];  // only used for 64b reads
         emrr_wr_data[`DATA_RANGE]     <= M_AXI_RDATA[31:0];

         // Steer read data according to size & host address lsbs
         case( emrq_rd_data[`DATAMODE_RANGE] )

           2'd0:  // BYTE read
             case( emrq_rd_data[`DSTADDR_LSB+2 -: 3] )
               3'd0:  emrr_wr_data[`DATA_LSB+7 -: 8] <= M_AXI_RDATA[7:0];
               3'd1:  emrr_wr_data[`DATA_LSB+7 -: 8] <= M_AXI_RDATA[15:8];
               3'd2:  emrr_wr_data[`DATA_LSB+7 -: 8] <= M_AXI_RDATA[23:16];
               3'd3:  emrr_wr_data[`DATA_LSB+7 -: 8] <= M_AXI_RDATA[31:24];
               3'd4:  emrr_wr_data[`DATA_LSB+7 -: 8] <= M_AXI_RDATA[39:32];
               3'd5:  emrr_wr_data[`DATA_LSB+7 -: 8] <= M_AXI_RDATA[47:40];
               3'd6:  emrr_wr_data[`DATA_LSB+7 -: 8] <= M_AXI_RDATA[55:48];
               default:  emrr_wr_data[`DATA_LSB+7 -: 8] <= M_AXI_RDATA[63:56];
             endcase // case ( emrq_rd_data[`DSTADDR_LSB+2 -: 3] )

           2'd1:  // 16b HWORD
             case( emrq_rd_data[`DSTADDR_LSB+2 -: 2] )
               2'd0: emrr_wr_data[`DATA_LSB+15 -: 16] <= M_AXI_RDATA[15:0];
               2'd1: emrr_wr_data[`DATA_LSB+15 -: 16] <= M_AXI_RDATA[31:16];
               2'd2: emrr_wr_data[`DATA_LSB+15 -: 16] <= M_AXI_RDATA[47:32];
               default: emrr_wr_data[`DATA_LSB+15 -: 16] <= M_AXI_RDATA[63:48];
             endcase // case ( emrq_rd_data[`DSTADDR_LSB+2 -: 2] )

           2'd2:  // 32b WORD
             if( emrq_rd_data[`DSTADDR_LSB+2] )
               emrr_wr_data[`DATA_RANGE] <= M_AXI_RDATA[63:32];
           // 32b w/0 offset handled by default

           // 64b word already defined by defaults above
         endcase
         
      end // else: !if( ~M_AXI_ARESETN )
   end // always @ ( posedge M_AXI_ACLK )
   
endmodule
