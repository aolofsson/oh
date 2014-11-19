/*
  File: eproto_rx.v
 
  This file is part of the Parallella Project.

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
 EPIPHANY eLink RX Protocol block
 ########################################################################
 
 This block takes the parallel output of the input deserializers, locates
 valid frame transitions, and decodes the bytes into standard eMesh 
 protocol (104-bit transactions).
 */

module eproto_rx (/*AUTOARG*/
   // Outputs
   rx_rd_wait, rx_wr_wait, emrx_access, emrx_write, emrx_datamode,
   emrx_ctrlmode, emrx_dstaddr, emrx_srcaddr, emrx_data,
   // Inputs
   reset, rxlclk_p, rxframe_p, rxdata_p, emrx_rd_wait, emrx_wr_wait
   );

   // System reset input
   input          reset;

   // Parallel interface, 8 eLink bytes at a time
   input          rxlclk_p; // Parallel clock input from IO block
   input [7:0]    rxframe_p;
   input [63:0]   rxdata_p;
   output         rx_rd_wait;  // The wait signals are passed through
   output         rx_wr_wait;  // from the emesh interfaces
   
   // Output to MMU / filter
   output         emrx_access;
   output         emrx_write;
   output [1:0]   emrx_datamode;
   output [3:0]   emrx_ctrlmode;
   output [31:0]  emrx_dstaddr;
   output [31:0]  emrx_srcaddr;
   output [31:0]  emrx_data;
   input          emrx_rd_wait;
   input          emrx_wr_wait;
   
   //#############
   //# Configuration bits
   //#############

   //######################
   //# Identify FRAME edges
   //######################

   reg            frame_prev;

   reg [2:0]      rxalign_in;
   reg            rxactive_in;
   reg [63:0]     rxdata_in;
   
   reg [2:0]      rxalign_0;
   reg            rxactive_0;
   reg [3:0]      ctrlmode_0;
   reg [31:0]     dstaddr_0;
   reg [1:0]      datamode_0;
   reg            write_0;
   reg            access_0;
   reg [31:16]    data_0;

   reg [2:0]      rxalign_1;
   reg            rxactive_1;
   reg [3:0]      ctrlmode_1;
   reg [31:0]     dstaddr_1;
   reg [1:0]      datamode_1;
   reg            write_1;
   reg            access_1;
   reg [31:0]     data_1;
   reg [31:0]     srcaddr_1;

   reg            rxactive_2;
   reg [3:0]      ctrlmode_2;
   reg [31:0]     dstaddr_2;
   reg [1:0]      datamode_2;
   reg            write_2;
   reg            access_2;
   reg [31:0]     data_2;
   reg [31:0]     srcaddr_2;

   // Here we handle any alignment of the frame within an 8-cycle group,
   // though in theory frames should only start on rising edges??

   always @( posedge rxlclk_p ) begin

      frame_prev  <= rxframe_p[0] ;  // Capture last bit for next group
      rxdata_in   <= rxdata_p;
      
      if( ~frame_prev & rxframe_p[7] ) begin   // All 8 bytes are a new frame
         rxalign_in  <= 3'd7;
         rxactive_in <= 1'b1;
      end else if( ~rxframe_p[7] & rxframe_p[6] ) begin
         rxalign_in  <= 3'd6;
         rxactive_in <= 1'b1;
      end else if( ~rxframe_p[6] & rxframe_p[5] ) begin
         rxalign_in  <= 3'd5;
         rxactive_in <= 1'b1;
      end else if( ~rxframe_p[5] & rxframe_p[4] ) begin
         rxalign_in  <= 3'd4;
         rxactive_in <= 1'b1;
      end else if( ~rxframe_p[4] & rxframe_p[3] ) begin
         rxalign_in  <= 3'd3;
         rxactive_in <= 1'b1;
      end else if( ~rxframe_p[3] & rxframe_p[2] ) begin
         rxalign_in  <= 3'd2;
         rxactive_in <= 1'b1;
      end else if( ~rxframe_p[2] & rxframe_p[1] ) begin
         rxalign_in  <= 3'd1;
         rxactive_in <= 1'b1;
      end else if( ~rxframe_p[1] & rxframe_p[0] ) begin
         rxalign_in  <= 3'd0;
         rxactive_in <= 1'b1;
      end else begin
         rxalign_in  <= 3'd0;   // No edge
         rxactive_in <= 3'd0;
      end
      
   end // always @ ( posedge rxlclk_p )

   // 1st cycle
   always @( posedge rxlclk_p ) begin

      rxactive_0 <= rxactive_in;
      rxalign_0  <= rxalign_in;
      
      case(rxalign_in)
        3'd7: begin
           ctrlmode_0       <= rxdata_in[55:52];
           dstaddr_0[31:0]  <= rxdata_in[51:20];
           datamode_0       <= rxdata_in[19:18];
           write_0          <= rxdata_in[17];
           access_0         <= rxdata_in[16];
           data_0[31:16]    <= rxdata_in[15:0];
        end
        
        3'd6: begin
           ctrlmode_0       <= rxdata_in[47:44];
           dstaddr_0[31:0]  <= rxdata_in[43:12];
           datamode_0       <= rxdata_in[11:10];
           write_0          <= rxdata_in[9];
           access_0         <= rxdata_in[8];
           data_0[31:24]    <= rxdata_in[7:0];
        end

        3'd5: begin
           ctrlmode_0       <= rxdata_in[39:36];
           dstaddr_0[31:0]  <= rxdata_in[35:4];
           datamode_0       <= rxdata_in[3:2];
           write_0          <= rxdata_in[1];
           access_0         <= rxdata_in[0];
        end

        3'd4: begin
           ctrlmode_0       <= rxdata_in[31:28];
           dstaddr_0[31:4]  <= rxdata_in[27:0];
        end

        3'd3: begin
           ctrlmode_0       <= rxdata_in[23:20];
           dstaddr_0[31:12] <= rxdata_in[19:0];
        end

        3'd2: begin
           ctrlmode_0       <= rxdata_in[15:12];
           dstaddr_0[31:20] <= rxdata_in[11:0];
        end

        3'd1: begin
           ctrlmode_0       <= rxdata_in[7:4];
           dstaddr_0[31:28] <= rxdata_in[3:0];
        end
        
         // if align == 0 then only the tran byte is present, ignore
      endcase // case (rxalign_in)
      
   end // always @ ( posedge rxlclk_p )

   // 2nd cycle
   always @( posedge rxlclk_p ) begin

      rxactive_1 <= rxactive_0;
      rxalign_1  <= rxalign_0;

      // default pass-throughs
      ctrlmode_1    <= ctrlmode_0;
      dstaddr_1     <= dstaddr_0;
      datamode_1    <= datamode_0;
      write_1       <= write_0;
      access_1      <= access_0;
      data_1[31:16] <= data_0[31:16];

      case(rxalign_0)
        3'd7: begin
           data_1[15:0] <= rxdata_in[63:48];
           srcaddr_1    <= rxdata_in[47:16];
        end

        3'd6: begin
           data_1[23:0] <= rxdata_in[63:40];
           srcaddr_1   <= rxdata_in[39:8];
        end

        3'd5: begin
           data_1       <= rxdata_in[63:32];
           srcaddr_1    <= rxdata_in[31:0];
        end

        3'd4: begin
           dstaddr_1[3:0]  <= rxdata_in[63:60];
           datamode_1      <= rxdata_in[59:58];
           write_1         <= rxdata_in[57];
           access_1        <= rxdata_in[56];
           data_1          <= rxdata_in[55:24];
           srcaddr_1[31:8] <= rxdata_in[23:0];
        end

        3'd3: begin
           dstaddr_1[11:0]  <= rxdata_in[63:52];
           datamode_1       <= rxdata_in[51:50];
           write_1          <= rxdata_in[49];
           access_1         <= rxdata_in[48];
           data_1           <= rxdata_in[47:16];
           srcaddr_1[31:16] <= rxdata_in[15:0];
        end
           
        3'd2: begin
           dstaddr_1[19:0]  <= rxdata_in[63:44];
           datamode_1       <= rxdata_in[43:42];
           write_1          <= rxdata_in[41];
           access_1         <= rxdata_in[40];
           data_1           <= rxdata_in[39:8];
           srcaddr_1[31:24] <= rxdata_in[7:0];
        end
        
        3'd1: begin
           dstaddr_1[27:0]  <= rxdata_in[63:36];
           datamode_1       <= rxdata_in[35:34];
           write_1          <= rxdata_in[33];
           access_1         <= rxdata_in[32];
           data_1           <= rxdata_in[31:0];
        end
           
        3'd0: begin
           ctrlmode_1       <= rxdata_in[63:60];
           dstaddr_1[31:0]  <= rxdata_in[59:28];
           datamode_1       <= rxdata_in[27:26];
           write_1          <= rxdata_in[25];
           access_1         <= rxdata_in[24];
           data_1[31:8]     <= rxdata_in[23:0];
        end
      endcase
   end // always @ ( posedge rxlclk_p )
   
   // 3rd cycle
   always @( posedge rxlclk_p ) begin

      // default pass-throughs
      ctrlmode_2    <= ctrlmode_1;
      dstaddr_2     <= dstaddr_1;
      datamode_2    <= datamode_1;
      write_2       <= write_1;
      access_2      <= access_1 & rxactive_1;  // avoid random non-frame data
      data_2        <= data_1;
      srcaddr_2 <= srcaddr_1;
         
      case( rxalign_1 )
        // 7-5: Full packet is complete in 2nd cycle
        3'd4:
          srcaddr_2[7:0]  <= rxdata_in[63:56];
        3'd3:
          srcaddr_2[15:0] <= rxdata_in[63:48];
        3'd2:
          srcaddr_2[23:0] <= rxdata_in[63:40];
        3'd1:
          srcaddr_2[31:0] <= rxdata_in[63:32];
        3'd0: begin
           data_2[7:0]     <= rxdata_in[63:56];
           srcaddr_2[31:0] <= rxdata_in[55:24];
        end
      endcase // case ( rxalign_1 )

   end // always @ ( posedge rxlclk_p )
   
