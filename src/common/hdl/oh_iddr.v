//##################################################################
//# ***DUAL DATA RATE INPUT***
//#
//# * Equivalent to "SAME_EDGE_PIPELINED" for xilinx
//# * din sampled on rising edge of clk
//# * din sampled on falling edge of clk
//# * q1 holds rising edge data
//# * q2 holds falling edge data
//#
//##################################################################

module oh_iddr (/*AUTOARG*/
   // Outputs
   q1, q2,
   // Inputs
   clk, ce, din
   );

   //parameters
   parameter DW  = 32;      // width of interface 
      
   //interface
   input 	    clk;    // clock
   input 	    ce;     // clock enable, set to high to clock in data
   input [DW-1:0]   din;    // data input 
   output [DW-1:0]  q1;     // iddr rising edge sampled data
   output [DW-1:0]  q2;     // iddr falling edge sampled data
   
   //regs("sl"=stable low, "sh"=stable high)
   reg [DW-1:0]     q1_sl;
   reg [DW-1:0]     q2_sh;
   reg [DW-1:0]     q1;
   reg [DW-1:0]     q2;
   
   // rising edge sample
   always @ (posedge clk)
     if(ce)
       q1_sl[DW-1:0] <= din[DW-1:0];
   
   // falling edge sample
   always @ (negedge clk)
     q2_sh[DW-1:0] <= din[DW-1:0];
   
   // pipeline for alignment
   always @ (posedge clk)
     begin
	q1[DW-1:0] <= q1_sl[DW-1:0];
	q2[DW-1:0] <= q2_sh[DW-1:0];
     end
            
endmodule // oh_iddr


