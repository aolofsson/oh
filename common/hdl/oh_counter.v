module oh_counter (/*AUTOARG*/
   // Outputs
   count, zero,
   // Inputs
   clk, nreset, in, en, load, wdata
   );
 
   //###############################################################
   //# Interface
   //###############################################################

   parameter DW   = 64;
   parameter TYPE = "BINARY"; //BINARY, GRAY, LFSR
   
   //clock interface
   input           clk;
   input 	   nreset;
   
   //counter control
   input 	   in;     //input to count
   input 	   en;     //counter enabled
   input 	   load;   //loads new start value
   input [DW-1:0]  wdata;  //write data
      
   //outputs
   output [DW-1:0] count;    //current count value   
   output 	   zero;     //counter is zero
   
   //###############################################################
   //# Interface
   //###############################################################
   reg [DW-1:0]    count;
   wire [DW-1:0]   count_in;
   
   always @(posedge clk)
     if(load)
       count[DW-1:0] = wdata[DW-1:0];
     else if (en)
       count[DW-1:0] = count_in[DW-1:0];
             
   generate
      if(TYPE=="BINARY")
	begin
	   assign count_in[DW-1:0] = count[DW-1:0] + in;
	end
      else if (TYPE=="GRAY")
	begin
	   initial
	     $display ("NOT IMPLEMENTED");	   
	end
      else if (TYPE=="LFSR")
	begin
	   initial
	     $display ("NOT IMPLEMENTED");	   
	end      
   endgenerate
   
   
endmodule // oh_counter







