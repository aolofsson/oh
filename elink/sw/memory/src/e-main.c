#include "common.h"

#include <stdlib.h>
#include <stdio.h>
#include <sys/epoll.h>
#include <sys/eventfd.h>
#include <string.h>
#include <e-hal.h>
#include <e-loader.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <ctype.h>
#include <err.h>
#include <errno.h>	// for errno
#include <stdint.h>
#include <assert.h>
#include <uapi/linux/epiphany.h> // for ioctl numbers

#define TAPS 64

// Stuff already defined somewhere else
#define E_REG_MESHCFG (0xF0700)
#define E_REG_ILATST (0xF042C)

//
#define E_SYS_TXSTATUS	(0xF0214)
#define E_SYS_TXMONITOR (0xF021c)
#define E_SYS_TXPACKET  (0xF0220)
#define E_SYS_RXSTATUS	(0xF0304)
#define E_SYS_RXIDELAY0 (0xF0310)
#define E_SYS_RXIDELAY1 (0xF0314)
#define EPIPHANY_DEV "/dev/epiphany"

#ifdef EPIPHANY_IOC_MB_ENABLE
typedef struct _MAILBOX_CONTROL
{
	int running;	// 1 if ready; otherwise not ready
	int devfd;	// handle for epiphany device driver
	int epollfd; 	// handle for blocking wait on notification
	int kernelEventfd;	// handle for kernel notification
	struct epoll_event *events;
	mailbox_notifier_t mailbox_notifier;
} mailbox_control_t;
static mailbox_control_t mc;
#endif

int InitialEpiphany(void);
void CloseEpiphany(void);
int InitialTestMessageStore(void);
void CloseTestMessageStore(void);
int InitialMailboxNotifier(void);
int OpenEpiphanyDevice(void);
int OpenKernelEventMonitor(void);
void CloseMailboxNotifier(void);
void CancelMailboxNotifier(void);
int WaitForMailboxNotifier(void);
void PrintStuffOfInterest(void);
int setup_system(void);
int my_reset_system(void);
void WriteTestPatternsToMemory(e_mem_t *emem, e_epiphany_t *dev);
void ReadTestPatternsFromMemory(e_mem_t *emem, e_epiphany_t *dev, int initval, int incr);
int CheckTestPatterns(int initval, int incr);

#define _BuffSize   (0x2000)
#define _SharedBuffOffset (0x1000000)
#define _LocalBuffOffset (0x5000)

static int Zero = 0;
static int UseInterrupts = 0; // interrupts 1 + 2000 + 10 bus errors!! with pc at various points
// interrupts 1 + 2000 + 9 freezes with pc 0xd1e, or 0xd2a or ...
static e_sys_rxcfg_t rxcfg         = { .reg = 0 };
static char emsg[_BuffSize];

static int idelay[TAPS]={0x00000000,0x00000000,//0
		  0x11111111,0x00000001,//1
		  0x22222222,0x00000002,//2
		  0x33333333,0x00000003,//3
		  0x44444444,0x00000004,//4
		  0x55555555,0x00000005,//5
		  0x66666666,0x00000006,//6
		  0x77777777,0x00000007,//7
		  0x88888888,0x00000008,//8
		  0x99999999,0x00000009,//9
		  0xaaaaaaaa,0x0000000a,//10
		  0xbbbbbbbb,0x0000000b,//11
		  0xcccccccc,0x0000000c,//12
		  0xdddddddd,0x0000000d,//13
		  0xeeeeeeee,0x0000000e,//14
		  0xffffffff,0x0000000f,//15
		  0x00000000,0x00000010,//16
		  0x11111111,0x00000011,//17
		  0x22222222,0x00000012,//18
		  0x33333333,0x00000013,//29
		  0x44444444,0x00000014,//20
		  0x55555555,0x00000015,//21
		  0x66666666,0x00000016,//22
		  0x77777777,0x00000017,//23
		  0x88888888,0x00000018,//24
		  0x99999999,0x00000019,//25
		  0xaaaaaaaa,0x0000001a,//26
		  0xbbbbbbbb,0x0000001b,//27
		  0xcccccccc,0x0000001c,//28
		  0xdddddddd,0x0000001d,//29
		  0xeeeeeeee,0x0000001e,//30
		  0xffffffff,0x0000001f};//31

