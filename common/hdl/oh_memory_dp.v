
/*###########################################################################
 # Function: Dual port memory wrapper (one read/ one write port)
 #           To run without hardware platform dependancy, `define:
 #           "TARGET_CLEAN"
 ############################################################################
 */

module oh_memory_dp(/*AUTOARG*/
   // Outputs
   rd_data,
   // Inputs
   wr_clk, wr_en, wr_addr, wr_data, rd_clk, rd_en, rd_addr
   );

   parameter AW      = 14;   
   parameter DW      = 32;
   parameter WED     = DW/8; //one per byte  
   parameter MD      = 1<<AW;//memory depth

   //write-port
   input               wr_clk; //write clock
   input [WED-1:0]     wr_en;  //write enable vector
   input [AW-1:0]      wr_addr;//write address
   input [DW-1:0]      wr_data;//write data

   //read-port   
   input 	       rd_clk; //read clock
   input 	       rd_en;  //read enable
   input [AW-1:0]      rd_addr;//read address
   output[DW-1:0]      rd_data;//read output data
   
   //////////////////////
   //SIMPLE MEMORY MODEL 
   //////////////////////   

   reg [DW-1:0]        ram    [MD-1:0];  
   reg [DW-1:0]        rd_data;
   
   //read port
   always @ (posedge rd_clk)
     if(rd_en)       
       rd_data[DW-1:0] <= ram[rd_addr[AW-1:0]];
   
   //write port
   generate
      genvar 	     i;
      for (i = 0; i < WED; i = i+1) begin: gen_ram
	 always @(posedge wr_clk)
           begin  
              if (wr_en[i]) 
                ram[wr_addr[AW-1:0]][(i+1)*8-1:i*8] <= wr_data[(i+1)*8-1:i*8];
           end
      end
   endgenerate
   
endmodule // memory_dp