/*  The spec says reads use the 'data' slot for src address, but apparently
    the silicon has not read this spec.
      if( write_1 ) begin

         srcaddr_2 <= srcaddr_1;
         
         case( rxalign_1 )
           // 7-5 Full packet is complete in 2nd cycle        
           3'd4:
             srcaddr_2[7:0]  <= rxdata_in[63:56];
           3'd3:
             srcaddr_2[15:0] <= rxdata_in[63:48];
           3'd2:
             srcaddr_2[23:0] <= rxdata_in[63:40];
           3'd1:
             srcaddr_2[31:0] <= rxdata_in[63:32];
           3'd0: begin
              data_2[7:0]     <= rxdata_in[63:56];
              srcaddr_2[31:0] <= rxdata_in[55:24];
           end
         endcase // case ( rxalign_1 )
         
      end else begin  // on reads, source addr is in data slot

         srcaddr_2 <= data_1;

         if( rxalign_1 == )
           srcaddr_2[7:0] <= rxdata_in[63:56];

      end // else: !if( write_1 )
      
   end // always @ ( posedge rxlclk_p )
*/
   // xxx_2 now has one complete transfer

   // TODO: Handle burst mode, for now we stop after one xaction

   assign emrx_access = access_2;
   assign emrx_write  = write_2;
   assign emrx_datamode = datamode_2;
   assign emrx_ctrlmode = ctrlmode_2;
   assign emrx_dstaddr  = dstaddr_2;
   assign emrx_srcaddr  = srcaddr_2;
   assign emrx_data     = data_2;
   
   //################################
   //# Wait signal passthrough
   //################################
   wire          rx_rd_wait = emrx_rd_wait;
   wire          rx_wr_wait = emrx_wr_wait;
   
endmodule // eproto_rx
