module oh_counter (/*AUTOARG*/
   // Outputs
   count, carry, zero,
   // Inputs
   clk, in, en, load, load_data
   );
 
   //###############################################################
   //# Interface
   //###############################################################

   parameter DW   = 64;
   parameter TYPE = "INCREMENT"; //INCREMENT, DECREMENT, GRAY, LFSR
   
   //clock interface
   input           clk;      // clk input

   //counter control
   input 	   in;       // input to count
   input 	   en;       // enable counter
   input 	   load;     // load counter
   input [DW-1:0]  load_data;// load data
      
   //outputs
   output [DW-1:0] count;    // current count value   
   output 	   carry;    // carry out from counter
   output 	   zero;     // counter is zero
   
   //###############################################################
   //# Interface
   //###############################################################
   reg [DW-1:0]    count;
   reg 		   carry;
   wire [DW-1:0]   count_in;
   wire 	   carry_in;
   
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

   assign zero = ~(count[DW-1:0]);
   
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
   
   
endmodule // oh_counter







