//#############################################################################
//# Function: Binary to gray encoder                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_counter #(parameter DW   = 32,         // width of data inputs
		    parameter TYPE = "INCREMENT" // also DECREMENT, GRAY, LFSR
		    ) 
   (
   input 	   clk, // clk input
   input 	   in, // input to count
   input 	   en, // enable counter
   input 	   load, // load counter
   input [DW-1:0]  load_data,// load data
   output [DW-1:0] count, // current count value   
   output 	   carry, // carry out from counter
   output 	   zero   // counter is zero
    );
   
   // local variables
   reg [DW-1:0]    count;
   reg 		   carry;
   wire [DW-1:0]   count_in;
   wire 	   carry_in;
   
   // configure counter based on type
   generate
      if(TYPE=="INCREMENT")
	begin
	   assign {carry_in,count_in[DW-1:0]} = count[DW-1:0] + in;
	end
      else if(TYPE=="DECREMENT")
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

   // counter
   always @(posedge clk)
     if(load)
       begin
	  carry         <= 1'b0;	  
	  count[DW-1:0] <= load_data[DW-1:0];
       end
     else if (en)
       begin
	  carry         <= carry_in;
	  count[DW-1:0] <= count_in[DW-1:0];
       end

   // counter expired
   assign zero = ~(count[DW-1:0]);
      
endmodule // oh_counter







