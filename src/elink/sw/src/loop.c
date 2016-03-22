#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <fcntl.h>

#define N              1000000000  //length of loop
#define ELINK_VERSION  0x1         //Set to 0 for 2015.1 version 
                                   //Set to 1 for 2015.12 version

//Declarations
void usage();

//LOOP TEST
int main(int argc, char *argv[]){
  unsigned int i;
  unsigned int dstaddr;
  unsigned int data,rdata;

  //Init
  e_debug_init(ELINK_VERSION);
  
  //Access
  dstaddr=0x80800000;
  for (i=0;i<N;i++){
    data=i;
    if(!(i%100000)){
      printf("LOOP(%d)\n",i);
    }
    e_debug_write(dstaddr,data);
    e_debug_read(dstaddr, &rdata);
    if(rdata!=data){
      printf ("LOOP %d: ERROR %08x != %08x\n", i, data, rdata); 
      break;
    }
  }
}
