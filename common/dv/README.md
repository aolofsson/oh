# What defines are used

```
iverilog -g2005 -DTARGET_SIM=1 $cfg $core.v $DV -f $LIBS -o $core.bin

```


# How to compile all duts?

The script "build_all.sh" builds all dut files in this directory with random  

```sh
./build_all.sh

```

