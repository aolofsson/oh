#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <fcntl.h>
#include "elink_regs.h"

#define EPIPHANY_BASE  0x80800000
#define ELINK_BASE     0x81000000 //Not used for now
#define ELINK_VERSION  0x1        //Set to 0 for 2015.1 version 
                                  //Set to 1 for 2015.12 version

#define COREADDR(a,b)  ((a << 26) | ( b << 20))

//TODO: Remove globals?
unsigned page_size = 0;
int      mem_fd = -1;

//Declarations
void usage();
void e_debug_unmap(void *ptr);
int e_debug_read(unsigned addr, unsigned *data);
int e_debug_write(unsigned addr, unsigned data);
int e_debug_map(unsigned addr, void **ptr, unsigned *offset);
void e_debug_init(int version);

//########################################################################
//# "Epiphany Access Function (e-access)"
//# Decodes a 104 bit packet and sends transaction to elink
//#########################################################################

int main(int argc, char *argv[]){
    unsigned int dstaddr, data, srcaddr,command, ctrlmode, datamode,write;
    unsigned int rdata;
    int ret;
    if(argc < 2){
	usage();
	return EXIT_FAILURE;
    }
    else{
	sscanf (argv[1],"%x_%x_%x_%x",&srcaddr,&data,&dstaddr,&command); 
    }
    //Parse command field
    write    = command & 0x01;
    ctrlmode = (command & 0xF8)>>3;//TODO:implement
    datamode = (command & 0x06)>>1;//TODO:implement later
    
    //Init
    e_debug_init(ELINK_VERSION);

    //Access
    if(write){
	e_debug_write(dstaddr,data);
    }
    else{
	e_debug_read(dstaddr, &rdata);
	printf("[%08x]=0x%08x\n",dstaddr,rdata);
    }
}

//############################################
//# Function Help
//############################################
void usage(){
    printf("Usage: e-access <packet>\n");
    printf("Ex: 00000000_76543210_80800000_05\n");
    return;
}

//############################################
//# Read from device
//############################################
int e_debug_read(unsigned addr, unsigned *data) {

  int  ret;
  unsigned offset;
  char *ptr;

  //Debug
  printf("read addr=%08x data=%08x\n", addr, *data);
  fflush(stdout);

  //Map device into memory
  ret = e_debug_map(addr, (void **)&ptr, &offset);

  //Read value from the device register  
  *data = *((unsigned *)(ptr + offset));

  //Unmap device memory
  e_debug_unmap(ptr);

  return 0;
}
//############################################
//# Write to device
//############################################
int e_debug_write(unsigned addr, unsigned data) {
  int  ret;
  unsigned offset;
  char *ptr;

  //Debug
  printf("write addr=%08x data=%08x\n", addr, data);
  fflush(stdout);
  //Map device into memory
  ret = e_debug_map(addr, (void **)&ptr, &offset);

  //Write to register
  *((unsigned *)(ptr + offset)) = data;

  //Unmap device memory
  e_debug_unmap(ptr);

  return 0;
}

//############################################
//# Map Memory Using Generic Epiphany driver
//############################################
int e_debug_map(unsigned addr, void **ptr, unsigned *offset) {

  unsigned page_addr; 

  //What does this do??
  if(!page_size)
    page_size = sysconf(_SC_PAGESIZE);

  //Open /dev/mem file if not already
  if(mem_fd < 1) {
    mem_fd = open ("/dev/epiphany", O_RDWR);
    if (mem_fd < 1) {
      perror("f_map");
      return -1;
    }
  }

  //Get page address
  page_addr = (addr & (~(page_size-1)));

  if(offset != NULL)
    *offset = addr - page_addr;

  //Perform mmap
  *ptr = mmap(NULL, page_size, PROT_READ|PROT_WRITE, MAP_SHARED, 
	      mem_fd, page_addr);

  //Check for errors
  if(*ptr == MAP_FAILED || !*ptr)
      return -2;
  else
      return 0;
}	

//#########################################
//# Unmap Memory
//#########################################
void e_debug_unmap(void *ptr) {
  
    //Unmap memory
    if(ptr && page_size){
	munmap(ptr, page_size);
    }
}

//#########################################
//# Initalize elink
//# Type:
//# 0 = jan 2015 release ("Fred's")
//# 1 = nov 2015 version ("Andreas'")
//#########################################
void e_debug_init(int version){

  unsigned int data;  

  if(version==0){
    //Assert Reset
    data = 0x1; 
    e_debug_write(E_SYS_RESET, data);
    usleep(1000);

    //Disable TX
    data = 0x0; 
    e_debug_write(E_SYS_CFGTX, data);
    usleep(1000);

    //Disable RX
    data = 0x0; 
    e_debug_write(E_SYS_CFGRX, data);
    usleep(1000);

    //Enable CCLK at full speed
    data = 0x7; 
    e_debug_write(E_SYS_CFGCLK, data);
    usleep(1000);

    //Stop Clock
    data = 0x0; 
    e_debug_write(E_SYS_CFGCLK, data);
    usleep(1000);

    //Deassert Reset
    data = 0x0; 
    e_debug_write(E_SYS_RESET, data);
    usleep(1000);

    //Start Clock
    data = 0x7; 
    e_debug_write(E_SYS_CFGCLK, data);
    usleep(1000);
    
    //Start TX LCLK and enable link
    data = 0x1;
    e_debug_write(E_SYS_CFGTX, data);
    usleep(1000);
    
    //Enable RX
    data = 0x1;
    e_debug_write(E_SYS_CFGRX, data);
    usleep(1000);
    
    //Reduce Epiphany Elink TX to half speed
    data = 0x51;
    e_debug_write(E_SYS_CFGTX, data);//set ctrlmode
    usleep(1000);
    data = 0x1;
    e_debug_write((EPIPHANY_BASE + COREADDR(2,3) + E_REG_LINKMODE), data);//set half speed
    usleep(1000);
    data = 0x1;
    e_debug_write(E_SYS_CFGTX, data);//set ctrlmode back to normal
    usleep(1000);
  }
  else{   
    //Do nothing! Access should be raw, no side effects!
    //Keep the old one there for now, too long a recipe
  }
}
