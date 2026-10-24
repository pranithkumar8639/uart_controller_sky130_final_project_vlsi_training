set pdk "$::env(HOME)/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd"
read_lef "$pdk/techlef/sky130_fd_sc_hd__nom.tlef"
read_lef "$pdk/lef/sky130_fd_sc_hd.lef"
read_liberty "$pdk/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db "physical_design/results_C/uart_global_route.odb"
read_sdc "constraints/uart.sdc"
set_routing_layers -signal met1-met5 -clock met1-met5
detailed_route -output_drc "physical_design/results_C/uart_drc.rpt"
write_def "physical_design/results_C/uart_detailed_route.def"
write_db "physical_design/results_C/uart_detailed_route.odb"
exit
