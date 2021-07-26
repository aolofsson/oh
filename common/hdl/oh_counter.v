//#############################################################################
//# Function: Generic counter                                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_counter
  #(parameter N   = 32,       // width of data inputs
    parameter SYN = "TRUE",   // synthesizable
    parameter TYPE = "DEFAULT"// implementation type
    )
   (
    //inputs
    input 	       clk, // clk input
    input 	       in, // input to count
    input 	       en, // enable counter
    input 	       dec,//1=decrement, 0 = increment
    input 	       autowrap, //auto wrap counter
    input 	       load, // load counter
    input [N-1:0]      load_data, // input data to load
    //outputs
    output reg [N-1:0] count, // count value
    output 	       wraparound // wraparound indicator
    );

   wire [N-1:0]	 inb;
   wire [N-1:0]  count_in;

   //Increment decrement option
   assign inb[N-1:0] = dec ? {{(N-1){1'b1}},~in} : {{(N-1){1'b0}},in};
   assign cin        = dec ? 1'b1 : 1'b0;

   // counter
   always @(posedge clk)
     if(load)
       count[N-1:0] <= load_data[N-1:0];
     else if (en & ~(wraparound & ~autowrap))
       count[N-1:0] <= count_in[N-1:0];

   assign wraparound = (dec & en & ~(|count[N-1:0])) |
		       (~dec & en & (&count[N-1:0]));

   // Soft/hard adder
   generate
      if(SYN == "TRUE")  begin
	 assign count_in[N-1:0] =count[N-1:0] + inb[N-1:0];
      end
      else begin
	 asic_add #(.TYPE(TYPE),
		    .N(N))
	 asic_add (// Outputs
		   .sum		(cout_in[N-1:0]),
		   .carry	(),
		   .cout	(),
		   // Inputs
		   .a		(count[N-1:0]),
		   .b		(in_mux[N-1:0]),
		   .k		({(N){1'b0}}),
		   .cin		(cin));
      end
   endgenerate

endmodule // oh_counter
