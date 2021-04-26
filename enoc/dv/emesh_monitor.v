/* verilator lint_off STMTDLY */
module emesh_monitor(/*AUTOARG*/
   // Inputs
   clk, nreset, dut_access, dut_packet, ready_in, coreid
   );

   parameter PW     = 104;
   parameter IDW    = 12;
   parameter INDEX  = 0;
   parameter NAME   = "not_declared";
   
   //clock and reset
   input            clk;
   input            nreset;
   
   //monitors transaction on the wire
   input            dut_access;
   input [PW-1:0]   dut_packet;   
   input 	    ready_in;  
   input [IDW-1:0]  coreid;   

   //core name for trace
   reg [31:0] 	    ftrace;
   reg [255:0] 	    tracefile;
 	    
   //Dumps into 
   initial
     begin
	//TODO: Figure out these delays
	#10
	  //index should be core ID
	  $sformat(tracefile,"%0s_%0h%s",NAME,coreid,".trace");
	ftrace  = $fopen({tracefile}, "w");  
     end
   
   always @ (posedge clk or negedge nreset)
     if(nreset & dut_access & ready_in)
       begin
	  $fwrite(ftrace, "%h_%h_%h_%h\n",dut_packet[PW-1:72],dut_packet[71:40],dut_packet[39:8],dut_packet[7:0]);   
	  //$display("%h_%h_%h_%h\n",dut_packet[PW-1:72],dut_packet[71:40],dut_packet[39:8],dut_packet[7:0]);   
       end
endmodule // dut_monitor




