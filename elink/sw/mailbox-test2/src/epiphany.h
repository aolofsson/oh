#ifndef EPIPHANY_H
#define EPIPHANY_H
#include <linux/ioctl.h>

/** Length of the Global shared memory region */
#define GLOBAL_SHM_SIZE               (4<<20)
#define SHM_LOCK_NAME                  "/eshmlock" 

#define SHM_MAGIC                     0xabcdef00

typedef struct _EPIPHANY_ALLOC
{
    unsigned long     size;
    unsigned long     flags;
    unsigned long     bus_addr;    /* out */
    unsigned long     phy_addr;    /* out */
    unsigned long     kvirt_addr;  /* out */
    unsigned long     uvirt_addr;  /* out */
    unsigned long     mmap_handle; /* Handle to use for mmap */
} epiphany_alloc_t;

struct epiphany_mailbox_msg {
	__u32		from;
	__u32		data;
} __attribute__((packed));

#define EPIPHANY_IOC_MAGIC  'k'

#define E_IO(nr)		_IO(EPIPHANY_IOC_MAGIC, nr)
#define E_IOR(nr, type)		_IOR(EPIPHANY_IOC_MAGIC, nr, type)
#define E_IOW(nr, type)		_IOW(EPIPHHANY_IOC_MAGIC, nr, type)
#define E_IOWR(nr, type)	_IOWR(EPIPHANY_IOC_MAGIC, nr, type)

/**
 * If you add an IOC command, please update the 
 * EPIPHANY_IOC_MAXNR macro
 */

#define EPIPHANY_IOC_GETSHM_CMD			24
#define EPIPHANY_IOC_MAILBOX_READ_CMD		25
#define EPIPHANY_IOC_MAILBOX_COUNT_CMD		26
#define EPIPHANY_IOC_MAXNR			26

#define EPIPHANY_IOC_GETSHM		E_IOWR(EPIPHANY_IOC_GETSHM_CMD, epiphany_alloc_t *)
#define EPIPHANY_IOC_MAILBOX_READ	E_IOWR(EPIPHANY_IOC_MAILBOX_READ_CMD, struct epiphany_mailbox_msg)
#define EPIPHANY_IOC_MAILBOX_COUNT	E_IO(EPIPHANY_IOC_MAILBOX_COUNT_CMD)

#endif
