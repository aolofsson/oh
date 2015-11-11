
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z020clg400-1

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: sys_wfifo_3
proc create_hier_cell_sys_wfifo_3 { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_sys_wfifo_3() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type clk adc_clk
  create_bd_pin -dir I adc_rst
  create_bd_pin -dir I -from 15 -to 0 adc_wdata
  create_bd_pin -dir O adc_wovf
  create_bd_pin -dir I adc_wr
  create_bd_pin -dir I -type clk dma_clk
  create_bd_pin -dir O -from 15 -to 0 dma_wdata
  create_bd_pin -dir I dma_wovf
  create_bd_pin -dir O dma_wr

  # Create instance: wfifo_ctl, and set properties
  set wfifo_ctl [ create_bd_cell -type ip -vlnv analog.com:user:util_wfifo:1.0 wfifo_ctl ]
  set_property -dict [ list CONFIG.ADC_DATA_WIDTH {16} CONFIG.DMA_DATA_WIDTH {16}  ] $wfifo_ctl

  # Create instance: wfifo_mem, and set properties
  set wfifo_mem [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:12.0 wfifo_mem ]
  set_property -dict [ list CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} CONFIG.INTERFACE_TYPE {Native} CONFIG.Input_Data_Width {16} CONFIG.Input_Depth {64} CONFIG.Output_Data_Width {16} CONFIG.Overflow_Flag {true}  ] $wfifo_mem

  # Create port connections
  connect_bd_net -net adc_clk [get_bd_pins adc_clk] [get_bd_pins wfifo_ctl/adc_clk] [get_bd_pins wfifo_mem/wr_clk]
  connect_bd_net -net adc_rst [get_bd_pins adc_rst] [get_bd_pins wfifo_ctl/adc_rst]
  connect_bd_net -net adc_wdata [get_bd_pins adc_wdata] [get_bd_pins wfifo_ctl/adc_wdata]
  connect_bd_net -net adc_wovf [get_bd_pins adc_wovf] [get_bd_pins wfifo_ctl/adc_wovf]
  connect_bd_net -net adc_wr [get_bd_pins adc_wr] [get_bd_pins wfifo_ctl/adc_wr]
  connect_bd_net -net dma_clk [get_bd_pins dma_clk] [get_bd_pins wfifo_ctl/dma_clk] [get_bd_pins wfifo_mem/rd_clk]
  connect_bd_net -net dma_wdata [get_bd_pins dma_wdata] [get_bd_pins wfifo_ctl/dma_wdata]
  connect_bd_net -net dma_wovf [get_bd_pins dma_wovf] [get_bd_pins wfifo_ctl/dma_wovf]
  connect_bd_net -net dma_wr [get_bd_pins dma_wr] [get_bd_pins wfifo_ctl/dma_wr]
  connect_bd_net -net wfifo_ctl_fifo_rd [get_bd_pins wfifo_ctl/fifo_rd] [get_bd_pins wfifo_mem/rd_en]
  connect_bd_net -net wfifo_ctl_fifo_rdata [get_bd_pins wfifo_ctl/fifo_rdata] [get_bd_pins wfifo_mem/dout]
  connect_bd_net -net wfifo_ctl_fifo_rempty [get_bd_pins wfifo_ctl/fifo_rempty] [get_bd_pins wfifo_mem/empty]
  connect_bd_net -net wfifo_ctl_fifo_rst [get_bd_pins wfifo_ctl/fifo_rst] [get_bd_pins wfifo_mem/rst]
  connect_bd_net -net wfifo_ctl_fifo_wdata [get_bd_pins wfifo_ctl/fifo_wdata] [get_bd_pins wfifo_mem/din]
  connect_bd_net -net wfifo_ctl_fifo_wovf [get_bd_pins wfifo_ctl/fifo_wovf] [get_bd_pins wfifo_mem/overflow]
  connect_bd_net -net wfifo_ctl_fifo_wr [get_bd_pins wfifo_ctl/fifo_wr] [get_bd_pins wfifo_mem/wr_en]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: sys_wfifo_2
proc create_hier_cell_sys_wfifo_2 { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_sys_wfifo_2() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type clk adc_clk
  create_bd_pin -dir I adc_rst
  create_bd_pin -dir I -from 15 -to 0 adc_wdata
  create_bd_pin -dir O adc_wovf
  create_bd_pin -dir I adc_wr
  create_bd_pin -dir I -type clk dma_clk
  create_bd_pin -dir O -from 15 -to 0 dma_wdata
  create_bd_pin -dir I dma_wovf
  create_bd_pin -dir O dma_wr

  # Create instance: wfifo_ctl, and set properties
  set wfifo_ctl [ create_bd_cell -type ip -vlnv analog.com:user:util_wfifo:1.0 wfifo_ctl ]
  set_property -dict [ list CONFIG.ADC_DATA_WIDTH {16} CONFIG.DMA_DATA_WIDTH {16}  ] $wfifo_ctl

  # Create instance: wfifo_mem, and set properties
  set wfifo_mem [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:12.0 wfifo_mem ]
  set_property -dict [ list CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} CONFIG.INTERFACE_TYPE {Native} CONFIG.Input_Data_Width {16} CONFIG.Input_Depth {64} CONFIG.Output_Data_Width {16} CONFIG.Overflow_Flag {true}  ] $wfifo_mem

  # Create port connections
  connect_bd_net -net adc_clk [get_bd_pins adc_clk] [get_bd_pins wfifo_ctl/adc_clk] [get_bd_pins wfifo_mem/wr_clk]
  connect_bd_net -net adc_rst [get_bd_pins adc_rst] [get_bd_pins wfifo_ctl/adc_rst]
  connect_bd_net -net adc_wdata [get_bd_pins adc_wdata] [get_bd_pins wfifo_ctl/adc_wdata]
  connect_bd_net -net adc_wovf [get_bd_pins adc_wovf] [get_bd_pins wfifo_ctl/adc_wovf]
  connect_bd_net -net adc_wr [get_bd_pins adc_wr] [get_bd_pins wfifo_ctl/adc_wr]
  connect_bd_net -net dma_clk [get_bd_pins dma_clk] [get_bd_pins wfifo_ctl/dma_clk] [get_bd_pins wfifo_mem/rd_clk]
  connect_bd_net -net dma_wdata [get_bd_pins dma_wdata] [get_bd_pins wfifo_ctl/dma_wdata]
  connect_bd_net -net dma_wovf [get_bd_pins dma_wovf] [get_bd_pins wfifo_ctl/dma_wovf]
  connect_bd_net -net dma_wr [get_bd_pins dma_wr] [get_bd_pins wfifo_ctl/dma_wr]
  connect_bd_net -net wfifo_ctl_fifo_rd [get_bd_pins wfifo_ctl/fifo_rd] [get_bd_pins wfifo_mem/rd_en]
  connect_bd_net -net wfifo_ctl_fifo_rdata [get_bd_pins wfifo_ctl/fifo_rdata] [get_bd_pins wfifo_mem/dout]
  connect_bd_net -net wfifo_ctl_fifo_rempty [get_bd_pins wfifo_ctl/fifo_rempty] [get_bd_pins wfifo_mem/empty]
  connect_bd_net -net wfifo_ctl_fifo_rst [get_bd_pins wfifo_ctl/fifo_rst] [get_bd_pins wfifo_mem/rst]
  connect_bd_net -net wfifo_ctl_fifo_wdata [get_bd_pins wfifo_ctl/fifo_wdata] [get_bd_pins wfifo_mem/din]
  connect_bd_net -net wfifo_ctl_fifo_wovf [get_bd_pins wfifo_ctl/fifo_wovf] [get_bd_pins wfifo_mem/overflow]
  connect_bd_net -net wfifo_ctl_fifo_wr [get_bd_pins wfifo_ctl/fifo_wr] [get_bd_pins wfifo_mem/wr_en]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: sys_wfifo_1
proc create_hier_cell_sys_wfifo_1 { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_sys_wfifo_1() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type clk adc_clk
  create_bd_pin -dir I adc_rst
  create_bd_pin -dir I -from 15 -to 0 adc_wdata
  create_bd_pin -dir O adc_wovf
  create_bd_pin -dir I adc_wr
  create_bd_pin -dir I -type clk dma_clk
  create_bd_pin -dir O -from 15 -to 0 dma_wdata
  create_bd_pin -dir I dma_wovf
  create_bd_pin -dir O dma_wr

  # Create instance: wfifo_ctl, and set properties
  set wfifo_ctl [ create_bd_cell -type ip -vlnv analog.com:user:util_wfifo:1.0 wfifo_ctl ]
  set_property -dict [ list CONFIG.ADC_DATA_WIDTH {16} CONFIG.DMA_DATA_WIDTH {16}  ] $wfifo_ctl

  # Create instance: wfifo_mem, and set properties
  set wfifo_mem [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:12.0 wfifo_mem ]
  set_property -dict [ list CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} CONFIG.INTERFACE_TYPE {Native} CONFIG.Input_Data_Width {16} CONFIG.Input_Depth {64} CONFIG.Output_Data_Width {16} CONFIG.Overflow_Flag {true}  ] $wfifo_mem

  # Create port connections
  connect_bd_net -net adc_clk [get_bd_pins adc_clk] [get_bd_pins wfifo_ctl/adc_clk] [get_bd_pins wfifo_mem/wr_clk]
  connect_bd_net -net adc_rst [get_bd_pins adc_rst] [get_bd_pins wfifo_ctl/adc_rst]
  connect_bd_net -net adc_wdata [get_bd_pins adc_wdata] [get_bd_pins wfifo_ctl/adc_wdata]
  connect_bd_net -net adc_wovf [get_bd_pins adc_wovf] [get_bd_pins wfifo_ctl/adc_wovf]
  connect_bd_net -net adc_wr [get_bd_pins adc_wr] [get_bd_pins wfifo_ctl/adc_wr]
  connect_bd_net -net dma_clk [get_bd_pins dma_clk] [get_bd_pins wfifo_ctl/dma_clk] [get_bd_pins wfifo_mem/rd_clk]
  connect_bd_net -net dma_wdata [get_bd_pins dma_wdata] [get_bd_pins wfifo_ctl/dma_wdata]
  connect_bd_net -net dma_wovf [get_bd_pins dma_wovf] [get_bd_pins wfifo_ctl/dma_wovf]
  connect_bd_net -net dma_wr [get_bd_pins dma_wr] [get_bd_pins wfifo_ctl/dma_wr]
  connect_bd_net -net wfifo_ctl_fifo_rd [get_bd_pins wfifo_ctl/fifo_rd] [get_bd_pins wfifo_mem/rd_en]
  connect_bd_net -net wfifo_ctl_fifo_rdata [get_bd_pins wfifo_ctl/fifo_rdata] [get_bd_pins wfifo_mem/dout]
  connect_bd_net -net wfifo_ctl_fifo_rempty [get_bd_pins wfifo_ctl/fifo_rempty] [get_bd_pins wfifo_mem/empty]
  connect_bd_net -net wfifo_ctl_fifo_rst [get_bd_pins wfifo_ctl/fifo_rst] [get_bd_pins wfifo_mem/rst]
  connect_bd_net -net wfifo_ctl_fifo_wdata [get_bd_pins wfifo_ctl/fifo_wdata] [get_bd_pins wfifo_mem/din]
  connect_bd_net -net wfifo_ctl_fifo_wovf [get_bd_pins wfifo_ctl/fifo_wovf] [get_bd_pins wfifo_mem/overflow]
  connect_bd_net -net wfifo_ctl_fifo_wr [get_bd_pins wfifo_ctl/fifo_wr] [get_bd_pins wfifo_mem/wr_en]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: sys_wfifo_0
