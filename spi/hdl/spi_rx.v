module spi_rx(/*AUTOARG*/
   // Outputs
   access, rxdata,
   // Inputs
   nreset, clk, cpol, cpha, sclk, mosi, miso, ss
   );

   //##############################################################
   //#INTERFACE
   //###############################################################
    
   //clk,reset
   input 	      clk;          // core clock
   
   //config
   input 	      master_mode;  // spi in master mode
   
   //IO interface
   input 	      sclk;         // serial clock
   input 	      mosi;         // slave input (from master)
   input 	      miso;         // slave output (to master)
   input 	      ss_master;    // slave select
   input 	      ss_slave;     // slave select

   //data received
   output 	      access_out;   // write fifo   
   output [7:0]       packet_out;   // data for fifo
                                    // (synchronized to clk)


 
   //##############################################################
   //#BODY
   //###############################################################
   reg [7:0] 	      spi_state;
   reg [7:0] 	      spi_rx;
   
   //master/slave configuration

   assign ss  = master_mode ? ss_master : ss_slave;
   assign din = master_mode ? miso : miso;
   
   //state machine
   always @ (posedge sclk)
     if(~ss) // slave select works as reset
       spi_state[7:0]  <= 8'b1;   
     else if(byte_transfer)
       spi_state[7:0]  <= 8'b1;   
     else if(~ss)
       spi_state[7:0]  <= {spi_state[6:0],1'b0};
   
   assign byte_transfer = spi_state[7];

   //rx shift register
    always @ (posedge sclk)
      if(~ss)
	spi_rx[7:0] <= {spi_rx[6:0],din};

   assign access_out     =  byte_transfer;
   assign packet_out[7:0] = spi_rx[7:0];
   
   
endmodule // spi_rx




