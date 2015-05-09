#PLL CLOCK
create_clock -name pll_clkin -period 10  [get_ports pll_clkin]

#SYS_CLK
create_clock -name sys_clk -period 8  [get_ports sys_clk]

#RECEIVER
create_clock -name rx_lclk -period 2 [get_ports rxi_lclk_p]	
set_input_delay -clock rx_lclk 0.5 [get_ports rxi_data_*]
set_input_delay -clock rx_lclk 0.5 [get_ports rxi_frame_*]

#TRANSMITTER
create_clock -name tx_lclk -period 2 elink/eclocks/pll_lclk/CLKOUT0
create_clock -name tx_lclk90 -period 2 elink/eclocks/pll_lclk/CLKOUT1
create_clock -name tx_lclk_div4 -period 8 elink/eclocks/pll_lclk/CLKOUT2
set_output_delay -clock tx_lclk 0.5 [get_ports txo_data_*]
set_output_delay -clock tx_lclk 0.5 [get_ports txo_frame_*]




