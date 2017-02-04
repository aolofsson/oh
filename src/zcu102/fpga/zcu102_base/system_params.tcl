# NOTE: See UG1118 for more information

#########################################
# VARIABLES
#########################################
set design zcu102_base
set projdir ./
set root "../../.."
#set partname "xczu9eg-ffvb1156-2L-e-es1"
#set partname "xczu9eg-ffvb1156-2L-e-es2"
set partname "xczu9eg-ffvb1156-2-i-es2"


set hdl_files [list \
	           $root/zcu102/hdl \
		   $root/common/hdl/ \
		   $root/emesh/hdl \
		   $root/emmu/hdl \
		   $root/axi/hdl \
		   $root/emailbox/hdl \
		   $root/edma/hdl \
	           $root/elink/hdl \
		  ]

set ip_files   [list \
		    $root/xilibs/ip/fifo_async_104x32.xci \
		   ]

set constraints_files []

