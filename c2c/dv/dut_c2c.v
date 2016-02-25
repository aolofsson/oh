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
   parameter PW    = 104;             // standard p
   parameter CPW   = `C2C_PW;         // data width (core)
   parameter IOW   = `C2C_IOW;        // IO data width
   localparam CW   = $clog2(2*PW/IOW);// transfer count width
   
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

   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			rx_wait;		// From c2c of c2c.v
   wire			tx_access;		// From c2c of c2c.v
   wire			tx_clk;			// From c2c of c2c.v
   wire [IOW-1:0]	tx_packet;		// From c2c of c2c.v
   // End of automatics
    
   assign dut_active       = 1'b1;
   assign datasize[CW-1:0] = CPW/(2*IOW);
   assign clkout           = clk1;
   wire [CPW-1:0]    dut_packet_in;
   wire [CPW-1:0]    dut_packet_out;
   assign dut_packet_in = packet_in;
   assign packet_out = dut_packet_out;
   
   //########################################
   //# DUT: C2C IN LOOPBACK
   //########################################

   /*c2c  AUTO_TEMPLATE (
             .io_clk         (clk),
	    .rx_clk	    (tx_clk),
	    .rx_access	    (tx_access),
            .rx_packet	    (tx_packet[IOW-1:0]),
	    .tx_wait        (rx_wait),
    );
    */
   
   c2c c2c (.divcfg			(4'b1), //divide by 2
	    .clk			(clk1),
	    .io_clk			(clk2),
	    .packet_in			(dut_packet_in[CPW-1:0]),
	    .packet_out			(dut_packet_out[CPW-1:0]),
	    /*AUTOINST*/
	    // Outputs
	    .tx_access			(tx_access),
	    .tx_packet			(tx_packet[IOW-1:0]),
	    .tx_clk			(tx_clk),
	    .wait_out			(wait_out),
	    .rx_wait			(rx_wait),
	    .access_out			(access_out),
	    // Inputs
	    .nreset			(nreset),
	    .tx_wait			(rx_wait),		 // Templated
	    .access_in			(access_in),
	    .datasize			(datasize[CW-1:0]),
	    .rx_clk			(tx_clk),		 // Templated
	    .rx_access			(tx_access),		 // Templated
	    .rx_packet			(tx_packet[IOW-1:0]),	 // Templated
	    .wait_in			(wait_in));
   
     
endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/dv" "../../emesh/hdl")
// End:

