P1600:   7010 + 0 GPIO
P1601:   7010 + 24 GPIO
P1602:   7020 + 48 GPIO
A101010: 7010 + 0 GPIO
A101020: 7010 + 24 GPIO
A101040: 7020 + 48 GPIO

parallella_headless.tcl --product number as argument
parallella_display.tcl
parallella_sdr.tcl

---
proc adi_add_bus {bus_name bus_type mode port_maps} {
        set bus [ipx::add_bus_interface $bus_name [ipx::current_core]]
        if { $bus_type == "axis" } {
                set abst_type "axis_rtl"
        } elseif { $bus_type == "aximm" } {
                set abst_type "aximm_rtl"
        } else {
                set abst_type $bus_type
        }

        set_property "ABSTRACTION_TYPE_LIBRARY" "interface" $bus
        set_property "ABSTRACTION_TYPE_NAME" $abst_type $bus
        set_property "ABSTRACTION_TYPE_VENDOR" "xilinx.com" $bus
        set_property "ABSTRACTION_TYPE_VERSION" "1.0" $bus
        set_property "BUS_TYPE_LIBRARY" "interface" $bus
        set_property "BUS_TYPE_NAME" $bus_type $bus
        set_property "BUS_TYPE_VENDOR" "xilinx.com" $bus
        set_property "BUS_TYPE_VERSION" "1.0" $bus
        set_property "CLASS" "bus_interface" $bus
        set_property "INTERFACE_MODE" $mode $bus

        foreach port_map $port_maps {
                adi_add_port_map $bus {*}$port_map
        }
}
