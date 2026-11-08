# ==============================================================================
# Clock Constraints
# ==============================================================================
# Create main clock: 50 MHz (Period = 20 ns) - Lowered to meet timing requirements
create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]

# ==============================================================================
# Input Delay Constraints
# ==============================================================================
# Assuming external components use a similar clock. You can adjust the max/min values based on actual board delays.
set_input_delay -clock [get_clocks clk] -max 2.000 [get_ports {rst_n start fault_enable fault_mode[*] fault_bit[*]}]
set_input_delay -clock [get_clocks clk] -min 0.500 [get_ports {rst_n start fault_enable fault_mode[*] fault_bit[*]}]

# ==============================================================================
# Output Delay Constraints
# ==============================================================================
set_output_delay -clock [get_clocks clk] -max 2.000 [get_ports {done final_signature[*]}]
set_output_delay -clock [get_clocks clk] -min 0.500 [get_ports {done final_signature[*]}]