int main(int argc, char *argv[]){
  e_loader_diag_t e_verbose;
  e_platform_t platform;
  e_epiphany_t dev, *pdev;
  e_mem_t      dram, *pdram;
  size_t       size;
  int status=1;//pass
  char elfFile[4096];
  pdev  = &dev;
  pdram = &dram;
  int i,j;
  unsigned result[N];
  unsigned data = 0xDEADBEEF;
  unsigned tmp,fail;
  unsigned row, col, loopcount;
  int count;
   
  srand(time(NULL));
 
  if (UseInterrupts)
  {
	  // Initialize the Mailbox notifier
	  InitialMailboxNotifier();
  }
	
  //Gets ELF file name from command line
  strcpy(elfFile, "./bin/e-task.elf");

  //Initalize Epiphany device
  e_set_host_verbosity(H_D0);
  e_init(NULL);                      
  my_reset_system();
  e_get_platform_info(&platform);

  // Allocate memory in shared area
  e_mem_t emem;
  e_alloc(&emem, _SharedBuffOffset, _BuffSize);

  row = 0;
  col = 0;
  for (loopcount=0; loopcount<40; loopcount++)
  {
    // Setup system
    if (setup_system())
    {
	  break;
    }
    usleep(1000);
    
    // Draw a random core
    //row = rand() % platform.rows;
    //col = rand() % platform.cols;

    // Visit each core
    unsigned lastCol = col;
    col = col % platform.cols;

    if (col < lastCol)
    {
	row++;
	unsigned lastRow = row;
	row = row % platform.rows;

	if (row < lastRow)
	{
		break;
	}
    }
		
    if (!UseInterrupts)
    {
	    // Without interrupts
	    // For some reason fixed row and col is better
	    //row = 0;
	    //col = 0;

	    // With interrupts fixed row and col fails earlier!
    }
    
    printf("INFO: loopcount: %d, row: %d, col: %d\n", loopcount, row, col);

    e_open(&dev, row, col, 1, 1); //open core 0,0
    usleep(1000);
    e_reset_group(&dev);
    usleep(1000);
    
    if (UseInterrupts)
    {
	  // Configure epoll to listen for interrupt event
	  int rtn = ArmMailboxNotifier();
	  if (rtn)
	  {
		  int rtns = errno;
		  printf ("main(): EPOLL_CTL_ADD kernelEventfd failed! %s errno: %d\n", strerror(rtns), rtns);

		  break;
	  }

	  // Enable the mailbox interrupt
	  rxcfg.reg = rxcfg.reg | (0x1 << 28);

	  if (sizeof(int) != ee_write_esys(E_SYS_RXCFG, rxcfg.reg))
	  {
		  printf("main(): Failed set rxcfg register\n");
	  }
	  usleep(1000);
    }

    WriteTestPatternsToMemory(&emem, &dev);
    ReadTestPatternsFromMemory(&emem, &dev, 0xff, -1);

    // Read significant registers on the core
    printf("E_REG_ILATST: 0x%x\n", ee_read_reg(&dev, 0,0, E_REG_ILATST));
    printf("E_REG_MESHCFG: 0x%x\n", ee_read_reg(&dev, 0,0, E_REG_MESHCFG));
    printf("E_REG_MEMSTATUS: 0x%x\n", ee_read_reg(&dev, 0,0, E_REG_MEMSTATUS));
    printf("E_REG_CONFIG: 0x%x\n", ee_read_reg(&dev, 0,0, E_REG_CONFIG));
    printf("E_REG_PC: 0x%x\n", ee_read_reg(&dev, 0,0, E_REG_PC));
    printf("E_REG_FSTATUS: 0x%x\n", ee_read_reg(&dev, 0,0, E_REG_FSTATUS));
	    
    //Start program
    printf("main(%d,%d): Load core\n", row, col);
    if (e_load_group(elfFile, &dev, 0, 0, 1, 1, E_TRUE))
    {
	    break;
    }

        // Read significant registers on the core
    printf("E_REG_CONFIG: 0x%x\n", ee_read_reg(&dev, 0,0, E_REG_CONFIG));
    printf("E_REG_PC: 0x%x\n", ee_read_reg(&dev, 0,0, E_REG_PC));
    printf("E_REG_FSTATUS: 0x%x\n", ee_read_reg(&dev, 0,0, E_REG_FSTATUS));
    printf("E_REG_ILATST: 0x%x\n", ee_read_reg(&dev, 0,0, E_REG_ILATST));
    printf("E_REG_MESHCFG: 0x%x\n", ee_read_reg(&dev, 0,0, E_REG_MESHCFG));
    printf("E_REG_MEMSTATUS: 0x%x\n", ee_read_reg(&dev, 0,0, E_REG_MEMSTATUS));

    usleep(1000);
 
    printf("main(%d,%d): Core Loaded\n", row, col);

    // Setup system
    if (setup_system())
    {
	  break;
    }
        
    if (UseInterrupts)
    {
	  WaitForMailboxNotifier();
    }
    else
    {
	    for (count=0; count<40; count++)
	    {
                //Reading mailbox
		    int pre_stat    = ee_read_esys(0xF0328);
 
		    if (pre_stat)
		    {
			    break;
		    }
		    usleep(100000);
	    }
    }

    PrintStuffOfInterest();
    ReadTestPatternsFromMemory(&emem, &dev, 0x0, 1);
    
    for (count=0; count<40; count++)
    {
      //Reading mailbox
      int pre_stat    = ee_read_esys(0xF0328);
      int mbox_lo     = ee_read_esys(0xF0320);
      int mbox_hi     = ee_read_esys(0xF0324);
      int post_stat   = ee_read_esys(0xF0328);
      printf ("PRE_STAT=%08x POST_STAT=%08x LO=%08x HI=%08x\n", pre_stat, post_stat, mbox_lo, mbox_hi);
      
      if (!post_stat)
      {
	      if (mbox_lo) printf("ERROR: e-task 0x%x read errors for local memory, last error at 0x%x\n", mbox_lo & 0xffff, (mbox_lo>>16) & 0xffff);
	      if (mbox_hi) printf("ERROR: e-task 0x%x read errors for shared memory, last error at 0x%x\n", mbox_hi & 0xffff, (mbox_hi>>16) & 0xffff);
	      
	      break;
      }
    }

    e_close(&dev);
    usleep(1000);
    
    col++;
  }
  
  if (UseInterrupts)
  {
	  CloseMailboxNotifier();
  }

  e_free(&emem);

  //Close down Epiphany device
  e_finalize();
  
  //self check
  if(status){
    return EXIT_SUCCESS;
  }
  else{
    return EXIT_FAILURE;
  }   
}

