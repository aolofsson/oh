
M_DEPS := run.tcl

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
M_FLIST += component.xml
M_FLIST += ip_tmp
M_FLIST += parallella_base.hw
M_FLIST += parallella_base.ip_user_files
M_FLIST += parallella_base.zip
M_FLIST += sim
M_FLIST += src

all: $(M_DEPS)
	$(M_VIVADO) run.tcl

clean:
	rm -rf $(M_FLIST)
