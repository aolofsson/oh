
/*###########################################################################
 # Function: Dual port memory wrapper (one read/ one write port)
 #           To run without hardware platform dependancy, `define:
 #           "TARGET_CLEAN"
 ############################################################################
 */

module oh_memory_dp(/*AUTOARG*/
   // Outputs
   rd_dout,
   // Inputs
   wr_clk, wr_en, wr_wem, wr_addr, wr_din, rd_clk, rd_en, rd_addr
   );

   parameter  AW      = 14;   //address width
   parameter  DW      = 32;   //memory width
   localparam MD      = 1<<AW;//memory depth

   //write-port
   input               wr_clk; //write clock
   input               wr_en;  //write enable
   input [DW-1:0]      wr_wem; //per bit write enable
   input [AW-1:0]      wr_addr;//write address
   input [DW-1:0]      wr_din; //write data

   //read-port   
   input 	       rd_clk; //read clock
   input 	       rd_en;  //read enable
   input [AW-1:0]      rd_addr;//read address
   output[DW-1:0]      rd_dout;//read output data
   
`ifdef CFG_ASIC

   initial  
     $display("Need to instantiate process specific macro here");
   
`else
   reg [DW-1:0]        ram    [MD-1:0];  
   reg [DW-1:0]        rd_dout;
   integer 	       i;
   
   //read port
   always @ (posedge rd_clk)
     if(rd_en)       
       rd_dout[DW-1:0] <= ram[rd_addr[AW-1:0]];
   
   //write port
   always @(posedge wr_clk)    
     for (i=0;i<DW;i=i+1)
       if (wr_en & wr_wem[i]) 
         ram[wr_addr[AW-1:0][i]] <= wr_din[i];
   
`endif // !`ifdef CFG_ASIC
   
   
endmodule // memory_dp


