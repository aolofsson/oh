M_DEPS := run.tcl Makefile system_params.tcl

M_VIVADO := vivado -mode batch -source

M_FLIST := *.cache
M_FLIST += *.data
M_FLIST += *.xpr
M_FLIST += *.log
M_FLIST += *.jou
M_FLIST +=  xgui
M_FLIST += *.runs
M_FLIST += *.srcs
M_FLIST += *.sdk
M_FLIST += .Xil
M_FLIST += src
M_FLIST += vivado.log
M_FLIST += vivado.jou
M_FLIST += xgui
M_FLIST += *.cache
M_FLIST += component.xml

all: $(M_DEPS)
	$(M_VIVADO) run.tcl

clean:
	rm -rf $(M_FLIST)
