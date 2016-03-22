//Registers addr[6:2], 64 bits per register
`ifndef EDMA_REGMAP_VH_
 `define EDMA_REGMAP_VH_
 `define EDMA_CONFIG0  5'd0  // general config
 `define EDMA_CONFIG1  5'd1  // general config
 `define EDMA_STRIDE0  5'd2  // stride
 `define EDMA_STRIDE1  5'd3  // stride
 `define EDMA_COUNT0   5'd4  // count
 `define EDMA_COUNT1   5'd5  // count 
 `define EDMA_SRCADDR0 5'd6  // source address
 `define EDMA_SRCADDR1 5'd7  // source address
 `define EDMA_DSTADDR0 5'd8  // destination address
 `define EDMA_DSTADDR1 5'd9  // destination address
 `define EDMA_AUTO0    5'd10 // slave auto dma
 `define EDMA_AUTO1    5'd11 // slave auto dma
 `define EDMA_STATUS   5'd14 // status register
`endif //  `ifndef EDMA_REGMAP_VH_


