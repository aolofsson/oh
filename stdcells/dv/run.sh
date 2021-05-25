#NAND2
sv2v  oh_nand2_tb.sv > oh_nand2_tb.v.tmp
sv2v  ../netlist/oh_nand2.sv > ../netlist/oh_nand2.v.tmp
iverilog oh_nand2_tb.v.tmp ../netlist/oh_nand2.v.tmp ../netlist/oh_nmos.sv ../netlist/oh_pmos.sv -o nand2.out

#NOR2
sv2v  oh_nor2_tb.sv > oh_nor2_tb.v.tmp
sv2v  ../netlist/oh_nor2.sv > ../netlist/oh_nor2.v.tmp
iverilog oh_nor2_tb.v.tmp ../netlist/oh_nor2.v.tmp ../netlist/oh_nmos.sv ../netlist/oh_pmos.sv -o nor2.out



