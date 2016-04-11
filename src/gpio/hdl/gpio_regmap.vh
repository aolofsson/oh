//64 bit registers, maps to addr[6:3]
`ifndef GPIO_REGMAP_VH_
 `define GPIO_REGMAP_VH_
 `define GPIO_DIR      4'h0  // set direction of pin
 `define GPIO_IN       4'h1  // input data (read only)
 `define GPIO_OUT      4'h2  // output data (write only)
 `define GPIO_OUTCLR   4'h3  // alias, clears specific bits in GPIO_OUT
 `define GPIO_OUTSET   4'h4  // alias, sets specific bits in GPIO_OUT
 `define GPIO_OUTXOR   4'h5  // alias, toggles specific bits in GPIO_OUT
 `define GPIO_IMASK    4'h6  // interrupt mask
 `define GPIO_ITYPE    4'h7  // interrupt type (level/edge)
 `define GPIO_IPOL     4'h8  // interrupt polarity (falling/rising edge)
 `define GPIO_ILAT     4'h9  // latched interrupts (read only)
 `define GPIO_ILATCLR  4'hA  // clear an interrupt

`endif