proc create_hier_cell_sys_wfifo_0 { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_sys_wfifo_0() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type clk adc_clk
  create_bd_pin -dir I adc_rst
  create_bd_pin -dir I -from 15 -to 0 adc_wdata
  create_bd_pin -dir O adc_wovf
  create_bd_pin -dir I adc_wr
  create_bd_pin -dir I -type clk dma_clk
  create_bd_pin -dir O -from 15 -to 0 dma_wdata
  create_bd_pin -dir I dma_wovf
  create_bd_pin -dir O dma_wr

  # Create instance: wfifo_ctl, and set properties
  set wfifo_ctl [ create_bd_cell -type ip -vlnv analog.com:user:util_wfifo:1.0 wfifo_ctl ]
  set_property -dict [ list CONFIG.ADC_DATA_WIDTH {16} CONFIG.DMA_DATA_WIDTH {16}  ] $wfifo_ctl

  # Create instance: wfifo_mem, and set properties
  set wfifo_mem [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:12.0 wfifo_mem ]
  set_property -dict [ list CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} CONFIG.INTERFACE_TYPE {Native} CONFIG.Input_Data_Width {16} CONFIG.Input_Depth {64} CONFIG.Output_Data_Width {16} CONFIG.Overflow_Flag {true}  ] $wfifo_mem

  # Create port connections
  connect_bd_net -net adc_clk [get_bd_pins adc_clk] [get_bd_pins wfifo_ctl/adc_clk] [get_bd_pins wfifo_mem/wr_clk]
  connect_bd_net -net adc_rst [get_bd_pins adc_rst] [get_bd_pins wfifo_ctl/adc_rst]
  connect_bd_net -net adc_wdata [get_bd_pins adc_wdata] [get_bd_pins wfifo_ctl/adc_wdata]
  connect_bd_net -net adc_wovf [get_bd_pins adc_wovf] [get_bd_pins wfifo_ctl/adc_wovf]
  connect_bd_net -net adc_wr [get_bd_pins adc_wr] [get_bd_pins wfifo_ctl/adc_wr]
  connect_bd_net -net dma_clk [get_bd_pins dma_clk] [get_bd_pins wfifo_ctl/dma_clk] [get_bd_pins wfifo_mem/rd_clk]
  connect_bd_net -net dma_wdata [get_bd_pins dma_wdata] [get_bd_pins wfifo_ctl/dma_wdata]
  connect_bd_net -net dma_wovf [get_bd_pins dma_wovf] [get_bd_pins wfifo_ctl/dma_wovf]
  connect_bd_net -net dma_wr [get_bd_pins dma_wr] [get_bd_pins wfifo_ctl/dma_wr]
  connect_bd_net -net wfifo_ctl_fifo_rd [get_bd_pins wfifo_ctl/fifo_rd] [get_bd_pins wfifo_mem/rd_en]
  connect_bd_net -net wfifo_ctl_fifo_rdata [get_bd_pins wfifo_ctl/fifo_rdata] [get_bd_pins wfifo_mem/dout]
  connect_bd_net -net wfifo_ctl_fifo_rempty [get_bd_pins wfifo_ctl/fifo_rempty] [get_bd_pins wfifo_mem/empty]
  connect_bd_net -net wfifo_ctl_fifo_rst [get_bd_pins wfifo_ctl/fifo_rst] [get_bd_pins wfifo_mem/rst]
  connect_bd_net -net wfifo_ctl_fifo_wdata [get_bd_pins wfifo_ctl/fifo_wdata] [get_bd_pins wfifo_mem/din]
  connect_bd_net -net wfifo_ctl_fifo_wovf [get_bd_pins wfifo_ctl/fifo_wovf] [get_bd_pins wfifo_mem/overflow]
  connect_bd_net -net wfifo_ctl_fifo_wr [get_bd_pins wfifo_ctl/fifo_wr] [get_bd_pins wfifo_mem/wr_en]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set ddr [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr ]
  set fixed_io [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 fixed_io ]
  set iic_main [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_main ]

  # Create ports
  set enable [ create_bd_port -dir O enable ]
  set gpio_i [ create_bd_port -dir I -from 63 -to 0 gpio_i ]
  set gpio_o [ create_bd_port -dir O -from 63 -to 0 gpio_o ]
  set gpio_t [ create_bd_port -dir O -from 63 -to 0 gpio_t ]
  set hdmi_data [ create_bd_port -dir O -from 15 -to 0 hdmi_data ]
  set hdmi_data_e [ create_bd_port -dir O hdmi_data_e ]
  set hdmi_hsync [ create_bd_port -dir O hdmi_hsync ]
  set hdmi_out_clk [ create_bd_port -dir O hdmi_out_clk ]
  set hdmi_vsync [ create_bd_port -dir O hdmi_vsync ]
  set ps_intr_00 [ create_bd_port -dir I -type intr ps_intr_00 ]
  set ps_intr_01 [ create_bd_port -dir I -type intr ps_intr_01 ]
  set ps_intr_02 [ create_bd_port -dir I -type intr ps_intr_02 ]
  set ps_intr_03 [ create_bd_port -dir I -type intr ps_intr_03 ]
  set ps_intr_04 [ create_bd_port -dir I -type intr ps_intr_04 ]
  set ps_intr_05 [ create_bd_port -dir I -type intr ps_intr_05 ]
  set ps_intr_06 [ create_bd_port -dir I -type intr ps_intr_06 ]
  set ps_intr_07 [ create_bd_port -dir I -type intr ps_intr_07 ]
  set ps_intr_08 [ create_bd_port -dir I -type intr ps_intr_08 ]
  set ps_intr_09 [ create_bd_port -dir I -type intr ps_intr_09 ]
  set ps_intr_10 [ create_bd_port -dir I -type intr ps_intr_10 ]
  set ps_intr_11 [ create_bd_port -dir I -type intr ps_intr_11 ]
  set rx_clk_in_n [ create_bd_port -dir I rx_clk_in_n ]
  set rx_clk_in_p [ create_bd_port -dir I rx_clk_in_p ]
  set rx_data_in_n [ create_bd_port -dir I -from 5 -to 0 rx_data_in_n ]
  set rx_data_in_p [ create_bd_port -dir I -from 5 -to 0 rx_data_in_p ]
  set rx_frame_in_n [ create_bd_port -dir I rx_frame_in_n ]
  set rx_frame_in_p [ create_bd_port -dir I rx_frame_in_p ]
  set spdif [ create_bd_port -dir O spdif ]
  set spi0_clk_i [ create_bd_port -dir I spi0_clk_i ]
  set spi0_clk_o [ create_bd_port -dir O spi0_clk_o ]
  set spi0_csn_0_o [ create_bd_port -dir O spi0_csn_0_o ]
  set spi0_csn_1_o [ create_bd_port -dir O spi0_csn_1_o ]
  set spi0_csn_2_o [ create_bd_port -dir O spi0_csn_2_o ]
  set spi0_csn_i [ create_bd_port -dir I spi0_csn_i ]
  set spi0_sdi_i [ create_bd_port -dir I spi0_sdi_i ]
  set spi0_sdo_i [ create_bd_port -dir I spi0_sdo_i ]
  set spi0_sdo_o [ create_bd_port -dir O spi0_sdo_o ]
  set spi1_clk_i [ create_bd_port -dir I spi1_clk_i ]
  set spi1_clk_o [ create_bd_port -dir O spi1_clk_o ]
  set spi1_csn_0_o [ create_bd_port -dir O spi1_csn_0_o ]
  set spi1_csn_1_o [ create_bd_port -dir O spi1_csn_1_o ]
  set spi1_csn_2_o [ create_bd_port -dir O spi1_csn_2_o ]
  set spi1_csn_i [ create_bd_port -dir I spi1_csn_i ]
  set spi1_sdi_i [ create_bd_port -dir I spi1_sdi_i ]
  set spi1_sdo_i [ create_bd_port -dir I spi1_sdo_i ]
  set spi1_sdo_o [ create_bd_port -dir O spi1_sdo_o ]
  set tdd_enable [ create_bd_port -dir O tdd_enable ]
  set tdd_sync_i [ create_bd_port -dir I tdd_sync_i ]
  set tdd_sync_o [ create_bd_port -dir O tdd_sync_o ]
  set tdd_sync_t [ create_bd_port -dir O tdd_sync_t ]
  set tx_clk_out_n [ create_bd_port -dir O tx_clk_out_n ]
  set tx_clk_out_p [ create_bd_port -dir O tx_clk_out_p ]
  set tx_data_out_n [ create_bd_port -dir O -from 5 -to 0 tx_data_out_n ]
  set tx_data_out_p [ create_bd_port -dir O -from 5 -to 0 tx_data_out_p ]
  set tx_frame_out_n [ create_bd_port -dir O tx_frame_out_n ]
  set tx_frame_out_p [ create_bd_port -dir O tx_frame_out_p ]
  set txnrx [ create_bd_port -dir O txnrx ]

  # Create instance: axi_ad9361, and set properties
  set axi_ad9361 [ create_bd_cell -type ip -vlnv analog.com:user:axi_ad9361:1.0 axi_ad9361 ]
  set_property -dict [ list CONFIG.PCORE_ID {0}  ] $axi_ad9361

  # Create instance: axi_ad9361_adc_dma, and set properties
  set axi_ad9361_adc_dma [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_ad9361_adc_dma ]
  set_property -dict [ list CONFIG.C_2D_TRANSFER {0} CONFIG.C_AXI_SLICE_DEST {0} CONFIG.C_AXI_SLICE_SRC {0} CONFIG.C_CLKS_ASYNC_DEST_REQ {0} CONFIG.C_CLKS_ASYNC_REQ_SRC {1} CONFIG.C_CLKS_ASYNC_SRC_DEST {1} CONFIG.C_CYCLIC {0} CONFIG.C_DMA_DATA_WIDTH_SRC {64} CONFIG.C_DMA_TYPE_DEST {0} CONFIG.C_DMA_TYPE_SRC {2} CONFIG.C_SYNC_TRANSFER_START {1}  ] $axi_ad9361_adc_dma

  # Create instance: axi_ad9361_dac_dma, and set properties
  set axi_ad9361_dac_dma [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_ad9361_dac_dma ]
  set_property -dict [ list CONFIG.C_2D_TRANSFER {0} CONFIG.C_AXI_SLICE_DEST {1} CONFIG.C_AXI_SLICE_SRC {0} CONFIG.C_CLKS_ASYNC_DEST_REQ {1} CONFIG.C_CLKS_ASYNC_REQ_SRC {0} CONFIG.C_CLKS_ASYNC_SRC_DEST {1} CONFIG.C_CYCLIC {1} CONFIG.C_DMA_DATA_WIDTH_DEST {64} CONFIG.C_DMA_TYPE_DEST {2} CONFIG.C_DMA_TYPE_SRC {0} CONFIG.C_SYNC_TRANSFER_START {0}  ] $axi_ad9361_dac_dma

  # Create instance: axi_cpu_interconnect, and set properties
  set axi_cpu_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_cpu_interconnect ]
  set_property -dict [ list CONFIG.NUM_MI {8}  ] $axi_cpu_interconnect

  # Create instance: axi_hdmi_clkgen, and set properties
  set axi_hdmi_clkgen [ create_bd_cell -type ip -vlnv analog.com:user:axi_clkgen:1.0 axi_hdmi_clkgen ]

  # Create instance: axi_hdmi_core, and set properties
  set axi_hdmi_core [ create_bd_cell -type ip -vlnv analog.com:user:axi_hdmi_tx:1.0 axi_hdmi_core ]

  # Create instance: axi_hdmi_dma, and set properties
  set axi_hdmi_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vdma:6.2 axi_hdmi_dma ]
  set_property -dict [ list CONFIG.c_include_s2mm {0} CONFIG.c_m_axis_mm2s_tdata_width {64} CONFIG.c_use_mm2s_fsync {1}  ] $axi_hdmi_dma

  # Create instance: axi_hp0_interconnect, and set properties
  set axi_hp0_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_hp0_interconnect ]
  set_property -dict [ list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1}  ] $axi_hp0_interconnect

  # Create instance: axi_hp1_interconnect, and set properties
  set axi_hp1_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_hp1_interconnect ]
  set_property -dict [ list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1}  ] $axi_hp1_interconnect

  # Create instance: axi_hp2_interconnect, and set properties
  set axi_hp2_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_hp2_interconnect ]
  set_property -dict [ list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1}  ] $axi_hp2_interconnect

  # Create instance: axi_iic_main, and set properties
  set axi_iic_main [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 axi_iic_main ]

  # Create instance: axi_spdif_tx_core, and set properties
  set axi_spdif_tx_core [ create_bd_cell -type ip -vlnv analog.com:user:axi_spdif_tx:1.0 axi_spdif_tx_core ]
  set_property -dict [ list CONFIG.C_DMA_TYPE {1} CONFIG.C_S_AXI_ADDR_WIDTH {16}  ] $axi_spdif_tx_core

  # Create instance: ila_adc, and set properties
  set ila_adc [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:5.1 ila_adc ]
  set_property -dict [ list CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_MONITOR_TYPE {Native} CONFIG.C_NUM_OF_PROBES {8} CONFIG.C_PROBE0_WIDTH {1} CONFIG.C_PROBE1_WIDTH {1} CONFIG.C_PROBE2_WIDTH {1} CONFIG.C_PROBE3_WIDTH {1} CONFIG.C_PROBE4_WIDTH {16} CONFIG.C_PROBE5_WIDTH {16} CONFIG.C_PROBE6_WIDTH {16} CONFIG.C_PROBE7_WIDTH {16} CONFIG.C_TRIGIN_EN {false}  ] $ila_adc

  # Create instance: sys_audio_clkgen, and set properties
  set sys_audio_clkgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.1 sys_audio_clkgen ]
  set_property -dict [ list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {12.288} CONFIG.PRIM_IN_FREQ {200.000} CONFIG.RESET_TYPE {ACTIVE_LOW} CONFIG.USE_LOCKED {false} CONFIG.USE_RESET {true}  ] $sys_audio_clkgen

  # Create instance: sys_concat_intc, and set properties
  set sys_concat_intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 sys_concat_intc ]
  set_property -dict [ list CONFIG.NUM_PORTS {16}  ] $sys_concat_intc

  # Create instance: sys_ps7, and set properties
