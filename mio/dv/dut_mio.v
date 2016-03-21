module dut(/*AUTOARG*/
   // Outputs
   emode, dstaddr, dmode, ddr_mode, amode, dut_active, clkout,
   wait_out, access_out, packet_out,
   // Inputs
   clk1, clk2, nreset, vdd, vss, access_in, packet_in, wait_in,
   clkphase0, clkphase1
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter N     =  1;   
   parameter AW    = 32;               // address width
   parameter NMIO =  8;                // IO data width
   localparam PW   = 2*AW + 40;        // standard packet   
   localparam CW   = $clog2(2*PW/NMIO);// transfer count width
   
   //clock, reset
   input            clk1;
   input            clk2;
   input            nreset;
   input [N*N-1:0]  vdd;
   input 	    vss;
   output 	    dut_active;
   output 	    clkout;
   
   //Stimulus Driven Transaction
   input [N-1:0]     access_in;
   input [N*PW-1:0]  packet_in;
   output [N-1:0]    wait_out;

   //DUT driven transactoin
   output [N-1:0]    access_out;
   output [N*PW-1:0] packet_out;
   input [N-1:0]     wait_in;

   wire [7:0] 	     datasize;
   wire [3:0] 	     divcfg;   
   wire [7:0] 	     clkdiv;
   input [15:0]      clkphase0;
   input [15:0]      clkphase1;

   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		amode;			// From mio_regs of mio_regs.v
   output		ddr_mode;		// From mio_regs of mio_regs.v
   output		dmode;			// From mio_regs of mio_regs.v
   output [AW-1:0]	dstaddr;		// From mio_regs of mio_regs.v
   output		emode;			// From mio_regs of mio_regs.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			io_clk;			// From oh_clockdiv of oh_clockdiv.v
   wire			lsbfirst;		// From mio_regs of mio_regs.v
   wire			rx_empty;		// From mio of mio.v
   wire			rx_en;			// From mio_regs of mio_regs.v
   wire			rx_full;		// From mio of mio.v
   wire			rx_prog_full;		// From mio of mio.v
   wire			rx_wait;		// From mio of mio.v
   wire			tx_access;		// From mio of mio.v
   wire			tx_clk;			// From oh_clockdiv of oh_clockdiv.v
   wire			tx_empty;		// From mio of mio.v
   wire			tx_en;			// From mio_regs of mio_regs.v
   wire			tx_full;		// From mio of mio.v
   wire [NMIO-1:0]	tx_packet;		// From mio of mio.v
   wire			tx_prog_full;		// From mio of mio.v
   // End of automatics
      
   assign dut_active       = 1'b1;
   assign datasize[CW-1:0] = PW/(2*NMIO);
   assign divcfg           = 4'b1;   
   assign clkout           = clk1;

   /*
   assign clkdiv           = 8'h07;                            // (divide by N-1)
   assign clkphase0        = {((clkdiv+8'd1)>>8'd1),8'd0};
   assign clkphase1        = {((clkdiv+8'd1)>>8'd2)+((clkdiv+8'd1)>>8'd1),
			      ((clkdiv+8'd1)>>8'd2)};   
    */
       
   //########################################
   //# DUT: MIO IN LOOPBACK
   //########################################
   /*oh_clockdiv  AUTO_TEMPLATE (
    .divcfg		(divcfg[3:0]), 
    .en			(1'b1),
    .clkout0     	(io_clk),
    .clkout1		(tx_clk),
    .clk		(clk2),
    );
    */

   oh_clockdiv oh_clockdiv(
			   .clken		(nreset), 
			   .clkrise0		(),
			   .clkfall0		(),
			   .clkrise1		(),
			   .clkfall1		(),
			   /*AUTOINST*/
			   // Outputs
			   .clkout0		(io_clk),	 // Templated
			   .clkout1		(tx_clk),	 // Templated
			   // Inputs
			   .clk			(clk2),		 // Templated
			   .nreset		(nreset),
			   .clkdiv		(clkdiv[7:0]),
			   .clkphase0		(clkphase0[15:0]),
			   .clkphase1		(clkphase1[15:0]));
   

   
   /*mio  AUTO_TEMPLATE (
            .io_clk         (io_clk),
            .clk	    (clk1),
	    .rx_clk	    (tx_clk),
	    .rx_access	    (tx_access),
            .rx_packet	    (tx_packet[NMIO-1:0]),
            .tx_packet	    (tx_packet[NMIO-1:0]),
	    .tx_wait        (rx_wait),
    );
    */
   
   mio mio (.ddr_mode			(1'b1),
	    /*AUTOINST*/
	    // Outputs
	    .tx_full			(tx_full),
	    .tx_prog_full		(tx_prog_full),
	    .tx_empty			(tx_empty),
	    .rx_full			(rx_full),
	    .rx_prog_full		(rx_prog_full),
	    .rx_empty			(rx_empty),
	    .tx_access			(tx_access),
	    .tx_packet			(tx_packet[NMIO-1:0]),	 // Templated
	    .rx_wait			(rx_wait),
	    .wait_out			(wait_out),
	    .access_out			(access_out),
	    .packet_out			(packet_out[PW-1:0]),
	    // Inputs
	    .clk			(clk1),			 // Templated
	    .io_clk			(io_clk),		 // Templated
	    .nreset			(nreset),
	    .datasize			(datasize[7:0]),
	    .lsbfirst			(lsbfirst),
	    .tx_en			(tx_en),
	    .rx_en			(rx_en),
	    .tx_wait			(rx_wait),		 // Templated
	    .rx_clk			(tx_clk),		 // Templated
	    .rx_access			(tx_access),		 // Templated
	    .rx_packet			(tx_packet[NMIO-1:0]),	 // Templated
	    .access_in			(access_in),
	    .packet_in			(packet_in[PW-1:0]),
	    .wait_in			(wait_in));
   

   /*mio_regs  AUTO_TEMPLATE (
            .clk         (clk1),
    );
    */
   
   mio_regs #(.AW(AW))
   mio_regs (/*AUTOINST*/
	     // Outputs
	     .wait_out			(wait_out),
	     .access_out		(access_out),
	     .packet_out		(packet_out[PW-1:0]),
	     .tx_en			(tx_en),
	     .rx_en			(rx_en),
	     .ddr_mode			(ddr_mode),
	     .emode			(emode),
	     .amode			(amode),
	     .dmode			(dmode),
	     .datasize			(datasize[7:0]),
	     .lsbfirst			(lsbfirst),
	     .dstaddr			(dstaddr[AW-1:0]),
	     .clkdiv			(clkdiv[7:0]),
	     // Inputs
	     .clk			(clk1),			 // Templated
	     .nreset			(nreset),
	     .access_in			(access_in),
	     .packet_in			(packet_in[PW-1:0]),
	     .wait_in			(wait_in),
	     .clkphase0			(clkphase0[15:0]),
	     .clkphase1			(clkphase1[15:0]),
	     .tx_full			(tx_full),
	     .tx_prog_full		(tx_prog_full),
	     .tx_empty			(tx_empty),
	     .rx_full			(rx_full),
	     .rx_prog_full		(rx_prog_full),
	     .rx_empty			(rx_empty));
   

     
endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../common/hdl" "../../emesh/dv" "../../emesh/hdl")
// End:

