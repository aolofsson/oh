//####################################################################
//# Function: Mailbox FIFO with a FIFO empty/full flag interrupts.
//#
//#           E_MAILBOXLO    = lower 32 bits of FIFO entry
//#           E_MAILBOXHI    = upper 32 bits of FIFO entry
//#           E_MAILBOXSTAT  = {30'b0,fifo_full, ~fifo_empty}
//#
//# Notes:    1.) System should take care of not overflowing the FIFO
//#           2.) Reading E_MAILBOXLO causes a fifo rd pointer update
//#           3.) The "embox_not_empty" is a "level" interrupt signal
//#
//#####################################################################
`include "emailbox_regmap.v" // is there a better way?
module emailbox (/*AUTOARG*/
   // Outputs
   reg_rdata, mailbox_irq,
   // Inputs
   nreset, wr_clk, rd_clk, emesh_access, emesh_packet, reg_access,
   reg_packet, mailbox_irq_en
   );

   //##################################################################
   //# INTERFACE
   //##################################################################
   parameter AW     = 32;          // data width of fifo
   parameter ID     = 12'h000;     // link id
   parameter RFAW   = 6;           // address bus width
   parameter DEPTH  = 32;          // fifo depth
   parameter PW     = 2*AW+40;     // packet size
   parameter MW     = PW;          // fifo memory width

   //clk+reset
   input           nreset;         // asynchronous active low reset
   input 	   wr_clk;         // write clock
   input 	   rd_clk;         // read clock
   
   //message interface
   input 	   emesh_access;   // message access (write only)
   input [PW-1:0]  emesh_packet;   // message packet
   
   //register interface
   input 	   reg_access;     // register access (read only)
   input [PW-1:0]  reg_packet;     // data/address
   output [31:0]   reg_rdata;      // readback dataa

   //mailbox flags
   input 	   mailbox_irq_en; // interupt enable 	    
   output 	   mailbox_irq;    // interrupt
   
   //##################################################################
   //# BODY
   //##################################################################  
   reg 		   read_hi;
   reg 		   read_lo;
   reg 		   read_status;     
   wire 	   mi_rd;  
   wire [31:0] 	   emesh_addr;
   wire [63:0] 	   emesh_din;
   wire 	   emesh_write;
   wire 	   mailbox_read;
   wire 	   mailbox_write;
   wire [MW-1:0]   mailbox_data;
   wire 	   mailbox_empty; 

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		reg_ctrlmode;		// From p2e1 of packet2emesh.v
   wire [AW-1:0]	reg_data;		// From p2e1 of packet2emesh.v
   wire [1:0]		reg_datamode;		// From p2e1 of packet2emesh.v
   wire [AW-1:0]	reg_dstaddr;		// From p2e1 of packet2emesh.v
   wire [AW-1:0]	reg_srcaddr;		// From p2e1 of packet2emesh.v
   wire			reg_write;		// From p2e1 of packet2emesh.v
   // End of automatics
   
   //###########################################
   // WRITE PORT
   //###########################################

   packet2emesh #(.AW(32))
   p2e0 (// Outputs
	.write_in	(emesh_write),
	.datamode_in	(),
	.ctrlmode_in	(),
	.data_in	(emesh_din[31:0]),
	.dstaddr_in	(emesh_addr[31:0]),
	.srcaddr_in	(emesh_din[63:32]),
	// Inputs
	.packet_in	(emesh_packet[PW-1:0]));
   
   assign mailbox_write = emesh_access &
	                  emesh_write  &
	                  (emesh_addr[31:20]==ID) & 
			  (emesh_addr[19:16]==`EGROUP_MMR) &
			  (emesh_addr[10:8] ==`EGROUP_MESH) & 
                          (emesh_addr[RFAW+1:2]==`E_MAILBOXLO); 
   
   //###########################################
   // READ PORT
   //###########################################  

   /*packet2emesh  AUTO_TEMPLATE ( .\(.*\)_in  (reg_\1[]));*/   

   packet2emesh #(.AW(AW))
   p2e1 (/*AUTOINST*/
	 // Outputs
	 .write_in			(reg_write),		 // Templated
	 .datamode_in			(reg_datamode[1:0]),	 // Templated
	 .ctrlmode_in			(reg_ctrlmode[4:0]),	 // Templated
	 .dstaddr_in			(reg_dstaddr[AW-1:0]),	 // Templated
	 .srcaddr_in			(reg_srcaddr[AW-1:0]),	 // Templated
	 .data_in			(reg_data[AW-1:0]),	 // Templated
	 // Inputs
	 .packet_in			(reg_packet[PW-1:0]));	 // Templated
   
   assign reg_read      = reg_access & ~reg_write;
   assign mailbox_read  = reg_read & (reg_dstaddr[RFAW+1:2]==`E_MAILBOXLO);

   always @ (posedge rd_clk)
     begin
	read_lo      <= mailbox_read;
	read_hi      <= reg_read & (reg_dstaddr[RFAW+1:2]==`E_MAILBOXHI);	
	read_status  <= reg_read & (reg_dstaddr[RFAW+1:2]==`E_MAILBOXSTAT);
     end

   //TODO: check that high bits stay high
   oh_mux3 #(.DW(32))
   oh_mux3 (// Outputs
	     .out (reg_rdata[31:0]),
	     // Inputs
	     .in0 ({30'h0,mailbox_full, mailbox_not_empty}), .sel0 (read_status),
	     .in1 (mailbox_data[63:32]),                     .sel1 (read_hi),
     	     .in2 (mailbox_data[31:0]),                      .sel2 (read_lo)
	     );

   //###########################################
   // FIFO
   //###########################################  
   oh_fifo_async #(.DW(MW),
		   .DEPTH(DEPTH)
		   )
   fifo(// Outputs
	.dout      (mailbox_data[MW-1:0]),
	.empty     (mailbox_empty),
	.full      (mailbox_full),
     	.prog_full (),
	.valid     (dout_valid),
	//Common async reset
	.rst       (~nreset),  
	//Read Port
	.rd_en     (mailbox_read), 
	.rd_clk    (rd_clk),  
	//Write Port 
	.din       ({40'b0,emesh_din[63:0]}),
	.wr_en     (mailbox_write),
	.wr_clk    (wr_clk)  			     
	); 

   //###########################################
   // INTERRUPT OUTPUTS
   //###########################################  

   assign mailbox_not_empty  = ~mailbox_empty;

   assign mailbox_irq        = mailbox_irq_en & 
			       (mailbox_not_empty | mailbox_full);
      
endmodule // emailbox
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl")
// End:
