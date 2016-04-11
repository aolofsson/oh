//#############################################################################
//# Function: CRC combinatorial encoder wrapper                               #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_crc #( parameter TYPE    = "ETH",  // type: "ETH", "OTHER"
		 parameter DW      = 8)       // width of data
   (
    input [DW-1:0]  data_in, // input data
    input [CW-1:0]  crc_state, // input crc state
    output [CW-1:0] crc_next // next crc state
    );
   
   localparam CW      = 32;         // width of polynomial
     
   generate
      if(TYPE=="ETH")
	begin
	   if(DW==8)	  	  
	     oh_crc32_8b crc(/*AUTOINST*/
			     // Outputs
			     .crc_next		(crc_next[31:0]),
			     // Inputs
			     .data_in		(data_in[7:0]),
			     .crc_state		(crc_state[31:0]));
	   else if(DW==64)
	     oh_crc32_64b crc(/*AUTOINST*/
			      // Outputs
			      .crc_next		(crc_next[31:0]),
			      // Inputs
			      .data_in		(data_in[63:0]),
			      .crc_state	(crc_state[31:0]));
      
	end // if (TYPE=="ETH")      
   endgenerate
  			 		 		    
endmodule // oh_crc

