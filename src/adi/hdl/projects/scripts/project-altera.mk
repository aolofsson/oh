####################################################################################
## Copyright 2018(c) Analog Devices, Inc.
####################################################################################

# Assumes this file is in projects/scripts/project-altera.mk
HDL_PROJECT_PATH := $(subst scripts/project-altera.mk,,$(lastword $(MAKEFILE_LIST)))
HDL_LIBRARY_PATH := $(HDL_PROJECT_PATH)../library/

include $(HDL_PROJECT_PATH)../quiet.mk

ifeq ($(NIOS2_MMU),)
  NIOS2_MMU := 1
endif

export ALT_NIOS_MMU_ENABLED := $(NIOS2_MMU)

ALTERA := quartus_sh --64bit -t

CLEAN_TARGET += *.log
CLEAN_TARGET += *_INFO.txt
CLEAN_TARGET += *_dump.txt
CLEAN_TARGET += db
CLEAN_TARGET += *.asm.rpt
CLEAN_TARGET += *.done
CLEAN_TARGET += *.eda.rpt
CLEAN_TARGET += *.fit.*
CLEAN_TARGET += *.map.*
CLEAN_TARGET += *.sta.*
CLEAN_TARGET += *.qsf
CLEAN_TARGET += *.qpf
CLEAN_TARGET += *.qws
CLEAN_TARGET += *.sof
CLEAN_TARGET += *.cdf
CLEAN_TARGET += *.sld
CLEAN_TARGET += *.qdf
CLEAN_TARGET += hc_output
CLEAN_TARGET += system_bd
CLEAN_TARGET += hps_isw_handoff
CLEAN_TARGET += hps_sdram_*.csv
CLEAN_TARGET += *ddr3_*.csv
CLEAN_TARGET += incremental_db
CLEAN_TARGET += reconfig_mif
CLEAN_TARGET += *.sopcinfo
CLEAN_TARGET +=  *.jdi
CLEAN_TARGET += *.pin
CLEAN_TARGET += *_summary.csv
CLEAN_TARGET += *.dpf
CLEAN_TARGET += system_qsys_script.tcl
CLEAN_TARGET += system_bd.qsys
CLEAN_TARGET += .qsys_edit

M_DEPS += system_top.v
M_DEPS += system_qsys.tcl
M_DEPS += system_project.tcl
M_DEPS += system_constr.sdc
M_DEPS += $(HDL_PROJECT_PATH)scripts/adi_tquest.tcl
M_DEPS += $(HDL_PROJECT_PATH)scripts/adi_project_alt.tcl
M_DEPS += $(HDL_PROJECT_PATH)scripts/adi_env.tcl

M_DEPS += $(foreach dep,$(LIB_DEPS),$(HDL_LIBRARY_PATH)$(dep)/.timestamp_altera)

.PHONY: all lib clean clean-all
all: lib $(PROJECT_NAME).sof


clean:
	$(call clean, \
		$(CLEAN_TARGET), \
		$(HL)$(PROJECT_NAME)$(NC) project)

clean-all: clean
	@for lib in $(LIB_DEPS); do \
		$(MAKE) -C $(HDL_LIBRARY_PATH)$${lib} clean; \
	done

$(PROJECT_NAME).sof: $(M_DEPS)
	-rm -rf $(CLEAN_TARGET)
	$(call build,\
		$(ALTERA) system_project.tcl, \
		$(PROJECT_NAME)_quartus.log, \
		$(HL)$(PROJECT_NAME)$(NC))

lib:
	@for lib in $(LIB_DEPS); do \
		$(MAKE) -C $(HDL_LIBRARY_PATH)$${lib} altera || exit $$?; \
	done
