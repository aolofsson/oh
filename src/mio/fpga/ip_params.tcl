# NOTE: See UG1118 for more information

set design parallella_mio
set projdir ./
set root "../.."
set partname "xc7z020clg400-1"

set hdl_files [list \
	           $root/mio/hdl \
		   $root/common/hdl/ \
		   $root/emesh/hdl \
		   $root/emmu/hdl \
		   $root/axi/hdl \
		   $root/emailbox/hdl \
		   $root/edma/hdl \
	           $root/elink/hdl \
	           $root/parallella/hdl \
		  ]

set ip_files   [list \
		    $root/xilibs/ip/fifo_async_104x32/fifo_async_104x32.xci \
		    $root/xilibs/ip/fifo_async_128x32/fifo_async_128x32.xci \
		   ]

set constraints_files []

