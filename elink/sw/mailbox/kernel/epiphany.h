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

typedef struct _MAILBOX_NOTIFIER
{
	int old_notifier;
	int new_notifier;
} mailbox_notifier_t;
	
#define EPIPHANY_IOC_MAGIC  'k'

/**
 * If you add an IOC command, please update the 
 * EPIPHANY_IOC_MAXNR macro
 */

#define EPIPHANY_IOC_GETSHM_CMD		24
#define EPIPHANY_IOC_MB_DISABLE_CMD	25
#define EPIPHANY_IOC_MB_ENABLE_CMD	26
#define EPIPHANY_IOC_MB_NOTIFIER_CMD	27

#define EPIPHANY_IOC_MAXNR		27
 
#define EPIPHANY_IOC_GETSHM _IOWR(EPIPHANY_IOC_MAGIC, EPIPHANY_IOC_GETSHM_CMD, epiphany_alloc_t *)
#define EPIPHANY_IOC_MB_ENABLE _IO(EPIPHANY_IOC_MAGIC, EPIPHANY_IOC_MB_ENABLE_CMD)
#define EPIPHANY_IOC_MB_DISABLE _IO(EPIPHANY_IOC_MAGIC, EPIPHANY_IOC_MB_DISABLE_CMD)
#define EPIPHANY_IOC_MB_NOTIFIER _IOW(EPIPHANY_IOC_MAGIC, EPIPHANY_IOC_MB_NOTIFIER_CMD, mailbox_notifier_t *)

/**
 * mailbox notifier file
 */
#define MAILBOX_NOTIFIER "/sys/class/epiphany/epiphany/mailbox_notifier"
/**
 * mailbox high byte valid after interrupt
 */
#define MAILBOX_HI "/sys/class/epiphany/epiphany/mailbox_hi"
/**
 * mailbox low byte valid after interrupt
 */
#define MAILBOX_LO "/sys/class/epiphany/epiphany/mailbox_lo"

#endif
