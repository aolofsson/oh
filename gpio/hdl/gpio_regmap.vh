//64 bit registers, maps to addr[7:3]
`ifndef GPIO_REGMAP_VH_
 `define GPIO_REGMAP_VH_
 `define GPIO_OEN      6'h0
 `define GPIO_OUT      6'h1
 `define GPIO_IEN      6'h2
 `define GPIO_IN       6'h3
 `define GPIO_OUTAND   6'h4
 `define GPIO_OUTORR   6'h5
 `define GPIO_OUTXOR   6'h6
 `define GPIO_IMASK    6'h7
`endif
