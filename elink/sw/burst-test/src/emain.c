#include <e-lib.h>
#include <stdint.h>

#include "common.h"

extern void test_dram();
extern void test_eram();

int main()
{
	volatile uint32_t *status = (uint32_t *) STATUS_ADDR;

	test_dram();
	test_eram();

	/* Tell host we're done */
	*status = 1;
}
