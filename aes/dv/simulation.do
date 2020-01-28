vlib work
vlog ../rtl/*.v
vlog *.v
vsim -novopt test_aes_128
add wave -noupdate -format Logic -radix unsigned /test_aes_128/clk
add wave -noupdate -divider input
add wave -noupdate -format Literal -radix hexadecimal /test_aes_128/state
add wave -noupdate -format Literal -radix hexadecimal /test_aes_128/key
add wave -noupdate -divider output
add wave -noupdate -format Literal -radix hexadecimal /test_aes_128/out
run -all
