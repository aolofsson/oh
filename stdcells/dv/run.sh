#NAND2
sv2v  oh_nand2_tb.sv > oh_nand2_tb.v
sv2v  ../netlist/oh_nand2.sv > ../netlist/oh_nand2.v
iverilog oh_nand2_tb.v ../netlist/oh_nand2.v ../netlist/oh_nmos.v ../netlist/oh_pmos.v -o nand2.out

#NOR2
sv2v  oh_nor2_tb.sv > oh_nor2_tb.v
sv2v  ../netlist/oh_nor2.sv > ../netlist/oh_nor2.v
iverilog oh_nor2_tb.v ../netlist/oh_nor2.v ../netlist/oh_nmos.v ../netlist/oh_pmos.v -o nor2.out