int CheckTestPatterns(int initval, int incr)
{
    char val = initval;
    int count;
    int failures=0;
    int passes = 0;
    int reports = 0;

    for (count=0; count<_BuffSize; count++)
    {
      if (emsg[count] != val)
      {
	      failures++;
      }
      else
      {
	      passes++;
      }
      
      if (0<failures && 10>reports)
      {
	      printf("INFO: Read 0x%x, should be 0x%x\n", emsg[count], val);
	      reports++;
      }
      val += incr;
    }

    if (0<failures)
    {
	    printf("ERROR: 0x%x memory read failures, 0x%x passes\n", failures, passes);
    }

    return failures;
}

void ReadTestPatternsFromMemory(e_mem_t *emem, e_epiphany_t *dev, int initval, int incr)
{
    // read message from shared buffer.
    e_read(emem, 0, 0, (off_t)0x0, (void*)emsg, _BuffSize);
    
    if (CheckTestPatterns(initval, incr))
    {
	    printf("ERROR: Shared memory check failed!\n");
    }    

    // read message from local buffer.
    e_read(dev, 0, 0, (off_t)(_LocalBuffOffset), (void*)emsg, _BuffSize);

    if (CheckTestPatterns(initval, incr))
    {
	    printf("ERROR: Local memory check failed!\n");
    }
}

