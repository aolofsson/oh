#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/pid.h>
#include <linux/fdtable.h>
#include <linux/rcupdate.h>
#include <linux/eventfd.h>
#include <linux/workqueue.h>
#include <linux/fs.h>
#include <linux/mm.h>
#include <linux/cdev.h>
#include <linux/platform_device.h>
#include <linux/device.h>
#include <linux/dma-mapping.h>
#include <linux/gfp.h>
#include <asm/uaccess.h>

#ifdef CONFIG_OF
/* For open firmware. */
#include <linux/of_address.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>
#endif

#include <linux/epiphany.h>

MODULE_AUTHOR("Peter Saunderson");
MODULE_DESCRIPTION("Adapteva Epiphany Driver");
MODULE_LICENSE("GPL");

#define UseReservedMem 1

#define DRIVER_NAME            "epiphany"

/* The physical address of the start and end of the Epiphany device memory */
#define EPIPHANY_MEM_START      0x80800000UL
#define EPIPHANY_MEM_END        0xC0000000UL

/* The physical address of the DRAM shared between the host and Epiphany */
#define HOST_MEM_START          0x3E000000UL
#define HOST_MEM_END            0x40000000UL

/* Physical address range that can be mapped to FPGA logic */
/* TODO: Define in devicetree */
#define PL_MEM_START            0x40000000UL
#define PL_MEM_END              0x80000000UL

#define ERX_REG_START 0x810F0300
#define ERX_REG_END 0x810F03FF
#define ERX_CFG_REG 0x0 	// 0xF0300
#define MAILBOX_LO_REG 0x20 	// 0xF0320
#define MAILBOX_HI_REG 0x24 	// 0xF0324
#define MAILBOX_STATE 0x28 	// 0xF0328
#define MAILBOX_ENABLE (0x1 << 28) 	// bit 28 in ERX_CFG_REG

static int major = 0;
static dev_t dev_no = 0;
static struct cdev epiphany_cdev;
static struct class *class_epiphany = 0;
static struct device *dev_epiphany = 0;
static epiphany_alloc_t global_shm;

/* Work stucture */
static struct workqueue_struct *irq_workqueue;
typedef struct
{
	struct work_struct work;
	struct task_struct * userspace_task;
} irq_work_t;

typedef struct {
	irq_work_t irq_work;	// @ start of structure so that work is at start
	unsigned int irq;
	void __iomem *reg_base;
} epiphany_mailbox_t;
static epiphany_mailbox_t mailbox;

static struct eventfd_ctx * efd_ctx = NULL;
static int mailbox_notifier = -1;
static int mailbox_lo = 0;
static int mailbox_hi = 0;

// mailbox_notifier is the eventfd sent by ioctl to the driver.
// Use epoll_wait on the user side to detect the arrival of
// an interrupt.  Note epoll_wait can be cancelled by
// waiting on a second eventfd descriptor.
DEVICE_INT_ATTR(mailbox_notifier, S_IRUGO, mailbox_notifier);

// mailbox content is read during interrupt servicing
// the user side code can read the sysfs files for the messages
DEVICE_INT_ATTR(mailbox_lo, S_IRUGO, mailbox_lo);
DEVICE_INT_ATTR(mailbox_hi, S_IRUGO, mailbox_hi);

static struct attribute *attrs[] = {
    &dev_attr_mailbox_notifier.attr.attr,
    &dev_attr_mailbox_lo.attr.attr,
    &dev_attr_mailbox_hi.attr.attr, NULL,
};

static struct attribute_group attr_group = {
    .attrs = attrs,
};

static const struct attribute_group *attr_groups[] = {
    &attr_group, NULL,
};

/* Function prototypes */
static int epiphany_of_probe(struct platform_device *op);
static int __init epiphany_init(void);
static int epiphany_probe(struct platform_device *pdev);
static int epiphany_remove(struct platform_device *pdev);
static void __exit epiphany_exit(void);
static int epiphany_open(struct inode *, struct file *);
static int epiphany_release(struct inode *, struct file *);
static int epiphany_map_host_memory(struct vm_area_struct *vma);
static int epiphany_map_device_memory(struct vm_area_struct *vma);
static int epiphany_mmap(struct file *, struct vm_area_struct *);
static long epiphany_ioctl(struct file *, unsigned int, unsigned long);
static void reg_write(epiphany_mailbox_t *mailbox, u32 reg, u32 val);
static u32 reg_read(epiphany_mailbox_t *mailbox, u32 reg);
static void enable_mailbox_irq(void);
static void disable_mailbox_irq(void);
static u32 read_mailbox_lo(void);
static u32 read_mailbox_hi(void);
static void irq_work_func(struct work_struct *work);
static irqreturn_t mailbox_irq_handler(int irq, void *data);

