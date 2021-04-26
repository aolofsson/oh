P1600:   7010 + 0 GPIO
P1601:   7010 + 24 GPIO
P1602:   7020 + 48 GPIO
A101010: 7010 + 0 GPIO
A101020: 7010 + 24 GPIO
A101040: 7020 + 48 GPIO

parallella_headless.tcl --product number as argument
parallella_display.tcl
parallella_sdr.tcl

----
## EDITING SYSTEM>BD IN GUI (ONE TIME..)
1. create ports
2. connect wires
3. run connection automation
4. create memory map
5. validate_bd_design
6. write_bd_tcl ./system_bd.tcl

----
## DESIGN LOOP
1. Make verilog change..
2. cd parallella_base; ./build.sh
3. cd ../headless;; ./build.sh
4. profit

