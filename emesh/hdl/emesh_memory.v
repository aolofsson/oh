/*******************************************************************************
 * Function:  SRAM with EMESH interface
 * Author:    Andreas Olofsson
 * License:   MIT (see LICENSE file in OH! repository)
 *
 ******************************************************************************/
module emesh_memory
  # (parameter AW        = 32,          // address width
     parameter PW        = 104,         // packet width
     parameter IDW       = 12,          // ID width
     parameter DEPTH     = 65536,       // memory depth
     parameter FILENAME  = "log",       // instance name
     parameter EN_WAIT   = 0,           // 0=disable random wait
     parameter EN_MON    = 0,           // 0=disable monitor
     parameter WAIT_MASK = 32'h0000000F // range limiter for wait signal
     )

   (// clk,reset
    input 	    clk,
    input 	    nreset,
    input [IDW-1:0] coreid,
    // incoming read/write
    input 	    valid_in,
    input [PW-1:0]  packet_in,
    output 	    ready_out, //pushback
    // back to mesh (readback data)
    output reg 	    valid_out,
    output [PW-1:0] packet_out,
    input 	    ready_in   //pushback
    );

   //derived parameters
   localparam DW  = AW;     //always the same
   parameter  MAW = $clog2(DEPTH);

   //###############
   //# LOCAL WIRES
   //##############

   wire [MAW-1:0]   addr;
   wire [63:0]      din;
   wire [63:0] 	    dout;
   wire 	    en;
   wire 	    mem_rd;
   reg [7:0] 	    wen;
   reg 		    write_out;
   reg [1:0] 	    datamode_out;
   reg [4:0] 	    ctrlmode_out;
   reg [AW-1:0]     dstaddr_out;
   wire [AW-1:0]    srcaddr_out;
   wire [AW-1:0]    data_out;
   reg  [2:0]       align_addr;
   wire [DW-1:0]    din_aligned;
   wire [63:0]      dout_aligned;
   wire 	    ready_random; //TODO: make random
   wire 	    ready_all;
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			cmd_atomic_add;		// From p2e of emesh_unpack.v
   wire			cmd_atomic_and;		// From p2e of emesh_unpack.v
   wire			cmd_atomic_or;		// From p2e of emesh_unpack.v
   wire			cmd_atomic_xor;		// From p2e of emesh_unpack.v
   wire			cmd_cas;		// From p2e of emesh_unpack.v
   wire [3:0]		cmd_length;		// From p2e of emesh_unpack.v
   wire [3:0]		cmd_opcode;		// From p2e of emesh_unpack.v
   wire			cmd_read;		// From p2e of emesh_unpack.v
   wire [2:0]		cmd_size;		// From p2e of emesh_unpack.v
   wire [7:0]		cmd_user;		// From p2e of emesh_unpack.v
   wire			cmd_write;		// From p2e of emesh_unpack.v
   wire			cmd_write_stop;		// From p2e of emesh_unpack.v
   wire [2*AW-1:0]	data;			// From p2e of emesh_unpack.v
   wire [AW-1:0]	dstaddr;		// From p2e of emesh_unpack.v
   wire [AW-1:0]	srcaddr;		// From p2e of emesh_unpack.v
   // End of automatics

   emesh_unpack #(.AW(AW),
		  .PW(PW))
   p2e (/*AUTOINST*/
	// Outputs
	.cmd_write			(cmd_write),
	.cmd_write_stop			(cmd_write_stop),
	.cmd_read			(cmd_read),
	.cmd_atomic_add			(cmd_atomic_add),
	.cmd_atomic_and			(cmd_atomic_and),
	.cmd_atomic_or			(cmd_atomic_or),
	.cmd_atomic_xor			(cmd_atomic_xor),
	.cmd_cas			(cmd_cas),
	.cmd_opcode			(cmd_opcode[3:0]),
	.cmd_length			(cmd_length[3:0]),
	.cmd_size			(cmd_size[2:0]),
	.cmd_user			(cmd_user[7:0]),
	.dstaddr			(dstaddr[AW-1:0]),
	.srcaddr			(srcaddr[AW-1:0]),
	.data				(data[2*AW-1:0]),
	// Inputs
	.packet_in			(packet_in[PW-1:0]));

   // Ready/valid
   assign ready_all = (ready_random | ready_in);
   assign en        =  valid_in & ready_all;
   assign mem_rd    = (valid_in & ~write_in & ready_all);

   //Pushback Circuit (pass through problems?)

   assign readt_out = ready_all;// & valid_in

   //Address-in (shifted by three bits, 64 bit wide memory)
   assign addr[MAW-1:0] = dstaddr[MAW+2:3];

   //Shift up
   assign  din_aligned[31:0] = (cmd_size[2:0]==3'b000) ? {(4){data[7:0]}}  :
			       (cmd_size[2:0]==3'b001) ? {(2){data[15:0]}} :
 			                                   data_in[31:0];

   //Data-in (hardoded width)
   assign din[63:0] =(cmd_size[2:0]==3'b011) ? {srcaddr[31:0],din_aligned[31:0]}:
		                               {din_aligned[31:0],din_aligned[31:0]};
   //Write mask
   always@*
     casez({cmd_write, cmd_size[1:0],dstaddr[2:0]})
       //Byte
       6'b100000 : wen[7:0] = 8'b00000001;
       6'b100001 : wen[7:0] = 8'b00000010;
       6'b100010 : wen[7:0] = 8'b00000100;
       6'b100011 : wen[7:0] = 8'b00001000;
       6'b100100 : wen[7:0] = 8'b00010000;
       6'b100101 : wen[7:0] = 8'b00100000;
       6'b100110 : wen[7:0] = 8'b01000000;
       6'b100111 : wen[7:0] = 8'b10000000;
       //Short
       6'b10100? : wen[7:0] = 8'b00000011;
       6'b10101? : wen[7:0] = 8'b00001100;
       6'b10110? : wen[7:0] = 8'b00110000;
       6'b10111? : wen[7:0] = 8'b11000000;
       //Word
       6'b1100?? : wen[7:0] = 8'b00001111;
       6'b1101?? : wen[7:0] = 8'b11110000;
       //Double
       6'b111??? : wen[7:0] = 8'b11111111;
       default   : wen[7:0] = 8'b00000000;
     endcase // casez ({write, datamode_in[1:0],addr_in[2:0]})

   //Single ported memory
   defparam mem.N=64;
   defparam mem.DEPTH=DEPTH;
   oh_memory_sp mem(
		    // Inputs
		    .clk (clk),
		    .en	 (en),
		    .we  (cmd_write),
		    .wem ({
			   {(8){wen[7]}},
			   {(8){wen[6]}},
			   {(8){wen[5]}},
			   {(8){wen[4]}},
			   {(8){wen[3]}},
			   {(8){wen[2]}},
			   {(8){wen[1]}},
			   {(8){wen[0]}}
			   }
			  ),
		    .addr     (addr[MAW-1:0]),
		    .din      (din[63:0]),
		    .dout     (dout[63:0]),
		    .vdd      (1'b1),
   		    .vddio    (1'b1),
       		    .memrepair(8'b0),
		    .memconfig(8'b0),
		    .bist_en  (1'b0),
		    .bist_we  (1'b0),
    		    .bist_wem (64'b0),
		    .bist_addr({(MAW){1'b0}}),
		    .bist_din (64'b0)
		    );

   //Outgoing transaction
   always @ (posedge  clk or negedge nreset)
     if(!nreset)
       valid_out <=1'b0;
     else
       begin
	  valid_out          <= mem_rd;
	  write_out           <= 1'b1;
          align_addr[2:0]     <= dstaddr[2:0];
	  datamode_out[1:0]   <= datamode[1:0];
	  ctrlmode_out[4:0]   <= ctrlmode[4:0];
          dstaddr_out[AW-1:0] <= srcaddr[AW-1:0];
       end

   //Data alignment for readback
   emesh_rdalign emesh_rdalign (// Outputs
				.data_out	(dout_aligned[63:0]),
				// Inputs
				.datamode	(datamode_out[1:0]),
				.addr		(align_addr[2:0]),
				.data_in	(dout[63:0]));

   assign srcaddr_out[AW-1:0] = (datamode_out[1:0]==2'b11) ? dout[63:32] : 32'b0;
   assign data_out[31:0]      = dout_aligned[31:0];

   //Concatenate
   emesh_pack #(.AW(AW),
		.PW(PW))
   e2p (// Outputs
	.packet_out			(packet_out[PW-1:0]),
	// Inputs
	.opcode_in			(cmd_opcode[3:0]),
	.length_in			(cmd_length[3:0]),
	.size_in			(cmd_size[2:0]),
	.user_in			(cmd_user[7:3]),
	.dstaddr_in			(dstaddr[AW-1:0]),
	.srcaddr_in			(srcaddr[AW-1:0]),
	.data_in			(data[2*AW-1:0]));

   // Traffic monitor
   emesh_monitor #(.PW(PW),
		   .FILENAME(FILENAME),
		   .ENABLE(EN_MON))
   emesh_monitor (.dut_valid	(valid_in & write_in),
		  .dut_packet	(packet_in[PW-1:0]),
		  .ready_in	(ready_random),
		  .clk		(clk),
		  .nreset	(nreset));

   //Random wait generator   //TODO: make this a module
   oh_pulse oh_pulse(// Outputs
		     .out     (pulse),
		     // Inputs
		     .clk     (clk),
		     .nreset  (nreset),
		     .en      (1'b1),
		     .mask    (WAIT_MASK));

   if(EN_MON)
     assign ready_random = pulse;
   else
     assign ready_random = 1'b1;

endmodule // emesh_memory
// Local Variables:
// verilog-library-directories:("." "../dv" "../../stdlib/hdl/")
// End:
