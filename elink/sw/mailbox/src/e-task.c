
/*A bare minimum self test function function */
#include <e-lib.h>
#include "common.h"
#include <string.h>

#define USE_DMA 1
#ifdef USE_DMA
#define e_memcopy(dst, src, size) e_dma_copy(dst, src, size)
#else
#define e_memcopy(dst, src, size) memcpy(dst, src, size)
#endif

#define MAILBOX_ADDR 0x810F0320

int main(void){

  int *mailbox= (int *) MAILBOX_ADDR;  

  long long message = 0xfedcba9876543210; 

  e_memcopy(mailbox, &message, sizeof(message));
  
}