static struct file_operations epiphany_fops = {
	.owner = THIS_MODULE,
	.open = epiphany_open,
	.release = epiphany_release,
	.mmap = epiphany_mmap,
	.unlocked_ioctl = epiphany_ioctl
};

#ifdef CONFIG_OF
/* Match table for device tree binding */
static const struct of_device_id epiphany_of_match[] = {
	{ .compatible = "xlnx,parallella-base-1.0"},
	{},
};
MODULE_DEVICE_TABLE(of, epiphany_of_match);
#else
#define epiphany_of_match NULL
#endif

#ifdef CONFIG_OF
static int epiphany_of_probe(struct platform_device *op)
{
	unsigned int elinkId;
	int retval;

	retval = of_property_read_u32(op->dev.of_node, "xlnx,read-tag-addr", &elinkId);
	printk(KERN_INFO
	       "epiphany_of_probe(): elinkId: 0x%x\n", elinkId);
	return retval;
}
#else
static int epiphany_of_probe(struct platform_device *op)
{
	return -EINVAL;
}
#endif /* CONFIG_OF */

static struct platform_driver epiphany_platform_driver = {
	.probe = epiphany_probe,
	.remove = epiphany_remove,
	.driver = {
		.name = DRIVER_NAME,
		.of_match_table = epiphany_of_match,
	},
};

static int __init epiphany_init(void)
{
	int retval;
	void *ptr_err = 0;

	// Allocate character device numbers
	// unregistered on error and in .exit
	retval = alloc_chrdev_region(&dev_no, 0, 1, DRIVER_NAME);
	if (retval < 0) {
		printk(KERN_ERR "Failed to register the epiphany driver\n");
		return retval;
	}

	major = MAJOR(dev_no);
	dev_no = MKDEV(major, 0);

	// Create device class for epiphany
	// destroyed on error and in .exit
	class_epiphany = class_create(THIS_MODULE, DRIVER_NAME);
	if (IS_ERR(ptr_err = class_epiphany)) {
		retval = PTR_ERR(ptr_err);
		goto err2;
	}

	// Assign the attribute groups to create the sysfs files
	class_epiphany->dev_groups = attr_groups;

	// Register the driver with platform
	// unregistered in .exit
	retval = platform_driver_register(&epiphany_platform_driver);
	if (retval) {
		goto err;
	}

	return retval;

err:
	class_destroy(class_epiphany);
err2:	
	unregister_chrdev_region(dev_no, 1);

	return retval;
}

