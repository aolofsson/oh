C2C: Generic chip to chip link 
===============================


## Introduction
* The C2C is a generic protocol agnostic link for moving data between dies. The block does not include any platform specific optimization

## Key Features

* Dual data rate data transfers
* Source synchronous
* Clock aligned by transmitter at 90 degrees
* Parametrized I/O and system side bus width
* Data transmitted MSB first

## Protocol

![alt tag](docs/c2c_waveform.png)

## Interface

## Registers
* None

## Simulation

```
cd $OH_HOME/c2v/dv
./build.sh
./run.sh dut_c2c.bin tests/test_random.emf
```



