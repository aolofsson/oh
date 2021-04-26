#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>

#include <sys/ioctl.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <e-hal.h>

#include <stdbool.h>

#include <errno.h>

#include <linux/types.h>
#include "epiphany.h"

#include "common.h"

/* Cache fd */
static int fd = -1;

/* TODO: Include in e-hal API */
int e_mailbox_read(struct e_message *msg, int flags)
{
	int rc;
	struct e_mailbox_msg kernel_msg;

	flags &= O_NONBLOCK;

	if (fd < 0)
        fd = open("/dev/epiphany/elink0", flags, O_RDONLY);
	if (fd < 0)
		return fd;

	rc = ioctl(fd, E_IOCTL_MAILBOX_READ, &kernel_msg);
	if (rc)
		return rc;

#if 0
	msg->from = kernel_msg.from;
	msg->data = kernel_msg.data;
#else
	/* work around FPGA Elink 64-bit burst bug
	 * Message can only be 32-bits for now so use lower bits for data
	 * and let sender be 0 */
	msg->from = 0;
	msg->data = kernel_msg.from;
#endif

	return 0;
}

int e_mailbox_count()
{
    int rc;

    if (fd < 0)
        fd = open("/dev/epiphany/elink0", 0, O_RDONLY);
	if (fd < 0)
		return fd;

	rc = ioctl(fd, E_IOCTL_MAILBOX_COUNT);

    return rc;
}

int main(int argc, char *argv[])
{
	unsigned rows, cols, i, count;
	const uint32_t one = 1, zero = 0;
	uint32_t step = 1;
	e_platform_t platform;
	e_epiphany_t dev;
	int expected, received, errors;
	double time, rate;
	struct timespec start, stop;
	struct e_message msg = { 0, 0 };

	// initialize system, read platform params from
	// default HDF. Then, reset the platform and
	// get the actual system parameters.
	e_init(NULL);
	e_reset_system();

	e_get_platform_info(&platform);

	//open the workgroup
	rows   = platform.rows;
	cols   = platform.cols;
	e_open(&dev, 0, 0, rows, cols);

	//load the device program on the board
	e_load_group("emain.elf", &dev, 0, 0, 1, 1, E_FALSE);


	e_write(&dev, 0, 0, STOP_ADDR, &zero, sizeof(zero));
	e_write(&dev, 0, 0, STEP_ADDR, &zero, sizeof(zero));

	e_start(&dev, 0, 0);

	/* Test blocking wait with interrupts */
	printf("Testing blocking wait with interrupts\n");
	for (i = 0; i < 16; i++) {
		e_write(&dev, 0, 0, STEP_ADDR, &step, sizeof(step));
		step++;
		/* Blocking wait while Epiphany performs dummy loop */
		e_mailbox_read(&msg, 0);
		printf("i: %.2d from: 0x%08x data: 0x%08x\n",
		       i, msg.from, msg.data);
	}

	e_write(&dev, 0, 0, STOP_ADDR, &one, sizeof(one));


	/* Test reading using count */

	expected = NMESSAGES;
	received = 0;
	errors = 0;

	printf("\nReading %d messages\n", expected);
	clock_gettime(CLOCK_THREAD_CPUTIME_ID, &start);
	count = e_mailbox_count();
	while (count >= 0 && !errors && received < expected) {
		if (!count)
			sched_yield();

		while (count--) {
			if (e_mailbox_read(&msg, 0)) {
				errors++;
				continue;
			}
			if (received != msg.data)
				errors++;

			received++;
		}
		count = e_mailbox_count();
	}
	clock_gettime(CLOCK_THREAD_CPUTIME_ID, &stop);
	time = (double) (stop.tv_sec - start.tv_sec) +
	       (double) (stop.tv_nsec - start.tv_nsec) / 1000000000.0;
	rate = (double) expected / time;

	printf("received: %d\terrors: %d\ttime: %3.2fs\trate: %d msgs/s\n",
	       received, errors, time, (int) rate);

	e_close(&dev);
	e_finalize();

	return errors ? EXIT_FAILURE : EXIT_SUCCESS;
}
