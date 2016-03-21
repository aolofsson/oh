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


   //wires
   wire 	     reg_access_in;   
   wire [PW-1:0]     reg_packet_in;
   wire [7:0] 	     datasize;
   wire [3:0] 	     divcfg;   
   wire [7:0] 	     clkdiv;
  
   /*AUTOINPUT*/
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			reg_access_out;		// From mio of mio.v
   wire [PW-1:0]	reg_packet_out;		// From mio of mio.v
   wire			reg_wait_out;		// From mio of mio.v
   wire			rx_wait;		// From mio of mio.v
   wire			tx_access;		// From mio of mio.v
   wire			tx_clk;			// From mio of mio.v
   wire [NMIO-1:0]	tx_packet;		// From mio of mio.v
   // End of automatics
 
   
   assign dut_active       = 1'b1;
   assign datasize[CW-1:0] = PW/(2*NMIO);
   assign divcfg           = 4'b1;   
   assign clkout           = clk1;
   assign reg_access_in    = 'b0;
   assign reg_packet_in    = 'b0;
   assign reg_wait_in      =  wait_in;

   //########################################
   //# DUT: MIO IN LOOPBACK
   //########################################
    
   /*mio  AUTO_TEMPLATE (
            .io_clk         (io_clk),
            .clk	    (clk1),
	    .rx_clk	    (tx_clk),
	    .rx_access	    (tx_access),
            .rx_packet	    (tx_packet[NMIO-1:0]),
            .tx_packet	    (tx_packet[NMIO-1:0]),
	    .tx_wait        (rx_wait),
            .reg_access_in  (reg_access_in),
	    .reg_packet_in  (reg_packet_in[PW-1:0]),
	    .reg_wait_in    (wait_in),
    );
    */
   
   mio mio (/*AUTOINST*/
	    // Outputs
	    .tx_clk			(tx_clk),
	    .tx_access			(tx_access),
	    .tx_packet			(tx_packet[NMIO-1:0]),	 // Templated
	    .rx_wait			(rx_wait),
	    .wait_out			(wait_out),
	    .access_out			(access_out),
	    .packet_out			(packet_out[PW-1:0]),
	    .reg_wait_out		(reg_wait_out),
	    .reg_access_out		(reg_access_out),
	    .reg_packet_out		(reg_packet_out[PW-1:0]),
	    // Inputs
	    .clk			(clk1),			 // Templated
	    .nreset			(nreset),
	    .tx_wait			(rx_wait),		 // Templated
	    .rx_clk			(tx_clk),		 // Templated
	    .rx_access			(tx_access),		 // Templated
	    .rx_packet			(tx_packet[NMIO-1:0]),	 // Templated
	    .access_in			(access_in),
	    .packet_in			(packet_in[PW-1:0]),
	    .wait_in			(wait_in),
	    .reg_access_in		(reg_access_in),	 // Templated
	    .reg_packet_in		(reg_packet_in[PW-1:0]), // Templated
	    .reg_wait_in		(wait_in));		 // Templated
   

  

     
endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../common/hdl" "../../emesh/dv" "../../emesh/hdl")
// End:

