#!/bin/bash
cd ~/UART_VLSI
OLD='physical_design/results_C/uart_detailed_route.odb'
mk_head() { sed -n '1,/^estimate_parasitics/p' physical_design/sta_route_$1_C.tcl | sed "s#$OLD#$2#"; }

# 1) SS: setup repair
{ mk_head ss physical_design/results_C/uart_cts.odb
cat << 'EOF'
set_dont_use [get_lib_cells sky130_fd_sc_hd__lpflow_*]
set_propagated_clock [all_clocks]
estimate_parasitics -placement
repair_design
repair_timing -setup -setup_margin 0.2 -repair_tns 100
write_db /tmp/s1.odb
exit
EOF
} > /tmp/step1.tcl

# 2) FF: hold repair
{ mk_head ff /tmp/s1.odb
cat << 'EOF'
set_dont_use [get_lib_cells sky130_fd_sc_hd__lpflow_*]
set_propagated_clock [all_clocks]
estimate_parasitics -placement
puts "FF hold BEFORE:"; report_worst_slack -min
repair_timing -hold -hold_margin 0.1 -repair_tns 100
write_db /tmp/s2.odb
exit
EOF
} > /tmp/step2.tcl

echo "##### step1 (SS setup repair)"
openroad -no_splash -exit /tmp/step1.tcl 2>&1 | grep -E 'RSZ-0040|Error|ERROR'
echo "##### step2 (FF hold repair)"
openroad -no_splash -exit /tmp/step2.tcl 2>&1 | grep -E 'FF hold|worst slack|RSZ-0(032|046|064)|Inserted|Error|ERROR'

# 3) check all corners on the repaired db
for c in ss tt ff; do
  { mk_head $c /tmp/s2.odb
    cat << 'EOF'
set_propagated_clock [all_clocks]
estimate_parasitics -placement
report_worst_slack -max
report_worst_slack -min
exit
EOF
  } > /tmp/chk_$c.tcl
  echo "##### check $c"
  openroad -no_splash -exit /tmp/chk_$c.tcl 2>&1 | grep -E 'worst slack|Error|ERROR'
done
