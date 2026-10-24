set pdk "$::env(HOME)/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd"
read_lef "$pdk/techlef/sky130_fd_sc_hd__nom.tlef"
read_lef "$pdk/lef/sky130_fd_sc_hd.lef"
read_liberty "$pdk/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_verilog "synthesis_optimized/uart_C_D7000_mapped.v"
link_design uart_top
initialize_floorplan -die_area {0 0 500 500} -core_area {20 20 480 480} -site unithd
make_tracks
place_pins -hor_layers met3 -ver_layers met2
global_placement
detailed_placement
write_def "physical_design/results_C/uart_floorplan.def"
write_db "physical_design/results_C/uart_floorplan.odb"
exit
