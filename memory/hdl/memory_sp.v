
/*###########################################################################
 # Function: Single port memory wrapper
 #           To run without hardware platform dependancy use:
 #           `define TARGET_CLEAN"
 ############################################################################
 */

module memory_sp(/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   clk, en, wen, addr, din
   );

   parameter AW      = 14;   
   parameter DW      = 32;
   parameter WED     = DW/8; //one write enable per byte  
   parameter MD      = 1<<AW;//memory depth

   //write-port
   input               clk; //clock
   input               en;  //memory access   
   input [WED-1:0]     wen; //write enable vector
   input [AW-1:0]      addr;//address
   input [DW-1:0]      din; //data input
   output [DW-1:0]     dout;//data output
      
   reg [DW-1:0]        ram    [MD-1:0];  
   reg [DW-1:0]        rd_data;
   reg [DW-1:0]        dout;
   
   //read port
   always @ (posedge clk)
     if(en)       
       dout[DW-1:0] <= ram[addr[AW-1:0]];

   //write port
   generate
      genvar 	     i;
      for (i = 0; i < WED; i = i+1) begin: gen_ram
	 always @(posedge clk)
           begin  
              if (wen[i] & en) 
                ram[addr[AW-1:0]][(i+1)*8-1:i*8] <= din[(i+1)*8-1:i*8];
           end
      end
   endgenerate
   
endmodule // memory_dp


  
     

