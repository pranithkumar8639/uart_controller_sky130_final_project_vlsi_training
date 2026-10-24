# =========================================================
# UART Controller - OpenSTA Constraints
# =========================================================

# Clock: 100 MHz
create_clock -name clk -period 10.0 [get_ports clk]

# Clock uncertainty
set_clock_uncertainty 0.2 [get_clocks clk]

# Input delays
set_input_delay 1.0 -clock clk [get_ports reset]
set_input_delay 1.0 -clock clk [get_ports tx_start]
set_input_delay 1.0 -clock clk [get_ports tx_data]
set_input_delay 1.0 -clock clk [get_ports rx]

# Output delays
set_output_delay 1.0 -clock clk [get_ports tx]
set_output_delay 1.0 -clock clk [get_ports tx_busy]
set_output_delay 1.0 -clock clk [get_ports tx_done]
set_output_delay 1.0 -clock clk [get_ports rx_data]
set_output_delay 1.0 -clock clk [get_ports rx_valid]

# =========================================================
# End of constraints
# =========================================================
