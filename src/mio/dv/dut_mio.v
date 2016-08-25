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
   parameter N       =  1;        // number of slices 
   parameter AW      =  32;       // address width
   parameter IOW     =  64;       // IO data width
   parameter PW      =  104;      // standard packet   
   parameter DEF_CFG =  18'h0010; // 16 bit interface, sdr mode   
   parameter DEF_CLK =  7;   
   
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

   //########################################
   //# BODY
   //########################################

   //wires
   wire 	     reg_access_in;   
   wire [PW-1:0]     reg_packet_in;
   wire 	     reg_wait_in;
   wire 	     mio_access_in;
   
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
   wire [IOW-1:0]	tx_packet;		// From mio of mio.v
   // End of automatics
 
   
   assign dut_active       = 1'b1;
   assign clkout           = clk1;

   //########################################
   //# DECODE (SPLITTING CTRL+DATA)
   //########################################

   //hack: send to regfile if addr[31:20] is zero
   assign mio_access_in    = access_in & |packet_in[39:28];
   assign reg_access_in    = access_in & ~(|packet_in[39:28]);   
   assign reg_packet_in    = packet_in;
   assign reg_wait_in      = wait_in;

   //########################################
   //# DUT: MIO IN LOOPBACK
   //########################################
    
   /*mio  AUTO_TEMPLATE (
            .io_clk         (io_clk),
            .clk	    (clk1),
	    .rx_clk	    (tx_clk),
	    .rx_access	    (tx_access),
            .rx_packet	    (tx_packet[IOW-1:0]),
            .tx_packet	    (tx_packet[IOW-1:0]),
	    .tx_wait        (rx_wait),
            .access_in	    (mio_access_in),
         
    );
    */
   
   mio #(.AW(AW),
	 .IOW(IOW),
	 .PW(PW),
	 .DEF_CFG(DEF_CFG),
	 .DEF_CLK(DEF_CLK))
   mio (/*AUTOINST*/
	// Outputs
	.tx_clk				(tx_clk),
	.tx_access			(tx_access),
	.tx_packet			(tx_packet[IOW-1:0]),	 // Templated
	.rx_wait			(rx_wait),
	.wait_out			(wait_out),
	.access_out			(access_out),
	.packet_out			(packet_out[PW-1:0]),
	.reg_wait_out			(reg_wait_out),
	.reg_access_out			(reg_access_out),
	.reg_packet_out			(reg_packet_out[PW-1:0]),
	// Inputs
	.clk				(clk1),			 // Templated
	.nreset				(nreset),
	.tx_wait			(rx_wait),		 // Templated
	.rx_clk				(tx_clk),		 // Templated
	.rx_access			(tx_access),		 // Templated
	.rx_packet			(tx_packet[IOW-1:0]),	 // Templated
	.access_in			(mio_access_in),	 // Templated
	.packet_in			(packet_in[PW-1:0]),
	.wait_in			(wait_in),
	.reg_access_in			(reg_access_in),
	.reg_packet_in			(reg_packet_in[PW-1:0]),
	.reg_wait_in			(reg_wait_in));
   
     
endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../common/hdl" "../../emesh/dv" "../../emesh/hdl")
// End:

