read_verilog rtl/uart_tx_C_experiment.v
read_verilog rtl/uart_rx_split_experiment.v
read_verilog rtl/uart_top.v

hierarchy -top uart_top
proc
opt
fsm
opt
memory
opt
flatten
opt
techmap
opt

dfflibmap -liberty constraints/libs/sky130_fd_sc_hd__ss_n40C_1v28_sta.lib
abc -liberty constraints/libs/sky130_fd_sc_hd__ss_n40C_1v28_sta.lib -constr synthesis_optimized/abc_timing.constr -D 7000

clean
rename -enumerate
write_verilog -noattr -noexpr synthesis_optimized/uart_C_D7000_mapped.v
stat -liberty constraints/libs/sky130_fd_sc_hd__ss_n40C_1v28_sta.lib
