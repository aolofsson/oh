/* Simple combinatorial priority arbiter
 * (lowest position has highest priority)
 *
 */

module arbiter_priority(/*AUTOARG*/
   // Outputs
   grant, await,
   // Inputs
   request
   );
   
   parameter ARW=99;
       
   input  [ARW-1:0] request;  //request vector
   output [ARW-1:0] grant;    //grant (one hot)
   output [ARW-1:0] await;    //grant mask
   
   genvar j;
   assign await[0]   = 1'b0;   
   generate for (j=ARW-1; j>=1; j=j-1) begin : gen_arbiter     
      assign await[j] = |request[j-1:0];
   end
   endgenerate

   //grant circuit
   assign grant[ARW-1:0] = request[ARW-1:0] & ~await[ARW-1:0];

   
endmodule // arbiter_priority

