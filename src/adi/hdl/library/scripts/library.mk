####################################################################################
## Copyright 2018(c) Analog Devices, Inc.
####################################################################################

# Assumes this file is in library/scripts/library.mk
HDL_LIBRARY_PATH := $(subst scripts/library.mk,,$(lastword $(MAKEFILE_LIST)))

include $(HDL_LIBRARY_PATH)../quiet.mk

VIVADO := vivado -mode batch -source

CLEAN_TARGET := *.cache
CLEAN_TARGET += *.data
CLEAN_TARGET += *.xpr
CLEAN_TARGET += *.log
CLEAN_TARGET += component.xml
CLEAN_TARGET += *.jou
CLEAN_TARGET +=  xgui
CLEAN_TARGET += *.ip_user_files
CLEAN_TARGET += *.srcs
CLEAN_TARGET += *.hw
CLEAN_TARGET += *.sim
CLEAN_TARGET += .Xil
CLEAN_TARGET += .timestamp_altera

GENERIC_DEPS += $(HDL_LIBRARY_PATH)scripts/adi_env.tcl

.PHONY: all altera altera_dep xilinx xilinx_dep clean clean-all

all: altera xilinx

clean: clean-all

clean-all:
	$(call clean, \
		$(CLEAN_TARGET), \
		$(HL)$(LIBRARY_NAME)$(NC) library)

ifneq ($(ALTERA_DEPS),)

ALTERA_DEPS += $(GENERIC_DEPS)
ALTERA_DEPS += $(HDL_LIBRARY_PATH)scripts/adi_ip_alt.tcl
ALTERA_DEPS += $(foreach dep,$(ALTERA_LIB_DEPS),$(HDL_LIBRARY_PATH)$(dep)/.timestamp_altera)

altera: altera_dep .timestamp_altera

.timestamp_altera: $(ALTERA_DEPS)
	touch $@

altera_dep:
	@for lib in $(ALTERA_LIB_DEPS); do \
		$(MAKE) -C $(HDL_LIBRARY_PATH)$${lib} altera || exit $$?; \
	done
endif

ifneq ($(XILINX_DEPS),)

XILINX_DEPS += $(GENERIC_DEPS)
XILINX_DEPS += $(HDL_LIBRARY_PATH)scripts/adi_ip.tcl
XILINX_DEPS += $(foreach dep,$(XILINX_LIB_DEPS),$(HDL_LIBRARY_PATH)$(dep)/component.xml)

xilinx: xilinx_dep component.xml

component.xml: $(XILINX_DEPS)
	-rm -rf $(CLEAN_TARGET)
	$(call build, \
		$(VIVADO) $(LIBRARY_NAME)_ip.tcl, \
		$(LIBRARY_NAME)_ip.log, \
		$(HL)$(LIBRARY_NAME)$(NC) library)

xilinx_dep:
	@for lib in $(XILINX_LIB_DEPS); do \
		$(MAKE) -C $(HDL_LIBRARY_PATH)$${lib} xilinx || exit $$?; \
	done
	@for intf in $(XILINX_INTERFACE_DEPS); do \
		$(MAKE) -C $(HDL_LIBRARY_PATH)$${intf} xilinx || exit $$?; \
	done
endif
