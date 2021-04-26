#pragma once

#define STATUS_ADDR 0x6000

#define NEXPECTED 8

/* External memory */
#define DRAM_RESULT_OFFSET 0x01100000
#define DRAM_RESULT_ADDR   0x8f100000

/* On-chip SRAM */
#define ERAM_RESULT_OFFSET 0x00001000
#define ERAM_RESULT_ADDR   0x80901000

#define EXPECTED_0 0x12345678
#define EXPECTED_1 0xffffffff
#define EXPECTED_2 0xf0f0f0f0
#define EXPECTED_3 0xffff0000
#define EXPECTED_4 0xff00ff00
#define EXPECTED_5 0xaaaaaaaa
#define EXPECTED_6 0x55555555
#define EXPECTED_7 0xa55aa55a