static int epiphany_probe(struct platform_device *pdev)
{
	int retval = 0;
	void *ptr_err = 0;
	const struct of_device_id *match;
	struct resource *io;

	match = of_match_device(epiphany_of_match, &pdev->dev);
	if (!match)
	{
		return -ENODEV;
	}

	retval = epiphany_of_probe(pdev);
	if (retval)
	{
		return -ENODEV;
	}

#if UseReservedMem
	/* 
	 ** Use the system reserved memory until we have a way
	 ** to tell epiphany what the dynamically allocated address is
	 */
	global_shm.size = GLOBAL_SHM_SIZE;
	global_shm.flags = 0;
	global_shm.bus_addr = 0x8e000000     + 0x01000000;	/* From platform.hdf + shared_dram offset */
	global_shm.phy_addr = HOST_MEM_START + 0x01000000;	/* From platform.hdf + shared_dram offset */
	global_shm.kvirt_addr = (unsigned long)ioremap_nocache(global_shm.phy_addr, 0x01000000);	/* FIXME: not portable */
	global_shm.uvirt_addr = 0;	/* Set by user when mmapped */
	global_shm.mmap_handle = global_shm.phy_addr;
#else
	// Allocate shared memory
	// Zero the shared memory
	memset(&global_shm, 0, sizeof(global_shm));
	global_shm.size = GLOBAL_SHM_SIZE;
	global_shm.flags = GFP_KERNEL;
	global_shm.kvirt_addr = __get_free_pages(GFP_KERNEL,
						 get_order(GLOBAL_SHM_SIZE));
	if (!global_shm.kvirt_addr) {
		printk(KERN_ERR
		       "epiphany_probe() - Unable to allocate contiguous "
		       "memory for global shared region\n");
		goto err;
	}

	global_shm.phy_addr = __pa(global_shm.kvirt_addr);
	global_shm.bus_addr = global_shm.phys_addr;
#endif

	// Zero the Global Shared Memory region
	memset((void *)global_shm.kvirt_addr, 0, GLOBAL_SHM_SIZE);

	printk(KERN_INFO
	       "epiphany_probe() - shared memory: bus 0x%08lx, phy 0x%08lx, kvirt 0x%08lx\n",
	       global_shm.bus_addr, global_shm.phy_addr, global_shm.kvirt_addr);

	// Map the rx registers for mailbox access
	io = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	printk(KERN_INFO
	       "epiphany_probe() - registers: start 0x%08lx, end 0x%08lx, name %s, flags %x\n",
	       (unsigned long)io->start, (unsigned long)io->end, io->name, io->flags);

	// for now keep it simple and dont reference the device tree stuff
	// not sure if ioremap here will prevent other user space mmap!
	io->start = ERX_REG_START;
	io->end = ERX_REG_END;
	mailbox.reg_base = devm_ioremap_resource(&pdev->dev, io);
	if (IS_ERR(mailbox.reg_base))
	{
		dev_err(&pdev->dev, "failed to map mailbox registers\n");
		return PTR_ERR(mailbox.reg_base);
	}
	
	// Get the mailbox irq from device tree
	mailbox.irq = platform_get_irq(pdev, 0);
	if (0 > mailbox.irq) {
		dev_err(&pdev->dev, "irq resource not found\n");
		return mailbox.irq;
	}

	printk(KERN_INFO
	       "epiphany_probe(): mailbox irq: 0x%x\n", mailbox.irq);

	// Register the mailbox irq handler
	// removed on error and in .remove
	retval = devm_request_irq(&pdev->dev, mailbox.irq, mailbox_irq_handler,
			       0, pdev->name, &mailbox);
	if (0 > retval) {
		dev_err(&pdev->dev, "request_irq failed\n");
		printk(KERN_ERR
		       "epiphany_probe() - Unable to request IRQ %d\n", mailbox.irq);
		goto err;
	}
	
	// Initialize the workqueue
	// Killed on error and in .remove
	irq_workqueue = create_workqueue("irq_work_queue");
	if (irq_workqueue)
	{
		INIT_WORK(((struct work_struct *)&mailbox), irq_work_func);
	}

	// Initialize the cdev structure
	// deleted on error and in .remove
	cdev_init(&epiphany_cdev, &epiphany_fops);
	epiphany_cdev.owner = THIS_MODULE;

	// Add the character driver to the system
	// deleted on error and in .remove
	retval = cdev_add(&epiphany_cdev, dev_no, 1);
	if (0 > retval) {
		printk(KERN_ERR
		       "epiphany_probe() - Unable to add character device\n");
		goto err1;
	}

	// Create the character device
	// deleted in .remove
	dev_epiphany = device_create(class_epiphany, NULL, dev_no, NULL,
				     DRIVER_NAME);
	if (IS_ERR(ptr_err = dev_epiphany)) {
		retval = PTR_ERR(ptr_err);
		goto err2;
	}
	
	return 0;

err2:
	cdev_del(&epiphany_cdev);
err1:
	destroy_workqueue(irq_workqueue);
	devm_free_irq(&pdev->dev, mailbox.irq, &mailbox);
err:
	return retval;
}

static int epiphany_remove(struct platform_device *pdev)
{
	// Disable the interrupt first
	disable_mailbox_irq();

	// Remove interrupt handler
        if (mailbox.irq > 0)
	{
		devm_free_irq(&pdev->dev, mailbox.irq, &mailbox);
	}

	// flush the queue
	flush_workqueue(irq_workqueue);
	
	// destroy the queue
	destroy_workqueue(irq_workqueue);
	
#if (UseReservedMem == 0)
	free_pages(global_shm.kvirt_addr, get_order(global_shm.size));
#endif
	device_destroy(class_epiphany, MKDEV(major, 0));
        cdev_del(&epiphany_cdev);

	return 0;
}

