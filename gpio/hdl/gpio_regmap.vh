//64 bit registers, maps to addr[6:3]
`ifndef GPIO_REGMAP_VH_
 `define GPIO_REGMAP_VH_
 `define GPIO_OEN      4'h0
 `define GPIO_OUT      4'h1
 `define GPIO_IEN      4'h2
 `define GPIO_IN       4'h3
 `define GPIO_OUTAND   4'h4
 `define GPIO_OUTORR   4'h5
 `define GPIO_OUTXOR   4'h6
 `define GPIO_IMASK    4'h7
`endif
