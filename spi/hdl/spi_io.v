module spi_io(/*AUTOARG*/
   // Outputs
   ss_sel,
   // Inouts
   sclk, mosi, miso, ss
   );

   //##############################################################
   //#INTERFACE
   //###############################################################
   parameter N = 1;      // number of slave selects supported
      
   //SPI IO interface
   inout          sclk;   // serial clk
   inout          mosi;   // master output / slave input
   inout          miso;   // master input / slave output  
   inout          ss;     // primary slave select master/slave
   output [N-2:0] ss_sel; // extra slave selects in master mode

   //master side
   input          m_mclk;   //master  clock
   input          m_mosi;   //master output
   input [N-1:0]  m_ss;     //slave select
   output         m_miso;   //master input

   //slave side
   output        s_mclk;   //slave clock
   output 	 s_mosi;   //slave input
   output        s_ss;     //slave select
   input 	 s_miso;   //slave output

   //place IO buffers
   
   
 	      
endmodule // spi_io



