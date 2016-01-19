module oh_fifo_async (/*AUTOARG*/
   // Outputs
   dout, full, prog_full, empty, valid, ccount,
   // Inputs
   nreset, wr_clk, wr_en, din, rd_clk, rd_en
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################
   parameter DW    = 104;          // FIFO width
   parameter DEPTH = 32;           // FIFO depth
   parameter TYPE  = "XILINX";     // "XILINX" or "ALTERA"
   parameter WAIT  = 0;            // assert random prog_full wait
   
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
   output 	   valid;     // data is valid at output
   output [15:0]   ccount;     // valid entries in fifo
   
   //#####################################################################
   //# BODY
   //#####################################################################
   //local wires
   wire 	   fifo_prog_full;
   wire 	   wait_random;
   
   assign prog_full = fifo_prog_full | wait_random;
   
generate
if(TYPE=="GENERIC") begin : basic   
   oh_fifo_async_model 
     #(.DEPTH(DEPTH),
       .DW(DW))
   fifo_model (
	       // Outputs
	       .full			(full),
	       .prog_full		(fifo_prog_full),
	       .dout			(dout[DW-1:0]),
	       .empty			(empty),
	       .valid			(valid),
	       // Inputs
	       .rst			(~nreset),
	       .wr_clk			(wr_clk),
	       .rd_clk			(rd_clk),
	       .wr_en			(wr_en),
	       .din			(din[DW-1:0]),
	       .rd_en			(rd_en));
end
else if (TYPE=="XILINX") begin : xilinx
   if((DW==104) & (DEPTH==32))
     begin	
	fifo_async_104x32 fifo (
	       // Outputs
	       .full			(full),
	       .prog_full		(fifo_prog_full),
	       .dout			(dout[DW-1:0]),
	       .empty			(empty),
	       .valid			(valid),
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

 //Random wait generator
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

module oh_fifo_async_model
   (/*AUTOARG*/
   // Outputs
   full, prog_full, dout, empty, valid, count,
   // Inputs
   nreset, wr_clk, rd_clk, wr_en, din, rd_en
   );
   
   parameter DW    = 104;            //Fifo width 
   parameter DEPTH = 1;              //Fifo depth (entries)         
   parameter AW    = $clog2(DEPTH);  //FIFO address width (for model)

   //##########
   //# RESET/CLOCK
   //##########
   input           nreset;    //asynchronous active low reset
   input           wr_clk;    //write clock   
   input           rd_clk;    //read clock   

   //##########
   //# FIFO WRITE
   //##########
   input           wr_en;   
   input  [DW-1:0] din;
   output          full;
   output 	   prog_full;
   
   //###########
   //# FIFO READ
   //###########
   input 	   rd_en;
   output [DW-1:0] dout;
   output          empty;
   output          valid;
   output [AW-1:0] count;

endmodule // oh_fifo_async_model