void WriteTestPatternsToMemory(e_mem_t *emem, e_epiphany_t *dev)
{
    char val = 0xff; //_BuffSize - 1;
    int count;
    int failures=0;
    int passes = 0;
    int reports = 0;

    for (count=0; count<_BuffSize; count++)
    {
	    emsg[count] = val;
	    val--;
    }

    // write message to shared buffer.
    e_write((void*)emem, 0, 0, (off_t)0x0, (void*)emsg, _BuffSize);

    // write message to local buffer.
    e_write((void*)dev, 0, 0, (off_t)(_LocalBuffOffset), (void*)emsg,  _BuffSize);
}

//////////////////////////////////////////////////////////////////////////////////////////////

int setup_system(void)
{
	int rc = 0;
	uint32_t divider;
	uint32_t chipid;
	e_sys_txcfg_t txcfg         = { .reg = 0 };
	e_sys_rx_dmacfg_t rx_dmacfg = { .reg = 0 };
	e_sys_clkcfg_t clkcfg       = { .reg = 0 };
	e_sys_reset_t resetcfg      = { .reg = 0 };
	e_epiphany_t dev;

#if 1 // ???
	chipid = 0x808 /* >> 2 */;
	if (sizeof(int) != ee_write_esys(E_SYS_CHIPID, chipid /* << 2 */))
		goto err;
	usleep(1000);
#endif

#if 1
	txcfg.enable = 1;
	txcfg.mmu_enable = 0;
	if (sizeof(int) != ee_write_esys(E_SYS_TXCFG, txcfg.reg))
		goto err;
	usleep(1000);
#endif

	rxcfg.testmode = 0; /* bug/(feature?) workaround */
	rxcfg.mmu_enable = 0;

	// I have no idea how this works!  mailbox data addressed to 810 -> 310??
	rxcfg.remap_cfg = 1; // "static" remap_addr
	rxcfg.remap_mask = 0xf00;
	rxcfg.remap_base = 0x300;//turn 8 into 3
	// But changing to this has no effect!
	//rxcfg.remap_mask = 0xff0;
	//rxcfg.remap_base = 0x810;//route all to 810
	if (sizeof(int) != ee_write_esys(E_SYS_RXCFG, rxcfg.reg))
		goto err;
	usleep(1000);

#if 0 // ?
	rx_dmacfg.enable = 1;
	if (sizeof(int) != ee_write_esys(E_SYS_RXDMACFG, rx_dmacfg.reg))
		goto err;
	usleep(1000);
#endif

	int delayNo = 7;
	if (sizeof(int) != ee_write_esys(E_SYS_RXIDELAY0, idelay[((delayNo+1)*2)-2]))
	{
		printf("ERROR: setting idelay0 failed\n");
		goto err;
	}

	if (sizeof(int) != ee_write_esys(E_SYS_RXIDELAY1, idelay[((delayNo+1)*2)-1]))
	{
		printf("ERROR: setting idelay1 failed\n");
		goto err;
	}

	rc = E_ERR;
	
	if ( E_OK != e_open(&dev, 2, 3, 1, 1) ) {
	  warnx("e_reset_system(): e_open() failure.");
	  goto err;
	}
	
	txcfg.ctrlmode = 0x5; /* Force east */
	txcfg.ctrlmode_select = 0x1; /* */
	usleep(1000);
	if (sizeof(int) != ee_write_esys(E_SYS_TXCFG, txcfg.reg))
	  goto cleanup_platform;
	
	//divider = 1; /* Divide by 4, see data sheet */
	divider = 0; /* Divide by 2, see data sheet */
	usleep(1000);
	if (sizeof(int) != e_write(&dev, 0, 0, E_REG_LINKCFG, &divider, sizeof(int)))
	  goto cleanup_platform;
	
	txcfg.ctrlmode = 0x0;
	txcfg.ctrlmode_select = 0x0; /* */
	usleep(1000);
	if (sizeof(int) != ee_write_esys(E_SYS_TXCFG, txcfg.reg))
	  goto cleanup_platform;

	rc = E_OK;
	
cleanup_platform:
	if (E_OK != rc) printf("e_reset_system(): fails\n");
	e_close(&dev);
	
	usleep(1000);
	return rc;

err:
	warnx("e_reset_system(): Failed\n");
	usleep(1000);
	return E_ERR;
}

