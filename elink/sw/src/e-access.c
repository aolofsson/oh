#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <fcntl.h>

//TODO: Remove globals?
unsigned page_size = 0;
int      mem_fd = -1;

void usage();
void e_debug_unmap(void *ptr);
int e_debug_read(unsigned addr, unsigned *data);
int e_debug_write(unsigned addr, unsigned data);
int e_debug_map(unsigned addr, void **ptr, unsigned *offset);

//########################################################################
//# "Epiphany Access Function"
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
    if(write){
	e_debug_write(dstaddr,data);
    }
    else{
	e_debug_read(dstaddr, &rdata);
	printf("%08x\n", rdata);
    }
}

//############################################
//# Function Help
//############################################
void usage(){
    printf("Usage: e-access <packet>\n");
    printf("Example: 00000000_76543210_82000000_05\n");
    return;
}

//############################################
//# Read from device
//############################################
int e_debug_read(unsigned addr, unsigned *data) {

  int  ret;
  unsigned offset;
  char *ptr;

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

