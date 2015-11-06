module pi2c (/*AUTOARG*/
   // Outputs
   i2c_sda_i, i2c_scl_i,
   // Inouts
   i2c_sda, i2c_scl,
   // Inputs
   i2c_sda_o, i2c_sda_t, i2c_scl_o, i2c_scl_t
   );

   parameter PORTABLE = 0;
      
   input  i2c_sda_o;
   input  i2c_sda_t;
   output i2c_sda_i;
   
   input  i2c_scl_o;
   input  i2c_scl_t;
   output i2c_scl_i;
   
   inout  i2c_sda;
   inout  i2c_scl;
   
   generate
      if(PORTABLE==1) begin
	 wire   i2c_sda = i2c_sda_t ? 1'bz: i2c_sda_o;
	 wire   i2c_sda_i = i2c_sda;
	 
	 wire   i2c_scl = i2c_scl_t ? 1'bz : i2c_scl_o;
	 wire   i2c_scl_i = i2c_scl;
      end
      else
	begin
	   IOBUF #(
		   .DRIVE(8),              // Specify the output drive strength
		   .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
		   .IOSTANDARD("DEFAULT"), // Specify the I/O standard
		   .SLEW("SLOW")           // Specify the output slew rate
		   ) i_sda (
			    .O(i2c_sda_i),  // Buffer output
			    .IO(i2c_sda),   // Buffer inout port (connect directly to top-level port)
			    .I(i2c_sda_o),  // Buffer input
			    .T(i2c_sda_t)   // 3-state enable input, high=input, low=output
			    );
	   
	   IOBUF #(
		   .DRIVE(8),
		   .IBUF_LOW_PWR("TRUE"),
		   .IOSTANDARD("DEFAULT"),
		   .SLEW("SLOW")   
		   ) i_scl (
			    .O(i2c_scl_i),
			    .IO(i2c_scl), 
			    .I(i2c_scl_o),
			    .T(i2c_scl_t) 
			    );
	end
   endgenerate
      
endmodule // pi2c




