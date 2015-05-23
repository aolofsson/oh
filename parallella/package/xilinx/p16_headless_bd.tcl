
# create board design

# instance: sys_ps7
global sys_ps7
set sys_ps7  [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.4 sys_ps7]

# ???
set_property -dict [list CONFIG.PCW_IMPORT_BOARD_PRESET {ZC702}] $sys_ps7

#import parallella board ps generated from adapteva .xci 
source ./import/parallella_ps.tcl

# interface ports
set DDR [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR]
set FIXED_IO [create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO]
set IIC_MAIN [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 IIC_MAIN]
#set GPIO_I [create_bd_port -dir I -from 31 -to 0 GPIO_I]
#set GPIO_O [create_bd_port -dir O -from 31 -to 0 GPIO_O]
#set GPIO_T [create_bd_port -dir O -from 31 -to 0 GPIO_T]

# hdmi interface
#set hdmi_out_clk    [create_bd_port -dir O hdmi_out_clk]
#set hdmi_hsync      [create_bd_port -dir O hdmi_hsync]
#set hdmi_vsync      [create_bd_port -dir O hdmi_vsync]
#set hdmi_data_e     [create_bd_port -dir O hdmi_data_e]
#set hdmi_data       [create_bd_port -dir O -from 15 -to 0 hdmi_data]

# spdif audio
#set spdif           [create_bd_port -dir O spdif]



# address map
set sys_zynq 1
set sys_mem_size 0x40000000
set sys_addr_cntrl_space [get_bd_addr_spaces sys_ps7/Data]

create_bd_addr_seg -range 0x00010000 -offset 0x41600000 $sys_addr_cntrl_space  [get_bd_addr_segs axi_iic_main/s_axi/Reg]             SEG_data_iic_main
create_bd_addr_seg -range 0x00010000 -offset 0x79000000 $sys_addr_cntrl_space  [get_bd_addr_segs axi_hdmi_clkgen/s_axi/axi_lite]     SEG_data_hdmi_clkgen
create_bd_addr_seg -range 0x00010000 -offset 0x43000000 $sys_addr_cntrl_space  [get_bd_addr_segs axi_hdmi_dma/S_AXI_LITE/Reg]        SEG_data_hdmi_dma
create_bd_addr_seg -range 0x00010000 -offset 0x70e00000 $sys_addr_cntrl_space  [get_bd_addr_segs axi_hdmi_core/s_axi/axi_lite]       SEG_data_hdmi_core
create_bd_addr_seg -range 0x00010000 -offset 0x75c00000 $sys_addr_cntrl_space  [get_bd_addr_segs axi_spdif_tx_core/S_AXI/reg0]       SEG_data_spdif_core

create_bd_addr_seg -range $sys_mem_size -offset 0x00000000 [get_bd_addr_spaces axi_hdmi_dma/Data_MM2S]     [get_bd_addr_segs sys_ps7/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_sys_ps7_hp0_ddr_lowocm



