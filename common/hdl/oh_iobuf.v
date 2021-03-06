//#############################################################################
//# Function: IO Buffer                                                       #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################
module oh_iobuf #(parameter N    = 1,            // BUS WIDTH
		  parameter TYPE = "BEHAVIORAL"  // BEHAVIORAL, HARD
		  )
   (
    //POWER
    inout 	   vdd, // core supply
    inout 	   vddio,// io supply
    inout 	   vss, // ground
    //CONTROLS
    input 	   enpullup, //enable pullup
    input 	   enpulldown, //enable pulldown
    input 	   slewlimit, //slew limiter
    input [3:0]    drivestrength, //drive strength
    //DATA
    input [N-1:0]  ie, //input enable
    input [N-1:0]  oe, //output enable
    output [N-1:0] out,//output to core
    input [N-1:0]  in, //input from core
    //BIDIRECTIONAL PAD
    inout [N-1:0]  pad
    );
   
   genvar 	   i;
   
   //TODO: Model power signals
   for (i = 0; i < N; i = i + 1) begin : gen_buf
      if(TYPE=="BEHAVIORAL") begin : gen_beh
	 assign pad[i] = oe[i] ? in[i] : 1'bZ;
	 assign out[i] = ie[i] ? pad[i] : 1'b0;
      end
      else begin : gen_custom
	 
      end
   end

endmodule // oh_iobuf


