//#############################################################################
//# Function: Generic counter                                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_counter #(parameter DW   = 32  // width of data inputs
		    ) 
   (
    //inputs
    input 	    clk, // clk input
    input 	    in, // input to count
    input 	    en, // enable counter
    input 	    dir,//0=increment, 1=decrement
    input 	    autowrap, //auto wrap around
    input 	    load, // load counter
    input [DW-1:0]  load_data, // input data to load
    //outputs
    output [DW-1:0] count, // count value
    output 	    wraparound // wraparound indicator
    );
   
   // local variables
   reg [DW-1:0]    count;
   wire [DW-1:0]   count_in;
   
   //Select count direction
   assign count_in[DW-1:0] = dir ? count[DW-1:0] - in :
			           count[DW-1:0] + in ;
   
   // counter
   always @(posedge clk)
     if(load)
       count[DW-1:0] <= load_data[DW-1:0];
     else if (en & ~(wraparound & ~autowrap))
       count[DW-1:0] <= count_in[DW-1:0];
   
   // counter expired
   assign wraparound = (dir & en & ~(|count[DW-1:0])) |
		       (~dir & en & (&count[DW-1:0]));
   
endmodule // oh_counter







