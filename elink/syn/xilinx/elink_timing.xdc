#MAIN CLOCK
create_clock -name clkin -period 8  [get_ports clkin]
create_clock -name sys_clk -period 8  [get_ports sys_clk]

#RECEIVER
#create_clock -name rx_lclk_div4 -period 8 [get_pins ]
create_clock -name rx_lclk -period 2 [get_ports rxi_lclk_p]	
set_input_delay -clock rx_lclk 0.5 [get_ports rxi_data_*]
set_input_delay -clock rx_lclk 0.5 [get_ports rxi_frame_*]

#TRANSMITTER
#create_clock -name tx_lclk -period 8 [get_pins ]
set_output_delay -clock rx_lclk 0.5 [get_ports txo_data_*]
set_output_delay -clock rx_lclk 0.5 [get_ports txo_frame_*]



