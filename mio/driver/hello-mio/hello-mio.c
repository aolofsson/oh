#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdint.h>
#include <stdio.h>

#define PAGE_SHIFT 12

#define MIO_CONFIG   0 // general config
#define MIO_STATUS   1 // status
#define MIO_CLKDIV   2 // clk divider config
#define MIO_CLKPHASE 3 // clk divider config
#define MIO_ODELAY   4 // output data delay element
#define MIO_IDELAY   5 // input data delay element
#define MIO_ADDR0    6 // destination address for amode
#define MIO_ADDR1    7 // destination address for amode

#define MIO_STATUS_RX_EMPTY		(1 << 0)
#define MIO_STATUS_RX_PROG_FULL		(1 << 1)
#define MIO_STATUS_RX_FULL		(1 << 2)
#define MIO_STATUS_TX_EMPTY		(1 << 3)
#define MIO_STATUS_TX_PROG_FULL		(1 << 4)
#define MIO_STATUS_TX_FULL		(1 << 5)

void mio_set_clkdiv(volatile uint32_t *regs, uint32_t clkdiv)
{
	uint32_t rise0, fall0, rise1, fall1;
	uint32_t clkphase;

	if (clkdiv > 254)
		clkdiv = 254;

	rise0 = 0;
	fall0 = 0xff & ((clkdiv  + 1) >> 1);   // 180 degrees
	rise1 = 0xff & ((clkdiv  + 1) >> 2);   // 90 degrees
	fall1 = 0xff & (((clkdiv + 1) >> 2) +
			((clkdiv + 1) >> 1));  // 270 degrees

	regs[MIO_CLKDIV] = clkdiv;
	regs[MIO_CLKPHASE] = fall1 << 24 |
			     rise1 << 16 |
			     fall0 <<  8 |
			     rise0 <<  0;

}

int main()
{
	bool pass = true;

	int fd;
	union acme_ptr {
		void *v;
		volatile uint8_t *u8;
		volatile uint16_t *u16;
		volatile uint32_t *u32;
	};
	union acme_ptr wormhole, regs, mem;

	fd = open("/dev/uio0", O_RDWR);
	if (fd < 0) {
		perror("open");
		return errno;
	}

	/* uio_pdrv_genirq uses (offset >> PAGE_SHIFT) as index into the region
	 * list. Device tree snippet:
	 * mio: mio@7fd00000 {
	 * 	#address-cells = <1>;
	 * 	#size-cells = <1>;
	 * 	ranges;
	 * 	compatible = "oh,mio";
	 * 	reg = <0x7fc00000 0x100000>, // TX wormhole
	 * 	      <0x7fd00000 0x100000>, // MIO registers
	 * 	      <0x3e000000 0x100000>; // TX destination
	 * };
	 */

	wormhole.v = mmap(NULL, 0x100000, PROT_WRITE | PROT_READ, MAP_SHARED,
			fd, 0 << PAGE_SHIFT);
	if (wormhole.v == MAP_FAILED) {
		perror("mmap wormhole");
		return errno;
	}

	regs.v = mmap(NULL, 0x100000, PROT_WRITE | PROT_READ, MAP_SHARED,
			fd, 1 << PAGE_SHIFT);
	if (regs.v == MAP_FAILED) {
		perror("mmap regs");
		return errno;
	}

	mem.v = mmap(NULL, 0x100000, PROT_WRITE | PROT_READ, MAP_SHARED,
			fd, 2 << PAGE_SHIFT);
	if (mem.v == MAP_FAILED) {
		perror("mmap mem");
		return errno;
	}

	mio_set_clkdiv(regs.u32, 10);

	// Clear memory region
	unsigned i, j;
	for (i = 0; i < 0x40000; i++)
		mem.u32[i] = 0;

	regs.u32[1] = 0;
	printf("status: 0x%08x\n", regs.u32[1]);

	printf("Testing pattern 1\n");

	for (i = 0; i < 0x40000; i++) {
		uint32_t val = (i + 1) * 0x10101010;
		wormhole.u32[i] = val;
		/* HACK: Pushback broken mio_wait_out <--> s_wr_wait broken */
		/* FIFO depth = 32 */
		while (mem.u32[i] != val) {
//			for (j = 0; j < 500; j++)
				asm("nop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop" ::: "memory");
//			if (mem.u32[i] == val)
//				break;

//			printf("PAT1 mem[%d]: 0x%08x expected: 0x%08x. Retrying\n",
//			       i, mem.u32[i], val);
		}
	}
	for (i = 0; i < 0x40000; i++) {
		uint32_t val = (i + 1) * 0x10101010;
		while (mem.u32[i] != val) {
			printf("PAT1 mem[%d]: 0x%08x expected: 0x%08x. Retrying\n",
			       i, mem.u32[i], val);
			usleep(50);
		}
	}

	printf("Testing pattern 2\n");
	for (i = 0; i < 0x40000; i++) {
		uint32_t val = (i + 1) * 0x01010101;
		wormhole.u32[i] = val;
		/* HACK: Pushback broken mio_wait_out <--> s_wr_wait broken */
		/* FIFO depth = 32 */
		while (mem.u32[i] != val) {
//			for (j = 0; j < 500; j++)
				asm("nop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop" ::: "memory");
//			if (mem.u32[i] == val)
//				break;

//			printf("PAT2 mem[%d]: 0x%08x expected: 0x%08x. Retrying\n",
//			       i, mem.u32[i], val);
		}
	}
	for (i = 0; i < 0x40000; i++) {
		uint32_t val = (i + 1) * 0x01010101;
		while (mem.u32[i] != val) {
			printf("PAT2 mem[%d]: 0x%08x expected: 0x%08x. Retrying\n",
			       i, mem.u32[i], val);
			usleep(50);
		}
	}

	munmap(wormhole.v, 0x100000);
	munmap(regs.v, 0x100000);
	munmap(mem.v, 0x100000);

	close(fd);

	/* If we reached here the test did pass */
	printf(pass ? "PASS\n" : "FAIL\n");
	return pass ? 0 : 1;
}
