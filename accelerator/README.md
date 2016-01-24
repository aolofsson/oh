ACCELERATOR
=======

A simple toy example designed to help get folks up to speed on FPGA and verilog design on the Parallella platform. This is an unoptimized "hello world" type AXI slave design. Optimization is left as an exercise to the reader.

## Build Instructions (on your regular machine)

```sh
git clone https://github.com/parallella/oh     # clone repo
cd accelerator/dv
./build.sh                                     # build
./run.sh tests/hello.emf                       # load data
gtkwave waveform.vcd                           # view waveform
emacs ../hdl/accelerator.v                     # "put code here"
cd ../fpga
./build.sh                                     # build bitstream
sudo cp parallella.bit.bin /media/$user/boot   # burn bitstream onto SD card on laptop/desktop
sync                                           # sync and insert SD card in parallella
```

## Testing Instructions (on Parallella)
```sh
git clone https://github.com/parallella/oh    # clone repo
cd accelerator/sw             
emacs test.c                                  # change numbers to test
gcc driver.c test.c -o hello.elf              # compile for ARM
./hello.elf                                   # run program
```





