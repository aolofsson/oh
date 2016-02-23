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
   reg [DW-1:0]     q2_sl;
   
   // sample on rising edge
   always @ (posedge clk)
     if(ce)
       q1_sl[DW-1:0] <= #0.2  din[DW-1:0];
   
   // sampling on falling edge
   always @ (negedge clk)
     if(ce)
       q2_sh[DW-1:0] <= #0.2  din[DW-1:0];
              
   // same phase sampling the negedge
   always @ (posedge clk)
     if(ce)
       q2_sl[DW-1:0] <= #0.2 q2_sh[DW-1:0];

   // driving vectors
   assign q1[DW-1:0] = q1_sl[DW-1:0];   
   assign q2[DW-1:0] = q2_sl[DW-1:0];
            
endmodule // oh_iddr


