# OH Linux generic UIO driver

Modules and devicetree compiled for Pubuntu 2016.3.x

1. Copy `zynq-parallella-oh-mio.dtb` to SD card boot partition, name it `devicetree.dtb`.
2. Reboot Parallella
3. (OPTIONAL) Load bitstream: `sudo dd if=parallella.bit.bin of=/dev/xdevcfg`
3. Load the required modules:  
```
sudo insmod uio.ko
sudo insmod uio_pdrv_genirq.ko of_id=oh,mio
sudo rmmod uio_pdrv_genirq.ko
sudo insmod uio_pdrv_genirq.ko of_id=oh,mio
chmod 777 /dev/uio0
```
4. You can now compile and run hello-mio in oh.git/src/mio/driver/hello-mio
