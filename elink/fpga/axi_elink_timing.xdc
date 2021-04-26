#SYS_CLK
create_clock -name sys_clk -period 10 [get_ports sys_clk]

#RECEIVER
create_clock -period 3.333 -name rx_lclk -waveform {0.000 1.667} [get_ports rxi_lclk_p]

