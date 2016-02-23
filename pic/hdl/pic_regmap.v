`ifndef IRQC_REGMAP_V_
 `define IRQC_REGMAP_V_

//registers
 `ifndef  ECORE_IRET  
  `define ECORE_IRET       6'h08
  `define ECORE_IMASK      6'h09
  `define ECORE_ILAT       6'h0A
  `define ECORE_ILATST     6'h0B
  `define ECORE_ILATCL     6'h0C
  `define ECORE_IPEND      6'h0D

  `define IRQ_VECTOR_TABLE 32'h00000000

 `endif  
`endif
