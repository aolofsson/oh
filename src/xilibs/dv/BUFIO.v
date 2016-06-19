/*###########################################################################
 *#An I/O clock buffer
 *########################################################################### 
 * 
 * BUIOs can drive:
 * -a single I/O clock network in the same region/bank
 * 
 * BUIOs can be driven by:
 * -SRCCs and MRCCs in the same clock region
 * -MRCCs in an adjacent clock region using BUFMRs
 * -MMCMs clock outputs 0-3 driving the HPC in the same clock region
 *
 * 
 * Input to Output Delay (Zynq7010/7020): 1.61/1.32/1.16 (-1/-2/-3 grade) 
 * 
 * 
 */ 


module BUFIO (/*AUTOARG*/
   // Outputs
   O,
   // Inputs
   I
   );

   output O;
   input  I;
    
   assign O=I;
     
endmodule
