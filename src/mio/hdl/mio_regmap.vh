`ifndef MIO_REGMAP_VH_
 `define MIO_REGMAP_VH_
//Registers addr[5:2]
 `define MIO_CONFIG   4'd0 // general config
 `define MIO_STATUS   4'd1 // status
 `define MIO_CLKDIV   4'd2 // clk divider config
 `define MIO_CLKPHASE 4'd3 // clk divider config
 `define MIO_ODELAY   4'd4 // output data delay element
 `define MIO_IDELAY   4'd5 // input data delay element
 `define MIO_ADDR0    4'd6 // destination address for amode
 `define MIO_ADDR1    4'd7 // destination address for amode

`endif //  `ifndef MIO_REGMAP_VH_



