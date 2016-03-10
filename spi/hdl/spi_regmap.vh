//64 bit register positions [7:2]
`ifndef GPIO_REGMAP_V_
 `define GPIO_REGMAP_V_
 `define SPI_CONFIG   6'd0  // config register
 `define SPI_STATUS   6'd1  // status register
 `define SPI_CLKDIV   6'd2  // baud rate (master)
 `define SPI_CMD      6'd3  // manual ss control (master)
 `define SPI_RXADDR0  6'd4  // auto return address (31:0)
 `define SPI_RXADDR1  6'd6  // auto return address (63:32)
 `define SPI_TX       6'd8  // TX FIFO
 `define SPI_RX       6'd12 // RX FIFO

`endif //  `ifndef GPIO_REGMAP_V_

