/*The Epiphany memory model assumes the following alignment on incoming transactions*/ 

//Byte Mode:
//ADDR[2:0]   B7 B6 B5 B4  B3 B2 B1 B0
//x00         0  0  0  MB0 0  0  0  MB0
//x01         0  0  0  MB1 0  0  0  MB1
//x10         0  0  0  MB2 0  0  0  MB2
//x11         0  0  0  MB3 0  0  0  MB3

//Short Mode:
//ADDR[2:0]   B7 B6 B5  B4  B3 B2 B1  B0
//x00         0  0  MB1 MB0 0  0  MB1 MB0
//x10         0  0  MB3 MB2 0  0  MB3 MB2

//Word Mode:
//ADDR[2:0]   B7  B6  B5  B4  B3  B2  B1  B0
//x00         MB3 MB2 MB1 MB0 MB3 MB2 MB1 MB0

//Double Mode:
//ADDR[2:0]   B7  B6  B5  B4  B3  B2  B1  B0
//000         MB7 MB6 MB5 MB4 MB3 MB2 MB1 MB0

module emesh_rdalign (/*AUTOARG*/
   // Outputs
   data_out,
   // Inputs
   datamode, addr, data_in
   );

   parameter DW = 32;

   //Inputs
   input  [1:0]      datamode;
   input  [2:0]      addr;
   input  [2*DW-1:0] data_in;

   //Outputs
   output [DW-1:0]   data_out;


   //wires
   wire [DW-1:0] data_low;


   //wires
   /* verilator lint_off UNOPTFLAT */     
   wire [3:0]      byte0_sel;
   /* verilator lint_on UNOPTFLAT */
   wire [3:0]      byte1_sel;
   wire [3:0]      byte2_sel;
   wire [3:0]      byte3_sel;
   wire [31:0]     data_mux;
   wire [31:0]     data_aligned;
   
   assign data_mux[31:0] = ((addr[2] & (datamode[1:0]!=2'b11))) ? data_in[2*DW-1:DW] : data_in[DW-1:0];
  
   
   //Byte0
   assign    byte0_sel[3] = datamode[1:0]==2'b00 & addr[1:0]==2'b11;

   assign    byte0_sel[2] = datamode[1:0]==2'b00 & addr[1:0]==2'b10 |
	                    datamode[1:0]==2'b01 & addr[1:0]==2'b10;

   assign    byte0_sel[1] = datamode[1:0]==2'b00 & addr[1:0]==2'b01;

   assign    byte0_sel[0] = ~(|byte0_sel[3:1]);   
  
   
   //Byte1
   assign    byte1_sel[1] = (datamode[1:0]==2'b01 & addr[1:0]==2'b00) |
	                     datamode[1:0]==2'b10                     | 
			     datamode[1:0]==2'b11;

   assign    byte1_sel[3] = datamode[1:0]==2'b01 & addr[1:0]==2'b10;

   assign    byte1_sel[2] = 1'b0;
   assign    byte1_sel[0] = 1'b0;
   

   //Byte2
   assign    byte2_sel[2] = datamode[1:0]==2'b10 | 
			    datamode[1:0]==2'b11;

   assign    byte2_sel[3] = 1'b0;
   assign    byte2_sel[1] = 1'b0;
   assign    byte2_sel[0] = 1'b0;
   
   //Byte3
   assign    byte3_sel[3]   = datamode[1:0]==2'b10 | 
			      datamode[1:0]==2'b11;

   assign    byte3_sel[2]   = 1'b0;
   assign    byte3_sel[1]   = 1'b0;
   assign    byte3_sel[0]   = 1'b0;
   
   //Alignment for lower 32 bits(upper 32 bits don't need alignment)

   //B0: 32 NANDs,8 NORS
   assign data_aligned[7:0]   = {(8){byte0_sel[3]}} & data_mux[31:24] |
	                        {(8){byte0_sel[2]}} & data_mux[23:16] |
	                        {(8){byte0_sel[1]}} & data_mux[15:8]  |
	                        {(8){byte0_sel[0]}} & data_mux[7:0];
   //B1:
   assign data_aligned[15:8]  = {(8){byte1_sel[3]}} & data_mux[31:24] |
	                        {(8){byte1_sel[1]}} & data_mux[15:8];

   //B2: 8 NANDS
   assign data_aligned[23:16] = {(8){byte2_sel[2]}} & data_mux[23:16];
   
   //B3: 
   assign data_aligned[31:24] = {(8){byte3_sel[3]}} & data_mux[31:24];
   
   assign data_out[DW-1:0]  = data_aligned[DW-1:0];

endmodule // emesh_rdalign



