#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <fcntl.h>

unsigned page_size = 0;
int      mem_fd = -1;

//Declarations
int e_map(unsigned addr, void **ptr, unsigned *offset);
void e_unmap(void *ptr);
int e_read(unsigned addr, unsigned *data);
int e_write(unsigned addr, unsigned data);

//############################################
//# Read from device
//############################################
int e_read(unsigned addr, unsigned *data) {

  int  ret;
  unsigned offset;
  char *ptr;

  //Map device into memory
  ret = e_map(addr, (void **)&ptr, &offset);

  //Read value from the device register  
  *data = *((unsigned *)(ptr + offset));

  //Unmap device memory
  e_unmap(ptr);

  return 0;
}
//############################################
//# Write to device
//############################################
int e_write(unsigned addr, unsigned data) {
  int  ret;
  unsigned offset;
  char *ptr;

  //Map device into memory
  ret = e_map(addr, (void **)&ptr, &offset);

  //Write to register
  *((unsigned *)(ptr + offset)) = data;

  //Unmap device memory
  e_unmap(ptr);

  return 0;
}

//############################################
//# Map Memory Using Generic Epiphany driver
//############################################
int e_map(unsigned addr, void **ptr, unsigned *offset) {

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
void e_unmap(void *ptr) {
  
    //Unmap memory
    if(ptr && page_size){
	munmap(ptr, page_size);
    }
}
