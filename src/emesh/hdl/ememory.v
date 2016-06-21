
module ememory # (parameter AW    = 32,     // address width
		  parameter PW    = 104,    // packet width
		  parameter IDW   = 12,     // ID width
		  parameter DEPTH = 65536,  // memory depth
		  parameter NAME  = "emem", // instance name
		  parameter WAIT  = 0,      // enable random wait
		  parameter MON   = 0       // enable monitor monitor
		  )
   
   (// clk,reset
    input 	    clk,
    input 	    nreset, 
    input [IDW-1:0] coreid,
    // incoming read/write
    input 	    access_in,
    input [PW-1:0]  packet_in, 
    output 	    wait_out, //pushback
    // back to mesh (readback data)
    output reg 	    access_out,
    output [PW-1:0] packet_out, 
    input 	    wait_in   //pushback
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
   wire 	    wait_random; //TODO: make random  
   wire 	    wait_all;
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	data_in;		// From p2e of packet2emesh.v
   wire [1:0]		datamode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From p2e of packet2emesh.v
   wire			write_in;		// From p2e of packet2emesh.v
   // End of automatics
   
   packet2emesh #(.AW(AW),
		  .PW(PW))
   p2e (/*AUTOINST*/
	// Outputs
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[4:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]),
	// Inputs
	.packet_in			(packet_in[PW-1:0]));
   
      
   //Access-in
   assign en     =  access_in & ~wait_all & ~wait_all;
   assign mem_rd = (access_in & ~write_in & ~wait_all);   


   //Pushback Circuit (pass through problems?)
   assign wait_all = (wait_random | wait_in);
   assign wait_out = wait_all;// & access_in
   
   //Address-in (shifted by three bits, 64 bit wide memory)
   assign addr[MAW-1:0] = dstaddr_in[MAW+2:3];     

   //Shift up
   assign  din_aligned[DW-1:0] = (datamode_in[1:0]==2'b00) ? {(4){data_in[7:0]}}  :
			  	 (datamode_in[1:0]==2'b01) ? {(2){data_in[15:0]}} :	
 			                                     data_in[31:0];
   
   //Data-in (hardoded width)
   assign din[63:0] =(datamode_in[1:0]==2'b11) ? {srcaddr_in[31:0],din_aligned[31:0]}:
		                                 {din_aligned[31:0],din_aligned[31:0]};
   //Write mask
   //TODO: make module
   always@*
     casez({write_in, datamode_in[1:0],dstaddr_in[2:0]})
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
   defparam mem.DW=64;
   defparam mem.DEPTH=DEPTH;		   
   oh_memory_sp mem(
		    // Inputs
		    .clk (clk),
		    .en	 (en),
		    .we  (write_in),
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
   		    .vddm     (1'b1),
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
       access_out <=1'b0;   
     else
       begin
	  access_out          <= mem_rd;
	  write_out           <= 1'b1;
          align_addr[2:0]     <= dstaddr_in[2:0];
	  datamode_out[1:0]   <= datamode_in[1:0];
	  ctrlmode_out[4:0]   <= ctrlmode_in[4:0];                  
          dstaddr_out[AW-1:0] <= srcaddr_in[AW-1:0];
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
   emesh2packet #(.AW(AW),
		  .PW(PW)) 
   e2p (
	/*AUTOINST*/
	// Outputs
	.packet_out			(packet_out[PW-1:0]),
	// Inputs
	.write_out			(write_out),
	.datamode_out			(datamode_out[1:0]),
	.ctrlmode_out			(ctrlmode_out[4:0]),
	.dstaddr_out			(dstaddr_out[AW-1:0]),
	.data_out			(data_out[AW-1:0]),
	.srcaddr_out			(srcaddr_out[AW-1:0]));
      

`ifdef TARGET_SIM
   generate
      if(MON)
	begin
	   emesh_monitor #(.PW(PW), 
			   .INDEX(1), 
			   .NAME(NAME),
			   .IDW(IDW)
			   )
	   emesh_monitor (.dut_access	(access_in & write_in),
			  .dut_packet	(packet_in[PW-1:0]),
			  .wait_in	(wait_random),
			  /*AUTOINST*/
			  // Inputs
			  .clk			(clk),
			  .nreset		(nreset),
			  .coreid		(coreid[IDW-1:0]));
	end // if (MON)      
   endgenerate
`endif
    
   //Random wait generator   //TODO: make this a module
   generate
      if(WAIT)
	begin	   
	   reg [8:0] wait_counter;  
	   always @ (posedge clk or negedge nreset)
	     if(!nreset)
	       wait_counter[8:0] <= 'b0;   
	     else
	       wait_counter[8:0] <= wait_counter+1'b1;         
	   assign wait_random      = (|wait_counter[5:0]);//(|wait_counter[3:0]);//1'b0;
	end
      else
	begin
	   assign wait_random = 1'b0;
	end // else: !if(WAIT)
   endgenerate
  
   
endmodule // emesh_memory
// Local Variables:
// verilog-library-directories:("." "../dv" )
// End:



