//64 bit register positions [7:2]
`ifndef GPIO_REGMAP_V_
 `define GPIO_REGMAP_V_
 `define SPI_CONFIG   6'd0  // config register
 `define SPI_STATUS   6'd1  // status register
 `define SPI_CMD      6'd2  // command register (first byte)
 `define SPI_PSIZE    6'd3  // package size (32 bits)
 `define SPI_CLKDIV   6'd4  // baud rate (master)
 `define SPI_START    6'd5  // manual transfer (master)
 `define SPI_JUNK     6'd6  // reserved
 `define SPI_JUNK     6'd7  // reserved
 `define SPI_TX       6'd8  // 4 regs for tx x 32
 `define SPI_RX       6'd12 // 4 regs for rx x 32

`endif //  `ifndef GPIO_REGMAP_V_

