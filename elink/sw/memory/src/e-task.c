
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

#define _BuffSize   (0x2000) // 0x10 + 5 freezes
#define _NoMessages (5) // 0x100 + 4 freezes
// 0x2000 + 10 freezes with various PC counters reported.
//#define _SharedBuffOffset (0x1000000)
#define _LocalBuffOffset (0x5000)
//following clears the test buffer! so instead use hard coded value
//char shared[_BuffSize] SECTION("shared_dram");
char *shared = (char*)0x8f000000;
char *local = (char*)0x5000;

void checkandupdate(int count, void *message, int size, int * location, int *failures, char * errorval, char * check, char *val);

int main(void){

  int count;
  int *mailbox = (int *) MAILBOX_ADDR;
  char sharedval = 0;
  char localval = 0;
  char sharedcheck = 0xff; //_BuffSize - 1;
  char localcheck = sharedcheck;
  int localfailures = 0;
  int sharedfailures = 0;
  char localfailure = 0;
  char sharedfailure = 0;
  int locallocation = 0;
  int sharedlocation = 0;

  long long message; 

  char * dst;

  for (count=0; count<_BuffSize/8; count++)
  {
	  // Read/Write from/to local memory
	  dst = (char*)(_LocalBuffOffset + count*sizeof(message));
	  e_read(&e_group_config, &message, 0,0, dst, sizeof(message));

	  // Limit the number of samples sent to the mailbox!
	  if (_NoMessages>count) e_memcopy(mailbox, &message, sizeof(message));
	  
	  checkandupdate(count, (void*)&message, sizeof(message), &localfailures, &locallocation, &localfailure, &localcheck, &localval);

	  e_write(&e_group_config, &message, 0,0, dst, sizeof(message));
	  
	  // Read/Write from/to shared memory
	  dst = (char*)(shared + count*sizeof(message));
	  e_memcopy((void *)&message, (void *)dst, sizeof(message));

	  // Limit the number of samples sent to the mailbox!
	  if (_NoMessages>count) e_memcopy(mailbox, &message, sizeof(message));
	  
	  checkandupdate(count, (void*)&message, sizeof(message), &sharedfailures, &sharedlocation, &sharedfailure, &sharedcheck, &sharedval);
	  
	  // Write to shared memory
	  e_memcopy((void *)dst, (void *)&message, sizeof(message));
  }

  //message = 0;
  message = 0xfedcba9876543210;
  //message = (long long)dst; - 0xffffffff8f000ff8

  // message = (long long)&message; - 0x7fc0
  // message = (long long)&shared - 0xffffffff8f000000
  // message = (long long)&shared[_BuffSize];- 0xffffffff8f001000
  
  for (count = 0; count<_NoMessages; count++)
  {
    e_memcopy(mailbox, &message, sizeof(message));
    //message++;
  }

  // In last message report the number of read failures
  message = (long long)sharedlocation;
  message = message << 16;
  //message += (long long)sharedfailure;
  //message = message << 16;
  message += (long long)sharedfailures;
  message = message << 16;
  message += (long long)locallocation;
  message = message << 16;
  message += (long long)localfailures;
  e_memcopy(mailbox, &message, sizeof(message));
}

void checkandupdate(int count, void *message, int size, int * failures, int * location, char * errorval, char * check, char * val)
{
	int index;
	char *pos;
	
	pos = (char*) message;
	for (index=0; index<size; index++)
	{
		if (*check != *pos)
		{
			(*failures)++;
			if (0xff==*failures)
			{
			*location = count * size + index;
			//*errorval = *pos;
			*errorval = *check;
			}
		}

		  // update with write value
		  *pos = *val;
		  pos++;
		  (*val)++;
		  (*check)--;
	  }
}
