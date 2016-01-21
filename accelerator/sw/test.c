#include <stdio.h>

//Hello World Test
int main(int argc, char *argv[])
{
    unsigned int data,rdata;
    
    //Write data to accelerator
    data=2;
    e_write(0x810f0000,data);
    data=3;
    e_write(0x810f0004,data);
    
    //read back result
    e_read(0x810f0008, &rdata);
    printf ("RESULT=%dn", rdata);         
}