int my_reset_system(void)
{
	int rc = 0;
	uint32_t divider;
	uint32_t chipid;
	e_sys_txcfg_t txcfg         = { .reg = 0 };
	e_sys_rx_dmacfg_t rx_dmacfg = { .reg = 0 };
	e_sys_clkcfg_t clkcfg       = { .reg = 0 };
	e_sys_reset_t resetcfg      = { .reg = 0 };
	e_epiphany_t dev;

#if 1
	resetcfg.reset = 1;
	if (sizeof(int) != ee_write_esys(E_SYS_RESET, resetcfg.reg))
		goto err;
	usleep(1000);

	/* Do we need this ? */
	resetcfg.reset = 0;
	if (sizeof(int) != ee_write_esys(E_SYS_RESET, resetcfg.reg))
		goto err;
	usleep(1000);
#endif

	return setup_system();

 err:
	warnx("e_reset_system(): Failed\n");
	usleep(1000);
	return E_ERR;
}

void PrintStuffOfInterest()
{
	// Print stuff of interest
	int etx_status = ee_read_esys(E_SYS_TXSTATUS);
	int etx_config = ee_read_esys(E_SYS_TXCFG);
	int erx_status = ee_read_esys(E_SYS_RXSTATUS);
	int erx_config = ee_read_esys(E_SYS_RXCFG);
	printf("INFO: etx_status: 0x%x, etx_config: 0x%x, erx_status: 0x%x, erx_config: 0x%x", etx_status, etx_config, erx_status, erx_config);

	int txmonitor = ee_read_esys(E_SYS_TXMONITOR);//TXMONITOR
	int packet    = ee_read_esys(E_SYS_TXPACKET);//TXPACKET
   
	printf(", TXMON=%d PACKET=0x%08x\n", txmonitor, packet);

    	ee_write_esys(E_SYS_TXSTATUS, Zero);//TXSTATUS
	ee_write_esys(E_SYS_TXMONITOR, Zero);//TXMONITOR
	ee_write_esys(E_SYS_RXSTATUS, Zero);//RXSTATUS
	
	//printf("E_REG_ILATST: 0x%x\n", ee_read_reg(dev, 0,0, E_REG_ILATST));
	//printf("E_REG_MESHCFG: 0x%x\n", ee_read_reg(dev, 0,0, E_REG_MESHCFG));
	//printf("E_REG_MEMSTATUS: 0x%x\n", ee_read_reg(dev, 0,0, E_REG_MEMSTATUS));
	//printf("E_REG_CONFIG: 0x%x\n", ee_read_reg(dev, 0,0, E_REG_CONFIG));
	//printf("E_REG_PC: 0x%x\n", ee_read_reg(dev, 0,0, E_REG_PC));
	//printf("E_REG_FSTATUS: 0x%x\n", ee_read_reg(dev, 0,0, E_REG_FSTATUS));
}

