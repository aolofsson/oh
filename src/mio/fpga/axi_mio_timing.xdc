# Use numbers from here:
# https://en.wikipedia.org/wiki/Propagation_delay
# Assume wires are shorter than < 30cm (12")

# slave
create_clock -period 30.000 -name mio_s_sclk -waveform {0.000 15.000} [get_ports {gpio_p[3]}]
# assign mio_s_mosi = gpio_in[8];
set_input_delay  -clock mio_s_sclk -max 2.000            [get_ports {gpio_n[4]}]
# assign mio_s_miso = gpio_out[9];
set_output_delay -clock mio_s_sclk -max -add_delay 2.000 [get_ports {gpio_n[5]}]
# assign mio_s_ss   = gpio_in[10];
set_input_delay  -clock mio_s_sclk -max 2.000            [get_ports {gpio_p[4]}]

#master
# assign mio_m_sclk = gpio_out[3];
# just misses timing for 100 MHz
create_clock -period 20.000 -name mio_m_sclk -waveform {0.000 10.000} [get_ports {gpio_p[1]}]
# assign mio_m_mosi = gpio_out[4];
set_output_delay -clock mio_m_sclk -max -add_delay 2.000 [get_ports {gpio_n[2]}]
# assign mio_m_miso = gpio_in[5];
set_input_delay  -clock mio_m_sclk -max 2.000            [get_ports {gpio_n[3]}]
# assign mio_m_ss   = gpio_out[6];
set_output_delay -clock mio_m_sclk -max -add_delay 2.000 [get_ports {gpio_p[2]}]

set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks mio_m_sclk]

# pgpio.v pin mapping
#  for(m=0; m<NGPIO; m=m+2) begin : assign_se_sigs
#     assign ps_gpio_i[2*m]   = gpio_i_n[m];
#     assign ps_gpio_i[2*m+1] = gpio_i_n[m+1];
#     assign ps_gpio_i[2*m+2] = gpio_i_p[m];
#     assign ps_gpio_i[2*m+3] = gpio_i_p[m+1];
