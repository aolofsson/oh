/*
 ########################################################################
 Epiphany eLink AXI Master Module
 ########################################################################
 
 */

module emaxi(/*autoarg*/
   // Outputs
   emwr_rd_en, emrq_rd_en, emrr_access, emrr_write, emrr_datamode,
   emrr_ctrlmode, emrr_dstaddr, emrr_data, emrr_srcaddr, m_axi_awaddr,
   m_axi_awlen, m_axi_awsize, m_axi_awburst, m_axi_awcache,
   m_axi_awprot, m_axi_awqos, m_axi_awvalid, m_axi_wdata, m_axi_wstrb,
   m_axi_wlast, m_axi_wvalid, m_axi_bready, m_axi_araddr, m_axi_arlen,
   m_axi_arsize, m_axi_arburst, m_axi_arcache, m_axi_arprot,
   m_axi_arqos, m_axi_arvalid, m_axi_rready,
   // Inputs
   emwr_access, emwr_write, emwr_datamode, emwr_ctrlmode,
   emwr_dstaddr, emwr_data, emwr_srcaddr, emrq_access, emrq_write,
   emrq_datamode, emrq_ctrlmode, emrq_dstaddr, emrq_data,
   emrq_srcaddr, emrr_progfull, m_axi_aclk, m_axi_aresetn,
   m_axi_awready, m_axi_wready, m_axi_bresp, m_axi_bvalid,
   m_axi_arready, m_axi_rdata, m_axi_rresp, m_axi_rlast, m_axi_rvalid
   );

   
   // fifo read-master port, writes from rx
   input 	       emwr_access;
   input 	       emwr_write;
   input [1:0]         emwr_datamode;
   input [3:0]         emwr_ctrlmode;
   input [31:0]        emwr_dstaddr;
   input [31:0]        emwr_data;
   input [31:0]        emwr_srcaddr;
   output 	       emwr_rd_en;   //read ptr update for fifo

   
   // fifo read-master port; read requests from rx 
   input 	       emrq_access;
   input 	       emrq_write;
   input [1:0]         emrq_datamode;
   input [3:0]         emrq_ctrlmode;
   input [31:0]        emrq_dstaddr;
   input [31:0]        emrq_data;
   input [31:0]        emrq_srcaddr;   
   output 	       emrq_rd_en; //read ptr update for fifo
   
   // fifo write-master port; read responses for etx
   output 	       emrr_access;
   output 	       emrr_write;
   output [1:0]        emrr_datamode;
   output [3:0]        emrr_ctrlmode;
   output [31:0]       emrr_dstaddr;
   output [31:0]       emrr_data;
   output [31:0]       emrr_srcaddr;
   input 	       emrr_progfull;
   
   /*****************************/
   /*axi                        */
   /*****************************/  
   
   input  	       m_axi_aclk;    // global clock signal.
   input  	       m_axi_aresetn; // global reset singal. this signal is active low   
   output [31 : 0]     m_axi_awaddr;  // master interface write address   
   output [7 : 0]      m_axi_awlen;   // burst length. the burst length gives the exact number of transfers in a burst		
   output [2 : 0]      m_axi_awsize;  // burst size. this signal indicates the size of each transfer in the burst
   output [1 : 0]      m_axi_awburst; // burst type. the burst type and the size information; 
   output [3 : 0]      m_axi_awcache; // memory type. this signal indicates how transactions
   output [2 : 0]      m_axi_awprot;  // protection type. this signal indicates the privilege
   output [3 : 0]      m_axi_awqos;   // quality of service; qos identifier sent for each write transaction.       
   output 	       m_axi_awvalid; // write address valid.channel is signaling valid write address and control information.
   input 	       m_axi_awready; // write address ready.the slave is ready to accept an address and associated control signals
   output [63 : 0]     m_axi_wdata;   // master interface write data.
   output [7 : 0]      m_axi_wstrb;   // write strobes.indicates which byte lanes hold valid data
   output 	       m_axi_wlast;   // write last. indicates the last transfer in a write burst.
   output 	       m_axi_wvalid;  // write valid. indicates that valid write data and strobes are available
   input 	       m_axi_wready;  // write ready. indicates that the slave can accept the write data.
   input [1 : 0]       m_axi_bresp;   // master interface write response. indicates the status of the write transaction.
   input 	       m_axi_bvalid;  // write response valid. channel is signaling a valid write response.
   output 	       m_axi_bready;  // response ready. indicates that master can accept write response.
   output [31 : 0]     m_axi_araddr;  // master interface read address. initial address of a read burst transaction.
   output [7 : 0]      m_axi_arlen;   // burst length. the burst length gives the exact number of transfers in a burst
   output [2 : 0]      m_axi_arsize;  // burst size. this signal indicates the size of each transfer in the burst
   output [1 : 0]      m_axi_arburst; // burst type. the burst type and the size information; 
   output [3 : 0]      m_axi_arcache; // memory type
   output [2 : 0]      m_axi_arprot;  // protection type
   output [3 : 0]      m_axi_arqos;   // qos identifier sent for each read transaction
   output 	       m_axi_arvalid; // write address valid. channel is signaling valid read address and control information
   input 	       m_axi_arready; // read address ready. indicates that slave is ready to accept an address
   input [63 : 0]      m_axi_rdata;   // master read data
   input [1 : 0]       m_axi_rresp;   // read response. indicates the status of the read transfer
   input 	       m_axi_rlast;   // read last. indicates the last transfer in a read burst
   input 	       m_axi_rvalid;  // read valid. channel is signaling the required read data
   output 	       m_axi_rready;  // read ready. indicates that master can accept the read data and response
  
   //registers   
   
   reg [31 : 0] 	m_axi_awaddr;
   reg [7:0] 		m_axi_awlen;
   reg [2:0] 		m_axi_awsize;
   reg 			m_axi_awvalid;
   reg [63 : 0] 	m_axi_wdata;
   reg [7 : 0] 		m_axi_wstrb;
   reg 			m_axi_wlast;
   reg 			m_axi_wvalid;
   reg 			awvalid_b;
   reg [31:0] 		awaddr_b;
   reg [2:0] 		awsize_b;
   reg [7:0] 		awlen_b;
   reg 			wvalid_b;
   reg [63:0] 		wdata_b;
   reg [7:0] 		wstrb_b;
   reg [63 : 0] 	wdata_aligned;
   reg [7 : 0] 		wstrb_aligned;

   reg 			emrr_access;
   reg [1:0] 		emrr_datamode;
   reg [3:0] 		emrr_ctrlmode;
   reg [31:0] 		emrr_dstaddr;
   reg [31:0] 		emrr_data;
   reg [31:0] 		emrr_srcaddr;
   
   //wires
   wire 		aw_go;
   wire 		w_go;
   wire 		readinfo_wren;
   wire 		readinfo_rden;
   wire 		readinfo_full;
   wire [40:0] 		readinfo_out;
   wire [40:0] 		readinfo_in;

   //i/o connections. write address (aw)
   assign m_axi_awburst[1:0]	= 2'b01;
   assign m_axi_awcache[3:0]	= 4'b0010;//TODO??update value to 4'b0011 if coherent accesses to be used via the zynq acp port
   assign m_axi_awprot[2:0]	= 3'h0;
   assign m_axi_awqos[3:0]	= 4'h0;
   assign m_axi_bready    	= 1'b1;   //TODO? axi_bready, why constant
   
   assign m_axi_arburst[1:0]	= 2'b01;
   assign m_axi_arcache[3:0]	= 4'b0010;
   assign m_axi_arprot[2:0]	= 3'h0;
   assign m_axi_arqos[3:0]	= 4'h0;

   //--------------------
   //write address channel
   //--------------------
   assign aw_go       = m_axi_awvalid & m_axi_awready;
   assign w_go        = m_axi_wvalid & m_axi_wready;
   assign emwr_rd_en  = ( emwr_access & ~awvalid_b & ~wvalid_b);

   // generate write-address signals
   always @( posedge m_axi_aclk )     
     if(~m_axi_aresetn) 
       begin
          m_axi_awvalid      <= 1'b0;
          m_axi_awaddr[31:0] <= 32'd0;
          m_axi_awlen[7:0]   <= 8'd0;
          m_axi_awsize[2:0]  <= 3'd0;	  
          awvalid_b          <= 1'b0;
          awaddr_b[31:0]     <= 32'd0;
          awlen_b[7:0]       <= 8'd0;
          awsize_b[2:0]      <= 3'd0;
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
		   m_axi_awvalid       <= emwr_rd_en;
		   m_axi_awaddr[31:0]  <= emwr_dstaddr[31:0];
		   m_axi_awlen[7:0]    <= 8'b0;
		   m_axi_awsize[2:0]   <= { 1'b0, emwr_datamode[1:0]};
		end
	    end
          if( emwr_rd_en & m_axi_awvalid & ~aw_go )
            awvalid_b <= 1'b1;
          else if( aw_go )
            awvalid_b <= 1'b0;
          
	 //Pipeline stage
         if( emwr_rd_en )
	   begin
              awaddr_b[31:0]  <= emwr_dstaddr[31:0];
              awlen_b[7:0]    <= 8'b0;
              awsize_b[2:0]   <= { 1'b0, emwr_datamode[1:0] };
         end        
       end // else: !if(~m_axi_aresetn)


     
   //--------------------
   //write alignment circuit
   //--------------------

   always @*
     case( emwr_datamode[1:0] )        
       2'd0:    wdata_aligned[63:0] = { 8{emwr_data[7:0]}};
       2'd1:    wdata_aligned[63:0] = { 4{emwr_data[15:0]}};
       2'd2:    wdata_aligned[63:0] = { 2{emwr_data[31:0]}};
       default: wdata_aligned[63:0] = { emwr_srcaddr[31:0], emwr_data[31:0]};
     endcase

   //TODO: Simplify logic below!!!!!
   //Should include separate fields for address/data/datamode!!!!
   always @*
     begin
	case(emwr_datamode[1:0])
          2'd0: // byte
            case(emwr_dstaddr[2:0])
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
            case(emwr_dstaddr[2:1])
              2'd0:    wstrb_aligned[7:0] = 8'h03;
              2'd1:    wstrb_aligned[7:0] = 8'h0c;
              2'd2:    wstrb_aligned[7:0] = 8'h30;
              default: wstrb_aligned[7:0] = 8'hc0;
            endcase
          2'd2: // 32b word
            if(emwr_dstaddr[2])
	      wstrb_aligned[7:0] = 8'hf0;
            else
	      wstrb_aligned[7:0] = 8'h0f;
	  2'd3: 
	    wstrb_aligned[7:0] = 8'hff;
	endcase // case (emwr_datamode[1:0])
     end // always @ *
   
   // generate the write-data signals
   always @ (posedge m_axi_aclk )
     if(~m_axi_aresetn) 
       begin	  
	  m_axi_wvalid      <= 1'b0;
          m_axi_wdata[63:0] <= 64'b0;
          m_axi_wstrb[7:0]  <= 8'b0;
          m_axi_wlast       <= 1'b1; // todo: no bursts for now?	  
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
		 m_axi_wvalid       <= emwr_rd_en;//todo
		 m_axi_wdata[63:0]  <= wdata_aligned[63:0];
		 m_axi_wstrb[7:0]   <= wstrb_aligned[7:0];
              end
            end // if ( ~axi_wvalid | w_go )

         if( emwr_rd_en & m_axi_wvalid & ~w_go )
           wvalid_b <= 1'b1;
         else if( w_go )
           wvalid_b <= 1'b0;
	  
          if( emwr_rd_en ) 
	    begin
               wdata_b[63:0] <= wdata_aligned[63:0];
               wstrb_b[7:0]  <= wstrb_aligned[7:0];
            end
       end // else: !if(~m_axi_aresetn)
   
   //----------------------------
   // read handler
   //   elink read requests generate a transaction on the ar channel,
   //   buffer the src info to generate an elink write when the
   //   read data comes back.
   //----------------------------

   assign  readinfo_in[40:0] = 
               {
                emrq_srcaddr[31:0],//40:9
                emrq_dstaddr[2:0], //8:6
                emrq_ctrlmode[3:0], //5:2
                emrq_datamode[1:0]
                };
   
   fifo_sync
     #(
       // parameters
       .AW                              (5),
       .DW                              (41))
   fifo_readinfo_i
     (
      // outputs
      .rd_data                          (readinfo_out[40:0]),
      .rd_empty                         (),
      .wr_full                          (readinfo_full),
      // inputs
      .clk                              (m_axi_aclk),
      .reset                            (~m_axi_aresetn),
      .wr_data                          (readinfo_in[40:0]),
      .wr_en                            (emrq_rd_en),
      .rd_en                            (readinfo_rden));
	                                                                        
   //----------------------------
   // read address channel
   //----------------------------

   assign    m_axi_araddr[31:0]   = emrq_dstaddr[31:0];
   assign    m_axi_arsize[2:0]    = {1'b0, emrq_datamode[1:0]};
   assign    m_axi_arlen[7:0]     = 8'd0;
   assign    m_axi_arvalid        = emrq_access & ~readinfo_full;
   assign    emrq_rd_en           = m_axi_arvalid & m_axi_arready;
   
   //--------------------------------
   // read data (and response) channel
   //--------------------------------

   assign m_axi_rready  = ~emrr_progfull;
   assign readinfo_rden = ~emrr_progfull & m_axi_rvalid;


   assign emrr_write  = 1'b1;
   
   always @( posedge m_axi_aclk )
     if( ~m_axi_aresetn ) 
       begin      
	  emrr_data[31:0]      <= 32'b0;
	  emrr_srcaddr[31:0]   <= 32'b0;
          emrr_access          <= 1'b0;         
      end 
     else 
       begin
          emrr_access         <= m_axi_rready & m_axi_rvalid;
          emrr_datamode[1:0]  <= readinfo_out[1:0];
          emrr_ctrlmode[3:0]  <= readinfo_out[5:2];
          emrr_dstaddr[31:0]  <= readinfo_out[40:9];
	  emrr_srcaddr[31:0]  <= m_axi_rdata[63:32];
	  // steer read data according to size & host address lsbs
	  //all data needs to be right aligned
	  case(readinfo_out[1:0])//datamode
            2'd0:  // byte read
              case(readinfo_out[8:6])
		3'd0:     emrr_data[7:0] <= m_axi_rdata[7:0];
		3'd1:     emrr_data[7:0] <= m_axi_rdata[15:8];
		3'd2:     emrr_data[7:0] <= m_axi_rdata[23:16];
		3'd3:     emrr_data[7:0] <= m_axi_rdata[31:24];
		3'd4:     emrr_data[7:0] <= m_axi_rdata[39:32];
		3'd5:     emrr_data[7:0] <= m_axi_rdata[47:40];
		3'd6:     emrr_data[7:0] <= m_axi_rdata[55:48];
		default:  emrr_data[7:0] <= m_axi_rdata[63:56];
              endcase	    
            2'd1:  // 16b hword
              case( readinfo_out[8:7] )
		2'd0:    emrr_data[15:0] <= m_axi_rdata[15:0];
		2'd1:    emrr_data[15:0] <= m_axi_rdata[31:16];
		2'd2:    emrr_data[15:0] <= m_axi_rdata[47:32];
		default: emrr_data[15:0] <= m_axi_rdata[63:48];
              endcase
            2'd2:  // 32b word
              if( readinfo_out[8] )
               emrr_data[31:0] <= m_axi_rdata[63:32];
             else
               emrr_data[31:0] <= m_axi_rdata[31:0];
           // 64b word already defined by defaults above
           2'd3: begin // 64b dword
              emrr_data[31:0]    <= m_axi_rdata[31:0];
              
           end
         endcase         
       end // else: !if( ~m_axi_aresetn )
   
endmodule
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
