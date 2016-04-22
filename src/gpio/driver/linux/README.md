# OH GPIO Linux Kernel driver

## Compilation

### Against system kernel sources

```
make
```

### Custom source path

```
make KDIR=path/to/src/linux
```

### Cross compiling (example w/ custom build-dir)

```
make -C path/to/built/linux-builddir \
	M=`pwd` \
	ARCH=arm \
	CROSS_COMPILE=arm-linux-gnueabihf- \
	LOADADDR=0x8000
```

For more flags etc, see:
https://www.kernel.org/doc/Documentation/kbuild/modules.txt
