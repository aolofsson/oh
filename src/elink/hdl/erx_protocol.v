//############################################################
//#This block handles the autoincrement needed for bursting
//############################################################
module erx_protocol (/*AUTOARG*/
   // Outputs
   erx_access, erx_packet,
   // Inputs
   clk, test_mode, rx_packet, rx_burst, rx_access
   );

   parameter AW   = 32;
   parameter DW   = 32;
   parameter PW   = 104;
   parameter ID   = 12'h999; //link id
   
   // System reset input
   input           clk;

   //test mode
   input 	   test_mode; //block all traffic in test mode
   
   // Parallel interface, 8 eLink bytes at a time
   
   input [PW-1:0]  rx_packet;
   input 	   rx_burst;
   input 	   rx_access;
   
   // Output to MMU / filter
   output          erx_access;
   output [PW-1:0] erx_packet;

   //wires
   reg [31:0] 	   dstaddr_reg;   
   wire [31:0] 	   dstaddr_next;
   wire [31:0] 	   dstaddr_mux;
   reg 		   erx_access;
   reg [PW-1:0]    erx_packet;
   wire [31:0] 	   rx_addr;
   
   //parsing inputs
   assign        rx_addr[31:0]  = rx_packet[39:8];
   
   //Address generator for bursting
   always @ (posedge clk)
     if(rx_access)
       dstaddr_reg[31:0]    <= dstaddr_mux[31:0];

   assign dstaddr_next[31:0] = dstaddr_reg[31:0] + 4'b1000;
   
   assign dstaddr_mux[31:0]  =  rx_burst ? dstaddr_next[31:0] :
			                   rx_addr[31:0];
                  
   //Pipeline stage and decode  
   
   always @ (posedge clk)
     begin
	  //Write/read request
	  erx_access          <= ~test_mode & rx_access;      	  
	  //Common packet
	  erx_packet[PW-1:0]  <= {rx_packet[PW-1:40],
				  dstaddr_mux[31:0],
				  {1'b0,rx_packet[7:1]} //NOTE: remvoing redundant access packet bit
				  };                    //This is to conform to new format	 
     end
     
endmodule // erx_protocol
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

