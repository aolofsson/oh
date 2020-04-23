/******************************************************************************
 * Function:  Results Checker
 * Author:    Andreas Olofsson                                                
 * Copyright: (c) 2020 Adapteva, Inc. All rights reserved.
 * ----------------------------------------------------------------------------
 * License: This file contains confidential and proprietary information of
 * Adapteva. No part of this file may be reproduced, transmitted, 
 * transcribed, stored in a retrieval system, or translated into any human or 
 * computer language, in any form or by any means, electronic, mechanical, 
 * magnetic, optical, chemical, manual, or otherwise, without prior written 
 * permission of Adapteva. This software may only be used in accordance with 
 * the terms and conditions of a signed license agreement with Adateva. All 
 * other use, reproduction or distribution of this software is 
 * strictly prohibited. 
 * ----------------------------------------------------------------------------
 * 
 *****************************************************************************/

module dv_checker 
   (
    //Inputs 
    input 	   clk,
    input 	   nreset,
    input [DW-1:0] result, // result to check
    input [DW-1:0] reference, // reference result
    output 	   fail, //fail indicator
    );

   reg 		   fail;
   always @ (negedge clk or negedge nreset)
     if(~nreset)
       fail <= 1'b0;   
     else  if(result!==reference)
       begin
	  fail <= 1'b1;	  
	  $display("ERROR(%0t): result=%b reference=%b", result, reference);
       end	 
endmodule // dv_checker
