#include "common.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <e-hal.h>
#include <e-loader.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <ctype.h>
#include <err.h>
#include <stdint.h>
#include <assert.h>

#define TAPS 64

// Epiphany system registers
typedef enum {
	E_SYS_RESET	= 0xF0200,
	E_SYS_CLKCFG	= 0xF0204,
	E_SYS_CHIPID	= 0xF0208,
	E_SYS_VERSION	= 0xF020c,
	E_SYS_TXCFG	= 0xF0210,
	E_SYS_RXCFG	= 0xF0300,
	E_SYS_RXDMACFG	= 0xF0500,
} e_sys_reg_id_t;

typedef union {
	unsigned int reg;
	struct {
		unsigned int reset:1;
//		unsigned int chip_reset:1;
//		unsigned int reset:1;
	};
} e_sys_reset_t;

typedef union {
	unsigned int reg;
	struct {
		unsigned int cclk_enable:1;
		unsigned int lclk_enable:1;
		unsigned int cclk_bypass:1;
		unsigned int lclk_bypass:1;
		unsigned int cclk_divider:4;
		unsigned int lclk_divider:4;
	};
} e_sys_clkcfg_t;

typedef union {
	unsigned int reg;
	struct {
		unsigned int col:6;
		unsigned int row:6;
	};
} e_sys_chipid_t;

typedef union {
	unsigned int reg;
	struct {
		unsigned int platform:8;
		unsigned int revision:8;
	};
} e_sys_version_t;

typedef union {
	unsigned int reg;
	struct {
		unsigned int enable:1;
		unsigned int mmu_enable:1;
		unsigned int remap_cfg:2;
		unsigned int ctrlmode:4;
		unsigned int ctrlmode_select:1;
		unsigned int transmit_mode:3;
	};
} e_sys_txcfg_t;

typedef union {
	unsigned int reg;
	struct {
		unsigned int testmode:1;
		unsigned int mmu_enable:1;
		unsigned int remap_cfg:2;
		unsigned int remap_mask:12;
		unsigned int remap_base:12;
		unsigned int timeout:2;
	};
} e_sys_rxcfg_t;

typedef union {
	unsigned int reg;
	struct {
		unsigned int enable:1;
		unsigned int master_mode:1;
		unsigned int __reserved1:3;
		unsigned int width:2;
		unsigned int __reserved2:3;
		unsigned int message_mode:1;
		unsigned int src_shift:1;
		unsigned int dst_shift:1;
	};
} e_sys_rx_dmacfg_t;

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

  //Gets ELF file name from command line
  strcpy(elfFile, "./bin/e-task.elf");

  //Initalize Epiphany device
  e_set_host_verbosity(H_D0);
  e_init(NULL);                      
  my_reset_system();
  e_get_platform_info(&platform);                          
  e_open(&dev, 0, 0, 1, 1); //open core 0,0
  e_alloc(pdram, 0x00000000, 0x00400000);

  
  int din=0x1; 
  ee_write_esys(0xF0300, din);//Put RX in test mode (disable RX)
  din = 0x1234;
  e_write(pdev, 0, 0, 0, (void *) &(din), sizeof(int));       
  int res;
  e_read(pdev, 0, 0, 0, (void *) &(res), sizeof(int));         
  printf ("RESULT=%08x\n",res);
    
  //Close down Epiphany device
  e_close(&dev);
  e_finalize();
  
  //self check
  if(status){
    return EXIT_SUCCESS;
  }
  else{
    return EXIT_FAILURE;
  }   
}
//////////////////////////////////////////////////////////////////////////////////////////////

int my_reset_system(void)
{
	int rc = 0;
	uint32_t divider;
	uint32_t chipid;
	e_sys_txcfg_t txcfg         = { .reg = 0 };
	e_sys_rxcfg_t rxcfg         = { .reg = 0 };
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
	rxcfg.remap_cfg = 1; // "static" remap_addr
	rxcfg.remap_mask = 0xfe0; // should be 0xfe0 ???
	rxcfg.remap_base = 0x3e0;
	if (sizeof(int) != ee_write_esys(E_SYS_RXCFG, rxcfg.reg))
		goto err;
	usleep(1000);

#if 0 // ?
	rx_dmacfg.enable = 1;
	if (sizeof(int) != ee_write_esys(E_SYS_RXDMACFG, rx_dmacfg.reg))
		goto err;
	usleep(1000);
#endif
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
	
	divider = 0; /* Divide by 4, see data sheet */
	//divider = 0; /* Divide by 2, see data sheet */
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
	e_close(&dev);
	
	usleep(1000);
	return E_OK;

err:
	warnx("e_reset_system(): Failed\n");
	usleep(1000);
	return E_ERR;
}
