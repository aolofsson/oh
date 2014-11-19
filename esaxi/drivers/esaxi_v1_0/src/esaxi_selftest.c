
/***************************** Include Files *******************************/
#include "esaxi.h"
#include "xparameters.h"
#include "stdio.h"
#include "xil_io.h"

/************************** Constant Definitions ***************************/
#define READ_WRITE_MUL_FACTOR 0x10

/************************** Function Definitions ***************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the ESAXIinstance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus ESAXI_Mem_SelfTest(void * baseaddr_p)
{
	int     Index;
	u32 baseaddr;
	u32 Mem32Value;

	baseaddr = (u32) baseaddr_p;

	xil_printf("******************************\n\r");
	xil_printf("* User Peripheral Self Test\n\r");
	xil_printf("******************************\n\n\r");

	/*
	 * Write data to user logic BRAMs and read back
	 */
	xil_printf("User logic memory test...\n\r");
	xil_printf("   - local memory address is 0x%08x\n\r", baseaddr);
	xil_printf("   - write pattern to local BRAM and read back\n\r");
	for ( Index = 0; Index < 16; Index++ )
	{
	  ESAXI_mWriteMemory(baseaddr+4*Index, (0xDEADBEEF % Index));
	}

	for ( Index = 0; Index < 16; Index++ )
	{
	  Mem32Value = ESAXI_mReadMemory(baseaddr+4*Index);
	  if ( Mem32Value != (0xDEADBEEF % Index) )
	  {
	    xil_printf("   - write/read memory failed on address 0x%08x\n\r", baseaddr+4*Index);
	    return XST_FAILURE;
	  }
	}
	xil_printf("   - write/read memory passed\n\n\r");

	return XST_SUCCESS;
}
