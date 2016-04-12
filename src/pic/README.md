PIC : Programmable Interrupt Controller
=====================================

## Introduction

A programmable interrupt controller supporting up to 32 indepenent interrupts.

## Examples
```c

```

## Register Summary

| Name   | Addr[7:2] | Access  | Default | Description                         |
|:------:|:---------:|:-------:|:-------:|-------------------------------------|
| IRET   | 0x8       | RD/WR   | n/a     | Latched interrupt events            |
| IMASK  | 0x9       | RD/WR   | 0       | Interrupt mask                      |
| ILAT   | 0xA       | RD/WR   | 0       | Interrupt latch                     |
| ILATST | 0xB       | WR      | n/a     | ILAT "set" alias                    |
| ILATCL | 0xC       | WR      | n/a     | ILAT "clear" alias                  |
| IPEND  | 0xD       | RD/WR   | 0       | Interrupts in process               |

----

## ILAT (0xA)

The ILAT register records all interrupt events. All events are positive edge-triggered Each bit in the ILAT register is tied to a specific hardware input signal. The ILAT register can be accessed directly or through the address aliases ILATST and ILATCL.

| Bits    | Name     | Description                                   |
|---------|----------|-----------------------------------------------|
| [N-1:0] | ILAT     | Latched interrupts waiting to enter CPU       |

----

## ILATCL (0xC)

An alias for the ILAT register that allows bits within the ILAT register to be cleared individually. Writing a “1” to an individual bit of the ILATCL register will clear the corresponding ILAT bit to “0”. Writing a “0” to an individual bit will have no effect on the ILAT register. The ILATST alias cannot be read.

| Bits    | Name       | Description                                     |
|---------|------------|-------------------------------------------------|
| [N-1:0] | ILAT       | ILAT= ILAT 'ANDNOT' bit set in this field       |

----

## ILATST (0xB)

An alias for the ILAT register that allows bits within the ILAT register to be set individually. Writing a “1” to an individual bit of the ILATST register will set the corresponding ILAT bit to “1”. Writing a “0” to an individual bit will have no effect on the ILAT register. The ILATST alias cannot be read.

| Bits    | Name       | Description                                     |
|---------|------------|-------------------------------------------------|
| [N-1:0] | ILAT       | ILAT= ILAT 'OR'  bit set in this field          |

----

## IMASK (0x9)

This is a masking register for blocking interrupts on a per-interrupt basis. All interrupts are latched by the ILAT register but can be blocked from reaching the program sequencer by setting the appropriate bit in the IMASK register. At each bit position, a “1” means the interrupt is masked.

| Bits    | Name       | Description                                     |
|---------|------------|-------------------------------------------------|
| [N-1:0] | IMASK      | Bit field mask for ILAT register                |

----

## IRET (0x8)

When an interrupt is serviced, the program counter of the upcoming sequential instruction is saved in the IRET register. The value in the IRET register is used by the RTI instruction to return to the original thread at a later time. For nested interrupt service routines, the IRET should be saved on the stack.

| Bits   | Name       | Description                                            |
|--------|------------|--------------------------------------------------------|
| [N-1:0]| IRET       | Save program counter (PC) at the time of the interrupt |

----

## IPEND (0xD)

This is a status register that keeps track of the interrupt service routines currently being processed. A bit is set when the interrupt enters the core and redirects the program flow and is cleared by the software executing an RTI instruction. The lowest numbered bit set to “1” indicates the currently serviced interrupt. Only interrupts in the ILAT register with a number less than the lowest bit in the IPEND register reach the program sequencer. This register can be used to implement nested interrupts. The register should never be directly written by a program.


| Bits    | Name       | Description                                       |
|---------|------------|---------------------------------------------------|
| [N-1:0] | IPEND      | Maintains record of all interrupts in process     |

----

