//#############################################################################
//# Function: Parallel to Serial Converter                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE in OH! repositpory)                            # 
//#############################################################################

module oh_par2ser #(parameter PW = 64, // parallel packet width
		    parameter SW = 1,  // serial packet width
		    parameter CW = $clog2(PW/SW)  // serialization factor
		    )
   (
    input 	    clk, // sampling clock   
    input 	    nreset, // async active low reset
    input [PW-1:0]  din, // parallel data
    output [SW-1:0] dout, // serial output data
    output 	    access_out,// output data valid    
    input 	    load, // load parallel data (priority)   
    input 	    shift, // shift data
    input [7:0]     datasize, // size of data to shift 
    input 	    lsbfirst, // lsb first order
    input 	    fill, // fill bit  
    input 	    wait_in, // wait input  
    output 	    wait_out // wait output (wait in | serial wait)
    );
 
   // local wires
   reg [PW-1:0]    shiftreg;
   reg [CW-1:0]    count;
   wire 	   start_transfer;
   wire 	   busy;
   
   // start serialization   
   assign start_transfer = load &  ~wait_in & ~busy;

   //transfer counter
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       count[CW-1:0] <= 'b0;   
     else if(start_transfer)
       count[CW-1:0] <= datasize[CW-1:0];  //one "SW sized" transfers
     else if(shift & busy)
       count[CW-1:0] <= count[CW-1:0] - 1'b1;
   
   //output data is valid while count > 0
   assign busy = |count[CW-1:0];
   
   //data valid while shifter is busy
   assign access_out = busy;
      
   //wait until valid data is finished
   assign wait_out  = wait_in | busy;
   
   // shift register
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       shiftreg[PW-1:0] = 'b0;   
     else if(start_transfer)
       shiftreg[PW-1:0] = din[PW-1:0];
     else if(shift & lsbfirst)		 
       shiftreg[PW-1:0] = {{(SW){fill}}, shiftreg[PW-1:SW]};
     else if(shift)
       shiftreg[PW-1:0] = {shiftreg[PW-SW-1:0],{(SW){fill}}};
   

   assign dout[SW-1:0] = lsbfirst ? shiftreg[SW-1:0] : 
			            shiftreg[PW-1:PW-SW];	

endmodule // oh_par2ser




