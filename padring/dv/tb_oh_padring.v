module testbench();

   parameter NO_GPIO = 8;
   parameter SO_GPIO = 8;
   parameter EA_GPIO = 8;
   parameter WE_GPIO = 8;

   parameter NO_DOMAINS = 2;
   parameter SO_DOMAINS = 2;
   parameter EA_DOMAINS = 2;
   parameter WE_DOMAINS = 2;


   // Beginning of automatic inputs (from unused autoinst inputs)
   wire [EA_GPIO*8-1:0] ea_cfg;		// To i0 of oh_padring.v
   wire [EA_GPIO-2:0]	ea_dout;		// To i0 of oh_padring.v
   wire [EA_GPIO-1:0]	ea_ie;			// To i0 of oh_padring.v
   wire [EA_GPIO-1:0]	ea_oen;			// To i0 of oh_padring.v
   wire [NO_GPIO*8-1:0] no_cfg;		// To i0 of oh_padring.v
   wire [NO_GPIO-2:0]	no_dout;		// To i0 of oh_padring.v
   wire [NO_GPIO-1:0]	no_ie;			// To i0 of oh_padring.v
   wire [NO_GPIO-1:0]	no_oen;			// To i0 of oh_padring.v
   wire [SO_GPIO*8-1:0] so_cfg;		// To i0 of oh_padring.v
   wire [SO_GPIO-2:0]	so_dout;		// To i0 of oh_padring.v
   wire [SO_GPIO-1:0]	so_ie;			// To i0 of oh_padring.v
   wire [SO_GPIO-1:0]	so_oen;			// To i0 of oh_padring.v
   wire [WE_GPIO*8-1:0] we_cfg;		// To i0 of oh_padring.v
   wire [WE_GPIO-2:0]	we_dout;		// To i0 of oh_padring.v
   wire [WE_GPIO-1:0]	we_ie;			// To i0 of oh_padring.v
   wire [WE_GPIO-1:0]	we_oen;			// To i0 of oh_padring.v
   // End of automatics
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [EA_GPIO-1:0]	ea_din;			// From i0 of oh_padring.v
   wire [EA_GPIO-1:0]	ea_pad;			// To/From i0 of oh_padring.v
   wire [EA_DOMAINS-1:0] ea_vddio;		// To/From i0 of oh_padring.v
   wire [EA_DOMAINS-1:0] ea_vssio;		// To/From i0 of oh_padring.v
   wire [NO_GPIO-1:0]	no_din;			// From i0 of oh_padring.v
   wire [NO_GPIO-1:0]	no_pad;			// To/From i0 of oh_padring.v
   wire [NO_DOMAINS-1:0] no_vddio;		// To/From i0 of oh_padring.v
   wire [NO_DOMAINS-1:0] no_vssio;		// To/From i0 of oh_padring.v
   wire [SO_GPIO-1:0]	so_din;			// From i0 of oh_padring.v
   wire [SO_GPIO-1:0]	so_pad;			// To/From i0 of oh_padring.v
   wire [SO_DOMAINS-1:0] so_vddio;		// To/From i0 of oh_padring.v
   wire [SO_DOMAINS-1:0] so_vssio;		// To/From i0 of oh_padring.v
   wire			vdd;			// To/From i0 of oh_padring.v
   wire			vss;			// To/From i0 of oh_padring.v
   wire [WE_GPIO-1:0]	we_din;			// From i0 of oh_padring.v
   wire [WE_GPIO-1:0]	we_pad;			// To/From i0 of oh_padring.v
   wire [WE_DOMAINS-1:0] we_vddio;		// To/From i0 of oh_padring.v
   wire [WE_DOMAINS-1:0] we_vssio;		// To/From i0 of oh_padring.v
   // End of automatics

   oh_padring   #(.TYPE("SOFT"),
		  .NO_DOMAINS(NO_DOMAINS),
		  .NO_GPIO(NO_GPIO),
		  .SO_DOMAINS(SO_DOMAINS),
		  .SO_GPIO(SO_GPIO),
		  .EA_DOMAINS(EA_DOMAINS),
		  .EA_GPIO(EA_GPIO),
		  .WE_DOMAINS(WE_DOMAINS),
		  .WE_GPIO(WE_GPIO))
   i0 (/*AUTOINST*/
       // Outputs
       .no_din				(no_din[NO_GPIO-1:0]),
       .so_din				(so_din[SO_GPIO-1:0]),
       .ea_din				(ea_din[EA_GPIO-1:0]),
       .we_din				(we_din[WE_GPIO-1:0]),
       // Inouts
       .vss				(vss),
       .vdd				(vdd),
       .no_vddio			(no_vddio[NO_DOMAINS-1:0]),
       .no_vssio			(no_vssio[NO_DOMAINS-1:0]),
       .no_pad				(no_pad[NO_GPIO-1:0]),
       .so_vddio			(so_vddio[SO_DOMAINS-1:0]),
       .so_vssio			(so_vssio[SO_DOMAINS-1:0]),
       .so_pad				(so_pad[SO_GPIO-1:0]),
       .ea_vddio			(ea_vddio[EA_DOMAINS-1:0]),
       .ea_vssio			(ea_vssio[EA_DOMAINS-1:0]),
       .ea_pad				(ea_pad[EA_GPIO-1:0]),
       .we_vddio			(we_vddio[WE_DOMAINS-1:0]),
       .we_vssio			(we_vssio[WE_DOMAINS-1:0]),
       .we_pad				(we_pad[WE_GPIO-1:0]),
       // Inputs
       .no_dout				(no_dout[NO_GPIO-1-1:0]),
       .no_cfg				(no_cfg[NO_GPIO*8-1:0]),
       .no_ie				(no_ie[NO_GPIO-1:0]),
       .no_oen				(no_oen[NO_GPIO-1:0]),
       .so_dout				(so_dout[SO_GPIO-1-1:0]),
       .so_cfg				(so_cfg[SO_GPIO*8-1:0]),
       .so_ie				(so_ie[SO_GPIO-1:0]),
       .so_oen				(so_oen[SO_GPIO-1:0]),
       .ea_dout				(ea_dout[EA_GPIO-1-1:0]),
       .ea_cfg				(ea_cfg[EA_GPIO*8-1:0]),
       .ea_ie				(ea_ie[EA_GPIO-1:0]),
       .ea_oen				(ea_oen[EA_GPIO-1:0]),
       .we_dout				(we_dout[WE_GPIO-1-1:0]),
       .we_cfg				(we_cfg[WE_GPIO*8-1:0]),
       .we_ie				(we_ie[WE_GPIO-1:0]),
       .we_oen				(we_oen[WE_GPIO-1:0]));
   
   initial
     begin
	$dumpvars;     
	#1000 $finish;    
     end

   
endmodule // top
// Local Variables:
// verilog-library-directories:("."  "../hdl") 
// End:
