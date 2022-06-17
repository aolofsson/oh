/*******************************************************************************
 * Function:  EMESH Transaction Monitor
 * Author:    Andreas Olofsson
 * License:   MIT (see LICENSE file in OH! repository)
 *
 ******************************************************************************/

/* verilator lint_off STMTDLY */
module emesh_monitor
  # (parameter PW       = 104,         // packet width
     parameter FILENAME = "UNDEFINED"  // filename
     )
   (
    //clock and reset
    input 	   clk,
    input 	   nreset,
    //monitors transaction on the wire
    input 	   dut_valid,
    input [PW-1:0] dut_packet,
    input 	   ready_in
    );

`ifdef DEBUG

   //core name for trace
   reg [31:0] 	    ftrace;
   reg [255:0] 	    tracefile;

   //Dumps into
   initial
     begin
	//TODO: Figure out these delays
	#10
	  //index should be core ID
	  $sformat(tracefile,"%0s_%0h%s",FILENAME);
	ftrace  = $fopen({tracefile}, "w");
     end

   always @ (posedge clk)
     if(nreset & dut_valid & ready_in)
       if (PW==112) begin: p112
	  $fwrite(ftrace, "%h_%h_%h_%h\n",dut_packet[110:80],dut_packet[79:48],dut_packet[47:16],dut_packet[15:0]);
       end
       else if (PW==144) begin: p144
	  $fwrite(ftrace, "%h_%h_%h_%h\n",dut_packet[143:112],dut_packet[111:48],dut_packet[47:16],dut_packet[15:0]);
       end
       else if (PW==208) begin: p208
	  $fwrite(ftrace, "%h_%h_%h_%h_%h\n",dut_packet[207:144],dut_packet[143:112],dut_packet[111:48],dut_packet[47:16],dut_packet[15:0]);
       end

`endif //  `ifdef DEBUG

endmodule // emesh_monitor
