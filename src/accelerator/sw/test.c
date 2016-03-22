#include <stdio.h>

#define REG_INPUT0 0x810f0000
#define REG_INPUT1 0x810f0004
#define REG_OUTPUT 0x810f0008

//Hello World Test
int main(int argc, char *argv[])
{
    unsigned int data,rdata;
    
    //Write data to accelerator
    data=2;
    e_write(REG_INPUT0,data);
    data=3;
    e_write(REG_INPUT1,data);
    
    //read back result
    e_read(REG_OUTPUT, &rdata);
    printf ("RESULT=%d\n", rdata);         
}