int InitialMailboxNotifier()
{
#ifdef EPIPHANY_IOC_MB_ENABLE
	int returns;
	
	mc.running = 0;

	// Open an epoll object
	mc.epollfd = epoll_create(1);
	if ( -1 == mc.epollfd ) {
		printf("InitialMailboxNotifier(): epoll open failure.");
		return E_ERR;
	}

	returns = OpenEpiphanyDevice();
	if (returns)
	{
		printf("InitialMailboxNotifier(): epiphany open failure.");
		close(mc.epollfd);
		return returns;
	}

	returns = OpenKernelEventMonitor();
	if (returns)
	{
		printf("InitialMailboxNotifier(): mailbox sysfs monitor open failure.");
		// Tidy up
		close(mc.devfd);
		close(mc.epollfd);
		return returns;
	}

	// Now allocate the event list
	mc.events = calloc(2, sizeof(struct epoll_event));
	if (NULL == mc.events)
	{
		printf("InitialMailboxNotifier(): malloc of event memory failure.");
		// Tidy up
		struct epoll_event event;
		epoll_ctl (mc.epollfd, EPOLL_CTL_DEL, mc.kernelEventfd, &event);
		close(mc.kernelEventfd);
		close(mc.devfd);
		close(mc.epollfd);
		return returns;
	}

	mc.running = 1;
	return returns;
#endif
	return 0;
}

int OpenEpiphanyDevice()
{
#ifdef EPIPHANY_IOC_MB_ENABLE
	// Now open the epiphany device for mailbox interrupt control
	mc.devfd = open(EPIPHANY_DEV, O_RDWR | O_SYNC);
	// printf ("OpenEpiphanyDevice(): mc.devfd %d\n", mc.devfd);
	if ( -1 == mc.devfd )
	{
		int rtn = errno;
		printf ("InitialMaiboxNotifier(): epiphany device open failed! %s errno %d\n", strerror(rtn), rtn);

		return E_ERR;
	}
#endif
	return 0;
}

int OpenKernelEventMonitor()
{
#ifdef EPIPHANY_IOC_MB_ENABLE
	int returns;
	char notifier[8];
	int notifierfd;
	int oldNotifier;

	// Open the kernel Event Notifier
	mc.kernelEventfd = eventfd(0, EFD_NONBLOCK);
	if ( -1 == mc.kernelEventfd )
	{
		int rtn = errno;
		printf ("InitialMailboxNotifier(): Kernel Event Notifier open failure! %s errno: %d\n", strerror(rtn), rtn);

		return E_ERR;
	}

	// Add the kernelEventfd handle to epoll
	returns = ModifyNotifier(mc.kernelEventfd, EPOLL_CTL_ADD);
	if (returns)
	{
		int rtn = errno;
		printf ("InitialMailboxNotifier(): EPOLL_CTL_ADD kernelEventfd failed! %s errno: %d kernelEventfd: %d\n", strerror(rtn), rtn, mc.kernelEventfd);

		// Tidy up
		close(mc.kernelEventfd);
		return rtn;
	}

	// Starting from scratch with no other application running
	// read the current kernel mailbox_notifier fd handle
	// If the current kernel mailbox_notifier fd handle is -1 there is no
	// other application using the mailbox.
	notifierfd = open(MAILBOX_NOTIFIER, O_RDONLY);
	oldNotifier = -1;
	if (0 < notifierfd)
	{
		int rtn = read(notifierfd, notifier, 8);

		// printf ("InitialMailboxNotifier(): returns: %d, Old notifier fd: %s\n", rtn, notifier);
		if (rtn)
		{
			sscanf(notifier, "%d", &oldNotifier);
		}

		close(notifierfd);
	}
	
	// Starting from scratch ignore other applications and override them
	// by passing the old kernel mailbox_notifier fd handle to the driver
	// and replace this with the new fd
	mc.mailbox_notifier.old_notifier = oldNotifier;
	mc.mailbox_notifier.new_notifier = mc.kernelEventfd;
	if ( -1 == ioctl(mc.devfd, EPIPHANY_IOC_MB_NOTIFIER, &mc.mailbox_notifier) )
	{
		int rtn = errno;
		printf("InitialMailboxNotifier(): Failed to send notifier to driver. %s errno: %d kernelEventfd: %d\n", strerror(rtn), rtn, mc.kernelEventfd);

		// Tidy up
		struct epoll_event event;
		epoll_ctl (mc.epollfd, EPOLL_CTL_DEL, mc.kernelEventfd, &event);
		close(mc.kernelEventfd);
		mc.kernelEventfd = -1;
		return rtn;
	}

	return returns;
#endif
	return 0;
}

