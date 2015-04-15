module ereset (/*AUTOARG*/
   // Outputs
   reset, chip_resetb,
   // Inputs
   hard_reset, soft_reset
   );

   //inputs
   input 	hard_reset;        // hardware reset from external block
   input 	soft_reset;        // soft reset drive by register (level)

   //outputs
   output 	reset;             //reset for elink
   output       chip_resetb;       //reset for epiphany
 
   //Reset for link logic
   assign reset    = hard_reset | soft_reset;

   //May become more sophisticated later..
   //(for example, for epiphany reset, you might want to include some
   //some hard coded logic to avoid reset edge errata)
   //also, for multi chip boards, since the coordinates are sampled on
   //the rising edge of chip_resetb it may be beneficial to have one
   //reset per chip and to stagger the 

   assign chip_resetb =  ~(hard_reset | soft_reset); 
   
endmodule // ereset

