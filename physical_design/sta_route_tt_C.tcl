set pdk "$::env(HOME)/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd"
read_lef "$pdk/techlef/sky130_fd_sc_hd__nom.tlef"
read_lef "$pdk/lef/sky130_fd_sc_hd.lef"
read_liberty constraints/libs/sky130_fd_sc_hd__tt_025C_1v80_sta.lib
read_db "physical_design/results_C/uart_detailed_route.odb"
read_sdc constraints/uart.sdc
set_wire_rc -signal -layer met2
set_wire_rc -clock -layer met3
estimate_parasitics -placement
puts "=== route_tt setup/hold worst slack ==="
report_worst_slack -max
report_worst_slack -min
report_checks -path_delay max -group_path_count 1
exit
