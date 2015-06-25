#PLL CLOCK
create_clock -name pll_clkin -period 10  [get_ports clkin_p]

#SYS_CLK
create_clock -name sys_clk -period 10 [get_ports sys_clk_p]

#RECEIVER
create_clock -period 3.333 -name rx_lclk -waveform {0.000 1.666} [get_ports rxi_lclk_p]
set_input_delay -clock [get_clocks rx_lclk] -max -add_delay 2.5 [get_ports {rxi_data_p[*] rxi_frame_p}]
set_input_delay -clock [get_clocks rx_lclk] -min -add_delay 0.833 [get_ports {rxi_data_p[*] rxi_frame_p}]
#set_false_path -rise_from [get_clocks rx_lclk] -through [get_ports {rxi_data_p[*] rxi_frame_p}] -fall_to [get_clocks rx_lclk]

set_input_delay -clock [get_clocks rx_lclk] -clock_fall -max -add_delay 2.5 [get_ports {rxi_data_p[*] rxi_frame_p}]
set_input_delay -clock [get_clocks rx_lclk] -clock_fall -min -add_delay 0.833 [get_ports {RX_data_p[*] rxi_frame_p}]
#set_false_path -fall_from [get_clocks rx_lclk] -through [get_ports {rxi_data_p[*] rxi_frame_p}] -rise_to [get_clocks rx_lclk]


#TRANSMITTER
#????
#create_clock -name tx_lclk -period 2 elink/eclocks/pll_lclk/CLKOUT0
#create_clock -name tx_lclk90 -period 2 elink/eclocks/pll_lclk/CLKOUT1
##create_clock -name tx_lclk_div4 -period 8 elink/eclocks/pll_lclk/CLKOUT2
#set_output_delay -clock tx_lclk 0.5 [get_ports txo_data_*]
#set_output_delay -clock tx_lclk 0.5 [get_ports txo_frame_*]




