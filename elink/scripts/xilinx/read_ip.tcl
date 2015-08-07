set pwd [file dirname [info script]]
source $pwd/../../../include/oh.tcl

read_ip $top_srcdir/xilibs/ip/fifo_async_104x16/fifo_async_104x16.xci
read_ip $top_srcdir/xilibs/ip/fifo_async_104x32/fifo_async_104x32.xci