static void __exit epiphany_exit(void)
{
	// Unregister driver from plaform
	platform_driver_unregister(&epiphany_platform_driver);

	// Destroy the epiphany class
	class_destroy(class_epiphany);

	// Unregister the character device numbers
	unregister_chrdev_region(dev_no, 1);
}
static int epiphany_open(struct inode *inode, struct file *file)
{
	return 0;
}

static int epiphany_release(struct inode *inode, struct file *file)
{
	return 0;
}

static const struct vm_operations_struct mmap_mem_ops = {
#ifdef CONFIG_HAVE_IOREMAP_PROT
	.access = generic_access_phys
#endif
};

/**
 * Map memory that can be shared between the Epiphany
 * device and user-space
 */
static int epiphany_map_host_memory(struct vm_area_struct *vma)
{
	int err;
	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);


	err = remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
			vma->vm_end - vma->vm_start, vma->vm_page_prot);

	if (err) {
		printk(KERN_ERR "Failed mapping host memory to vma 0x%08lx, "
				"size 0x%08lx, page offset 0x%08lx\n",
				vma->vm_start, vma->vm_end - vma->vm_start,
				vma->vm_pgoff);
	}

	return err;
}

static int epiphany_map_device_memory(struct vm_area_struct *vma)
{
	int err, retval = 0;
	unsigned long pfn = vma->vm_pgoff;
	unsigned long size = vma->vm_end - vma->vm_start;

	vma->vm_flags |= (VM_IO | VM_DONTEXPAND | VM_DONTDUMP);
	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);

#ifdef EHalUsesOffsetsRatherThanAbsoluteAddress
	pfn = (EPIPHANY_MEM_START + off) >> PAGE_SHIFT;
#endif

	err = io_remap_pfn_range(vma, vma->vm_start, pfn, size,
			vma->vm_page_prot);

	if (err) {
		printk(KERN_ERR "Failed mapping device memory to vma 0x%08lx, "
				"size 0x%08lx, page offset 0x%08lx\n",
				vma->vm_start, vma->vm_end - vma->vm_start,
				vma->vm_pgoff);
		retval = -EAGAIN;
	}

	return retval;
}

static int epiphany_mmap(struct file *file, struct vm_area_struct *vma)
{
	int retval = 0;
	unsigned long off = vma->vm_pgoff << PAGE_SHIFT;
	unsigned long size = vma->vm_end - vma->vm_start;

	vma->vm_ops = &mmap_mem_ops;

	if ((EPIPHANY_MEM_START <= off ) && ((off + size) <= EPIPHANY_MEM_END)) {
		retval = epiphany_map_device_memory(vma);
	} else if ((PL_MEM_START <= off ) && ((off + size) <= PL_MEM_END)) {
		retval = epiphany_map_device_memory(vma);
	} else if ((HOST_MEM_START <= off) && ((off + size) <= HOST_MEM_END)) {
		retval = epiphany_map_host_memory(vma);
	} else {
		printk(KERN_DEBUG "epiphany_mmap - invalid request to map "
				"0x%08lx, length 0x%08lx bytes\n", off, size);
		retval = -EINVAL;
	}

	return retval;
}

