module oh_crc (/*AUTOARG*/
   // Outputs
   crc_state, crc_next,
   // Inputs
   data_in
   );

   //###############################################################
   //# Interface
   //###############################################################

   // parameters
   parameter TYPE    = "ETH";      // type: "ETH", "OTHER"
   parameter DW      = 8;          // width of data
   parameter CW      = 32;         // width of polynomial
      
   // signals
   input [DW-1:0]  data_in;
   output [CW-1:0] crc_state;
   output [CW-1:0] crc_next;

   //###############################################################
   //# BODY
   //###############################################################
   
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