int ArmMailboxNotifier()
{
#ifdef EPIPHANY_IOC_MB_ENABLE
	if (mc.running)
	{
		return ModifyNotifier(mc.kernelEventfd, EPOLL_CTL_MOD);
	}

	return E_ERR;
#endif
	return 0;
}

int ModifyNotifier(int fd, int operation)
{
	return UpdateEpoll(fd, operation, EPOLLIN | EPOLLET);
}

int UpdateEpoll(int fd, int operation, uint32_t waitOnEvent)
{
#ifdef EPIPHANY_IOC_MB_ENABLE
	int returns;
	struct epoll_event event;
	
	returns = E_ERR;
	
	// Add the kernelEventfd handle to epoll
	event.data.fd = fd;
	event.events = waitOnEvent;
	returns = epoll_ctl (mc.epollfd, operation, fd, &event);
	if (returns)
	{
		returns = errno;
		printf ("InitialMailboxNotifier(): epoll_ctl failed! %s errno: %d operation: %d, event: %d, fd: %d\n", strerror(returns), returns, operation, waitOnEvent, fd);
	}

	return returns;
#endif
	return 0;
}

int WaitForMailboxNotifier()
{
#ifdef EPIPHANY_IOC_MB_ENABLE
	int numberOfEvents;
	size_t bytesRead;
	int64_t eventfdCount;

	numberOfEvents = epoll_wait(mc.epollfd, mc.events, 2, -1);
	if ((1 < numberOfEvents) || (mc.events[0].data.fd != mc.kernelEventfd))
	{
		printf("INFO: WaitForMailboxNotifier(): Cancelled!\n");
	}

	if (0 > numberOfEvents)
	{
		int epollerrno = errno;
		printf("WaitForMailboxNotifier(): epoll_wait failed! %s errno %d\n", strerror(epollerrno), epollerrno);
	}

	bytesRead = read(mc.kernelEventfd, &eventfdCount, sizeof(int64_t));
	if (0 > bytesRead)
	{
		// failure to reset the eventfd counter to zero
		// can cause lockups!
		int eventfderrno = errno;
		printf("ERROR: WaitForMailboxNotifier(): lockup likely: eventfd counter reset failed! %s errno %d\n", strerror(eventfderrno), eventfderrno);
	}
	
	// printf("WaitForMailboxNotifier(): bytesRead: %d, eventfdCount: %d\n", bytesRead, eventfdCount);

	return numberOfEvents;
#else
	// do the best we can and wait
	usleep(100000);
	return 0;
#endif	
}

void CloseMailboxNotifier()
{
#ifdef EPIPHANY_IOC_MB_ENABLE
	//printf ("INFO: MailboxNotifier Closing\n");
	if (mc.running)
	{
		if (0 < mc.kernelEventfd)
		{
			mc.mailbox_notifier.old_notifier = mc.kernelEventfd;
			mc.mailbox_notifier.new_notifier = -1;
			ioctl(mc.devfd, EPIPHANY_IOC_MB_NOTIFIER, &mc.mailbox_notifier);
		}
		
		struct epoll_event event;
		epoll_ctl (mc.epollfd, EPOLL_CTL_DEL, mc.kernelEventfd, &event);
		free((void *)mc.events);
		close(mc.kernelEventfd);
		mc.kernelEventfd = -1;
		close(mc.devfd);
		close(mc.epollfd);
	}
#endif
}