static long epiphany_ioctl(struct file *file, unsigned int cmd,
			   unsigned long arg)
{
	int retval = 0;
	int err = 0;
	epiphany_alloc_t *ealloc = NULL;
	mailbox_notifier_t notifier;
 
	if (_IOC_TYPE(cmd) != EPIPHANY_IOC_MAGIC) {
		return -ENOTTY;
	}

	if (_IOC_NR(cmd) > EPIPHANY_IOC_MAXNR) {
		return -ENOTTY;
	}

	if (_IOC_DIR(cmd) & _IOC_READ) {
		err =
		    !access_ok(VERIFY_READ, (void __user *)arg, _IOC_SIZE(cmd));
	} else if (_IOC_DIR(cmd) & _IOC_WRITE) {
		err =
		    !access_ok(VERIFY_WRITE, (void __user *)arg,
			       _IOC_SIZE(cmd));
	}

	if (err) {
		return -EFAULT;
	}
 
	switch (cmd) {
	case EPIPHANY_IOC_GETSHM:
		ealloc = (epiphany_alloc_t *) (arg);
		if (copy_to_user(ealloc, &global_shm, sizeof(*ealloc))) {
			printk(KERN_ERR "EPIPHANY_IOC_GETSHM - failed\n");
			retval = -EACCES;
		}

		break;
		
	case EPIPHANY_IOC_MB_ENABLE:
		enable_mailbox_irq();
		break;

	case EPIPHANY_IOC_MB_DISABLE:
		disable_mailbox_irq();
		break;

	case EPIPHANY_IOC_MB_NOTIFIER:
		// TODO lock access
		if (copy_from_user(&notifier, (void __user *)arg, sizeof(mailbox_notifier_t)))
		{
			printk(KERN_ERR "EPIPHANY_IOC_MB_NOTIFIER - failed\n");
			retval = -EACCES;
		}

		if (notifier.old_notifier != mailbox_notifier)
		{
			printk(KERN_ERR "EPIPHANY_IOC_MB_NOTIFIER - %d != %d\n", notifier.old_notifier, mailbox_notifier);
			retval = -EACCES;
		}
		else
		{
			// flush the queue
			flush_workqueue(irq_workqueue);
			mailbox_notifier = notifier.new_notifier;
		}

		if (0 < mailbox_notifier)
		{
			// Save the userspace task for later use
			mailbox.irq_work.userspace_task = pid_task(find_vpid(current->pid), PIDTYPE_PID);
		}
	     
		// TODO unlock
		break;
			
		
	default:		/* Redundant, cmd was checked against MAXNR */
		return -ENOTTY;
	}

	return retval;
}

static inline void reg_write(epiphany_mailbox_t *mailbox, u32 reg, u32 val)
{
	iowrite32(val, mailbox->reg_base + reg);
}

static inline u32 reg_read(epiphany_mailbox_t *mailbox, u32 reg)
{
	return ioread32(mailbox->reg_base + reg);
}

static inline void enable_mailbox_irq(void)
{
	u32 cfg;
	
	// How to lock ERX_CFG_REG access - could be used from user side at same time!
	cfg = reg_read(&mailbox, ERX_CFG_REG);
	reg_write(&mailbox, ERX_CFG_REG, cfg | MAILBOX_ENABLE);
}

static inline void disable_mailbox_irq(void)
{
	u32 cfg;

	// How to lock ERX_CFG_REG access - could be used from user side at same time!
	cfg = reg_read(&mailbox, ERX_CFG_REG);
	reg_write(&mailbox, ERX_CFG_REG, cfg & ~MAILBOX_ENABLE);
}

static inline u32 read_mailbox_lo(void)
{
        return reg_read(&mailbox, (u32)MAILBOX_LO_REG);
}

static inline u32 read_mailbox_hi(void)
{
	return reg_read(&mailbox, (u32)MAILBOX_HI_REG);
}

static void irq_work_func(struct work_struct *work)
{
	irq_work_t * irq_work = (irq_work_t *)work;
	struct file * efd_file = NULL;

	mailbox_lo = (int)read_mailbox_lo();
	mailbox_hi = (int)read_mailbox_hi();

	// current file is always used at the time of the interrupt
	if (0 < mailbox_notifier)
	{
		rcu_read_lock();
		efd_file = fcheck_files(irq_work->userspace_task->files, mailbox_notifier);
		rcu_read_unlock();
		// printk(KERN_INFO "EPIPHANY_IOC_MB_NOTIFIER: %p\n", efd_file);

		efd_ctx = eventfd_ctx_fileget(efd_file);
		if (!efd_ctx)
		{
			printk(KERN_ERR "EPIPHANY_IOC_MB_NOTIFIER: failed to get eventfd file\n");
			// TODO consider setting mailbox_notifier back to default
			// this might complicate the user side
			// mailbox_notifier = -1;
			return;
		}

		// send the event
		eventfd_signal(efd_ctx, 1);
	}
}

/**
 * mailbox_irq_handler - Mailbox Interrupt handler
 * @irq: IRQ number
 * @data: Pointer to 
 *
 * Return: IRQ_HANDLED/IRQ_NONE
 */
static irqreturn_t mailbox_irq_handler(int irq, void *data)
{
	epiphany_mailbox_t *mailbox = (epiphany_mailbox_t *)data;

	// disable the interrupt	
	disable_mailbox_irq();

	if (0 < mailbox_notifier && irq_workqueue)
	{
		queue_work(irq_workqueue, &mailbox->irq_work.work);
	}
	
	return IRQ_HANDLED;
}

module_init(epiphany_init);
module_exit(epiphany_exit);
