//#############################################################################
//# Function: 2 Input Nand Gate                                               #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         # 
//#############################################################################

module oh_nand2 
  #(parameter SIM               = "rtl", 
    parameter NMODEL            = "nmos",		  
    parameter PMODEL            = "pmos",
    parameter N                 = 4,
    parameter integer W[N-1:0]  = '{0, 0, 0, 0}, //nanometers
    parameter integer L[N-1:0]  = '{0, 0, 0, 0}, //nanometers
    parameter integer M[N-1:0]  = '{1, 1, 1, 1}, 
    parameter integer NF[N-1:0] = '{1, 1, 1, 1}
    )
   (
    input  vdd,
    input  vss, 
    input  a,
    input  b, 
    output z
    );

   generate
      if(SIM=="rtl") 
	begin
	   assign z = ~(a & b);
	end
      else
	begin
	   wire     inet;

	   oh_nmos #(.MODEL(NMODEL),.W(W[0]),.L(L[0]),.M(M[0]), .NF(NF[0])) 
	   m0 (.d(inet), .g(a), .s(vss), .bulk(vss));   	   

	   oh_nmos #(.MODEL(NMODEL),.W(W[1]),.L(L[1]),.M(M[1]), .NF(NF[1])) 
	   m1 (.d(z), .g(b), .s(inet), .bulk(vss));	   

	   oh_pmos #(.MODEL(PMODEL),.W(W[2]),.L(L[2]),.M(M[2]), .NF(NF[2]))  
	   m2 (.d(z), .g(a), .s(vdd), .bulk(vdd));

	   oh_pmos #(.MODEL(PMODEL),.W(W[3]),.L(L[3]),.M(M[3]), .NF(NF[3])) 
	   m3 (.d(z), .g(b), .s(vdd), .bulk(vdd));

	end
   endgenerate
   
endmodule
