module edma (/*AUTOARG*/
   // Outputs
   mi_dout, edma_access, edma_write, edma_datamode, edma_ctrlmode,
   edma_dstaddr, edma_data, edma_srcaddr,
   // Inputs
   reset, clk, mi_en, mi_we, mi_addr, mi_din, edma_wait
   );

   /******************************/
   /*Compile Time Parameters     */
   /******************************/
   parameter RFAW            = 5;          // 32 registers for now
   parameter AW              = 32;
   parameter DW              = 32;
   parameter TEST_PATTERN    = 00000000; // test pattern for dummy writes
   
   /******************************/
   /*HARDWARE RESET (EXTERNAL)   */
   /******************************/
   input 	 reset;            // ecfg registers reset only by "hard reset"
   
   /*****************************/
   /*REGISTER INTERFACE         */
   /*****************************/    
   input 	 clk;
   input 	 mi_en;         
   input 	 mi_we;            // single we, must write 32 bit words
   input [19:0]  mi_addr;          // complete physical address (no shifting!)
   input [31:0]  mi_din;
   output [31:0] mi_dout;   
   
   /*****************************/
   /*DMA TRANSACTION            */
   /*****************************/
   output 	   edma_access;
   output          edma_write;
   output [1:0]    edma_datamode;
   output [3:0]    edma_ctrlmode;
   output [AW-1:0] edma_dstaddr;
   output [DW-1:0] edma_data;
   output [AW-1:0] edma_srcaddr;
   input 	   edma_wait;
   
          
   //registers
   reg [AW-1:0]  edma_srcaddr_reg;
   reg [AW-1:0]  edma_dstaddr_reg;
   reg [AW-1:0]  edma_count_reg;
   reg [AW-1:0]  edma_stride_reg;
   reg [8:0]     edma_cfg_reg;
   reg [1:0]     edma_status_reg;
   reg [31:0] 	 mi_dout;
   
   //wires
   wire 	 edma_write;
   wire 	 edma_read;
   wire 	 edma_cfg_write ;
   wire 	 edma_srcaddr_write;
   wire 	 edma_dstaddr_write;
   wire 	 edma_stride_write;
   wire 	 edma_count_write;
   wire 	 edma_message;
   wire 	 edma_expired;
   wire          edma_last_tran;
   wire 	 edma_error;
   wire          edma_enable;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/

   //read/write decode
   assign edma_write  = mi_en &  mi_we;
   assign edma_read   = mi_en & ~mi_we;   

   //DMA configuration
   assign edma_cfg_write      = edma_write & (mi_addr[RFAW+1:2]==`EDMACFG);
   assign edma_srcaddr_write  = edma_write & (mi_addr[RFAW+1:2]==`EDMASRCADDR);
   assign edma_dstaddr_write  = edma_write & (mi_addr[RFAW+1:2]==`EDMADSTADDR);
   assign edma_count_write    = edma_write & (mi_addr[RFAW+1:2]==`EDMACOUNT);
   assign edma_stride_write   = edma_write & (mi_addr[RFAW+1:2]==`EDMASTRIDE);
   
   //###########################
   //# DMACFG
   //###########################
   always @ (posedge clk or posedge reset)
     if(reset)
       edma_cfg_reg[8:0] <= 'd0;   
     else if (edma_cfg_write)
       edma_cfg_reg[8:0] <= mi_din[8:0];

   assign edma_enable         = edma_cfg_reg[0];  //should be zero     
   assign edma_message        = edma_cfg_reg[8];

   assign edma_access         = edma_enable & ~edma_expired;   
   assign edma_write          = edma_cfg_reg[1];  //only 1 for test pattern   
   assign edma_datamode[1:0]  = edma_cfg_reg[3:2];
   assign edma_ctrlmode[3:0]  = (edma_message & edma_last_tran) ? 4'b1100 : edma_cfg_reg[7:4];

   //###########################
   //# DMASTATUS
   //###########################
   //Misalignment
   assign edma_error = ((edma_srcaddr_reg[0] | edma_dstaddr_reg[0]) & (edma_datamode[1:0]!=2'b00)) | //16/32/64
                       ((edma_srcaddr_reg[1] | edma_dstaddr_reg[1]) & (edma_datamode[1]))          | //32/64
                       ((edma_srcaddr_reg[2] | edma_dstaddr_reg[2]) & (edma_datamode[1:0]==2'b11));  //64


   always @ (posedge clk or posedge reset)
     if(reset)
       edma_status_reg[1:0] <= 'd0;   
     else if (edma_cfg_write)
       edma_status_reg[1:0] <= mi_din[1:0];
     else if (edma_enable)
       begin
	  edma_status_reg[0] <= edma_enable & ~edma_expired;//dma busy
	  edma_status_reg[1] <= edma_status_reg[1]  | (edma_enable & edma_error);
       end
        
   //###########################
   //# EDMASRCADDR
   //###########################
   always @ (posedge clk or posedge reset)
     if(reset)
       edma_srcaddr_reg[AW-1:0] <= 'd0;   
     else if (edma_srcaddr_write)
       edma_srcaddr_reg[AW-1:0] <= mi_din[AW-1:0];
     else if (edma_enable & ~edma_wait)
       edma_srcaddr_reg[AW-1:0] <= edma_srcaddr_reg[AW-1:0] + (1<<edma_datamode[1:0]);

   assign edma_srcaddr[31:0]  = edma_srcaddr_reg[31:0];
   //###########################
   //# EDMADSTADR
   //###########################
   always @ (posedge clk or posedge reset)
     if(reset)
       edma_dstaddr_reg[AW-1:0] <= 'd0;   
     else if (edma_dstaddr_write)
       edma_dstaddr_reg[AW-1:0] <= mi_din[AW-1:0];
     else if (edma_enable & ~edma_wait)
       edma_dstaddr_reg[AW-1:0] <= edma_dstaddr_reg[AW-1:0] + (1<<edma_datamode[1:0]);
   
   assign edma_dstaddr[31:0]  = edma_dstaddr_reg[31:0];

   //###########################
   //# EDMACOUNT
   //###########################
   always @ (posedge clk or posedge reset)
     if(reset)
       edma_count_reg[AW-1:0] <= 'd0;   
     else if (edma_count_write)
       edma_count_reg[AW-1:0] <= mi_din[AW-1:0];
     else if (edma_enable & ~edma_wait)
       edma_count_reg[AW-1:0] <= edma_count_reg[AW-1:0] - 1'b1;
   
   assign edma_last_tran = (edma_count_reg[AW-1:0]==32'b1);   
   assign edma_expired   = (edma_count_reg[AW-1:0]==32'b0);   

   //###########################
   //# EDMASTRIDE
   //###########################
   //NOTE: not supported yet, need to think about feature...
   always @ (posedge clk or posedge reset)
     if(reset)
       edma_stride_reg[AW-1:0] <= 'd0;   
     else if (edma_stride_write)
       edma_stride_reg[AW-1:0] <= mi_din[AW-1:0];
        
   //###########################
   //# DUMMY DATA
   //###########################
   assign edma_data[31:0]     = TEST_PATTERN;   
     
   //###############################
   //# DATA READBACK MUX
   //###############################

   //Pipelineing readback
   always @ (posedge clk)
     if(edma_read)
       case(mi_addr[RFAW+1:2])
         `EDMACFG:    mi_dout[31:0] <= {23'b0, edma_cfg_reg[8:0]};
	 `EDMASTATUS: mi_dout[31:0] <= {30'b0, edma_status_reg[1:0]};
	 `EDMASRCADDR:mi_dout[31:0] <= {edma_srcaddr_reg[31:0]};
	 `EDMADSTADDR:mi_dout[31:0] <= {edma_dstaddr_reg[31:0]};
	 `EDMACOUNT:  mi_dout[31:0] <= {edma_count_reg[31:0]};	         
         default:    mi_dout[31:0] <= 32'd0;
       endcase

endmodule // edma
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:


/*
  Copyright (C) 2013 Adapteva, Inc.
  Contributed by Andreas Olofsson <andreas@adapteva.com>
 
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
