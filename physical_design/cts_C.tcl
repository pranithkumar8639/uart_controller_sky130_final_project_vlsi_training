set pdk "$::env(HOME)/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd"
read_lef "$pdk/techlef/sky130_fd_sc_hd__nom.tlef"
read_lef "$pdk/lef/sky130_fd_sc_hd.lef"
read_liberty "$pdk/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db "physical_design/results_C/uart_floorplan.odb"
read_sdc "constraints/uart.sdc"
set_wire_rc -signal -layer met2
set_wire_rc -clock -layer met3
clock_tree_synthesis -clk_nets clk -buf_list {sky130_fd_sc_hd__clkbuf_1 sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_4} -root_buf sky130_fd_sc_hd__clkbuf_4
write_def "physical_design/results_C/uart_cts.def"
write_db "physical_design/results_C/uart_cts.odb"
exit
