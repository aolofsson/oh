module elink_monitor(/*AUTOARG*/
   // Inputs
   frame, clk, din
   );

   parameter AW = 32;
   parameter PW = 2*AW+40;
   
   input       frame;
   input       clk;
   input [7:0] din;

   reg [3:0]   cycle;
   reg 	       read;
   reg [31:0]  dstaddr;
   reg [31:0]  srcaddr;
   reg [31:0]  data;
   reg [3:0]   ctrlmode;
   reg [1:0]   datamode;
   reg 	       burst;
   reg 	       access;
   reg 	       write;
   wire [103:0] packet;
   
   always @ (posedge clk)
     if(~frame)
       cycle[3:0] <= 'b0;
     else
       cycle[3:0] <=  cycle[3:0]+1'b1;
   
   //Rising edge sampling
   always @ (posedge clk)
     if(frame)
       case (cycle)
	 0:
	   begin
	      read  <= din[7];
	      burst <= din[2];
	   end
	 1:
	   dstaddr[27:20] <= din[7:0];
	 2:
	   dstaddr[11:4]  <= din[7:0];
	 3:
	   data[31:24]    <= din[7:0];
	 4:
	   data[15:8]     <= din[7:0];
	 5:
	   srcaddr[31:24] <= din[7:0];
	 6:
	   srcaddr[15:8]  <= din[7:0];
	 default:
	   ;              	   
       endcase // case (cycle)
   
   //Falling edge sampling
   always @ (negedge clk)
     if(frame)
       case (cycle)
	 1:
	   begin
	      ctrlmode[3:0]  <= din[7:4];
	      dstaddr[31:28] <= din[3:0];
	   end
	 2:
	   dstaddr[19:12] <= din[7:0];
	 3:
	   begin
	      dstaddr[3:0]  <= din[7:4];
	      datamode[1:0] <= din[3:2];
	      write         <= din[1];
	      access        <= din[0];			     
	   end
	 4:
	   data[23:16]     <= din[7:0];
	 5:
	   data[7:0]       <= din[7:0];
	 6:
	   srcaddr[23:16]  <= din[7:0];
	 7:
	   srcaddr[7:0]    <= din[7:0];
	 default: ;              	   
       endcase // case (cycle)
   
   emesh2packet #(.AW(AW))
   e2p (
	// Outputs
	.packet_out			(packet[PW-1:0]),
	// Inputs
	.write_out			(write),
	.datamode_out			(datamode[1:0]),
	.ctrlmode_out			({1'b0,ctrlmode[3:0]}),
	.dstaddr_out			(dstaddr[AW-1:0]),
	.data_out			(data[AW-1:0]),
	.srcaddr_out			(srcaddr[AW-1:0]));

endmodule // elink_monitor
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/dv" "../../emesh/hdl")
// End:
