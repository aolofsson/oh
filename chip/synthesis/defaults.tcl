#################################
# PROCESS/LIBS DEFAULTS (SHELL)
#################################

if {[info exists env(OH_VENDOR)]} {
    set OH_VENDOR  "$env(OH_VENDOR)"; # synopsys, cadence, xilinx
}

if {[info exists env(OH_TARGET)]} {
    set OH_TARGET  "$env(OH_TARGET)"; # "lib1.db lib2.db lib3.db" or "xc7z020clg400-1"
}

if {[info exists env(OH_MACROS)]} {
    set OH_MACROS  "$env(OH_MACROS)"; # "macro1.lib macro2.lib"
}
