module dut(/*AUTOARG*/
   // Outputs
   dut_active, clkout, wait_out, access_out, packet_out,
   // Inputs
   clk1, clk2, nreset, vdd, vss, access_in, packet_in, wait_in
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter N     =  1;   
   parameter AW    = 32;               // address width
   parameter CPW   = `CFG_MIOPW;       // data width (core)
   parameter MIOW  = `CFG_MIOW;        // IO data width
   localparam PW   = 2*AW + 40;        // standard packet   
   localparam CW   = $clog2(2*PW/MIOW);// transfer count width
   
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

   wire [CW-1:0]     datasize;
   wire [3:0] 	     divcfg;
   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			io_clk;			// From oh_clockdiv of oh_clockdiv.v
   wire			rx_wait;		// From mio of mio.v
   wire			tx_access;		// From mio of mio.v
   wire			tx_clk;			// From oh_clockdiv of oh_clockdiv.v
   wire [MIOW-1:0]	tx_packet;		// From mio of mio.v
   // End of automatics
    
  
   wire [CPW-1:0]    dut_packet_in;
   wire [CPW-1:0]    dut_packet_out;


   assign dut_active       = 1'b1;
   assign datasize[CW-1:0] = CPW/(2*MIOW);
   assign divcfg           = 4'b1;   
   assign clkout           = clk1;

   assign dut_packet_in    = packet_in;
   assign packet_out       = dut_packet_out;
   
   //########################################
   //# DUT: MIO IN LOOPBACK
   //########################################
   /*oh_clockdiv  AUTO_TEMPLATE (
    .divcfg		(divcfg[3:0]), 
    .en			(1'b1),
    .clkout		(io_clk),
    .clkout90		(tx_clk),
    .clk		(clk2),
    );
    */

   oh_clockdiv oh_clockdiv(
			   /*AUTOINST*/
			   // Outputs
			   .clkout		(io_clk),	 // Templated
			   .clkout90		(tx_clk),	 // Templated
			   // Inputs
			   .clk			(clk2),		 // Templated
			   .en			(1'b1),		 // Templated
			   .nreset		(nreset),
			   .divcfg		(divcfg[3:0]));	 // Templated
   

   
   /*mio  AUTO_TEMPLATE (
            .io_clk         (io_clk),
            .clk	    (clk1),
	    .rx_clk	    (tx_clk),
	    .rx_access	    (tx_access),
            .rx_packet	    (tx_packet[MIOW-1:0]),
	    .tx_wait        (rx_wait),
    );
    */
   
   mio mio (
	    .packet_in			(dut_packet_in[CPW-1:0]),
	    .packet_out			(dut_packet_out[CPW-1:0]),
	    /*AUTOINST*/
	    // Outputs
	    .tx_access			(tx_access),
	    .tx_packet			(tx_packet[MIOW-1:0]),
	    .rx_wait			(rx_wait),
	    .wait_out			(wait_out),
	    .access_out			(access_out),
	    // Inputs
	    .clk			(clk1),			 // Templated
	    .io_clk			(io_clk),		 // Templated
	    .nreset			(nreset),
	    .datasize			(datasize[CW-1:0]),
	    .tx_wait			(rx_wait),		 // Templated
	    .rx_clk			(tx_clk),		 // Templated
	    .rx_access			(tx_access),		 // Templated
	    .rx_packet			(tx_packet[MIOW-1:0]),	 // Templated
	    .access_in			(access_in),
	    .wait_in			(wait_in));
   
     
endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../common/hdl" "../../emesh/dv" "../../emesh/hdl")
// End:

