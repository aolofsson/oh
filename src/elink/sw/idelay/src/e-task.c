
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

int main(void){

  int *dram   = (int*)0x8e000000;  
  int *local  = (int*)0x2000;  
  int *result = (int*)0x4000;  
  int *pass   = (int*)0x8e000000;    //overwrite the sync ivt entry on exit
  int i;

  //ZERO DATA
  for (i=0;i<2048;i++){
    *(result+i)=0xDEADBEEF;
  }
  //EXPECTED RESULTS
  for (i=0;i<N;i++){
    *(local+i) =0x55550000+i;
  }
  //WRITE TO DRAM  
  e_memcopy(dram, local, N*sizeof(int));

  //READ FROM DRAM
  e_memcopy(result,dram, N*sizeof(int));

  int fail=0;
  for (i=0;i<N;i++){
    if(*(result+i)!=(0x55550000+i)){
      fail=fail+1;
    }
  }
  
  if(fail==0){
    //PRINT SUCCESS IF PASSED
    *pass = 0x12345678;
  }
  else{
    *pass = 0xFFFFFFFF;//-1
  }
  //Write how many failed
  *(pass+1) =  fail;
  //while(1);
}
