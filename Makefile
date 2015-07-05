have_vivado	:= $(shell which vivado 1>/dev/null 2>/dev/null && echo yes)
top_srcdir	:= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
top_builddir	:= $(shell pwd)

export

.PHONY: builddeps all parallella-16-nohdmi clean

help:
	@echo "TARGETS:"
	@echo "all -- everything (TODO)"
	@echo "parallella-z7020 -- Parallella Embedded (no HDMI)"

builddeps:
	@if [ "x$(have_vivado)" != "xyes" ]; then echo vivado not in path; exit 1; fi

all: builddeps parallella-z7020

parallella-z7020: builddeps
	make -C targets/parallella-z7020/Makefile
#	vivado -mode batch -source targets/parallella-z7020/system_project.tcl

test:
	vivado -mode batch -source $(top_srcdir)/elink/scripts/xilinx/package_axi_elink.tcl

clean:
	find . \( -name vivado*.log -or -name vivado*.jou \) -delete
