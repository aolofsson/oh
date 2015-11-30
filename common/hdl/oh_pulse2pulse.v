// FUNCTION: Transfers a pulse on clkin domain to a pulse on clkout domain
// !!!WARNING: "din" pulse width must be greater than clkout width!!!

module oh_pulse2pulse(/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   nrstin, din, clkin, nrstout, clkout
   );
      
   //input clock domain
   input  nrstin;  //input domain reset   
   input  din;     //input pulse (one clock cycle)
   input  clkin;   //input clock

   //output clock domain
   input  nrstout; //output domain reset  
   input  clkout;  //output clock       
   output dout;    //output pulse (one clock cycle)

  
   reg toggle_reg;
   reg pulse_reg;   
   wire toggle;
   
   //pulse to toggle
   assign toggle = din ? ~toggle_reg : toggle_reg;
   
   always @ (posedge clkin)
     if(~nrstin)
       toggle_reg <= 1'b0;
     else
       toggle_reg <= toggle;
   
   
   //metastability synchronizer
   oh_dsync #(1) sync(.dout	(toggle_sync),
		      .din      (toggle),
		      .clk      (clkout)
		      );
   
   //toogle to pulse
   always @ (posedge clkout)
     if(!nrstout)
       pulse_reg <= 1'b0;
     else
       pulse_reg <= toggle_sync;

   assign dout = pulse_reg ^ toggle_sync;
   
endmodule // oh_pulse2pulse


