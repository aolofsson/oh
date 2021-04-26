//Registers addr[6:2], 64 bits per register
`ifndef EDMA_REGMAP_VH_
 `define EDMA_REGMAP_VH_
 `define EDMA_CONFIG    5'd0  // general config
 `define EDMA_STRIDE    5'd1  // stride 
 `define EDMA_COUNT     5'd2  // count
 `define EDMA_SRCADDR   5'd3  // source address
 `define EDMA_DSTADDR   5'd4  // destination address
 `define EDMA_SRCADDR64 5'd5  // extended source address (64b)
 `define EDMA_DSTADDR64 5'd6  // extended destinationa ddress (64b)
 `define EDMA_STATUS    5'd7  // status register
`endif //  `ifndef EDMA_REGMAP_VH_


