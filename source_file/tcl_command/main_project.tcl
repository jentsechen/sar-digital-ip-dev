# main_project.tcl — create the Vivado project
# Usage (driven by the Makefile):
#   vivado -mode batch -source main_project.tcl -tclargs <proj_name> <part>

set proj_name [lindex $argv 0]
set part      [lindex $argv 1]

if {$proj_name eq ""} { set proj_name "sar_rx_dsp_verification" }
if {$part eq ""}      { set part      "xczu48dr-fsvg1517-2-e" }

# Create the project in ./<proj_name> relative to the repo root.
create_project $proj_name $proj_name -part $part -force

puts "Created project '$proj_name' targeting part '$part'"

# --- Add sources here as the project grows, e.g.: ---
# add_files        -fileset sources_1 [glob -nocomplain source_file/design/*.v source_file/design/*.sv]
# add_files -fileset sim_1           [glob -nocomplain source_file/testbench/*.v source_file/testbench/*.sv]
# update_compile_order -fileset sources_1
# update_compile_order -fileset sim_1
