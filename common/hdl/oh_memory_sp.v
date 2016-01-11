
/*###########################################################################
 # Function: Single port memory wrapper
 #           To run without hardware platform dependancy use:
 #           `define TARGET_CLEAN"
 ############################################################################
 */

module oh_memory_sp(/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   clk, en, we, wem, addr, din
   );

   //parameters
   parameter DEPTH   = 14;   
   parameter DW      = 32;
   parameter AW      = $clog2(DEPTH);
   parameter NAME   = "not_declared";
   
   //interface
   input               clk;  //clock
   input               en;   //memory access   
   input 	       we;   //write enable global signal   
   input [DW-1:0]      wem;  //write enable vector
   input [AW-1:0]      addr; //address
   input [DW-1:0]      din;  //data input
   output [DW-1:0]     dout; //data output
      
`ifdef CFG_ASIC

   initial  
     $display("Need to instantiate process specific macro here");
   
`else
   //Assume FPGA tool knows what it's doing (single clock...)
   reg [DW-1:0]        ram    [DEPTH-1:0];  
   reg [DW-1:0]        dout;
   integer 	       i;
   
   //read port (one cycle latency)
   always @ (posedge clk)
     if(en)       
       dout[DW-1:0] <= ram[addr[AW-1:0]];

   //write port
   always @ (posedge clk)
     for(i=0;i<DW;i=i+1)	   
       if(en & wem[i] & we)	       
 	 ram[addr[AW-1:0]][i] <= din[i]; 

`endif
  
endmodule // oh_memory_sp



  
     

