# Reproducing results_D

Final design: rtl/uart_top.v, uart_tx_C_experiment.v, uart_rx_split_experiment.v

RTL sim: iverilog -g2012 tb/uart_tb.v rtl/*.v
Gate-level sim: add -DFUNCTIONAL -DUNIT_DELAY='#0' and use the sky130 PDK
primitives.v and sky130_fd_sc_hd.v with synthesis/uart_C_D7000_mapped.v.

Physical flow order (OpenROAD):
1. floorplan_C.tcl (floorplan, pins, placement)
2. cts_C.tcl
3. pdn_C.tcl and repair_pdn_C.tcl, run on uart_cts.odb (not uart_floorplan.odb)
4. repair_D.tcl (SS setup and hold repair, legalization)
5. global_route_C.tcl and detailed_route_C.tcl on the repaired database
6. sta_route_{ss,tt,ff}_C.tcl with set_propagated_clock added

Steps 3 to 6 used the *_C.tcl scripts with results_C replaced by results_D
(sed on the paths). STA uses estimate_parasitics -placement, not signoff RC.
