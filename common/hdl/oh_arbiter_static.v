/* Simple combinatorial priority arbiter
 * bit[0] has highest priority
 *
 */

module oh_arbiter_static(/*AUTOARG*/
   // Outputs
   grants,
   // Inputs
   requests
   );
   
   parameter N=99;
       
   input  [N-1:0] requests;  //request vector
   output [N-1:0] grants;    //grant (one hot)
   
   genvar 	  j;
   wire [N-1:0]   waitmask;
      
   assign waitmask[0]   = 1'b0;   
   generate for (j=N-1; j>=1; j=j-1) 
     begin : gen_arbiter     
	assign waitmask[j] = |requests[j-1:0];
     end
   endgenerate

   //grant circuit
   assign grants[N-1:0] = requests[N-1:0] & ~waitmask[N-1:0];
   
endmodule // oh_arbiter_priority


