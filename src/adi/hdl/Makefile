####################################################################################
####################################################################################
## Copyright 2011(c) Analog Devices, Inc.
## Auto-generated, do not modify!
####################################################################################
####################################################################################

include quiet.mk

help:
	@echo ""
	@echo "Please specify a target."
	@echo ""
	@echo "To make all projects:"
	@echo "    make all"
	@echo ""
	@echo "To build a specific project:"
	@echo "    make proj.board"
	@echo "e.g.,"
	@echo "    make adv7511.zed"


PROJECTS := $(filter-out $(NO_PROJ), $(notdir $(wildcard projects/*)))
SUBPROJECTS := $(foreach projname,$(PROJECTS), \
	$(foreach archname,$(notdir $(subst /Makefile,,$(wildcard projects/$(projname)/*/Makefile))), \
		$(projname).$(archname)))

.PHONY: lib all clean clean-all $(SUBPROJECTS)

$(SUBPROJECTS):
	$(MAKE) -C projects/$(subst .,/,$@)

lib:
	$(MAKE) -C library/ all


all:
	$(MAKE) -C projects/ all


clean:
	$(MAKE) -C projects/ clean


clean-all:clean
	$(MAKE) -C projects/ clean
	$(MAKE) -C library/ clean

####################################################################################
####################################################################################
