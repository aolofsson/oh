# NOTE: See UG1118 for more information

#########################################
# VARIABLES
#########################################
set design parallella_base
set projdir ./
set root "../../.."
set partname "xc7z020clg400-1"

set hdl_files [list \
		   $root/common/hdl \
		   $root/memory/hdl \
		   $root/emesh/hdl \
		   $root/emmu/hdl \
		   $root/emailbox/hdl \
		   $root/edma/hdl \
	           $root/elink/hdl \
	           $root/parallella/hdl \
		   $root/parallella/hdl/parallella_base.v \
		  ]

set ip_files   [list \
		    $root/memory/fpga/fifo_async_104x32.xci \
		   ]

set constraints_files []

