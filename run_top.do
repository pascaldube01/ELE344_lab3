vlib work

vcom -93 -work work regfile.vhd
vcom -93 -work work imem.vhd
vcom -93 -work work dmem.vhd
vcom -93 -work work controlleur.vhd
vcom -93 -work work ual.vhd
vcom -93 -work work datapath.vhd
vcom -93 -work work mips.vhd
vcom -93 -work work top.vhd

vsim top
add wave -r -hexadecimal *
force clk 1,0 10 ns -repeat 20 ns
force reset 1,0 15 ns
run 500 ns
wave zoom full
