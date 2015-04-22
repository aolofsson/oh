#AXI Master Clock
create_clock -period 10 -name m_axi_aclk -waveform {0.000 5} [get_ports m_axi_aclk]

#AXI Slave Clock
create_clock -period 10 -name s_axi_aclk -waveform {0.000 5} [get_ports s_axi_aclk]

#AXI Slave Config Clock
create_clock -period 10 -name s_axicfg_aclk -waveform {0.000 5} [get_ports s_axicfg_aclk]

#RX Clock
create_clock -period 2 -name rx_lclk_p -waveform {0.000 1} [get_ports rx_lclk_p]

#CLKIN
create_clock -period 10 -name clkin -waveform {0.000 1} [get_ports clkin]
