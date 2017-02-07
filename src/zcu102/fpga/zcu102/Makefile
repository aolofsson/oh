M_DEPS += Makefile
M_DEPS += run.tcl
M_DEPS += system_bd.tcl
M_DEPS += system_params.tcl
M_DEPS += ../zcu102_base/zcu102_base.xpr
M_DEPS += ../zcu102_base/zcu102_base.zip
M_DEPS += ../zcu102_base/run.tcl

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
M_FLIST += zcu102_elink.bit.bin
M_FLIST += system_wrapper.bit.bin
M_FLIST += reports
M_FLIST += results
M_FLIST += system.hw
M_FLIST += system.ip_user_files
M_FLIST += system.sim
M_FLIST += system.bin
M_FLIST += system.bit
M_FLIST += system.hdf
M_FLIST += system.hwdef
M_FLIST += vivado_*.str

.PHONY: all clean

all: $(M_DEPS)
	#rm -f system_wrapper.bit.bin bit2bin.bin
	$(M_VIVADO) run.tcl
	#cp -f system_wrapper.bit.bin parallella_e16_headless_gpiose_7010.bit.bin

clean:
	rm -rf $(M_FLIST)
