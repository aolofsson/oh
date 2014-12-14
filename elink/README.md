## Design structure

```
elink/              -  Top level level AXI elink peripheral
  emaxi/            -  AXI master interface
  exaxi/            -  AXI slave interface
  exaxilite/        -  AXI slave interface for configuration registers
  etx/              -  Elink transmit block
      etx_io        -  Converts packet to high speed serial
      etx_protocol  -  Creates an elink transaction packet
      etx_arbiter   -  Selects one of three AXI traffic sources (rd, wr, rr)
      s_rq_fifo     -  Read request fifo for slave AXI interface
      s_wr_fifo     -  Write request fifo for slave AXI interface
      m_rr_fifo     -  Read response fifo for master AXI interface 
  erx/              -  Elink receiver block
      etx_io        -  Converts serial packet received to parallel
      etx_protocol  -  Converts the elink packet to 104 bit emesh transaction
      etx_disty     -  Decodes emesh transaction and sends to AXI interface
      emmu          -  Translates the dstaddr of incoming transaction  
      m_rq_fifo     -  Read request fifo for master AXI interface
      m_wr_fifo     -  Write request fifo for master AXI interface
      s_rr_fifo     -  Read response fifo for slave AXI interface 
  ecfg/             -  Configurationr register file for elink
  embox/            -  Mail box (with interrupt output)
  eclock/           -  Clock generator



