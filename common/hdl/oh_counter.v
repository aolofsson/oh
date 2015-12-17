module oh_counter (/*AUTOARG*/
   // Outputs
   count, zero,
   // Inputs
   clk, nreset, en, load, wdata
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
   
   always @(posedge clk or negedge)
     if(nreset)
       count[DW-1:0] = 'b0;
     else if(load)
       count[DW-1:0] = wdata[DW-1:0];
     else if (en)
       count[DW-1:0] = count_in[DW-1:0];
             
   generate
      if(TYPE=="BINARY")
	begin
	   assign count_in[DW-1:0] = count[DW-1:0] + 1'b1;
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







