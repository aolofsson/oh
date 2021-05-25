
module oh_pmos #(parameter MODEL = "pmos",
		 parameter W     = "0",
		 parameter L     = "0",
		 parameter M     = "0",
		 parameter NF    = "0"
		 )
   (
    input  bulk,
    input  g,
    input  s,
    inout  d
    );

   //out,in,ctrlr
   pmos p (d,s,g);
   
   // Debug information
`ifdef OH_DEBUG
   initial
     begin
	$display("inst=%m model=%s w=%0d l=%0d m=%0d nf=%0d",
		 MODEL,W,L,M,NF);	  
     end
`endif
      
endmodule
		
