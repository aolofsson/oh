`include "mio_constants.vh"
module oh_fifo_async (/*AUTOARG*/
   // Outputs
   dout, full, prog_full, empty, rd_count,
   // Inputs
   nreset, wr_clk, wr_en, din, rd_clk, rd_en
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################
   parameter DW         = 104;          // FIFO width
   parameter DEPTH      = 32;           // FIFO depth (entries)
   parameter TARGET     = "GENERIC";    // GENERIC,XILINX,ALTERA,GENERIC,ASIC
   parameter WAIT       = 0;            // assert random prog_full wait
   parameter PROG_FULL  = DEPTH/2;      // program full threshold   
   parameter AW         = $clog2(DEPTH);// binary read count width
      
   //clk/reset
   input 	   nreset;    // async reset

   //write port
   input           wr_clk;    // write clock   
   input 	   wr_en;     // write fifo
   input [DW-1:0]  din;       // data to write

   //read port
   input           rd_clk;    // read clock   
   input 	   rd_en;     // read fifo
   output [DW-1:0] dout;      // output data (next cycle)

   //status
   output 	   full;      // fifo is full
   output 	   prog_full; // fifo reaches full threshold
   output 	   empty;     // fifo is empty
   output [AW-1:0] rd_count;  // valid entries in fifo
   
   //#####################################################################
   //# BODY
   //#####################################################################
   //local wires
   wire 	   fifo_prog_full;
   wire 	   wait_random;
   wire [AW-1:0]   wr_count;  // valid entries in fifo
   
   assign prog_full = fifo_prog_full | wait_random;
   
generate
   if(TARGET=="GENERIC") begin : basic   
      oh_fifo_generic 
     #(.DEPTH(DEPTH),
       .DW(DW))
   fifo_generic (
	       // Outputs
	       .full			(full),
	       .prog_full		(fifo_prog_full),
	       .dout			(dout[DW-1:0]),
	       .empty			(empty),
	       .rd_count		(rd_count[AW-1:0]),
	       .wr_count		(wr_count[AW-1:0]),
	       // Inputs
	       .nreset   		(nreset),
	       .wr_clk			(wr_clk),
	       .rd_clk			(rd_clk),
	       .wr_en			(wr_en),
	       .din			(din[DW-1:0]),
	       .rd_en			(rd_en));
end
else if (TARGET=="XILINX") begin : xilinx
   if((DW==104) & (DEPTH==32))
     begin	
	fifo_async_104x32 fifo (
	       // Outputs
	       .full			(full),
	       .prog_full		(fifo_prog_full),
	       .dout			(dout[DW-1:0]),
	       .empty			(empty),
	       .rd_data_count		(rd_count[AW-1:0]),
	       // Inputs
	       .rst			(~nreset),
	       .wr_clk			(wr_clk),
	       .rd_clk			(rd_clk),
	       .wr_en			(wr_en),
	       .din			(din[DW-1:0]),
	       .rd_en			(rd_en));
     end // if ((DW==104) & (DEPTH==32))
end // block: xilinx   
endgenerate

 //Random wait generator (for testing)
   generate
      if(WAIT>0)
	begin	   
	   reg [7:0] wait_counter;  
	   always @ (posedge wr_clk or negedge nreset)
	     if(~nreset)
	       wait_counter[7:0] <= 'b0;   
	     else
	       wait_counter[7:0] <= wait_counter+1'b1;         
	   assign wait_random      = (|wait_counter[4:0]);//(|wait_counter[3:0]);//1'b0;
	end
      else
	begin
	   assign wait_random = 1'b0;
	end // else: !if(WAIT)
   endgenerate
      
endmodule // oh_fifo_async
// Local Variables:
// verilog-library-directories:("." "../fpga/" "../dv")
// End:
