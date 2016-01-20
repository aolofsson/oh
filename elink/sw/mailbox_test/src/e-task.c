
/*A bare minimum self test function function */
#include <e-lib.h>
#include "common.h"
#include <string.h>

int main(void){
  unsigned int volatile *mailbox= (int *) 0x810F0730;  
  unsigned int volatile *dram= (int *) 0x8e000000;  

  *mailbox  = 0x11111111;
  *mailbox  = 0x22222222;
  *mailbox  = 0x33333333;
  *mailbox  = 0x44444444;
  *mailbox  = 0x55555555;
  *mailbox  = 0x66666666;
  *mailbox  = 0x77777777;


  *(dram+0) = 0xaaaaaaaa;
  *(dram+1) = 0xbbbbbbbb;
  *(dram+2) = 0xcccccccc;
  *(dram+3) = 0xdddddddd;
  *(dram+4) = 0xeeeeeeee;

}
