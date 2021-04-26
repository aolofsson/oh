/* Aligns data before writing.
 * Incoming data is aligned to lsb's
 */ 
module emesh_wralign (/*AUTOARG*/
   // Outputs
   data_out,
   // Inputs
   datamode, data_in
   );

   input  [1:0]    datamode;
   input  [63:0]   data_in;
   output [63:0]   data_out;

   wire [3:0] data_size;
      
   assign data_size[0]= (datamode[1:0]==2'b00);//byte
   assign data_size[1]= (datamode[1:0]==2'b01);//short
   assign data_size[2]= (datamode[1:0]==2'b10);//word
   assign data_size[3]= (datamode[1:0]==2'b11);//double

   //B0(0)
   assign data_out[7:0]   = data_in[7:0];

   //B1(16 NAND2S,8 NOR2S)
   assign data_out[15:8]  = {(8){data_size[0]}}      & data_in[7:0]   |
                            {(8){(|data_size[3:1])}} & data_in[15:8] ;
   
   //B2(16 NAND2S,8 NOR2S)
   assign data_out[23:16] = {(8){(|data_size[1:0])}} & data_in[7:0]   |
                            {(8){(|data_size[3:2])}} & data_in[23:16] ; 

   //B3(24 NAND2S,8 NOR3S)
   assign data_out[31:24] = {(8){data_size[0]}}      & data_in[7:0]   |
                            {(8){data_size[1]}}      & data_in[15:8]  |
                            {(8){(|data_size[3:2])}} & data_in[31:24] ; 
   
   //B4(24 NAND2S,8 NOR3S)
   assign data_out[39:32] = {(8){(|data_size[2:0])}} & data_in[7:0]   |
                            {(8){data_size[3]}}      & data_in[39:32] ;

   //B5(24 NAND2S,8 NOR3S)
   assign data_out[47:40] = {(8){data_size[0]}}      & data_in[7:0]   |
                            {(8){(|data_size[2:1])}} & data_in[15:8]  |
                            {(8){data_size[3]}}      & data_in[47:40] ;

   //B6(24 NAND2S,8 NOR3S)
   assign data_out[55:48] = {(8){(|data_size[1:0])}} & data_in[7:0]   |
                            {(8){data_size[2]}}      & data_in[23:16] |
                            {(8){data_size[3]}}      & data_in[55:48] ;
   
   //B7(32 NAND2S,16 NOR2S)
   assign data_out[63:56] = {(8){data_size[0]}}      & data_in[7:0]   |
                            {(8){data_size[1]}}      & data_in[15:8]  |
                            {(8){data_size[2]}}      & data_in[31:24] |
                            {(8){data_size[3]}}      & data_in[63:56] ;

endmodule // memory_wralign



