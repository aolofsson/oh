
module oh_nand2 
  #(parameter NMODEL          = "nmos",		  
    parameter PMODEL          = "pmos",	  
    parameter integer W[3:0]  = {0,1,2,3},
    parameter integer L[3:0]  = {0,1,2,3},
    parameter integer M[3:0]  = {1,1,2,4},
    parameter integer NF[3:0] = {1,2,4,8}
    )
   ( 
     input  vdd,
     input  vss,
     input  a,
     input  b, 
     output z
     );
   
   wire     inet;
 
   // Topology
   oh_nmos m0 (.d(inet),.g(a),.s(vss), .bulk(vss));   
   oh_nmos m1 (.d(z),   .g(b),.s(inet),.bulk(vss));
   oh_pmos m2 (.d(z),   .g(a),.s(vdd), .bulk(vdd));
   oh_pmos m3 (.d(z),   .g(b),.s(vdd), .bulk(vdd));
   
   // Driving Parameters
   defparam m0.MODEL = NMODEL;   
   defparam m0.W     = W[0];   
   defparam m0.L     = L[0];
   defparam m0.M     = M[0];
   defparam m0.NF    = NF[0];

   defparam m1.MODEL = NMODEL;   
   defparam m1.W     = W[1];   
   defparam m1.L     = L[1];
   defparam m1.M     = M[1];
   defparam m1.NF    = NF[1];

   defparam m2.MODEL = PMODEL;   
   defparam m2.W     = W[2];   
   defparam m2.L     = L[2];
   defparam m2.M     = M[2];
   defparam m2.NF    = NF[2];

   defparam m3.MODEL = PMODEL;   
   defparam m3.W     = W[3];   
   defparam m3.L     = L[3];
   defparam m3.M     = M[3];
   defparam m3.NF    = NF[3];
   
endmodule


