ifneq ($(KERNELRELEASE),)
# kbuild part of makefile
obj-y  := gpio-oh.o
else
# normal makefile
KDIR ?= /lib/modules/`uname -r`/build

default:
$(MAKE) -C $(KDIR) M=$$PWD

clean:
	rm -fr gpio-oh.mod.c *.o *.ko .*.cmd modules.order Module.symvers .tmp_versions

endif
