# Zynq Ultrascale+ MPSoC zcu102 designs

## Caveats

- Only lower 5 bits (of 9) of IDELAY can be programmed ATM.
- Vivado DRC bug(?) prevents us from using IDELAYCTRL.
  This forces us to use .DELAY_FORMAT("COUNT") instead of "TIME" in IDELAYE3.
  So no automatic PVT adjustments for now.
- CLKIN_N1 and CLKIN_P1 not connected.

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
2. make
3. profit

