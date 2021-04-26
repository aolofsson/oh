// Test burst writes
// https://github.com/parallella/oh/issues/37
//
// "Remembered that we have a long forgotten mode in the epiphany chip elink
// (not impemented in the fpga elink) that creates bursts when you write
// doubles to the same address. (F**K!)
// So the writes were likely coming in as bursts.
// Looks like the mailbox works fine when you write in "int"s (I tested it on
// the board with consecutive)
// (see "mailbox_test" in elink/sw0)"

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdbool.h>

#include <e-hal.h>

#include "common.h"

uint32_t EXPECTED[NEXPECTED] = {
	EXPECTED_0,
	EXPECTED_1,
	EXPECTED_2,
	EXPECTED_3,
	EXPECTED_4,
	EXPECTED_5,
	EXPECTED_6,
	EXPECTED_7,
};

int main(int argc, char *argv[])
{
	uint32_t result[NEXPECTED] = { 0, };
	unsigned rows, cols, i;
	e_platform_t platform;
	e_epiphany_t dev;
	uint32_t status;
	const uint32_t one = 1, zero = 0;
	uint32_t step = 1;
	bool exit_ok = true;
	e_mem_t emem;

	// initialize system, read platform params from
	// default HDF. Then, reset the platform and
	// get the actual system parameters.
	e_init(NULL);
	e_reset_system();

	e_alloc(&emem, DRAM_RESULT_OFFSET, 2*sizeof(result));

	e_get_platform_info(&platform);

	//open the workgroup
	rows   = platform.rows;
	cols   = platform.cols;
	e_open(&dev, 0, 0, rows, cols);

	//load the device program on the board
	e_load_group("emain.elf", &dev, 0, 0, 1, 1, E_FALSE);

	// Clear DRAM
	// clear 32-bit write vector (str)
	e_write(&emem, 0, 0, 0, &result, sizeof(result));
	// clear 64-bit write test vector (strd)
	e_write(&emem, 0, 0, sizeof(result), &result, sizeof(result));


	// Clear ERAM
	// clear 32-bit write vector (str)
	e_write(&dev, 0, 1, ERAM_RESULT_OFFSET, &result, sizeof(result));
	// clear 64-bit write test vector (strd)
	e_write(&dev, 0, 1, ERAM_RESULT_OFFSET+sizeof(result), &result, sizeof(result));


	// Clear status flag
	e_write(&dev, 0, 0, STATUS_ADDR, &zero, sizeof(zero));

	e_start(&dev, 0, 0);

	// Wait for test to complete
	while (true) {
		usleep(1000000);

		e_read(&dev, 0, 0, STATUS_ADDR, &status, sizeof(status));

		if (status)
			break;
	}

	// Check DRAM

	// Check 32-bit results
	printf("Checking DRAM\n");
	printf("32-bit STR:\n");
	e_read(&emem, 0, 0, 0, &result, sizeof(result));
	for (i = 0; i < NEXPECTED; i++) {
		if (result[i] != EXPECTED[i]) {
			exit_ok = false;
			printf("Fail at %d consecutive writes to same address\n", i + 1);
		}
	}

	// Check 64-bit results
	printf("64-bit STRD:\n");
	e_read(&emem, 0, 0, sizeof(result), &result, sizeof(result));
	for (i = 0; i < NEXPECTED; i++) {
		if (result[i] != EXPECTED[i]) {
			exit_ok = false;
			printf("Fail at %d consecutive writes to same address\n", i / 2 + 1);
		}
	}

	// Check ERAM

	// Check 32-bit results
	printf("\nChecking on-chip ERAM\n");
	printf("32-bit STR:\n");
	e_read(&dev, 0, 1, ERAM_RESULT_OFFSET, &result, sizeof(result));
	for (i = 0; i < NEXPECTED; i++) {
		if (result[i] != EXPECTED[i]) {
			exit_ok = false;
			printf("Fail at %d consecutive writes to same address\n", i + 1);
		}

	}

	// Check 64-bit results
	printf("64-bit STRD:\n");
	e_read(&dev, 0, 1, ERAM_RESULT_OFFSET+sizeof(result), &result, sizeof(result));
	for (i = 0; i < NEXPECTED; i++) {
		if (result[i] != EXPECTED[i]) {
			exit_ok = false;
			printf("Fail at %d consecutive writes to same address\n", i / 2 + 1);
		}
	}

	e_close(&dev);
	e_free(&emem);
	e_finalize();

	printf(exit_ok ? "\nPASSED\n" : "\nFAILED\n");
	exit(exit_ok ? EXIT_SUCCESS : EXIT_FAILURE);
}
