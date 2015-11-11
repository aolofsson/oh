#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <fcntl.h>

#define ELINK_VERSION  0x1        //Set to 0 for 2015.1 version 
                                  //Set to 1 for 2015.12 version

//Declarations
void usage();

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
