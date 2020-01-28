create_clock -period 3.33333333 -name rxi_lclk_p -waveform {0.000 1.66666667} [get_ports rxi_lclk_p]

# Differential input clock from SI570 clock synthesizer
# Constrained to 297MHz (2160p30 video resolution)
create_clock -period 3.367 -name si570_clk [get_ports si570_clk_p]