#  set design_1_processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.4 design_1_processing_system7_0 ]
#  set_property -dict [ list CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.062893} CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {40.000000} CONFIG.PCW_ACT_I2C_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {50.000000} CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} CONFIG.PCW_ACT_USB0_PERIPHERAL_FREQMHZ {60} CONFIG.PCW_ACT_USB1_PERIPHERAL_FREQMHZ {60} CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {666.666666} CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} CONFIG.PCW_CAN0_BASEADDR {0xE0008000} CONFIG.PCW_CAN0_CAN0_IO {<Select>} CONFIG.PCW_CAN0_GRP_CLK_ENABLE {0} CONFIG.PCW_CAN0_GRP_CLK_IO {<Select>} CONFIG.PCW_CAN0_HIGHADDR {0xE0008FFF} CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External} CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0} CONFIG.PCW_CAN0_PERIPHERAL_FREQMHZ {-1} CONFIG.PCW_CAN1_BASEADDR {0xE0009000} CONFIG.PCW_CAN1_CAN1_IO {<Select>} CONFIG.PCW_CAN1_GRP_CLK_ENABLE {0} CONFIG.PCW_CAN1_GRP_CLK_IO {<Select>} CONFIG.PCW_CAN1_HIGHADDR {0xE0009FFF} CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External} CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0} CONFIG.PCW_CAN1_PERIPHERAL_FREQMHZ {-1} CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_CAN_PERIPHERAL_VALID {0} CONFIG.PCW_CLK0_FREQ {100000000} CONFIG.PCW_CLK1_FREQ {200000000} CONFIG.PCW_CLK2_FREQ {200000000} CONFIG.PCW_CLK3_FREQ {40000000} CONFIG.PCW_CORE0_FIQ_INTR {0} CONFIG.PCW_CORE0_IRQ_INTR {0} CONFIG.PCW_CORE1_FIQ_INTR {0} CONFIG.PCW_CORE1_IRQ_INTR {0} CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {667} CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {53} CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {3} CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} CONFIG.PCW_DDRPLL_CTRL_FBDIV {48} CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1600.000} CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION {HPR(0)/LPR(32)} CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL {15} CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL {2} CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {4} CONFIG.PCW_DDR_PORT0_HPR_ENABLE {0} CONFIG.PCW_DDR_PORT1_HPR_ENABLE {0} CONFIG.PCW_DDR_PORT2_HPR_ENABLE {0} CONFIG.PCW_DDR_PORT3_HPR_ENABLE {0} CONFIG.PCW_DDR_PRIORITY_READPORT_0 {<Select>} CONFIG.PCW_DDR_PRIORITY_READPORT_1 {<Select>} CONFIG.PCW_DDR_PRIORITY_READPORT_2 {<Select>} CONFIG.PCW_DDR_PRIORITY_READPORT_3 {<Select>} CONFIG.PCW_DDR_PRIORITY_WRITEPORT_0 {<Select>} CONFIG.PCW_DDR_PRIORITY_WRITEPORT_1 {<Select>} CONFIG.PCW_DDR_PRIORITY_WRITEPORT_2 {<Select>} CONFIG.PCW_DDR_PRIORITY_WRITEPORT_3 {<Select>} CONFIG.PCW_DDR_RAM_BASEADDR {0x00100000} CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF} CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL {2} CONFIG.PCW_DM_WIDTH {4} CONFIG.PCW_DQS_WIDTH {4} CONFIG.PCW_DQ_WIDTH {32} CONFIG.PCW_ENET0_BASEADDR {0xE000B000} CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} CONFIG.PCW_ENET0_HIGHADDR {0xE000BFFF} CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} CONFIG.PCW_ENET0_RESET_ENABLE {0} CONFIG.PCW_ENET0_RESET_IO {<Select>} CONFIG.PCW_ENET1_BASEADDR {0xE000C000} CONFIG.PCW_ENET1_ENET1_IO {<Select>} CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {0} CONFIG.PCW_ENET1_GRP_MDIO_IO {<Select>} CONFIG.PCW_ENET1_HIGHADDR {0xE000CFFF} CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ {1000 Mbps} CONFIG.PCW_ENET1_RESET_ENABLE {0} CONFIG.PCW_ENET1_RESET_IO {<Select>} CONFIG.PCW_ENET_RESET_POLARITY {Active Low} CONFIG.PCW_EN_4K_TIMER {0} CONFIG.PCW_EN_CAN0 {0} CONFIG.PCW_EN_CAN1 {0} CONFIG.PCW_EN_CLK0_PORT {1} CONFIG.PCW_EN_CLK1_PORT {0} CONFIG.PCW_EN_CLK2_PORT {0} CONFIG.PCW_EN_CLK3_PORT {1} CONFIG.PCW_EN_CLKTRIG0_PORT {0} CONFIG.PCW_EN_CLKTRIG1_PORT {0} CONFIG.PCW_EN_CLKTRIG2_PORT {0} CONFIG.PCW_EN_CLKTRIG3_PORT {0} CONFIG.PCW_EN_DDR {1} CONFIG.PCW_EN_EMIO_CAN0 {0} CONFIG.PCW_EN_EMIO_CAN1 {0} CONFIG.PCW_EN_EMIO_CD_SDIO0 {0} CONFIG.PCW_EN_EMIO_CD_SDIO1 {0} CONFIG.PCW_EN_EMIO_ENET0 {0} CONFIG.PCW_EN_EMIO_ENET1 {0} CONFIG.PCW_EN_EMIO_GPIO {1} CONFIG.PCW_EN_EMIO_I2C0 {1} CONFIG.PCW_EN_EMIO_I2C1 {0} CONFIG.PCW_EN_EMIO_MODEM_UART0 {0} CONFIG.PCW_EN_EMIO_MODEM_UART1 {0} CONFIG.PCW_EN_EMIO_PJTAG {0} CONFIG.PCW_EN_EMIO_SDIO0 {0} CONFIG.PCW_EN_EMIO_SDIO1 {0} CONFIG.PCW_EN_EMIO_SPI0 {0} CONFIG.PCW_EN_EMIO_SPI1 {0} CONFIG.PCW_EN_EMIO_SRAM_INT {0} CONFIG.PCW_EN_EMIO_TRACE {0} CONFIG.PCW_EN_EMIO_TTC0 {0} CONFIG.PCW_EN_EMIO_TTC1 {0} CONFIG.PCW_EN_EMIO_UART0 {0} CONFIG.PCW_EN_EMIO_UART1 {0} CONFIG.PCW_EN_EMIO_WDT {0} CONFIG.PCW_EN_EMIO_WP_SDIO0 {0} CONFIG.PCW_EN_EMIO_WP_SDIO1 {0} CONFIG.PCW_EN_ENET0 {1} CONFIG.PCW_EN_ENET1 {0} CONFIG.PCW_EN_GPIO {1} CONFIG.PCW_EN_I2C0 {1} CONFIG.PCW_EN_I2C1 {0} CONFIG.PCW_EN_MODEM_UART0 {0} CONFIG.PCW_EN_MODEM_UART1 {0} CONFIG.PCW_EN_PJTAG {0} CONFIG.PCW_EN_QSPI {1} CONFIG.PCW_EN_RST0_PORT {1} CONFIG.PCW_EN_RST1_PORT {0} CONFIG.PCW_EN_RST2_PORT {0} CONFIG.PCW_EN_RST3_PORT {0} CONFIG.PCW_EN_SDIO0 {0} CONFIG.PCW_EN_SDIO1 {1} CONFIG.PCW_EN_SMC {0} CONFIG.PCW_EN_SPI0 {0} CONFIG.PCW_EN_SPI1 {0} CONFIG.PCW_EN_TRACE {0} CONFIG.PCW_EN_TTC0 {0} CONFIG.PCW_EN_TTC1 {0} CONFIG.PCW_EN_UART0 {0} CONFIG.PCW_EN_UART1 {1} CONFIG.PCW_EN_USB0 {1} CONFIG.PCW_EN_USB1 {1} CONFIG.PCW_EN_WDT {0} CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {10} CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {5} CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {5} CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {25} CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_FCLK_CLK0_BUF {true} CONFIG.PCW_FCLK_CLK1_BUF {false} CONFIG.PCW_FCLK_CLK2_BUF {false} CONFIG.PCW_FCLK_CLK3_BUF {true} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {40} CONFIG.PCW_FPGA_FCLK0_ENABLE {1} CONFIG.PCW_FPGA_FCLK1_ENABLE {0} CONFIG.PCW_FPGA_FCLK2_ENABLE {0} CONFIG.PCW_FPGA_FCLK3_ENABLE {1} CONFIG.PCW_FTM_CTI_IN0 {<Select>} CONFIG.PCW_FTM_CTI_IN1 {<Select>} CONFIG.PCW_FTM_CTI_IN2 {<Select>} CONFIG.PCW_FTM_CTI_IN3 {<Select>} CONFIG.PCW_FTM_CTI_OUT0 {<Select>} CONFIG.PCW_FTM_CTI_OUT1 {<Select>} CONFIG.PCW_FTM_CTI_OUT2 {<Select>} CONFIG.PCW_FTM_CTI_OUT3 {<Select>} CONFIG.PCW_GPIO_BASEADDR {0xE000A000} CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} CONFIG.PCW_GPIO_EMIO_GPIO_IO {64} CONFIG.PCW_GPIO_EMIO_GPIO_WIDTH {64} CONFIG.PCW_GPIO_HIGHADDR {0xE000AFFF} CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {0} CONFIG.PCW_I2C0_BASEADDR {0xE0004000} CONFIG.PCW_I2C0_GRP_INT_ENABLE {1} CONFIG.PCW_I2C0_GRP_INT_IO {EMIO} CONFIG.PCW_I2C0_HIGHADDR {0xE0004FFF} CONFIG.PCW_I2C0_I2C0_IO {EMIO} CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} CONFIG.PCW_I2C0_RESET_ENABLE {0} CONFIG.PCW_I2C0_RESET_IO {<Select>} CONFIG.PCW_I2C1_BASEADDR {0xE0005000} CONFIG.PCW_I2C1_GRP_INT_ENABLE {0} CONFIG.PCW_I2C1_GRP_INT_IO {<Select>} CONFIG.PCW_I2C1_HIGHADDR {0xE0005FFF} CONFIG.PCW_I2C1_I2C1_IO {<Select>} CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} CONFIG.PCW_I2C1_RESET_ENABLE {0} CONFIG.PCW_I2C1_RESET_IO {<Select>} CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_I2C_RESET_POLARITY {Active Low} CONFIG.PCW_IMPORT_BOARD_PRESET {None} CONFIG.PCW_INCLUDE_ACP_TRANS_CHECK {0} CONFIG.PCW_INCLUDE_TRACE_BUFFER {0} CONFIG.PCW_IOPLL_CTRL_FBDIV {30} CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} CONFIG.PCW_IRQ_F2P_INTR {0} CONFIG.PCW_IRQ_F2P_MODE {DIRECT} CONFIG.PCW_MIO_0_DIRECTION {inout} CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_0_PULLUP {enabled} CONFIG.PCW_MIO_0_SLEW {slow} CONFIG.PCW_MIO_10_DIRECTION {inout} CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_10_PULLUP {enabled} CONFIG.PCW_MIO_10_SLEW {slow} CONFIG.PCW_MIO_11_DIRECTION {inout} CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_11_PULLUP {enabled} CONFIG.PCW_MIO_11_SLEW {slow} CONFIG.PCW_MIO_12_DIRECTION {inout} CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_12_PULLUP {enabled} CONFIG.PCW_MIO_12_SLEW {slow} CONFIG.PCW_MIO_13_DIRECTION {inout} CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_13_PULLUP {enabled} CONFIG.PCW_MIO_13_SLEW {slow} CONFIG.PCW_MIO_14_DIRECTION {inout} CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_14_PULLUP {enabled} CONFIG.PCW_MIO_14_SLEW {slow} CONFIG.PCW_MIO_15_DIRECTION {inout} CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_15_PULLUP {enabled} CONFIG.PCW_MIO_15_SLEW {slow} CONFIG.PCW_MIO_16_DIRECTION {out} CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_16_PULLUP {enabled} CONFIG.PCW_MIO_16_SLEW {slow} CONFIG.PCW_MIO_17_DIRECTION {out} CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_17_PULLUP {enabled} CONFIG.PCW_MIO_17_SLEW {slow} CONFIG.PCW_MIO_18_DIRECTION {out} CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_18_PULLUP {enabled} CONFIG.PCW_MIO_18_SLEW {slow} CONFIG.PCW_MIO_19_DIRECTION {out} CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_19_PULLUP {enabled} CONFIG.PCW_MIO_19_SLEW {slow} CONFIG.PCW_MIO_1_DIRECTION {out} CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_1_PULLUP {enabled} CONFIG.PCW_MIO_1_SLEW {slow} CONFIG.PCW_MIO_20_DIRECTION {out} CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_20_PULLUP {enabled} CONFIG.PCW_MIO_20_SLEW {slow} CONFIG.PCW_MIO_21_DIRECTION {out} CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_21_PULLUP {enabled} CONFIG.PCW_MIO_21_SLEW {slow} CONFIG.PCW_MIO_22_DIRECTION {in} CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_22_PULLUP {enabled} CONFIG.PCW_MIO_22_SLEW {slow} CONFIG.PCW_MIO_23_DIRECTION {in} CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_23_PULLUP {enabled} CONFIG.PCW_MIO_23_SLEW {slow} CONFIG.PCW_MIO_24_DIRECTION {in} CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_24_PULLUP {enabled} CONFIG.PCW_MIO_24_SLEW {slow} CONFIG.PCW_MIO_25_DIRECTION {in} CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_25_PULLUP {enabled} CONFIG.PCW_MIO_25_SLEW {slow} CONFIG.PCW_MIO_26_DIRECTION {in} CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_26_PULLUP {enabled} CONFIG.PCW_MIO_26_SLEW {slow} CONFIG.PCW_MIO_27_DIRECTION {in} CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_27_PULLUP {enabled} CONFIG.PCW_MIO_27_SLEW {slow} CONFIG.PCW_MIO_28_DIRECTION {inout} CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_28_PULLUP {enabled} CONFIG.PCW_MIO_28_SLEW {slow} CONFIG.PCW_MIO_29_DIRECTION {in} CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_29_PULLUP {enabled} CONFIG.PCW_MIO_29_SLEW {slow} CONFIG.PCW_MIO_2_DIRECTION {inout} CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_2_PULLUP {disabled} CONFIG.PCW_MIO_2_SLEW {slow} CONFIG.PCW_MIO_30_DIRECTION {out} CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_30_PULLUP {enabled} CONFIG.PCW_MIO_30_SLEW {slow} CONFIG.PCW_MIO_31_DIRECTION {in} CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_31_PULLUP {enabled} CONFIG.PCW_MIO_31_SLEW {slow} CONFIG.PCW_MIO_32_DIRECTION {inout} CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_32_PULLUP {enabled} CONFIG.PCW_MIO_32_SLEW {slow} CONFIG.PCW_MIO_33_DIRECTION {inout} CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_33_PULLUP {enabled} CONFIG.PCW_MIO_33_SLEW {slow} CONFIG.PCW_MIO_34_DIRECTION {inout} CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_34_PULLUP {enabled} CONFIG.PCW_MIO_34_SLEW {slow} CONFIG.PCW_MIO_35_DIRECTION {inout} CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_35_PULLUP {enabled} CONFIG.PCW_MIO_35_SLEW {slow} CONFIG.PCW_MIO_36_DIRECTION {in} CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_36_PULLUP {enabled} CONFIG.PCW_MIO_36_SLEW {slow} CONFIG.PCW_MIO_37_DIRECTION {inout} CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_37_PULLUP {enabled} CONFIG.PCW_MIO_37_SLEW {slow} CONFIG.PCW_MIO_38_DIRECTION {inout} CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_38_PULLUP {enabled} CONFIG.PCW_MIO_38_SLEW {slow} CONFIG.PCW_MIO_39_DIRECTION {inout} CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_39_PULLUP {enabled} CONFIG.PCW_MIO_39_SLEW {slow} CONFIG.PCW_MIO_3_DIRECTION {inout} CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_3_PULLUP {disabled} CONFIG.PCW_MIO_3_SLEW {slow} CONFIG.PCW_MIO_40_DIRECTION {inout} CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_40_PULLUP {enabled} CONFIG.PCW_MIO_40_SLEW {slow} CONFIG.PCW_MIO_41_DIRECTION {in} CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_41_PULLUP {enabled} CONFIG.PCW_MIO_41_SLEW {slow} CONFIG.PCW_MIO_42_DIRECTION {out} CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_42_PULLUP {enabled} CONFIG.PCW_MIO_42_SLEW {slow} CONFIG.PCW_MIO_43_DIRECTION {in} CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_43_PULLUP {enabled} CONFIG.PCW_MIO_43_SLEW {slow} CONFIG.PCW_MIO_44_DIRECTION {inout} CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_44_PULLUP {enabled} CONFIG.PCW_MIO_44_SLEW {slow} CONFIG.PCW_MIO_45_DIRECTION {inout} CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_45_PULLUP {enabled} CONFIG.PCW_MIO_45_SLEW {slow} CONFIG.PCW_MIO_46_DIRECTION {inout} CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_46_PULLUP {enabled} CONFIG.PCW_MIO_46_SLEW {slow} CONFIG.PCW_MIO_47_DIRECTION {inout} CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_47_PULLUP {enabled} CONFIG.PCW_MIO_47_SLEW {slow} CONFIG.PCW_MIO_48_DIRECTION {in} CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_48_PULLUP {enabled} CONFIG.PCW_MIO_48_SLEW {slow} CONFIG.PCW_MIO_49_DIRECTION {inout} CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_49_PULLUP {enabled} CONFIG.PCW_MIO_49_SLEW {slow} CONFIG.PCW_MIO_4_DIRECTION {inout} CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_4_PULLUP {disabled} CONFIG.PCW_MIO_4_SLEW {slow} CONFIG.PCW_MIO_50_DIRECTION {inout} CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_50_PULLUP {enabled} CONFIG.PCW_MIO_50_SLEW {slow} CONFIG.PCW_MIO_51_DIRECTION {inout} CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_51_PULLUP {enabled} CONFIG.PCW_MIO_51_SLEW {slow} CONFIG.PCW_MIO_52_DIRECTION {out} CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_52_PULLUP {enabled} CONFIG.PCW_MIO_52_SLEW {slow} CONFIG.PCW_MIO_53_DIRECTION {inout} CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_53_PULLUP {enabled} CONFIG.PCW_MIO_53_SLEW {slow} CONFIG.PCW_MIO_5_DIRECTION {inout} CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_5_PULLUP {disabled} CONFIG.PCW_MIO_5_SLEW {slow} CONFIG.PCW_MIO_6_DIRECTION {out} CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_6_PULLUP {disabled} CONFIG.PCW_MIO_6_SLEW {slow} CONFIG.PCW_MIO_7_DIRECTION {out} CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_7_PULLUP {disabled} CONFIG.PCW_MIO_7_SLEW {slow} CONFIG.PCW_MIO_8_DIRECTION {out} CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_8_PULLUP {disabled} CONFIG.PCW_MIO_8_SLEW {slow} CONFIG.PCW_MIO_9_DIRECTION {in} CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_9_PULLUP {enabled} CONFIG.PCW_MIO_9_SLEW {slow} CONFIG.PCW_MIO_PRIMITIVE {54} CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#GPIO#UART 1#UART 1#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#Enet 0#Enet 0} CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]#qspi0_sclk#gpio[7]#tx#rx#data[0]#cmd#clk#data[1]#data[2]#data[3]#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#mdc#mdio} CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {0} CONFIG.PCW_M_AXI_GP0_FREQMHZ {10} CONFIG.PCW_M_AXI_GP0_ID_WIDTH {12} CONFIG.PCW_M_AXI_GP0_SUPPORT_NARROW_BURST {0} CONFIG.PCW_M_AXI_GP0_THREAD_ID_WIDTH {12} CONFIG.PCW_M_AXI_GP1_ENABLE_STATIC_REMAP {0} CONFIG.PCW_M_AXI_GP1_FREQMHZ {10} CONFIG.PCW_M_AXI_GP1_ID_WIDTH {12} CONFIG.PCW_M_AXI_GP1_SUPPORT_NARROW_BURST {0} CONFIG.PCW_M_AXI_GP1_THREAD_ID_WIDTH {12} CONFIG.PCW_NAND_CYCLES_T_AR {0} CONFIG.PCW_NAND_CYCLES_T_CLR {0} CONFIG.PCW_NAND_CYCLES_T_RC {2} CONFIG.PCW_NAND_CYCLES_T_REA {1} CONFIG.PCW_NAND_CYCLES_T_RR {0} CONFIG.PCW_NAND_CYCLES_T_WC {2} CONFIG.PCW_NAND_CYCLES_T_WP {1} CONFIG.PCW_NAND_GRP_D8_ENABLE {0} CONFIG.PCW_NAND_GRP_D8_IO {<Select>} CONFIG.PCW_NAND_NAND_IO {<Select>} CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} CONFIG.PCW_NOR_CS0_T_CEOE {1} CONFIG.PCW_NOR_CS0_T_PC {1} CONFIG.PCW_NOR_CS0_T_RC {2} CONFIG.PCW_NOR_CS0_T_TR {1} CONFIG.PCW_NOR_CS0_T_WC {2} CONFIG.PCW_NOR_CS0_T_WP {1} CONFIG.PCW_NOR_CS0_WE_TIME {2} CONFIG.PCW_NOR_CS1_T_CEOE {1} CONFIG.PCW_NOR_CS1_T_PC {1} CONFIG.PCW_NOR_CS1_T_RC {2} CONFIG.PCW_NOR_CS1_T_TR {1} CONFIG.PCW_NOR_CS1_T_WC {2} CONFIG.PCW_NOR_CS1_T_WP {1} CONFIG.PCW_NOR_CS1_WE_TIME {2} CONFIG.PCW_NOR_GRP_A25_ENABLE {0} CONFIG.PCW_NOR_GRP_A25_IO {<Select>} CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} CONFIG.PCW_NOR_GRP_CS0_IO {<Select>} CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} CONFIG.PCW_NOR_GRP_CS1_IO {<Select>} CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} CONFIG.PCW_NOR_GRP_SRAM_CS0_IO {<Select>} CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} CONFIG.PCW_NOR_GRP_SRAM_CS1_IO {<Select>} CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} CONFIG.PCW_NOR_GRP_SRAM_INT_IO {<Select>} CONFIG.PCW_NOR_NOR_IO {<Select>} CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1} CONFIG.PCW_NOR_SRAM_CS0_T_PC {1} CONFIG.PCW_NOR_SRAM_CS0_T_RC {2} CONFIG.PCW_NOR_SRAM_CS0_T_TR {1} CONFIG.PCW_NOR_SRAM_CS0_T_WC {2} CONFIG.PCW_NOR_SRAM_CS0_T_WP {1} CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {2} CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1} CONFIG.PCW_NOR_SRAM_CS1_T_PC {1} CONFIG.PCW_NOR_SRAM_CS1_T_RC {2} CONFIG.PCW_NOR_SRAM_CS1_T_TR {1} CONFIG.PCW_NOR_SRAM_CS1_T_WC {2} CONFIG.PCW_NOR_SRAM_CS1_T_WP {1} CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {2} CONFIG.PCW_NUM_F2P_INTR_INPUTS {1} CONFIG.PCW_OVERRIDE_BASIC_CLOCK {0} CONFIG.PCW_P2F_CAN0_INTR {0} CONFIG.PCW_P2F_CAN1_INTR {0} CONFIG.PCW_P2F_CTI_INTR {0} CONFIG.PCW_P2F_DMAC0_INTR {0} CONFIG.PCW_P2F_DMAC1_INTR {0} CONFIG.PCW_P2F_DMAC2_INTR {0} CONFIG.PCW_P2F_DMAC3_INTR {0} CONFIG.PCW_P2F_DMAC4_INTR {0} CONFIG.PCW_P2F_DMAC5_INTR {0} CONFIG.PCW_P2F_DMAC6_INTR {0} CONFIG.PCW_P2F_DMAC7_INTR {0} CONFIG.PCW_P2F_DMAC_ABORT_INTR {0} CONFIG.PCW_P2F_ENET0_INTR {0} CONFIG.PCW_P2F_ENET1_INTR {0} CONFIG.PCW_P2F_GPIO_INTR {0} CONFIG.PCW_P2F_I2C0_INTR {0} CONFIG.PCW_P2F_I2C1_INTR {0} CONFIG.PCW_P2F_QSPI_INTR {0} CONFIG.PCW_P2F_SDIO0_INTR {0} CONFIG.PCW_P2F_SDIO1_INTR {0} CONFIG.PCW_P2F_SMC_INTR {0} CONFIG.PCW_P2F_SPI0_INTR {0} CONFIG.PCW_P2F_SPI1_INTR {0} CONFIG.PCW_P2F_UART0_INTR {0} CONFIG.PCW_P2F_UART1_INTR {0} CONFIG.PCW_P2F_USB0_INTR {0} CONFIG.PCW_P2F_USB1_INTR {0} CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.014} CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.012} CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.014} CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.015} CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.004} CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {0.002} CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {-0.001} CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.005} CONFIG.PCW_PACKAGE_NAME {clg400} CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_PERIPHERAL_BOARD_PRESET {None} CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} CONFIG.PCW_PJTAG_PJTAG_IO {<Select>} CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} CONFIG.PCW_PS7_SI_REV {PRODUCTION} CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {0} CONFIG.PCW_QSPI_GRP_FBCLK_IO {<Select>} CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} CONFIG.PCW_QSPI_GRP_IO1_IO {<Select>} CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} CONFIG.PCW_QSPI_GRP_SS1_IO {<Select>} CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF} CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {5} CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} CONFIG.PCW_SD0_GRP_CD_ENABLE {0} CONFIG.PCW_SD0_GRP_CD_IO {<Select>} CONFIG.PCW_SD0_GRP_POW_ENABLE {0} CONFIG.PCW_SD0_GRP_POW_IO {<Select>} CONFIG.PCW_SD0_GRP_WP_ENABLE {0} CONFIG.PCW_SD0_GRP_WP_IO {<Select>} CONFIG.PCW_SD0_PERIPHERAL_ENABLE {0} CONFIG.PCW_SD0_SD0_IO {<Select>} CONFIG.PCW_SD1_GRP_CD_ENABLE {0} CONFIG.PCW_SD1_GRP_CD_IO {<Select>} CONFIG.PCW_SD1_GRP_POW_ENABLE {0} CONFIG.PCW_SD1_GRP_POW_IO {<Select>} CONFIG.PCW_SD1_GRP_WP_ENABLE {0} CONFIG.PCW_SD1_GRP_WP_IO {<Select>} CONFIG.PCW_SD1_PERIPHERAL_ENABLE {1} CONFIG.PCW_SD1_SD1_IO {MIO 10 .. 15} CONFIG.PCW_SDIO0_BASEADDR {0xE0100000} CONFIG.PCW_SDIO0_HIGHADDR {0xE0100FFF} CONFIG.PCW_SDIO1_BASEADDR {0xE0101000} CONFIG.PCW_SDIO1_HIGHADDR {0xE0101FFF} CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {20} CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} CONFIG.PCW_SMC_CYCLE_T0 {NA} CONFIG.PCW_SMC_CYCLE_T1 {NA} CONFIG.PCW_SMC_CYCLE_T2 {NA} CONFIG.PCW_SMC_CYCLE_T3 {NA} CONFIG.PCW_SMC_CYCLE_T4 {NA} CONFIG.PCW_SMC_CYCLE_T5 {NA} CONFIG.PCW_SMC_CYCLE_T6 {NA} CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_SMC_PERIPHERAL_VALID {0} CONFIG.PCW_SPI0_BASEADDR {0xE0006000} CONFIG.PCW_SPI0_GRP_SS0_ENABLE {0} CONFIG.PCW_SPI0_GRP_SS0_IO {<Select>} CONFIG.PCW_SPI0_GRP_SS1_ENABLE {0} CONFIG.PCW_SPI0_GRP_SS1_IO {<Select>} CONFIG.PCW_SPI0_GRP_SS2_ENABLE {0} CONFIG.PCW_SPI0_GRP_SS2_IO {<Select>} CONFIG.PCW_SPI0_HIGHADDR {0xE0006FFF} CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {0} CONFIG.PCW_SPI0_SPI0_IO {<Select>} CONFIG.PCW_SPI1_BASEADDR {0xE0007000} CONFIG.PCW_SPI1_GRP_SS0_ENABLE {0} CONFIG.PCW_SPI1_GRP_SS0_IO {<Select>} CONFIG.PCW_SPI1_GRP_SS1_ENABLE {0} CONFIG.PCW_SPI1_GRP_SS1_IO {<Select>} CONFIG.PCW_SPI1_GRP_SS2_ENABLE {0} CONFIG.PCW_SPI1_GRP_SS2_IO {<Select>} CONFIG.PCW_SPI1_HIGHADDR {0xE0007FFF} CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {0} CONFIG.PCW_SPI1_SPI1_IO {<Select>} CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} CONFIG.PCW_SPI_PERIPHERAL_VALID {0} CONFIG.PCW_S_AXI_ACP_ARUSER_VAL {31} CONFIG.PCW_S_AXI_ACP_AWUSER_VAL {31} CONFIG.PCW_S_AXI_ACP_FREQMHZ {10} CONFIG.PCW_S_AXI_ACP_ID_WIDTH {3} CONFIG.PCW_S_AXI_GP0_FREQMHZ {10} CONFIG.PCW_S_AXI_GP0_ID_WIDTH {6} CONFIG.PCW_S_AXI_GP1_FREQMHZ {10} CONFIG.PCW_S_AXI_GP1_ID_WIDTH {6} CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64} CONFIG.PCW_S_AXI_HP0_FREQMHZ {10} CONFIG.PCW_S_AXI_HP0_ID_WIDTH {6} CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64} CONFIG.PCW_S_AXI_HP1_FREQMHZ {10} CONFIG.PCW_S_AXI_HP1_ID_WIDTH {6} CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64} CONFIG.PCW_S_AXI_HP2_FREQMHZ {10} CONFIG.PCW_S_AXI_HP2_ID_WIDTH {6} CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64} CONFIG.PCW_S_AXI_HP3_FREQMHZ {10} CONFIG.PCW_S_AXI_HP3_ID_WIDTH {6} CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_TRACE_BUFFER_CLOCK_DELAY {12} CONFIG.PCW_TRACE_BUFFER_FIFO_SIZE {128} CONFIG.PCW_TRACE_GRP_16BIT_ENABLE {0} CONFIG.PCW_TRACE_GRP_16BIT_IO {<Select>} CONFIG.PCW_TRACE_GRP_2BIT_ENABLE {0} CONFIG.PCW_TRACE_GRP_2BIT_IO {<Select>} CONFIG.PCW_TRACE_GRP_32BIT_ENABLE {0} CONFIG.PCW_TRACE_GRP_32BIT_IO {<Select>} CONFIG.PCW_TRACE_GRP_4BIT_ENABLE {0} CONFIG.PCW_TRACE_GRP_4BIT_IO {<Select>} CONFIG.PCW_TRACE_GRP_8BIT_ENABLE {0} CONFIG.PCW_TRACE_GRP_8BIT_IO {<Select>} CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0} CONFIG.PCW_TRACE_PIPELINE_WIDTH {8} CONFIG.PCW_TRACE_TRACE_IO {<Select>} CONFIG.PCW_TTC0_BASEADDR {0xE0104000} CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333333} CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333333} CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333333} CONFIG.PCW_TTC0_HIGHADDR {0xE0104fff} CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} CONFIG.PCW_TTC0_TTC0_IO {<Select>} CONFIG.PCW_TTC1_BASEADDR {0xE0105000} CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC1_CLK0_PERIPHERAL_FREQMHZ {133.333333} CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC1_CLK1_PERIPHERAL_FREQMHZ {133.333333} CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC1_CLK2_PERIPHERAL_FREQMHZ {133.333333} CONFIG.PCW_TTC1_HIGHADDR {0xE0105fff} CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} CONFIG.PCW_TTC1_TTC1_IO {<Select>} CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_UART0_BASEADDR {0xE0000000} CONFIG.PCW_UART0_BAUD_RATE {115200} CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} CONFIG.PCW_UART0_GRP_FULL_IO {<Select>} CONFIG.PCW_UART0_HIGHADDR {0xE0000FFF} CONFIG.PCW_UART0_PERIPHERAL_ENABLE {0} CONFIG.PCW_UART0_UART0_IO {<Select>} CONFIG.PCW_UART1_BASEADDR {0xE0001000} CONFIG.PCW_UART1_BAUD_RATE {115200} CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} CONFIG.PCW_UART1_GRP_FULL_IO {<Select>} CONFIG.PCW_UART1_HIGHADDR {0xE0001FFF} CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART1_UART1_IO {MIO 8 .. 9} CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {10} CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {400.000000} CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} CONFIG.PCW_UIPARAM_DDR_AL {0} CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} CONFIG.PCW_UIPARAM_DDR_BL {8} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {.434} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {.398} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {.410} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.0} CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} CONFIG.PCW_UIPARAM_DDR_CL {9} CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {80.4535} CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {80.4535} CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {80.4535} CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {80.4535} CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} CONFIG.PCW_UIPARAM_DDR_CWL {9} CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {8192 MBits} CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {105.056} CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {66.904} CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {89.1715} CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {113.63} CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {.315} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {.391} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {.374} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {.271} CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {98.503} CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {68.5855} CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {90.295} CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {103.977} CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {32 Bits} CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} CONFIG.PCW_UIPARAM_DDR_ENABLE {1} CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {400} CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3 (Low Voltage)} CONFIG.PCW_UIPARAM_DDR_PARTNO {Custom} CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} CONFIG.PCW_UIPARAM_DDR_T_FAW {50} CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {40} CONFIG.PCW_UIPARAM_DDR_T_RC {60} CONFIG.PCW_UIPARAM_DDR_T_RCD {9} CONFIG.PCW_UIPARAM_DDR_T_RP {9} CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {1} CONFIG.PCW_UIPARAM_GENERATE_SUMMARY {NA} CONFIG.PCW_USB0_BASEADDR {0xE0102000} CONFIG.PCW_USB0_HIGHADDR {0xE0102fff} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} CONFIG.PCW_USB0_RESET_ENABLE {0} CONFIG.PCW_USB0_RESET_IO {<Select>} CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} CONFIG.PCW_USB1_BASEADDR {0xE0103000} CONFIG.PCW_USB1_HIGHADDR {0xE0103fff} CONFIG.PCW_USB1_PERIPHERAL_ENABLE {1} CONFIG.PCW_USB1_PERIPHERAL_FREQMHZ {60} CONFIG.PCW_USB1_RESET_ENABLE {0} CONFIG.PCW_USB1_RESET_IO {<Select>} CONFIG.PCW_USB1_USB1_IO {MIO 40 .. 51} CONFIG.PCW_USB_RESET_POLARITY {Active Low} CONFIG.PCW_USE_AXI_FABRIC_IDLE {0} CONFIG.PCW_USE_CORESIGHT {0} CONFIG.PCW_USE_CROSS_TRIGGER {0} CONFIG.PCW_USE_CR_FABRIC {1} CONFIG.PCW_USE_DDR_BYPASS {0} CONFIG.PCW_USE_DEBUG {0} CONFIG.PCW_USE_DEFAULT_ACP_USER_VAL {0} CONFIG.PCW_USE_DMA0 {0} CONFIG.PCW_USE_DMA1 {0} CONFIG.PCW_USE_DMA2 {0} CONFIG.PCW_USE_DMA3 {0} CONFIG.PCW_USE_EXPANDED_IOP {0} CONFIG.PCW_USE_EXPANDED_PS_SLCR_REGISTERS {0} CONFIG.PCW_USE_FABRIC_INTERRUPT {0} CONFIG.PCW_USE_HIGH_OCM {0} CONFIG.PCW_USE_M_AXI_GP0 {0} CONFIG.PCW_USE_M_AXI_GP1 {1} CONFIG.PCW_USE_PROC_EVENT_BUS {0} CONFIG.PCW_USE_PS_SLCR_REGISTERS {0} CONFIG.PCW_USE_S_AXI_ACP {0} CONFIG.PCW_USE_S_AXI_GP0 {0} CONFIG.PCW_USE_S_AXI_GP1 {0} CONFIG.PCW_USE_S_AXI_HP0 {0} CONFIG.PCW_USE_S_AXI_HP1 {1} CONFIG.PCW_USE_S_AXI_HP2 {0} CONFIG.PCW_USE_S_AXI_HP3 {0} CONFIG.PCW_USE_TRACE {0} CONFIG.PCW_USE_TRACE_DATA_EDGE_DETECTOR {0} CONFIG.PCW_VALUE_SILVERSION {3} CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0} CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ {133.333333} CONFIG.PCW_WDT_WDT_IO {<Select>} CONFIG.preset {None}  ] $design_1_processing_system7_0
  
  set sys_ps7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 sys_ps7 ]
  set_property -dict [ list CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
CONFIG.PCW_ACT_CAN0_PERIPHERAL_FREQMHZ {23.8095} CONFIG.PCW_ACT_CAN1_PERIPHERAL_FREQMHZ {23.8095} \
CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.062893} \
CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {200.000000} \
CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {40.000000} \
CONFIG.PCW_ACT_I2C_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {50.000000} \
CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {166.666672} \
CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} CONFIG.PCW_ACT_USB0_PERIPHERAL_FREQMHZ {60} \
CONFIG.PCW_ACT_USB1_PERIPHERAL_FREQMHZ {60} CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {666.666666} \
CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} CONFIG.PCW_CAN0_BASEADDR {0xE0008000} \
CONFIG.PCW_CAN0_CAN0_IO {<Select>} CONFIG.PCW_CAN0_GRP_CLK_ENABLE {0} \
CONFIG.PCW_CAN0_GRP_CLK_IO {<Select>} CONFIG.PCW_CAN0_HIGHADDR {0xE0008FFF} \
CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External} CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_CAN0_PERIPHERAL_FREQMHZ {-1} CONFIG.PCW_CAN1_BASEADDR {0xE0009000} \
CONFIG.PCW_CAN1_CAN1_IO {<Select>} CONFIG.PCW_CAN1_GRP_CLK_ENABLE {0} \
CONFIG.PCW_CAN1_GRP_CLK_IO {<Select>} CONFIG.PCW_CAN1_HIGHADDR {0xE0009FFF} \
CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External} CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_CAN1_PERIPHERAL_FREQMHZ {-1} CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_CAN_PERIPHERAL_VALID {0} \
CONFIG.PCW_CLK0_FREQ {100000000} CONFIG.PCW_CLK1_FREQ {200000000} \
CONFIG.PCW_CLK2_FREQ {200000000} CONFIG.PCW_CLK3_FREQ {40000000} \
CONFIG.PCW_CORE0_FIQ_INTR {0} CONFIG.PCW_CORE0_IRQ_INTR {0} \
CONFIG.PCW_CORE1_FIQ_INTR {0} CONFIG.PCW_CORE1_IRQ_INTR {0} \
CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {667} CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {53} CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {3} \
CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} CONFIG.PCW_DDRPLL_CTRL_FBDIV {48} \
CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1600.000} CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION {HPR(0)/LPR(32)} \
CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL {15} CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL {2} \
CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {4} \
CONFIG.PCW_DDR_PORT0_HPR_ENABLE {0} CONFIG.PCW_DDR_PORT1_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PORT2_HPR_ENABLE {0} CONFIG.PCW_DDR_PORT3_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PRIORITY_READPORT_0 {<Select>} CONFIG.PCW_DDR_PRIORITY_READPORT_1 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_READPORT_2 {<Select>} CONFIG.PCW_DDR_PRIORITY_READPORT_3 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_0 {<Select>} CONFIG.PCW_DDR_PRIORITY_WRITEPORT_1 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_2 {<Select>} CONFIG.PCW_DDR_PRIORITY_WRITEPORT_3 {<Select>} \
CONFIG.PCW_DDR_RAM_BASEADDR {0x00100000} CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF} \
CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL {2} CONFIG.PCW_DM_WIDTH {4} \
CONFIG.PCW_DQS_WIDTH {4} CONFIG.PCW_DQ_WIDTH {32} \
CONFIG.PCW_ENET0_BASEADDR {0xE000B000} CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
CONFIG.PCW_ENET0_HIGHADDR {0xE000BFFF} CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
CONFIG.PCW_ENET0_RESET_ENABLE {0} CONFIG.PCW_ENET0_RESET_IO {<Select>} \
CONFIG.PCW_ENET1_BASEADDR {0xE000C000} CONFIG.PCW_ENET1_ENET1_IO {<Select>} \
CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {0} CONFIG.PCW_ENET1_GRP_MDIO_IO {<Select>} \
CONFIG.PCW_ENET1_HIGHADDR {0xE000CFFF} CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ {1000 Mbps} \
CONFIG.PCW_ENET1_RESET_ENABLE {0} CONFIG.PCW_ENET1_RESET_IO {<Select>} \
CONFIG.PCW_ENET_RESET_ENABLE {1} CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} CONFIG.PCW_EN_4K_TIMER {0} \
CONFIG.PCW_EN_CAN0 {0} CONFIG.PCW_EN_CAN1 {0} \
CONFIG.PCW_EN_CLK0_PORT {1} CONFIG.PCW_EN_CLK1_PORT {1} \
CONFIG.PCW_EN_CLK2_PORT {0} CONFIG.PCW_EN_CLK3_PORT {0} \
CONFIG.PCW_EN_CLKTRIG0_PORT {0} CONFIG.PCW_EN_CLKTRIG1_PORT {0} \
CONFIG.PCW_EN_CLKTRIG2_PORT {0} CONFIG.PCW_EN_CLKTRIG3_PORT {0} \
CONFIG.PCW_EN_DDR {1} CONFIG.PCW_EN_EMIO_CAN0 {0} \
CONFIG.PCW_EN_EMIO_CAN1 {0} CONFIG.PCW_EN_EMIO_CD_SDIO0 {0} \
CONFIG.PCW_EN_EMIO_CD_SDIO1 {0} CONFIG.PCW_EN_EMIO_ENET0 {0} \
CONFIG.PCW_EN_EMIO_ENET1 {0} CONFIG.PCW_EN_EMIO_GPIO {1} \
CONFIG.PCW_EN_EMIO_I2C0 {1} CONFIG.PCW_EN_EMIO_I2C1 {0} \
CONFIG.PCW_EN_EMIO_MODEM_UART0 {0} CONFIG.PCW_EN_EMIO_MODEM_UART1 {0} \
CONFIG.PCW_EN_EMIO_PJTAG {0} CONFIG.PCW_EN_EMIO_SDIO0 {0} \
CONFIG.PCW_EN_EMIO_SDIO1 {0} CONFIG.PCW_EN_EMIO_SPI0 {1} \
CONFIG.PCW_EN_EMIO_SPI1 {1} CONFIG.PCW_EN_EMIO_SRAM_INT {0} \
CONFIG.PCW_EN_EMIO_TRACE {0} CONFIG.PCW_EN_EMIO_TTC0 {0} \
CONFIG.PCW_EN_EMIO_TTC1 {0} CONFIG.PCW_EN_EMIO_UART0 {0} \
CONFIG.PCW_EN_EMIO_UART1 {0} CONFIG.PCW_EN_EMIO_WDT {0} \
CONFIG.PCW_EN_EMIO_WP_SDIO0 {0} CONFIG.PCW_EN_EMIO_WP_SDIO1 {0} \
CONFIG.PCW_EN_ENET0 {1} CONFIG.PCW_EN_ENET1 {0} \
CONFIG.PCW_EN_GPIO {1} CONFIG.PCW_EN_I2C0 {1} \
CONFIG.PCW_EN_I2C1 {0} CONFIG.PCW_EN_MODEM_UART0 {0} \
CONFIG.PCW_EN_MODEM_UART1 {0} CONFIG.PCW_EN_PJTAG {0} \
CONFIG.PCW_EN_QSPI {1} CONFIG.PCW_EN_RST0_PORT {1} \
CONFIG.PCW_EN_RST1_PORT {1} CONFIG.PCW_EN_RST2_PORT {0} \
CONFIG.PCW_EN_RST3_PORT {0} CONFIG.PCW_EN_SDIO0 {0} \
CONFIG.PCW_EN_SDIO1 {1} CONFIG.PCW_EN_SMC {0} \
CONFIG.PCW_EN_SPI0 {1} CONFIG.PCW_EN_SPI1 {1} \
CONFIG.PCW_EN_TRACE {0} CONFIG.PCW_EN_TTC0 {0} \
CONFIG.PCW_EN_TTC1 {0} CONFIG.PCW_EN_UART0 {0} \
CONFIG.PCW_EN_UART1 {1} CONFIG.PCW_EN_USB0 {1} \
CONFIG.PCW_EN_USB1 {1} CONFIG.PCW_EN_WDT {0} \
CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {10} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {5} CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {5} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {25} CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK_CLK0_BUF {true} CONFIG.PCW_FCLK_CLK1_BUF {true} \
CONFIG.PCW_FCLK_CLK2_BUF {false} CONFIG.PCW_FCLK_CLK3_BUF {false} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100.0} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {200.0} \
CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {40} \
CONFIG.PCW_FPGA_FCLK0_ENABLE {1} CONFIG.PCW_FPGA_FCLK1_ENABLE {1} \
CONFIG.PCW_FPGA_FCLK2_ENABLE {0} CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
CONFIG.PCW_FTM_CTI_IN0 {<Select>} CONFIG.PCW_FTM_CTI_IN1 {<Select>} \
CONFIG.PCW_FTM_CTI_IN2 {<Select>} CONFIG.PCW_FTM_CTI_IN3 {<Select>} \
CONFIG.PCW_FTM_CTI_OUT0 {<Select>} CONFIG.PCW_FTM_CTI_OUT1 {<Select>} \
CONFIG.PCW_FTM_CTI_OUT2 {<Select>} CONFIG.PCW_FTM_CTI_OUT3 {<Select>} \
CONFIG.PCW_GPIO_BASEADDR {0xE000A000} CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_EMIO_GPIO_IO {64} CONFIG.PCW_GPIO_EMIO_GPIO_WIDTH {64} \
CONFIG.PCW_GPIO_HIGHADDR {0xE000AFFF} CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_I2C0_BASEADDR {0xE0004000} CONFIG.PCW_I2C0_GRP_INT_ENABLE {1} \
CONFIG.PCW_I2C0_GRP_INT_IO {EMIO} CONFIG.PCW_I2C0_HIGHADDR {0xE0004FFF} \
CONFIG.PCW_I2C0_I2C0_IO {EMIO} CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_I2C0_RESET_ENABLE {0} CONFIG.PCW_I2C0_RESET_IO {<Select>} \
CONFIG.PCW_I2C1_BASEADDR {0xE0005000} CONFIG.PCW_I2C1_GRP_INT_ENABLE {0} \
CONFIG.PCW_I2C1_GRP_INT_IO {<Select>} CONFIG.PCW_I2C1_HIGHADDR {0xE0005FFF} \
CONFIG.PCW_I2C1_I2C1_IO {<Select>} CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_I2C1_RESET_ENABLE {0} CONFIG.PCW_I2C1_RESET_IO {<Select>} \
CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_I2C_RESET_ENABLE {1} \
CONFIG.PCW_I2C_RESET_POLARITY {Active Low} CONFIG.PCW_I2C_RESET_SELECT {Share reset pin} \
CONFIG.PCW_IMPORT_BOARD_PRESET {None} CONFIG.PCW_INCLUDE_ACP_TRANS_CHECK {0} \
CONFIG.PCW_INCLUDE_TRACE_BUFFER {0} CONFIG.PCW_IOPLL_CTRL_FBDIV {30} \
CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} CONFIG.PCW_IRQ_F2P_INTR {1} \
CONFIG.PCW_IRQ_F2P_MODE {DIRECT} CONFIG.PCW_MIO_0_DIRECTION {inout} \
CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_0_PULLUP {enabled} \
CONFIG.PCW_MIO_0_SLEW {slow} CONFIG.PCW_MIO_10_DIRECTION {inout} \
CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_10_PULLUP {enabled} \
CONFIG.PCW_MIO_10_SLEW {slow} CONFIG.PCW_MIO_11_DIRECTION {inout} \
CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_11_PULLUP {enabled} \
CONFIG.PCW_MIO_11_SLEW {slow} CONFIG.PCW_MIO_12_DIRECTION {inout} \
CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_12_PULLUP {enabled} \
CONFIG.PCW_MIO_12_SLEW {slow} CONFIG.PCW_MIO_13_DIRECTION {inout} \
CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_13_PULLUP {enabled} \
CONFIG.PCW_MIO_13_SLEW {slow} CONFIG.PCW_MIO_14_DIRECTION {inout} \
CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_14_PULLUP {enabled} \
CONFIG.PCW_MIO_14_SLEW {slow} CONFIG.PCW_MIO_15_DIRECTION {inout} \
CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_15_PULLUP {enabled} \
CONFIG.PCW_MIO_15_SLEW {slow} CONFIG.PCW_MIO_16_DIRECTION {out} \
CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_16_PULLUP {enabled} \
CONFIG.PCW_MIO_16_SLEW {slow} CONFIG.PCW_MIO_17_DIRECTION {out} \
CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_17_PULLUP {enabled} \
CONFIG.PCW_MIO_17_SLEW {slow} CONFIG.PCW_MIO_18_DIRECTION {out} \
CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_18_PULLUP {enabled} \
CONFIG.PCW_MIO_18_SLEW {slow} CONFIG.PCW_MIO_19_DIRECTION {out} \
CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_19_PULLUP {enabled} \
CONFIG.PCW_MIO_19_SLEW {slow} CONFIG.PCW_MIO_1_DIRECTION {out} \
CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_1_PULLUP {enabled} \
CONFIG.PCW_MIO_1_SLEW {slow} CONFIG.PCW_MIO_20_DIRECTION {out} \
CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_20_PULLUP {enabled} \
CONFIG.PCW_MIO_20_SLEW {slow} CONFIG.PCW_MIO_21_DIRECTION {out} \
CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_21_PULLUP {enabled} \
CONFIG.PCW_MIO_21_SLEW {slow} CONFIG.PCW_MIO_22_DIRECTION {in} \
CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_22_PULLUP {enabled} \
CONFIG.PCW_MIO_22_SLEW {slow} CONFIG.PCW_MIO_23_DIRECTION {in} \
CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_23_PULLUP {enabled} \
CONFIG.PCW_MIO_23_SLEW {slow} CONFIG.PCW_MIO_24_DIRECTION {in} \
CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_24_PULLUP {enabled} \
CONFIG.PCW_MIO_24_SLEW {slow} CONFIG.PCW_MIO_25_DIRECTION {in} \
CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_25_PULLUP {enabled} \
CONFIG.PCW_MIO_25_SLEW {slow} CONFIG.PCW_MIO_26_DIRECTION {in} \
CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_26_PULLUP {enabled} \
CONFIG.PCW_MIO_26_SLEW {slow} CONFIG.PCW_MIO_27_DIRECTION {in} \
CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_27_PULLUP {enabled} \
CONFIG.PCW_MIO_27_SLEW {slow} CONFIG.PCW_MIO_28_DIRECTION {inout} \
CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_28_PULLUP {enabled} \
CONFIG.PCW_MIO_28_SLEW {slow} CONFIG.PCW_MIO_29_DIRECTION {in} \
CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_29_PULLUP {enabled} \
CONFIG.PCW_MIO_29_SLEW {slow} CONFIG.PCW_MIO_2_DIRECTION {inout} \
CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_2_PULLUP {disabled} \
CONFIG.PCW_MIO_2_SLEW {slow} CONFIG.PCW_MIO_30_DIRECTION {out} \
CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_30_PULLUP {enabled} \
CONFIG.PCW_MIO_30_SLEW {slow} CONFIG.PCW_MIO_31_DIRECTION {in} \
CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_31_PULLUP {enabled} \
CONFIG.PCW_MIO_31_SLEW {slow} CONFIG.PCW_MIO_32_DIRECTION {inout} \
CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_32_PULLUP {enabled} \
CONFIG.PCW_MIO_32_SLEW {slow} CONFIG.PCW_MIO_33_DIRECTION {inout} \
CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_33_PULLUP {enabled} \
CONFIG.PCW_MIO_33_SLEW {slow} CONFIG.PCW_MIO_34_DIRECTION {inout} \
CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_34_PULLUP {enabled} \
CONFIG.PCW_MIO_34_SLEW {slow} CONFIG.PCW_MIO_35_DIRECTION {inout} \
CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_35_PULLUP {enabled} \
CONFIG.PCW_MIO_35_SLEW {slow} CONFIG.PCW_MIO_36_DIRECTION {in} \
CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_36_PULLUP {enabled} \
CONFIG.PCW_MIO_36_SLEW {slow} CONFIG.PCW_MIO_37_DIRECTION {inout} \
CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_37_PULLUP {enabled} \
CONFIG.PCW_MIO_37_SLEW {slow} CONFIG.PCW_MIO_38_DIRECTION {inout} \
CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_38_PULLUP {enabled} \
CONFIG.PCW_MIO_38_SLEW {slow} CONFIG.PCW_MIO_39_DIRECTION {inout} \
CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_39_PULLUP {enabled} \
CONFIG.PCW_MIO_39_SLEW {slow} CONFIG.PCW_MIO_3_DIRECTION {inout} \
CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_3_PULLUP {disabled} \
CONFIG.PCW_MIO_3_SLEW {slow} CONFIG.PCW_MIO_40_DIRECTION {inout} \
CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_40_PULLUP {enabled} \
CONFIG.PCW_MIO_40_SLEW {slow} CONFIG.PCW_MIO_41_DIRECTION {in} \
CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_41_PULLUP {enabled} \
CONFIG.PCW_MIO_41_SLEW {slow} CONFIG.PCW_MIO_42_DIRECTION {out} \
CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_42_PULLUP {enabled} \
CONFIG.PCW_MIO_42_SLEW {slow} CONFIG.PCW_MIO_43_DIRECTION {in} \
CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_43_PULLUP {enabled} \
CONFIG.PCW_MIO_43_SLEW {slow} CONFIG.PCW_MIO_44_DIRECTION {inout} \
CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_44_PULLUP {enabled} \
CONFIG.PCW_MIO_44_SLEW {slow} CONFIG.PCW_MIO_45_DIRECTION {inout} \
CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_45_PULLUP {enabled} \
CONFIG.PCW_MIO_45_SLEW {slow} CONFIG.PCW_MIO_46_DIRECTION {inout} \
CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_46_PULLUP {enabled} \
CONFIG.PCW_MIO_46_SLEW {slow} CONFIG.PCW_MIO_47_DIRECTION {inout} \
CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_47_PULLUP {enabled} \
CONFIG.PCW_MIO_47_SLEW {slow} CONFIG.PCW_MIO_48_DIRECTION {in} \
CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_48_PULLUP {enabled} \
CONFIG.PCW_MIO_48_SLEW {slow} CONFIG.PCW_MIO_49_DIRECTION {inout} \
CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_49_PULLUP {enabled} \
CONFIG.PCW_MIO_49_SLEW {slow} CONFIG.PCW_MIO_4_DIRECTION {inout} \
CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_4_PULLUP {disabled} \
CONFIG.PCW_MIO_4_SLEW {slow} CONFIG.PCW_MIO_50_DIRECTION {inout} \
CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_50_PULLUP {enabled} \
CONFIG.PCW_MIO_50_SLEW {slow} CONFIG.PCW_MIO_51_DIRECTION {inout} \
CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_51_PULLUP {enabled} \
CONFIG.PCW_MIO_51_SLEW {slow} CONFIG.PCW_MIO_52_DIRECTION {out} \
CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_52_PULLUP {enabled} \
CONFIG.PCW_MIO_52_SLEW {slow} CONFIG.PCW_MIO_53_DIRECTION {inout} \
CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_53_PULLUP {enabled} \
CONFIG.PCW_MIO_53_SLEW {slow} CONFIG.PCW_MIO_5_DIRECTION {inout} \
CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_5_PULLUP {disabled} \
CONFIG.PCW_MIO_5_SLEW {slow} CONFIG.PCW_MIO_6_DIRECTION {out} \
CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_6_PULLUP {disabled} \
CONFIG.PCW_MIO_6_SLEW {slow} CONFIG.PCW_MIO_7_DIRECTION {out} \
CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_7_PULLUP {disabled} \
CONFIG.PCW_MIO_7_SLEW {slow} CONFIG.PCW_MIO_8_DIRECTION {out} \
CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_8_PULLUP {disabled} \
CONFIG.PCW_MIO_8_SLEW {slow} CONFIG.PCW_MIO_9_DIRECTION {in} \
CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_9_PULLUP {enabled} \
CONFIG.PCW_MIO_9_SLEW {slow} CONFIG.PCW_MIO_PRIMITIVE {54} \
CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#GPIO#UART 1#UART 1#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#USB 1#Enet 0#Enet 0} CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]#qspi0_sclk#gpio[7]#tx#rx#data[0]#cmd#clk#data[1]#data[2]#data[3]#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#mdc#mdio} \
CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {0} CONFIG.PCW_M_AXI_GP0_ID_WIDTH {12} \
CONFIG.PCW_M_AXI_GP0_SUPPORT_NARROW_BURST {0} CONFIG.PCW_M_AXI_GP0_THREAD_ID_WIDTH {12} \
CONFIG.PCW_M_AXI_GP1_ENABLE_STATIC_REMAP {0} CONFIG.PCW_M_AXI_GP1_FREQMHZ {10} \
CONFIG.PCW_M_AXI_GP1_ID_WIDTH {12} CONFIG.PCW_M_AXI_GP1_SUPPORT_NARROW_BURST {0} \
CONFIG.PCW_M_AXI_GP1_THREAD_ID_WIDTH {12} CONFIG.PCW_NAND_CYCLES_T_AR {0} \
CONFIG.PCW_NAND_CYCLES_T_CLR {0} CONFIG.PCW_NAND_CYCLES_T_RC {2} \
CONFIG.PCW_NAND_CYCLES_T_REA {1} CONFIG.PCW_NAND_CYCLES_T_RR {0} \
CONFIG.PCW_NAND_CYCLES_T_WC {2} CONFIG.PCW_NAND_CYCLES_T_WP {1} \
CONFIG.PCW_NAND_GRP_D8_ENABLE {0} CONFIG.PCW_NAND_GRP_D8_IO {<Select>} \
CONFIG.PCW_NAND_NAND_IO {<Select>} CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_NOR_CS0_T_CEOE {1} CONFIG.PCW_NOR_CS0_T_PC {1} \
CONFIG.PCW_NOR_CS0_T_RC {2} CONFIG.PCW_NOR_CS0_T_TR {1} \
CONFIG.PCW_NOR_CS0_T_WC {2} CONFIG.PCW_NOR_CS0_T_WP {1} \
CONFIG.PCW_NOR_CS0_WE_TIME {2} CONFIG.PCW_NOR_CS1_T_CEOE {1} \
CONFIG.PCW_NOR_CS1_T_PC {1} CONFIG.PCW_NOR_CS1_T_RC {2} \
CONFIG.PCW_NOR_CS1_T_TR {1} CONFIG.PCW_NOR_CS1_T_WC {2} \
CONFIG.PCW_NOR_CS1_T_WP {1} CONFIG.PCW_NOR_CS1_WE_TIME {2} \
CONFIG.PCW_NOR_GRP_A25_ENABLE {0} CONFIG.PCW_NOR_GRP_A25_IO {<Select>} \
CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} CONFIG.PCW_NOR_GRP_CS0_IO {<Select>} \
CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} CONFIG.PCW_NOR_GRP_CS1_IO {<Select>} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} CONFIG.PCW_NOR_GRP_SRAM_CS0_IO {<Select>} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} CONFIG.PCW_NOR_GRP_SRAM_CS1_IO {<Select>} \
CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} CONFIG.PCW_NOR_GRP_SRAM_INT_IO {<Select>} \
CONFIG.PCW_NOR_NOR_IO {<Select>} CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1} CONFIG.PCW_NOR_SRAM_CS0_T_PC {1} \
CONFIG.PCW_NOR_SRAM_CS0_T_RC {2} CONFIG.PCW_NOR_SRAM_CS0_T_TR {1} \
CONFIG.PCW_NOR_SRAM_CS0_T_WC {2} CONFIG.PCW_NOR_SRAM_CS0_T_WP {1} \
CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {2} CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1} \
CONFIG.PCW_NOR_SRAM_CS1_T_PC {1} CONFIG.PCW_NOR_SRAM_CS1_T_RC {2} \
CONFIG.PCW_NOR_SRAM_CS1_T_TR {1} CONFIG.PCW_NOR_SRAM_CS1_T_WC {2} \
CONFIG.PCW_NOR_SRAM_CS1_T_WP {1} CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {2} \
CONFIG.PCW_OVERRIDE_BASIC_CLOCK {0} CONFIG.PCW_P2F_CAN0_INTR {0} \
CONFIG.PCW_P2F_CAN1_INTR {0} CONFIG.PCW_P2F_CTI_INTR {0} \
CONFIG.PCW_P2F_DMAC0_INTR {0} CONFIG.PCW_P2F_DMAC1_INTR {0} \
CONFIG.PCW_P2F_DMAC2_INTR {0} CONFIG.PCW_P2F_DMAC3_INTR {0} \
CONFIG.PCW_P2F_DMAC4_INTR {0} CONFIG.PCW_P2F_DMAC5_INTR {0} \
CONFIG.PCW_P2F_DMAC6_INTR {0} CONFIG.PCW_P2F_DMAC7_INTR {0} \
CONFIG.PCW_P2F_DMAC_ABORT_INTR {0} CONFIG.PCW_P2F_ENET0_INTR {0} \
CONFIG.PCW_P2F_ENET1_INTR {0} CONFIG.PCW_P2F_GPIO_INTR {0} \
CONFIG.PCW_P2F_I2C0_INTR {0} CONFIG.PCW_P2F_I2C1_INTR {0} \
CONFIG.PCW_P2F_QSPI_INTR {0} CONFIG.PCW_P2F_SDIO0_INTR {0} \
CONFIG.PCW_P2F_SDIO1_INTR {0} CONFIG.PCW_P2F_SMC_INTR {0} \
CONFIG.PCW_P2F_SPI0_INTR {0} CONFIG.PCW_P2F_SPI1_INTR {0} \
CONFIG.PCW_P2F_UART0_INTR {0} CONFIG.PCW_P2F_UART1_INTR {0} \
CONFIG.PCW_P2F_USB0_INTR {0} CONFIG.PCW_P2F_USB1_INTR {0} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.089} CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.075} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.085} CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.092} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.025} CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {0.014} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {-0.009} CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.033} \
CONFIG.PCW_PACKAGE_NAME {clg400} CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_PERIPHERAL_BOARD_PRESET {None} CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_PJTAG_PJTAG_IO {<Select>} CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} CONFIG.PCW_PS7_SI_REV {PRODUCTION} \
CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {0} CONFIG.PCW_QSPI_GRP_FBCLK_IO {<Select>} \
CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} CONFIG.PCW_QSPI_GRP_IO1_IO {<Select>} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} CONFIG.PCW_QSPI_GRP_SS1_IO {<Select>} \
CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF} CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {5} CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
CONFIG.PCW_SD0_GRP_CD_ENABLE {0} CONFIG.PCW_SD0_GRP_CD_IO {<Select>} \
CONFIG.PCW_SD0_GRP_POW_ENABLE {0} CONFIG.PCW_SD0_GRP_POW_IO {<Select>} \
CONFIG.PCW_SD0_GRP_WP_ENABLE {0} CONFIG.PCW_SD0_GRP_WP_IO {<Select>} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE {0} CONFIG.PCW_SD0_SD0_IO {<Select>} \
CONFIG.PCW_SD1_GRP_CD_ENABLE {0} CONFIG.PCW_SD1_GRP_CD_IO {<Select>} \
CONFIG.PCW_SD1_GRP_POW_ENABLE {0} CONFIG.PCW_SD1_GRP_POW_IO {<Select>} \
CONFIG.PCW_SD1_GRP_WP_ENABLE {0} CONFIG.PCW_SD1_GRP_WP_IO {<Select>} \
CONFIG.PCW_SD1_PERIPHERAL_ENABLE {1} CONFIG.PCW_SD1_SD1_IO {MIO 10 .. 15} \
CONFIG.PCW_SDIO0_BASEADDR {0xE0100000} CONFIG.PCW_SDIO0_HIGHADDR {0xE0100FFF} \
CONFIG.PCW_SDIO1_BASEADDR {0xE0101000} CONFIG.PCW_SDIO1_HIGHADDR {0xE0101FFF} \
CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {20} \
CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
CONFIG.PCW_SMC_CYCLE_T0 {NA} CONFIG.PCW_SMC_CYCLE_T1 {NA} \
CONFIG.PCW_SMC_CYCLE_T2 {NA} CONFIG.PCW_SMC_CYCLE_T3 {NA} \
CONFIG.PCW_SMC_CYCLE_T4 {NA} CONFIG.PCW_SMC_CYCLE_T5 {NA} \
CONFIG.PCW_SMC_CYCLE_T6 {NA} CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_SMC_PERIPHERAL_VALID {0} CONFIG.PCW_SPI0_BASEADDR {0xE0006000} \
CONFIG.PCW_SPI0_GRP_SS0_ENABLE {1} CONFIG.PCW_SPI0_GRP_SS0_IO {EMIO} \
CONFIG.PCW_SPI0_GRP_SS1_ENABLE {1} CONFIG.PCW_SPI0_GRP_SS1_IO {EMIO} \
CONFIG.PCW_SPI0_GRP_SS2_ENABLE {1} CONFIG.PCW_SPI0_GRP_SS2_IO {EMIO} \
CONFIG.PCW_SPI0_HIGHADDR {0xE0006FFF} CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SPI0_SPI0_IO {EMIO} CONFIG.PCW_SPI1_BASEADDR {0xE0007000} \
CONFIG.PCW_SPI1_GRP_SS0_ENABLE {1} CONFIG.PCW_SPI1_GRP_SS0_IO {EMIO} \
CONFIG.PCW_SPI1_GRP_SS1_ENABLE {1} CONFIG.PCW_SPI1_GRP_SS1_IO {EMIO} \
CONFIG.PCW_SPI1_GRP_SS2_ENABLE {1} CONFIG.PCW_SPI1_GRP_SS2_IO {EMIO} \
CONFIG.PCW_SPI1_HIGHADDR {0xE0007FFF} CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SPI1_SPI1_IO {EMIO} CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {6} CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} \
CONFIG.PCW_SPI_PERIPHERAL_VALID {1} CONFIG.PCW_S_AXI_ACP_ARUSER_VAL {31} \
CONFIG.PCW_S_AXI_ACP_AWUSER_VAL {31} CONFIG.PCW_S_AXI_ACP_FREQMHZ {10} \
CONFIG.PCW_S_AXI_ACP_ID_WIDTH {3} CONFIG.PCW_S_AXI_GP0_FREQMHZ {10} \
CONFIG.PCW_S_AXI_GP0_ID_WIDTH {6} CONFIG.PCW_S_AXI_GP1_FREQMHZ {10} \
CONFIG.PCW_S_AXI_GP1_ID_WIDTH {6} CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64} \
CONFIG.PCW_S_AXI_HP0_ID_WIDTH {6} CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64} \
CONFIG.PCW_S_AXI_HP1_ID_WIDTH {6} CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64} \
CONFIG.PCW_S_AXI_HP2_ID_WIDTH {6} CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64} \
CONFIG.PCW_S_AXI_HP3_FREQMHZ {10} CONFIG.PCW_S_AXI_HP3_ID_WIDTH {6} \
CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_TRACE_BUFFER_CLOCK_DELAY {12} \
CONFIG.PCW_TRACE_BUFFER_FIFO_SIZE {128} CONFIG.PCW_TRACE_GRP_16BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_16BIT_IO {<Select>} CONFIG.PCW_TRACE_GRP_2BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_2BIT_IO {<Select>} CONFIG.PCW_TRACE_GRP_32BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_32BIT_IO {<Select>} CONFIG.PCW_TRACE_GRP_4BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_4BIT_IO {<Select>} CONFIG.PCW_TRACE_GRP_8BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_8BIT_IO {<Select>} CONFIG.PCW_TRACE_INTERNAL_WIDTH {32} \
CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0} CONFIG.PCW_TRACE_PIPELINE_WIDTH {8} \
CONFIG.PCW_TRACE_TRACE_IO {<Select>} CONFIG.PCW_TTC0_BASEADDR {0xE0104000} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333333} CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333333} CONFIG.PCW_TTC0_HIGHADDR {0xE0104fff} \
CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} CONFIG.PCW_TTC0_TTC0_IO {<Select>} \
CONFIG.PCW_TTC1_BASEADDR {0xE0105000} CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC1_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_FREQMHZ {133.333333} CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC1_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC1_HIGHADDR {0xE0105fff} CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_TTC1_TTC1_IO {<Select>} CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_UART0_BASEADDR {0xE0000000} CONFIG.PCW_UART0_BAUD_RATE {115200} \
CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} CONFIG.PCW_UART0_GRP_FULL_IO {<Select>} \
CONFIG.PCW_UART0_HIGHADDR {0xE0000FFF} CONFIG.PCW_UART0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_UART0_UART0_IO {<Select>} CONFIG.PCW_UART1_BASEADDR {0xE0001000} \
CONFIG.PCW_UART1_BAUD_RATE {115200} CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
CONFIG.PCW_UART1_GRP_FULL_IO {<Select>} CONFIG.PCW_UART1_HIGHADDR {0xE0001FFF} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART1_UART1_IO {MIO 8 .. 9} \
CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {10} \
CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {400.000000} CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
CONFIG.PCW_UIPARAM_DDR_AL {0} CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
CONFIG.PCW_UIPARAM_DDR_BL {8} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {.434} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {.398} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {.410} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.0} CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} \
CONFIG.PCW_UIPARAM_DDR_CL {9} CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {80.4535} CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {80.4535} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {80.4535} CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {80.4535} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} \
CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} CONFIG.PCW_UIPARAM_DDR_CWL {9} \
CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {8192 MBits} CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {105.056} CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {66.904} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {89.1715} CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {113.63} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {.315} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {.391} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {.374} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {.271} CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {98.503} CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {68.5855} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {90.295} CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {103.977} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {32 Bits} \
CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {400} CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3 (Low Voltage)} CONFIG.PCW_UIPARAM_DDR_PARTNO {Custom} \
CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} CONFIG.PCW_UIPARAM_DDR_T_FAW {50} \
CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {40} CONFIG.PCW_UIPARAM_DDR_T_RC {60} \
CONFIG.PCW_UIPARAM_DDR_T_RCD {9} CONFIG.PCW_UIPARAM_DDR_T_RP {9} \
CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {1} CONFIG.PCW_UIPARAM_GENERATE_SUMMARY {NA} \
CONFIG.PCW_USB0_BASEADDR {0xE0102000} CONFIG.PCW_USB0_HIGHADDR {0xE0102fff} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} \
CONFIG.PCW_USB0_RESET_ENABLE {0} CONFIG.PCW_USB0_RESET_IO {<Select>} \
CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} CONFIG.PCW_USB1_BASEADDR {0xE0103000} \
CONFIG.PCW_USB1_HIGHADDR {0xE0103fff} CONFIG.PCW_USB1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_USB1_PERIPHERAL_FREQMHZ {60} CONFIG.PCW_USB1_RESET_ENABLE {0} \
CONFIG.PCW_USB1_RESET_IO {<Select>} CONFIG.PCW_USB1_USB1_IO {MIO 40 .. 51} \
CONFIG.PCW_USB_RESET_ENABLE {1} CONFIG.PCW_USB_RESET_POLARITY {Active Low} \
CONFIG.PCW_USB_RESET_SELECT {Share reset pin} CONFIG.PCW_USE_AXI_FABRIC_IDLE {0} \
CONFIG.PCW_USE_AXI_NONSECURE {0} CONFIG.PCW_USE_CORESIGHT {0} \
CONFIG.PCW_USE_CROSS_TRIGGER {0} CONFIG.PCW_USE_CR_FABRIC {1} \
CONFIG.PCW_USE_DDR_BYPASS {0} CONFIG.PCW_USE_DEBUG {0} \
CONFIG.PCW_USE_DEFAULT_ACP_USER_VAL {0} CONFIG.PCW_USE_DMA0 {1} \
CONFIG.PCW_USE_DMA1 {0} CONFIG.PCW_USE_DMA2 {0} \
CONFIG.PCW_USE_DMA3 {0} CONFIG.PCW_USE_EXPANDED_IOP {0} \
CONFIG.PCW_USE_EXPANDED_PS_SLCR_REGISTERS {0} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
CONFIG.PCW_USE_HIGH_OCM {0} CONFIG.PCW_USE_M_AXI_GP0 {1} \
CONFIG.PCW_USE_M_AXI_GP1 {0} CONFIG.PCW_USE_PROC_EVENT_BUS {0} \
CONFIG.PCW_USE_PS_SLCR_REGISTERS {0} CONFIG.PCW_USE_S_AXI_ACP {0} \
CONFIG.PCW_USE_S_AXI_GP0 {0} CONFIG.PCW_USE_S_AXI_GP1 {0} \
CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_USE_S_AXI_HP1 {1} \
CONFIG.PCW_USE_S_AXI_HP2 {1} CONFIG.PCW_USE_S_AXI_HP3 {0} \
CONFIG.PCW_USE_TRACE {0} CONFIG.PCW_USE_TRACE_DATA_EDGE_DETECTOR {0} \
CONFIG.PCW_VALUE_SILVERSION {3} CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ {133.333333} CONFIG.PCW_WDT_WDT_IO {<Select>} \
CONFIG.preset {None}  ] $sys_ps7

  # Create instance: sys_rstgen, and set properties
  set sys_rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_rstgen ]
  set_property -dict [ list CONFIG.C_EXT_RST_WIDTH {1}  ] $sys_rstgen

  # Create instance: sys_wfifo_0
  create_hier_cell_sys_wfifo_0 [current_bd_instance .] sys_wfifo_0

  # Create instance: sys_wfifo_1
  create_hier_cell_sys_wfifo_1 [current_bd_instance .] sys_wfifo_1

  # Create instance: sys_wfifo_2
  create_hier_cell_sys_wfifo_2 [current_bd_instance .] sys_wfifo_2

  # Create instance: sys_wfifo_3
  create_hier_cell_sys_wfifo_3 [current_bd_instance .] sys_wfifo_3

  # Create instance: util_adc_pack, and set properties
  set util_adc_pack [ create_bd_cell -type ip -vlnv analog.com:user:util_adc_pack:1.0 util_adc_pack ]
  set_property -dict [ list CONFIG.CHANNELS {4}  ] $util_adc_pack

  # Create instance: util_dac_unpack, and set properties
  set util_dac_unpack [ create_bd_cell -type ip -vlnv analog.com:user:util_dac_unpack:1.0 util_dac_unpack ]
  set_property -dict [ list CONFIG.CHANNELS {4}  ] $util_dac_unpack

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_cpu_interconnect/S00_AXI] [get_bd_intf_pins sys_ps7/M_AXI_GP0]
  connect_bd_intf_net -intf_net S00_AXI_2 [get_bd_intf_pins axi_hdmi_dma/M_AXI_MM2S] [get_bd_intf_pins axi_hp0_interconnect/S00_AXI]
  connect_bd_intf_net -intf_net S00_AXI_3 [get_bd_intf_pins axi_ad9361_adc_dma/m_dest_axi] [get_bd_intf_pins axi_hp1_interconnect/S00_AXI]
  connect_bd_intf_net -intf_net S00_AXI_4 [get_bd_intf_pins axi_ad9361_dac_dma/m_src_axi] [get_bd_intf_pins axi_hp2_interconnect/S00_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M00_AXI [get_bd_intf_pins axi_cpu_interconnect/M00_AXI] [get_bd_intf_pins axi_iic_main/S_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M01_AXI [get_bd_intf_pins axi_cpu_interconnect/M01_AXI] [get_bd_intf_pins axi_hdmi_clkgen/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M02_AXI [get_bd_intf_pins axi_cpu_interconnect/M02_AXI] [get_bd_intf_pins axi_hdmi_dma/S_AXI_LITE]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M03_AXI [get_bd_intf_pins axi_cpu_interconnect/M03_AXI] [get_bd_intf_pins axi_hdmi_core/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M04_AXI [get_bd_intf_pins axi_cpu_interconnect/M04_AXI] [get_bd_intf_pins axi_spdif_tx_core/S_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M05_AXI [get_bd_intf_pins axi_ad9361/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M05_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M06_AXI [get_bd_intf_pins axi_ad9361_adc_dma/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M06_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M07_AXI [get_bd_intf_pins axi_ad9361_dac_dma/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M07_AXI]
  connect_bd_intf_net -intf_net axi_hdmi_dma_M_AXIS_MM2S [get_bd_intf_pins axi_hdmi_core/m_axis_mm2s] [get_bd_intf_pins axi_hdmi_dma/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_hp0_interconnect_M00_AXI [get_bd_intf_pins axi_hp0_interconnect/M00_AXI] [get_bd_intf_pins sys_ps7/S_AXI_HP0]
  connect_bd_intf_net -intf_net axi_hp1_interconnect_M00_AXI [get_bd_intf_pins axi_hp1_interconnect/M00_AXI] [get_bd_intf_pins sys_ps7/S_AXI_HP1]
  connect_bd_intf_net -intf_net axi_hp2_interconnect_M00_AXI [get_bd_intf_pins axi_hp2_interconnect/M00_AXI] [get_bd_intf_pins sys_ps7/S_AXI_HP2]
  connect_bd_intf_net -intf_net axi_spdif_tx_core_DMA_REQ [get_bd_intf_pins axi_spdif_tx_core/DMA_REQ] [get_bd_intf_pins sys_ps7/DMA0_REQ]
  connect_bd_intf_net -intf_net sys_ps7_DDR [get_bd_intf_ports ddr] [get_bd_intf_pins sys_ps7/DDR]
  connect_bd_intf_net -intf_net sys_ps7_DMA0_ACK [get_bd_intf_pins axi_spdif_tx_core/DMA_ACK] [get_bd_intf_pins sys_ps7/DMA0_ACK]
  connect_bd_intf_net -intf_net sys_ps7_FIXED_IO [get_bd_intf_ports fixed_io] [get_bd_intf_pins sys_ps7/FIXED_IO]
  connect_bd_intf_net -intf_net sys_ps7_IIC_0 [get_bd_intf_ports iic_main] [get_bd_intf_pins sys_ps7/IIC_0]

  # Create port connections
  connect_bd_net -net axi_ad9361_adc_data_i0 [get_bd_pins axi_ad9361/adc_data_i0] [get_bd_pins sys_wfifo_0/adc_wdata] [get_bd_pins util_adc_pack/chan_data_0]
  connect_bd_net -net axi_ad9361_adc_data_i1 [get_bd_pins axi_ad9361/adc_data_i1] [get_bd_pins sys_wfifo_2/adc_wdata] [get_bd_pins util_adc_pack/chan_data_2]
  connect_bd_net -net axi_ad9361_adc_data_q0 [get_bd_pins axi_ad9361/adc_data_q0] [get_bd_pins sys_wfifo_1/adc_wdata] [get_bd_pins util_adc_pack/chan_data_1]
  connect_bd_net -net axi_ad9361_adc_data_q1 [get_bd_pins axi_ad9361/adc_data_q1] [get_bd_pins sys_wfifo_3/adc_wdata] [get_bd_pins util_adc_pack/chan_data_3]
  connect_bd_net -net axi_ad9361_adc_dma_fifo_wr_overflow [get_bd_pins axi_ad9361/adc_dovf] [get_bd_pins axi_ad9361_adc_dma/fifo_wr_overflow]
  connect_bd_net -net axi_ad9361_adc_dma_irq [get_bd_pins axi_ad9361_adc_dma/irq] [get_bd_pins sys_concat_intc/In13]
  connect_bd_net -net axi_ad9361_adc_enable_i0 [get_bd_pins axi_ad9361/adc_enable_i0] [get_bd_pins util_adc_pack/chan_enable_0]
  connect_bd_net -net axi_ad9361_adc_enable_i1 [get_bd_pins axi_ad9361/adc_enable_i1] [get_bd_pins util_adc_pack/chan_enable_2]
  connect_bd_net -net axi_ad9361_adc_enable_q0 [get_bd_pins axi_ad9361/adc_enable_q0] [get_bd_pins util_adc_pack/chan_enable_1]
  connect_bd_net -net axi_ad9361_adc_enable_q1 [get_bd_pins axi_ad9361/adc_enable_q1] [get_bd_pins util_adc_pack/chan_enable_3]
  connect_bd_net -net axi_ad9361_adc_valid_i0 [get_bd_pins axi_ad9361/adc_valid_i0] [get_bd_pins sys_wfifo_0/adc_wr] [get_bd_pins util_adc_pack/chan_valid_0]
  connect_bd_net -net axi_ad9361_adc_valid_i1 [get_bd_pins axi_ad9361/adc_valid_i1] [get_bd_pins sys_wfifo_2/adc_wr] [get_bd_pins util_adc_pack/chan_valid_2]
  connect_bd_net -net axi_ad9361_adc_valid_q0 [get_bd_pins axi_ad9361/adc_valid_q0] [get_bd_pins sys_wfifo_1/adc_wr] [get_bd_pins util_adc_pack/chan_valid_1]
  connect_bd_net -net axi_ad9361_adc_valid_q1 [get_bd_pins axi_ad9361/adc_valid_q1] [get_bd_pins sys_wfifo_3/adc_wr] [get_bd_pins util_adc_pack/chan_valid_3]
  connect_bd_net -net axi_ad9361_clk [get_bd_pins axi_ad9361/clk] [get_bd_pins axi_ad9361/l_clk] [get_bd_pins axi_ad9361_adc_dma/fifo_wr_clk] [get_bd_pins axi_ad9361_dac_dma/fifo_rd_clk] [get_bd_pins sys_wfifo_0/adc_clk] [get_bd_pins sys_wfifo_1/adc_clk] [get_bd_pins sys_wfifo_2/adc_clk] [get_bd_pins sys_wfifo_3/adc_clk] [get_bd_pins util_adc_pack/clk] [get_bd_pins util_dac_unpack/clk]
  connect_bd_net -net axi_ad9361_dac_dma_fifo_rd_dout [get_bd_pins axi_ad9361_dac_dma/fifo_rd_dout] [get_bd_pins util_dac_unpack/dma_data]
  connect_bd_net -net axi_ad9361_dac_dma_fifo_rd_underflow [get_bd_pins axi_ad9361/dac_dunf] [get_bd_pins axi_ad9361_dac_dma/fifo_rd_underflow]
  connect_bd_net -net axi_ad9361_dac_dma_fifo_rd_valid [get_bd_pins axi_ad9361_dac_dma/fifo_rd_valid] [get_bd_pins util_dac_unpack/fifo_valid]
  connect_bd_net -net axi_ad9361_dac_dma_irq [get_bd_pins axi_ad9361_dac_dma/irq] [get_bd_pins sys_concat_intc/In12]
  connect_bd_net -net axi_ad9361_dac_enable_i0 [get_bd_pins axi_ad9361/dac_enable_i0] [get_bd_pins util_dac_unpack/dac_enable_00]
  connect_bd_net -net axi_ad9361_dac_enable_i1 [get_bd_pins axi_ad9361/dac_enable_i1] [get_bd_pins util_dac_unpack/dac_enable_02]
  connect_bd_net -net axi_ad9361_dac_enable_q0 [get_bd_pins axi_ad9361/dac_enable_q0] [get_bd_pins util_dac_unpack/dac_enable_01]
  connect_bd_net -net axi_ad9361_dac_enable_q1 [get_bd_pins axi_ad9361/dac_enable_q1] [get_bd_pins util_dac_unpack/dac_enable_03]
  connect_bd_net -net axi_ad9361_dac_valid_i0 [get_bd_pins axi_ad9361/dac_valid_i0] [get_bd_pins util_dac_unpack/dac_valid_00]
  connect_bd_net -net axi_ad9361_dac_valid_i1 [get_bd_pins axi_ad9361/dac_valid_i1] [get_bd_pins util_dac_unpack/dac_valid_02]
  connect_bd_net -net axi_ad9361_dac_valid_q0 [get_bd_pins axi_ad9361/dac_valid_q0] [get_bd_pins util_dac_unpack/dac_valid_01]
  connect_bd_net -net axi_ad9361_dac_valid_q1 [get_bd_pins axi_ad9361/dac_valid_q1] [get_bd_pins util_dac_unpack/dac_valid_03]
  connect_bd_net -net axi_ad9361_enable [get_bd_ports enable] [get_bd_pins axi_ad9361/enable]
  connect_bd_net -net axi_ad9361_tdd_enable [get_bd_ports tdd_enable] [get_bd_pins axi_ad9361/tdd_enable]
  connect_bd_net -net axi_ad9361_tdd_sync_o [get_bd_ports tdd_sync_o] [get_bd_pins axi_ad9361/tdd_sync_o]
  connect_bd_net -net axi_ad9361_tdd_sync_t [get_bd_ports tdd_sync_t] [get_bd_pins axi_ad9361/tdd_sync_t]
  connect_bd_net -net axi_ad9361_tx_clk_out_n [get_bd_ports tx_clk_out_n] [get_bd_pins axi_ad9361/tx_clk_out_n]
  connect_bd_net -net axi_ad9361_tx_clk_out_p [get_bd_ports tx_clk_out_p] [get_bd_pins axi_ad9361/tx_clk_out_p]
  connect_bd_net -net axi_ad9361_tx_data_out_n [get_bd_ports tx_data_out_n] [get_bd_pins axi_ad9361/tx_data_out_n]
  connect_bd_net -net axi_ad9361_tx_data_out_p [get_bd_ports tx_data_out_p] [get_bd_pins axi_ad9361/tx_data_out_p]
  connect_bd_net -net axi_ad9361_tx_frame_out_n [get_bd_ports tx_frame_out_n] [get_bd_pins axi_ad9361/tx_frame_out_n]
  connect_bd_net -net axi_ad9361_tx_frame_out_p [get_bd_ports tx_frame_out_p] [get_bd_pins axi_ad9361/tx_frame_out_p]
  connect_bd_net -net axi_ad9361_txnrx [get_bd_ports txnrx] [get_bd_pins axi_ad9361/txnrx]
  connect_bd_net -net axi_hdmi_clkgen_clk_0 [get_bd_pins axi_hdmi_clkgen/clk_0] [get_bd_pins axi_hdmi_core/hdmi_clk]
  connect_bd_net -net axi_hdmi_core_hdmi_16_data [get_bd_ports hdmi_data] [get_bd_pins axi_hdmi_core/hdmi_16_data]
  connect_bd_net -net axi_hdmi_core_hdmi_16_data_e [get_bd_ports hdmi_data_e] [get_bd_pins axi_hdmi_core/hdmi_16_data_e]
  connect_bd_net -net axi_hdmi_core_hdmi_16_hsync [get_bd_ports hdmi_hsync] [get_bd_pins axi_hdmi_core/hdmi_16_hsync]
  connect_bd_net -net axi_hdmi_core_hdmi_16_vsync [get_bd_ports hdmi_vsync] [get_bd_pins axi_hdmi_core/hdmi_16_vsync]
  connect_bd_net -net axi_hdmi_core_hdmi_out_clk [get_bd_ports hdmi_out_clk] [get_bd_pins axi_hdmi_core/hdmi_out_clk]
  connect_bd_net -net axi_hdmi_core_m_axis_mm2s_fsync [get_bd_pins axi_hdmi_core/m_axis_mm2s_fsync] [get_bd_pins axi_hdmi_core/m_axis_mm2s_fsync_ret] [get_bd_pins axi_hdmi_dma/mm2s_fsync]
  connect_bd_net -net axi_hdmi_dma_mm2s_introut [get_bd_pins axi_hdmi_dma/mm2s_introut] [get_bd_pins sys_concat_intc/In15]
  connect_bd_net -net axi_iic_main_iic2intc_irpt [get_bd_pins axi_iic_main/iic2intc_irpt] [get_bd_pins sys_concat_intc/In14]
  connect_bd_net -net axi_spdif_tx_core_spdif_tx_o [get_bd_ports spdif] [get_bd_pins axi_spdif_tx_core/spdif_tx_o]
  connect_bd_net -net gpio_i_1 [get_bd_ports gpio_i] [get_bd_pins sys_ps7/GPIO_I]
  connect_bd_net -net ps_intr_00_1 [get_bd_ports ps_intr_00] [get_bd_pins sys_concat_intc/In0]
  connect_bd_net -net ps_intr_01_1 [get_bd_ports ps_intr_01] [get_bd_pins sys_concat_intc/In1]
  connect_bd_net -net ps_intr_02_1 [get_bd_ports ps_intr_02] [get_bd_pins sys_concat_intc/In2]
  connect_bd_net -net ps_intr_03_1 [get_bd_ports ps_intr_03] [get_bd_pins sys_concat_intc/In3]
  connect_bd_net -net ps_intr_04_1 [get_bd_ports ps_intr_04] [get_bd_pins sys_concat_intc/In4]
  connect_bd_net -net ps_intr_05_1 [get_bd_ports ps_intr_05] [get_bd_pins sys_concat_intc/In5]
  connect_bd_net -net ps_intr_06_1 [get_bd_ports ps_intr_06] [get_bd_pins sys_concat_intc/In6]
  connect_bd_net -net ps_intr_07_1 [get_bd_ports ps_intr_07] [get_bd_pins sys_concat_intc/In7]
  connect_bd_net -net ps_intr_08_1 [get_bd_ports ps_intr_08] [get_bd_pins sys_concat_intc/In8]
  connect_bd_net -net ps_intr_09_1 [get_bd_ports ps_intr_09] [get_bd_pins sys_concat_intc/In9]
  connect_bd_net -net ps_intr_10_1 [get_bd_ports ps_intr_10] [get_bd_pins sys_concat_intc/In10]
  connect_bd_net -net ps_intr_11_1 [get_bd_ports ps_intr_11] [get_bd_pins sys_concat_intc/In11]
  connect_bd_net -net rx_clk_in_n_1 [get_bd_ports rx_clk_in_n] [get_bd_pins axi_ad9361/rx_clk_in_n]
  connect_bd_net -net rx_clk_in_p_1 [get_bd_ports rx_clk_in_p] [get_bd_pins axi_ad9361/rx_clk_in_p]
  connect_bd_net -net rx_data_in_n_1 [get_bd_ports rx_data_in_n] [get_bd_pins axi_ad9361/rx_data_in_n]
  connect_bd_net -net rx_data_in_p_1 [get_bd_ports rx_data_in_p] [get_bd_pins axi_ad9361/rx_data_in_p]
  connect_bd_net -net rx_frame_in_n_1 [get_bd_ports rx_frame_in_n] [get_bd_pins axi_ad9361/rx_frame_in_n]
  connect_bd_net -net rx_frame_in_p_1 [get_bd_ports rx_frame_in_p] [get_bd_pins axi_ad9361/rx_frame_in_p]
  connect_bd_net -net spi0_clk_i_1 [get_bd_ports spi0_clk_i] [get_bd_pins sys_ps7/SPI0_SCLK_I]
  connect_bd_net -net spi0_csn_i_1 [get_bd_ports spi0_csn_i] [get_bd_pins sys_ps7/SPI0_SS_I]
  connect_bd_net -net spi0_sdi_i_1 [get_bd_ports spi0_sdi_i] [get_bd_pins sys_ps7/SPI0_MISO_I]
  connect_bd_net -net spi0_sdo_i_1 [get_bd_ports spi0_sdo_i] [get_bd_pins sys_ps7/SPI0_MOSI_I]
  connect_bd_net -net spi1_clk_i_1 [get_bd_ports spi1_clk_i] [get_bd_pins sys_ps7/SPI1_SCLK_I]
  connect_bd_net -net spi1_csn_i_1 [get_bd_ports spi1_csn_i] [get_bd_pins sys_ps7/SPI1_SS_I]
  connect_bd_net -net spi1_sdi_i_1 [get_bd_ports spi1_sdi_i] [get_bd_pins sys_ps7/SPI1_MISO_I]
  connect_bd_net -net spi1_sdo_i_1 [get_bd_ports spi1_sdo_i] [get_bd_pins sys_ps7/SPI1_MOSI_I]
  connect_bd_net -net sys_200m_clk [get_bd_pins axi_ad9361/delay_clk] [get_bd_pins axi_hdmi_clkgen/clk] [get_bd_pins sys_audio_clkgen/clk_in1] [get_bd_pins sys_ps7/FCLK_CLK1]
  connect_bd_net -net sys_audio_clkgen_clk_out1 [get_bd_pins axi_spdif_tx_core/spdif_data_clk] [get_bd_pins sys_audio_clkgen/clk_out1]
  connect_bd_net -net sys_concat_intc_dout [get_bd_pins sys_concat_intc/dout] [get_bd_pins sys_ps7/IRQ_F2P]
  connect_bd_net -net sys_cpu_clk [get_bd_pins axi_ad9361/s_axi_aclk] [get_bd_pins axi_ad9361_adc_dma/m_dest_axi_aclk] [get_bd_pins axi_ad9361_adc_dma/s_axi_aclk] [get_bd_pins axi_ad9361_dac_dma/m_src_axi_aclk] [get_bd_pins axi_ad9361_dac_dma/s_axi_aclk] [get_bd_pins axi_cpu_interconnect/ACLK] [get_bd_pins axi_cpu_interconnect/M00_ACLK] [get_bd_pins axi_cpu_interconnect/M01_ACLK] [get_bd_pins axi_cpu_interconnect/M02_ACLK] [get_bd_pins axi_cpu_interconnect/M03_ACLK] [get_bd_pins axi_cpu_interconnect/M04_ACLK] [get_bd_pins axi_cpu_interconnect/M05_ACLK] [get_bd_pins axi_cpu_interconnect/M06_ACLK] [get_bd_pins axi_cpu_interconnect/M07_ACLK] [get_bd_pins axi_cpu_interconnect/S00_ACLK] [get_bd_pins axi_hdmi_clkgen/s_axi_aclk] [get_bd_pins axi_hdmi_core/m_axis_mm2s_clk] [get_bd_pins axi_hdmi_core/s_axi_aclk] [get_bd_pins axi_hdmi_dma/m_axi_mm2s_aclk] [get_bd_pins axi_hdmi_dma/m_axis_mm2s_aclk] [get_bd_pins axi_hdmi_dma/s_axi_lite_aclk] [get_bd_pins axi_hp0_interconnect/ACLK] [get_bd_pins axi_hp0_interconnect/M00_ACLK] [get_bd_pins axi_hp0_interconnect/S00_ACLK] [get_bd_pins axi_hp1_interconnect/ACLK] [get_bd_pins axi_hp1_interconnect/M00_ACLK] [get_bd_pins axi_hp1_interconnect/S00_ACLK] [get_bd_pins axi_hp2_interconnect/ACLK] [get_bd_pins axi_hp2_interconnect/M00_ACLK] [get_bd_pins axi_hp2_interconnect/S00_ACLK] [get_bd_pins axi_iic_main/s_axi_aclk] [get_bd_pins axi_spdif_tx_core/DMA_REQ_ACLK] [get_bd_pins axi_spdif_tx_core/S_AXI_ACLK] [get_bd_pins ila_adc/clk] [get_bd_pins sys_ps7/DMA0_ACLK] [get_bd_pins sys_ps7/FCLK_CLK0] [get_bd_pins sys_ps7/M_AXI_GP0_ACLK] [get_bd_pins sys_ps7/S_AXI_HP0_ACLK] [get_bd_pins sys_ps7/S_AXI_HP1_ACLK] [get_bd_pins sys_ps7/S_AXI_HP2_ACLK] [get_bd_pins sys_rstgen/slowest_sync_clk] [get_bd_pins sys_wfifo_0/dma_clk] [get_bd_pins sys_wfifo_1/dma_clk] [get_bd_pins sys_wfifo_2/dma_clk] [get_bd_pins sys_wfifo_3/dma_clk]
  connect_bd_net -net sys_cpu_reset [get_bd_pins sys_rstgen/peripheral_reset]
  connect_bd_net -net sys_cpu_resetn [get_bd_pins axi_ad9361/s_axi_aresetn] [get_bd_pins axi_ad9361_adc_dma/m_dest_axi_aresetn] [get_bd_pins axi_ad9361_adc_dma/s_axi_aresetn] [get_bd_pins axi_ad9361_dac_dma/m_src_axi_aresetn] [get_bd_pins axi_ad9361_dac_dma/s_axi_aresetn] [get_bd_pins axi_cpu_interconnect/ARESETN] [get_bd_pins axi_cpu_interconnect/M00_ARESETN] [get_bd_pins axi_cpu_interconnect/M01_ARESETN] [get_bd_pins axi_cpu_interconnect/M02_ARESETN] [get_bd_pins axi_cpu_interconnect/M03_ARESETN] [get_bd_pins axi_cpu_interconnect/M04_ARESETN] [get_bd_pins axi_cpu_interconnect/M05_ARESETN] [get_bd_pins axi_cpu_interconnect/M06_ARESETN] [get_bd_pins axi_cpu_interconnect/M07_ARESETN] [get_bd_pins axi_cpu_interconnect/S00_ARESETN] [get_bd_pins axi_hdmi_clkgen/s_axi_aresetn] [get_bd_pins axi_hdmi_core/s_axi_aresetn] [get_bd_pins axi_hdmi_dma/axi_resetn] [get_bd_pins axi_hp0_interconnect/ARESETN] [get_bd_pins axi_hp0_interconnect/M00_ARESETN] [get_bd_pins axi_hp0_interconnect/S00_ARESETN] [get_bd_pins axi_hp1_interconnect/ARESETN] [get_bd_pins axi_hp1_interconnect/M00_ARESETN] [get_bd_pins axi_hp1_interconnect/S00_ARESETN] [get_bd_pins axi_hp2_interconnect/ARESETN] [get_bd_pins axi_hp2_interconnect/M00_ARESETN] [get_bd_pins axi_hp2_interconnect/S00_ARESETN] [get_bd_pins axi_iic_main/s_axi_aresetn] [get_bd_pins axi_spdif_tx_core/DMA_REQ_RSTN] [get_bd_pins axi_spdif_tx_core/S_AXI_ARESETN] [get_bd_pins sys_audio_clkgen/resetn] [get_bd_pins sys_rstgen/peripheral_aresetn]
  connect_bd_net -net sys_ps7_FCLK_RESET0_N [get_bd_pins sys_ps7/FCLK_RESET0_N] [get_bd_pins sys_rstgen/ext_reset_in]
  connect_bd_net -net sys_ps7_GPIO_O [get_bd_ports gpio_o] [get_bd_pins sys_ps7/GPIO_O]
  connect_bd_net -net sys_ps7_GPIO_T [get_bd_ports gpio_t] [get_bd_pins sys_ps7/GPIO_T]
  connect_bd_net -net sys_ps7_SPI0_MOSI_O [get_bd_ports spi0_sdo_o] [get_bd_pins sys_ps7/SPI0_MOSI_O]
  connect_bd_net -net sys_ps7_SPI0_SCLK_O [get_bd_ports spi0_clk_o] [get_bd_pins sys_ps7/SPI0_SCLK_O]
  connect_bd_net -net sys_ps7_SPI0_SS1_O [get_bd_ports spi0_csn_1_o] [get_bd_pins sys_ps7/SPI0_SS1_O]
  connect_bd_net -net sys_ps7_SPI0_SS2_O [get_bd_ports spi0_csn_2_o] [get_bd_pins sys_ps7/SPI0_SS2_O]
  connect_bd_net -net sys_ps7_SPI0_SS_O [get_bd_ports spi0_csn_0_o] [get_bd_pins sys_ps7/SPI0_SS_O]
  connect_bd_net -net sys_ps7_SPI1_MOSI_O [get_bd_ports spi1_sdo_o] [get_bd_pins sys_ps7/SPI1_MOSI_O]
  connect_bd_net -net sys_ps7_SPI1_SCLK_O [get_bd_ports spi1_clk_o] [get_bd_pins sys_ps7/SPI1_SCLK_O]
  connect_bd_net -net sys_ps7_SPI1_SS1_O [get_bd_ports spi1_csn_1_o] [get_bd_pins sys_ps7/SPI1_SS1_O]
  connect_bd_net -net sys_ps7_SPI1_SS2_O [get_bd_ports spi1_csn_2_o] [get_bd_pins sys_ps7/SPI1_SS2_O]
  connect_bd_net -net sys_ps7_SPI1_SS_O [get_bd_ports spi1_csn_0_o] [get_bd_pins sys_ps7/SPI1_SS_O]
  connect_bd_net -net sys_wfifo_0_dma_wdata [get_bd_pins ila_adc/probe4] [get_bd_pins sys_wfifo_0/dma_wdata]
  connect_bd_net -net sys_wfifo_0_dma_wr [get_bd_pins ila_adc/probe0] [get_bd_pins sys_wfifo_0/dma_wr]
  connect_bd_net -net sys_wfifo_1_dma_wdata [get_bd_pins ila_adc/probe5] [get_bd_pins sys_wfifo_1/dma_wdata]
  connect_bd_net -net sys_wfifo_1_dma_wr [get_bd_pins ila_adc/probe1] [get_bd_pins sys_wfifo_1/dma_wr]
  connect_bd_net -net sys_wfifo_2_dma_wdata [get_bd_pins ila_adc/probe6] [get_bd_pins sys_wfifo_2/dma_wdata]
  connect_bd_net -net sys_wfifo_2_dma_wr [get_bd_pins ila_adc/probe2] [get_bd_pins sys_wfifo_2/dma_wr]
  connect_bd_net -net sys_wfifo_3_dma_wdata [get_bd_pins ila_adc/probe7] [get_bd_pins sys_wfifo_3/dma_wdata]
  connect_bd_net -net sys_wfifo_3_dma_wr [get_bd_pins ila_adc/probe3] [get_bd_pins sys_wfifo_3/dma_wr]
  connect_bd_net -net tdd_sync_i_1 [get_bd_ports tdd_sync_i] [get_bd_pins axi_ad9361/tdd_sync_i]
  connect_bd_net -net util_adc_pack_ddata [get_bd_pins axi_ad9361_adc_dma/fifo_wr_din] [get_bd_pins util_adc_pack/ddata]
  connect_bd_net -net util_adc_pack_dsync [get_bd_pins axi_ad9361_adc_dma/fifo_wr_sync] [get_bd_pins util_adc_pack/dsync]
  connect_bd_net -net util_adc_pack_dvalid [get_bd_pins axi_ad9361_adc_dma/fifo_wr_en] [get_bd_pins util_adc_pack/dvalid]
  connect_bd_net -net util_dac_unpack_dac_data_00 [get_bd_pins axi_ad9361/dac_data_i0] [get_bd_pins util_dac_unpack/dac_data_00]
  connect_bd_net -net util_dac_unpack_dac_data_01 [get_bd_pins axi_ad9361/dac_data_q0] [get_bd_pins util_dac_unpack/dac_data_01]
  connect_bd_net -net util_dac_unpack_dac_data_02 [get_bd_pins axi_ad9361/dac_data_i1] [get_bd_pins util_dac_unpack/dac_data_02]
  connect_bd_net -net util_dac_unpack_dac_data_03 [get_bd_pins axi_ad9361/dac_data_q1] [get_bd_pins util_dac_unpack/dac_data_03]
  connect_bd_net -net util_dac_unpack_dma_rd [get_bd_pins axi_ad9361_dac_dma/fifo_rd_en] [get_bd_pins util_dac_unpack/dma_rd]

  # Create address segments
  create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces axi_ad9361_adc_dma/m_dest_axi] [get_bd_addr_segs sys_ps7/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_sys_ps7_HP1_DDR_LOWOCM
  create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces axi_ad9361_dac_dma/m_src_axi] [get_bd_addr_segs sys_ps7/S_AXI_HP2/HP2_DDR_LOWOCM] SEG_sys_ps7_HP2_DDR_LOWOCM
  create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces axi_hdmi_dma/Data_MM2S] [get_bd_addr_segs sys_ps7/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_sys_ps7_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x10000 -offset 0x79020000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_ad9361/s_axi/axi_lite] SEG_data_axi_ad9361
  create_bd_addr_seg -range 0x10000 -offset 0x7C400000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_ad9361_adc_dma/s_axi/axi_lite] SEG_data_axi_ad9361_adc_dma
  create_bd_addr_seg -range 0x10000 -offset 0x7C420000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_ad9361_dac_dma/s_axi/axi_lite] SEG_data_axi_ad9361_dac_dma
  create_bd_addr_seg -range 0x10000 -offset 0x79000000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_hdmi_clkgen/s_axi/axi_lite] SEG_data_axi_hdmi_clkgen
  create_bd_addr_seg -range 0x10000 -offset 0x70E00000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_hdmi_core/s_axi/axi_lite] SEG_data_axi_hdmi_core
  create_bd_addr_seg -range 0x10000 -offset 0x43000000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_hdmi_dma/S_AXI_LITE/Reg] SEG_data_axi_hdmi_dma
  create_bd_addr_seg -range 0x10000 -offset 0x41600000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_iic_main/S_AXI/Reg] SEG_data_axi_iic_main
  create_bd_addr_seg -range 0x10000 -offset 0x75C00000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs axi_spdif_tx_core/S_AXI/reg0] SEG_data_axi_spdif_tx_core
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


