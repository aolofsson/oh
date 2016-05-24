# SPI slave clock
create_clock -name spi_s_sclk -period 10 [get_ports spi_s_sclk]
# SPI master clock
create_clock -name spi_m_sclk -period 10 [get_ports spi_m_sclk]
