#pragma once

#include <stdint.h>

#define NMESSAGES 1000000

#define STEP_ADDR 0x6000
#define STOP_ADDR 0x6004

/* move to e-hal/e-lib when API is stabilized */
struct e_message {
	uint32_t from;
	uint32_t data;
} __attribute__((packed)) __attribute__((aligned(8)));

