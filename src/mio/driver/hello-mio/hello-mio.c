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

int main()
{
	bool pass;

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

	wormhole.u32[0] = 0x12345678;
	usleep(1000);
	printf("mem: 0x%08x\n", mem.u32[0]);
	pass = (mem.u32[0] == 0x12345678);

	munmap(wormhole.v, 0x100000);
	munmap(regs.v, 0x100000);
	munmap(mem.v, 0x100000);

	printf(pass ? "PASS\n" : "FAIL\n");
	return pass ? 0 : 1;
}
