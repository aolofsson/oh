#NAND2
sv2v  oh_nand2_tb.sv > oh_nand2_tb.v.tmp
sv2v  ../hdl/oh_nand2.sv > oh_nand2.v.tmp
iverilog oh_nand2_tb.v.tmp oh_nand2.v.tmp ../hdl/oh_nmos.sv ../netlist/oh_pmos.sv -o nand2.out



